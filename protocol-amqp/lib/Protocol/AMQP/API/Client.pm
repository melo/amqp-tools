package Protocol::AMQP::API::Client;

use Moose;
use Scalar::Util ();

has host => (
  isa => 'Str',
  is  => 'rw',
);

has port => (
  isa => 'Str',
  is  => 'rw',
);

has is_connected => (
  isa     => 'Bool',
  is      => 'rw',
  default => 0,
);

has api => (
  isa     => 'Object',      ## TODO: does it have a common parent?
  is      => 'rw',
  clearer => 'clear_api',
);

has impl => (
  isa     => 'Protocol::AMQP::Peer',
  is      => 'rw',
  clearer => 'clear_impl',
);

has impl_class => (
  isa      => 'Str',
  is       => 'ro',
  required => 1,
);

with qw( Protocol::AMQP::Roles::UserCallbacks );

sub _build_impl { return shift->impl_class->new }

##################################

sub connect {
  my ($self) = @_;
  my %args;

  $args{remote_addr} = $self->host if $self->host;
  $args{remote_port} = $self->port if $self->port;

  Scalar::Util::weaken($self);
  $args{on_connect}    = sub { $self->_on_connect_cb(@_) };
  $args{on_disconnect} = sub { $self->_on_disconnect_cb(@_) };

  $self->impl(my $impl = $self->impl_class->new(\%args));
  $impl->connect;

  return;
}

sub disconnect {
  my ($self) = @_;

  my $impl = $self->impl;
  return unless $impl;
  
  $impl->close;
  return;
}

sub cleanup {
  my ($self) = @_;

  $self->clear_api;
  $self->clear_impl;
  $self->is_connected(0);
}


##################################

sub _on_connect_cb {
  my ($self) = @_;
  
  $self->is_connected(1);
  ## TODO: get AMQP API object from args
  ## $self->api($api);
  
  $self->user_on_connect_cb;
  return;
}


sub _on_disconnect_cb {
  my ($self) = @_;
  
  $self->user_on_disconnect_cb;
  $self->cleanup;
  return;
}

1;
