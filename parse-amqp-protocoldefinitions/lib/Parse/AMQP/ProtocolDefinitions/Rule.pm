package Parse::AMQP::ProtocolDefinitions::Rule;

use Moose;

with
  'Parse::AMQP::ProtocolDefinitions::Roles::Parse',
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';

has on_failure => (
  isa => 'Str',
  is  => 'rw',
);

no Moose;
__PACKAGE__->meta->make_immutable;

##############################

sub xpath_expr  {'rule'}
sub valid_attrs {qw( on-failure )}

##############################


1;
