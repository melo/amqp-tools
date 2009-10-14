package Parse::AMQP::ProtocolDefinitions::Chassis;

use Moose;
use Moose::Util::TypeConstraints;

with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs';

has implement => (
  isa => 'Str',
  is  => 'rw',
);

no Moose;
no Moose::Util::TypeConstraints;

__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'chassis'}
sub valid_attrs {qw(implement)}

##############################


1;
