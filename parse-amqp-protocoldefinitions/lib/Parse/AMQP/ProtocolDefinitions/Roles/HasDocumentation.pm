package Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation;

use Moose::Role;

has doc => (
  isa => 'Str',
  is  => 'rw',
);

sub type { return (split(/::/, shift))[-1] }


no Moose::Role;

1;
