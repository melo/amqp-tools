package Parse::AMQP::ProtocolDefinitions::Roles::HasFields;

use Moose::Role;
use Parse::AMQP::ProtocolDefinitions::Field;

has fields => (
  isa     => 'ArrayRef',
  is      => 'rw',
  default => sub { [] },
);

after extract_from => sub {
  my ($self, $elem) = @_;

  $self->fields(
    Parse::AMQP::ProtocolDefinitions::Field->parse_all(
      $elem, parent => $self
    )
  );
};

no Moose::Role;

1;
