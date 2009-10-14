package Parse::AMQP::ProtocolDefinitions::Response;

use Moose;

with 'Parse::AMQP::ProtocolDefinitions::Roles::Parse';
with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs';

no Moose;
no Moose::Util::TypeConstraints;

__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'response'}
sub valid_attrs {qw()}

##############################


1;
