package FakePeer;

use Moose;
extends 'Protocol::AMQP::Peer';

has 'write_buffer' => (
  isa        => 'Str',
  is         => 'rw',
  lazy_build => 1,
);

sub _build_write_buffer { return '' }

has 'last_method' => (
  isa     => 'HashRef',
  is      => 'rw',
  clearer => 'clear_last_method'
);


sub write {
  my ($self, $info) = @_;

  $self->write_buffer($self->write_buffer . $info);
}

sub handle_method {
  my ($self, $method) = @_;

  $self->last_method($method);
}

1;
