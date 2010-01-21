package Protocol::AMQP::Peer;

## A sockt connection to a AMQP peer

use Moose;
use Protocol::AMQP::Registry;
use Protocol::AMQP::Constants qw( :all );
use Protocol::AMQP::Util qw( unpack_method trace );

has remote_addr => (
  isa     => 'Str',
  is      => 'ro',
  default => '127.0.0.1',
);

has remote_port => (
  isa     => 'Str',
  is      => 'ro',
  default => 5672,    ## IANA assigned port for AMQP
);

has parser => (
  isa     => 'ArrayRef[CodeRef]',
  is      => 'rw',
  clearer => 'clear_parser',
);

has version => (
  isa => 'HashRef',
  is  => 'rw',
);

with 'Protocol::AMQP::Roles::UserCallbacks',
     'Protocol::AMQP::Roles::SendMethod';

no Moose;
__PACKAGE__->meta->make_immutable;


##################################

sub connect { confess("Implement connect()  on " . ref($_[0]) . ", ") }
sub write   { confess("Implement write() on " . ref($_[0]) . ", ") }
sub close   { confess("Implement close() on " . ref($_[0]) . ", ") }

sub error {
  my $self = shift;
  trace("AMQP error: ", \@_);

  $self->close(@_);
  $self->cleanup(@_);

  return;
}

sub cleanup {
  my ($self) = @_;

  trace('Calling on_disconnect_cb');
  $self->user_on_disconnect_cb;

  trace('Connection is closed, cleanup Peer');
  $self->clear_parser;
  return;
}


##################################

sub handle_method {
  confess 'Implement handle_method() on ' . (ref($_[0]) || $_[0]) . ', ';
}


##################################

sub conn_exception {
  my ($self) = @_;
  ## TODO: send connection exception here...

  $self->close;
}


###################################

## impl => peer: report socket established
sub _on_connect_ok {
  my ($self) = @_;
  trace('socket connection established');

  $self->_send_protocol_header;

  ## FIXME: this is too soon, it should be after the Connection.Tune_Ok
  ## Only temporary to make sure our tests end properly
  $self->user_on_connect_cb();

  return;
}

## impl => peer: impl haz data for peer
sub _on_read {
  my ($self, $bref) = @_;

  ## If no parser, we are skipping reads until EOF
  $$bref = '', return unless $self->{parser};

  my $parser;
  do {
    trace('reading buf ', $bref);
    $parser = $self->{parser};
  } while ($$bref && $parser && $parser->[0]($self, $bref, $parser->[1]));
  trace('done reading');
}


##################################

sub _send_protocol_header {
  my ($self) = @_;

  my $v = $self->_pick_best_protocol_version;
  my $protocol_header =
    pack('a* C CCC', "AMQP", 0, $v->{major}, $v->{minor}, $v->{revision});
  trace('header is ', \$protocol_header, ' for version ', $v);

  $self->write($protocol_header);
  $self->version($v);
  $self->{parser} = [\&_parse_protocol_header];
  return;
}

sub _parse_protocol_header {
  my ($self, $bref) = @_;

  trace('not enough data to check proto header'), return
    if length($$bref) < 8;

  if (substr($$bref, 0, 4) eq 'AMQP') {
    my $hdr = substr($$bref, 0, 8, '');

    my %version;
    @version{qw(version major minor revision)} =
      split(//, substr($hdr, 4, 4));

    # FIXME: we should provide a hook to negotiate down version
    $self->error('amqp_max_version', \%version);
    return;
  }

  trace('our protocol header was accepted, switch to frame parser');
  $self->{parser} = [\&_parse_frame];
  return 1;
}

sub _send_frame {
  my ($self, $type, $chan, $payload) = @_;
  my $size = length($payload);
  
  trace("Sending frame type $type over chan $chan, payload size $size");
  
  $self->write(pack('CnN', $type, $chan, $size) . $payload . chr(0xCE));
}

sub _parse_frame {
  my ($self, $bref) = @_;

  trace('not enough data for frame header'), return
    if length($$bref) < 7;

  my ($type, $chan, $size) = unpack('CnN', substr($$bref, 0, 7, ''));
  trace("Got frame type $type chan $chan size $size");

  ## FIXME: revisit this - if we have to shutdown the socket, you must
  ## place it in "ignore all bytes incoming until EOF" - mayber we need
  ## a state 'waiting_for_eof' - check if on_read fix is enough
  $self->error('AMQP: invalid frame type ' . $type), return
    unless Protocol::AMQP::Registry->fetch_frame_type($type);

  ## Read payload and frame-end
  $self->{parser} = [\&_frame_dispatcher, [$type, $chan, $size]];

  return 1;
}

sub _frame_dispatcher {
  my ($self, $bref, $args) = @_;
  my ($type, $chan, $size) = @$args;

  trace('not enough data for frame payload'), return
    if length($$bref) < $size + 1;    ## include frame-end

  my $marker = ord(substr($$bref, $size, 1, ''));
  ## FIXME: revisit this - same problem - we need to 'skip until EOF'
  ## check if on_read fix is enough
  $self->error("AMQP: invalid frame-end marker chr($marker)"), return
    unless $marker == 0xCE;

  Protocol::AMQP::Registry->fetch_frame_type($type)
    ->($self, substr($$bref, 0, $size, ''), $chan, $size);

  $self->{parser} = [\&_parse_frame];
  return 1;
}


##################################

sub _handle_method_frame {
  my ($self, $payload, $chan, $size) = @_;

  my $meth = unpack_method($payload);
  trace("Prepare to dispatch method '$meth->{name}'", $meth);

  if ($chan == 0) {
    $self->handle_method($meth);
  }
  else {
    # TODO: fetch the channel object and handle_method on that one
  }
}
Protocol::AMQP::Registry->register_frame_type(AMQP_FRAME_METHOD,
  \&_handle_method_frame);

sub _handle_header_frame {
  confess("Unhandled frame type " . AMQP_FRAME_HEADER);
}
Protocol::AMQP::Registry->register_frame_type(AMQP_FRAME_HEADER,
  \&_handle_header_frame);

sub _handle_body_frame {
  confess("Unhandled frame type " . AMQP_FRAME_BODY);
}
Protocol::AMQP::Registry->register_frame_type(AMQP_FRAME_BODY,
  \&_handle_body_frame);

sub _handle_heartbeat_frame {
  my ($self, $bref, $chan, $size) = @_;

  if ($chan == 0) {
    trace('Got heartbeat frame');
    ## TODO: reply to hearbeat frames
  }
  else {
    $self->conn_exception(503, "AMQP: heartbeat frame on invalid chan $chan");
  }
}
Protocol::AMQP::Registry->register_frame_type(AMQP_FRAME_HEARTBEAT,
  \&_handle_heartbeat_frame);


##################################

sub _pick_best_protocol_version {
  my ($self) = @_;

  my $all = Protocol::AMQP::Registry->fetch_version();
  return unless $all && %$all;

  my @ordered = sort {
         $all->{$b}{value}{major} <=> $all->{$a}{value}{major}
      || $all->{$b}{value}{minor} <=> $all->{$a}{value}{minor}
      || $all->{$b}{value}{revision} <=> $all->{$a}{value}{revision}
  } keys %$all;

  return $all->{$ordered[0]}{value};
}


1;
