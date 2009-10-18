package Protocol::AMQP::Roles::UserCallbacks;

use Moose::Role;

requires 'cleanup';

has [qw{on_connect on_disconnect}] => (
  isa => 'Str|CodeRef',
  is  => 'ro',
);

sub user_on_connect_cb {
  my $self = shift;
  return unless my $cb = $self->on_connect;
  
  $self->$cb(@_) if $cb;
  return;
}

sub user_on_disconnect_cb {
  my $self = shift;
  return unless my $cb = $self->on_disconnect;
  
  $self->$cb(@_) if $cb;
  return;
}

after cleanup => sub {
  my ($self) = @_;
  
  delete $self->{$_} for qw( on_connect on_disconnect );
};

1;
