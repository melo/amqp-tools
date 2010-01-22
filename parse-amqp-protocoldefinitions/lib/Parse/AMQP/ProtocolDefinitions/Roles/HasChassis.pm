package Parse::AMQP::ProtocolDefinitions::Roles::HasChassis;

use Moose::Role;
use Parse::AMQP::ProtocolDefinitions::Chassis;

has chassis => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

after extract_from => sub {
  my ($self, $elem) = @_;

  $self->chassis(
    Parse::AMQP::ProtocolDefinitions::Chassis->parse_all(
      $elem, parent => $self
    )
  );
};

no Moose::Role;

1;
