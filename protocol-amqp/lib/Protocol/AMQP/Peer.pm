package Protocol::AMQP::Peer;

## A sockt connection to a AMQP peer

use Moose;

has impl => (
  isa      => 'Object',
  is       => 'rw',
  required => 1,
);

has remote_addr => (
  isa      => 'Str',
  is       => 'ro',
  required => 1,
);

has remote_port => (
  isa     => 'Str',
  is      => 'ro',
  default => 5672,    ## IANA assigned port for AMQP
);

has parser => (
  isa => 'CodeRef',
  is  => 'rw',
);

has [qw(connect_cb write_cb shutdown_cb destroy_cb )] => (
  isa      => 'CodeRef',
  is       => 'ro',
  required => 1
);

no Moose;
__PACKAGE__->meta->make_immutable;

###################################

## impl => peer: start the connection
sub impl_connect {
  my $self = shift;
  
  _trace('call impl connect_cb');
  my $connect_cb = $self->{connect_cb};
  $self->{impl}->$connect_cb();

  return $self;
}

## impl => peer: report socket established
sub impl_connect_ok {
  my ($self) = @_;
  _trace('socket connection established');

  $self->_send_protocol_header;
  return;
}

## impl => peer: impl haz data for peer
sub impl_read {
  my ($self, $bref) = @_;

  do {
    _trace('reading buf ', $bref);
  } while ($$bref && $self->{parser}->($self, $bref));
  _trace('done reading');
}

## impl => peer: impl haz socket error
sub impl_error {
  my $self = shift;
  _trace("AMQP error: ", \@_);

  $self->shutdown;
  $self->destroy;

  return;
}

## peer => impl: we are shutindown, please close that socket
sub impl_shutdown {
  my ($self) = @_;
  _trace('ask for socket shutdown');

  _trace('calling impl shutdown_cb');
  my $shutdown_cb = $self->{shutdown_cb};
  $self->{impl}->$shutdown_cb();

  return;
}

## peer => impl: we are shutdown, clear internal state
sub impl_destroy {
  my ($self) = @_;
  _trace('destroy peer internals');

  _trace('calling impl destroy_cb');
  my $destroy_cb = $self->{destroy_cb};
  $self->impl->$destroy_cb();

  %$self = ();
  return;
}


##################################

sub _send_protocol_header {
  my ($self) = @_;
  my $write_cb = $self->write_cb;

  ## TODO: from registered AMQP protocol specs, fetch possible list of
  ## headers to send, pick best, prepare retries with the others
  my $protocol_header = "AMQP\x00\x00\x09\x01";
  _trace("header is ", \$protocol_header);

  $self->{impl}->$write_cb($protocol_header);
  $self->{parser} = \&_recv_protocol_header;
  return;
}

sub _recv_protocol_header {
  my ($self, $bref) = @_;

  _trace('not enough data to check proto header'), return
    if length($$bref) < 8;

  if (substr($$bref, 0, 4) eq 'AMQP') {
    my $hdr = substr($$bref, 0, 8, '');

    my %version;
    @version{qw(version major minor revision)} =
      split(//, substr($hdr, 4, 4));

    $self->error('amqp_max_version', \%version);
    return;
  }

  _trace('our protocol header was accepted, switch to frame parser');
  $self->{parser} = \&_frame_parser;
  return 1;
}

sub _frame_parser {
  my ($self, $bref) = @_;

  ## TODO: implement frame parser here
}

##################################

use Data::Dump ();

sub _trace {
  my ($line) = (caller(0))[2];
  my ($sub)  = (caller(1))[3];

  my @args;
  foreach my $arg (@_) {
    if (my $type = ref $arg) {
      if ($type eq 'SCALAR') {
        my $partial = $$arg;
        my $len = length($partial);
        substr($partial, 45, $len, '...')        if $len > 45;
        push @args, Data::Dump::pp(\$partial), " (len $len)";
        next;
      }
      
      $arg = Data::Dump::pp($arg);
    }
    push @args, $arg;
  }
  
  my $pad = ' ';
  foreach my $l (split(/\015?\012/, join('', @args))) {
    print STDERR "# [$sub:$line]$pad$l\n";
    $pad = '+   ';
  }

  return;
}

1;
