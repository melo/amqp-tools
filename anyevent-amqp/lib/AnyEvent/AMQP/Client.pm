package AnyEvent::AMQP::Client;

use Moose;
use Protocol::AMQP::Peer;
use Protocol::AMQP::Util qw( trace );
use AnyEvent::Handle;
use Scalar::Util ();

has hdl => (
  isa => 'AnyEvent::Handle',
  is  => 'rw',
);

has peer => (
  isa => 'Protocol::AMQP::Peer',
  is  => 'rw',
);

has host => (
  isa     => 'Str',
  is      => 'rw',
  default => '127.0.0.1',
);

has port => (
  isa     => 'Str',
  is      => 'rw',
  default => 5672,    ## IANA assigned port for AMQP
);

##################################

sub connect {
  my ($self) = @_;
  confess('Already connected, ') if $self->{peer};

  my $peer = Protocol::AMQP::Peer->new(
    impl        => $self,
    remote_addr => $self->{host},
    remote_port => $self->{port},
    connect_cb  => \&_connect_cb,
    write_cb    => \&_write_cb,
    shutdown_cb => \&_shutdown_cb,
    destroy_cb  => \&_destroy_cb,
  );

  $self->peer($peer);
  $peer->impl_connect;

  return;
}


##################################

sub _connect_cb {
  my ($self) = @_;
  my $peer = $self->{peer};

  trace("Start connect to ",
    $peer->remote_addr, ' port ', $peer->remote_port);

  my $hdl = AnyEvent::Handle->new(
    connect => [$peer->remote_addr, $peer->remote_port],

    on_connect => sub { $peer->impl_connect_ok() },
    on_read    => sub { $peer->impl_read(\($_[0]->{rbuf})) },
    on_error   => sub { $peer->impl_error($_[1]) },
    on_eof     => sub { $peer->impl_error('eof') },
  );

  $self->hdl($hdl);
  return;
}

sub _write_cb {
  trace('writing ', \$_[1]);
  $_[0]->{hdl}->push_write($_[1]);
}

sub _shutdown_cb {
  trace('start sock shutdown');
  $_[0]->hdl->push_shutdown;
}

sub _destroy_cb {
  trace('cleanup old connection and peer');
  delete $_[0]->{$_} for qw( hdl peer );
}


1;
