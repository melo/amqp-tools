package Parse::AMQP::ProtocolDefinitions::Domain;

use Moose;

with
  'Parse::AMQP::ProtocolDefinitions::Roles::Parse',
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasRules',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasAssertions',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';


has type => (
  isa => 'Str',
  is  => 'rw',
);

has label => (
  isa => 'Str',
  is  => 'rw',
);

no Moose;
__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'domain'}
sub valid_attrs {qw( type label)}

##############################


1;
