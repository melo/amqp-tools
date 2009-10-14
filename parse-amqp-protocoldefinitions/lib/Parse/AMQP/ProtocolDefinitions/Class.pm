package Parse::AMQP::ProtocolDefinitions::Class;

use Moose;
use Parse::AMQP::ProtocolDefinitions::Method;


extends 'Parse::AMQP::ProtocolDefinitions::Base';

has handler => (
  isa => 'Str',
  is  => 'rw',
);

has index => (
  isa => 'Int',
  is  => 'rw',
);

has label => (
  isa => 'Str',
  is  => 'rw',
);

has methods => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

with 'Parse::AMQP::ProtocolDefinitions::Roles::Parse';
with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasChassis',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';

no Moose;
__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'class'}
sub valid_attrs {qw(handler index label)}

##############################

sub parse {
  my ($self, $elem) = @_;

  $self->methods(Parse::AMQP::ProtocolDefinitions::Method->parse_all($elem, parent => $self));
}

1;
