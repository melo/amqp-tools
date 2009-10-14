package Parse::AMQP::ProtocolDefinitions::Roles::HasChassis;

use Moose::Role;
use Parse::AMQP::ProtocolDefinitions::Chassis;

has chassis => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

after parse => sub {
  my ($self, $elem) = @_;

  $self->chassis(Parse::AMQP::ProtocolDefinitions::Chassis->parse_all($elem));
};

no Moose::Role;

1;
