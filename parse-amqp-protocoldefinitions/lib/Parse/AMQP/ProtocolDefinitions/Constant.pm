package Parse::AMQP::ProtocolDefinitions::Constant;

use Moose;
with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';


has value => (
  isa => 'Int',
  is  => 'rw',
);

has class => (
  isa => 'Str',
  is  => 'rw',
);


no Moose;
__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'/amqp/constant'}
sub valid_attrs {qw(value class)}

##############################


1;
