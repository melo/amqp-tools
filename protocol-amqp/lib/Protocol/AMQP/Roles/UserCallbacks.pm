package Protocol::AMQP::Roles::UserCallbacks;

use Moose::Role;

requires 'cleanup';

has 'on_connect' => (
  isa => 'Str|CodeRef',
  is  => 'ro',
  clearer => 'clear_on_connect',
);

has 'on_disconnect' => (
  isa => 'Str|CodeRef',
  is  => 'ro',
  clearer => 'clear_on_disconnect',
);

sub user_on_connect_cb {
  my $self = shift;
  return unless my $cb = $self->on_connect;
  
  $self->$cb(@_);
  return;
}

sub user_on_disconnect_cb {
  my $self = shift;
  return unless my $cb = $self->on_disconnect;
  
  $self->$cb(@_);
  return;
}

after cleanup => sub {
  my ($self) = @_;
  
  $self->clear_on_connect;
  $self->clear_on_disconnect;
};

1;
