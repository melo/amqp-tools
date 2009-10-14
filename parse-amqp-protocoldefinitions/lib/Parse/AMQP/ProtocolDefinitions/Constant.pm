package Parse::AMQP::ProtocolDefinitions::Constant;

use Moose;


has value => (
  isa => 'Int',
  is  => 'rw',
);

has class => (
  isa => 'Str',
  is  => 'rw',
);

with 'Parse::AMQP::ProtocolDefinitions::Roles::Parse';
with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';

no Moose;
__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'constant'}
sub valid_attrs {qw(value class)}

##############################


1;
