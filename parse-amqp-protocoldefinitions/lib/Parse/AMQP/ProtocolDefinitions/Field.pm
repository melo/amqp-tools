package Parse::AMQP::ProtocolDefinitions::Field;

use Moose;

extends 'Parse::AMQP::ProtocolDefinitions::Base';

has domain => (
  isa => 'Str',
  is  => 'rw',  
);

has label => (
  isa => 'Str',
  is  => 'rw',  
);

has reserved => (
  isa => 'Bool',
  is  => 'rw',
);

## type is a Elementary domain, used only when reserved is true for
## deprecated fields
has type => (
  isa => 'Str',
  is  => 'rw',  
);

with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseSequence',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasRules',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasAssertions',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs';

no Moose;

__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'field'}
sub valid_attrs {qw(domain label type reserved)}

##############################


1;
