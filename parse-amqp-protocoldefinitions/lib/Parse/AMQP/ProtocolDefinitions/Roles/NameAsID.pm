package Parse::AMQP::ProtocolDefinitions::Roles::NameAsID;

use Moose::Role;

has name => (
  isa => 'Str',
  is  => 'rw',
);

sub id { $_[0]->name };

no Moose::Role;

1;
