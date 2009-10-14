package Parse::AMQP::ProtocolDefinitions::Chassis;

use Moose;


extends 'Parse::AMQP::ProtocolDefinitions::Base';

has implement => (
  isa => 'Str',
  is  => 'rw',
);

with 'Parse::AMQP::ProtocolDefinitions::Roles::Parse';
with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs';

no Moose;
no Moose::Util::TypeConstraints;

__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'chassis'}
sub valid_attrs {qw(implement)}

##############################


1;
