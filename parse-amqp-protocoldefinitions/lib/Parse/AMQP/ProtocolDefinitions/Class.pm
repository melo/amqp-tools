package Parse::AMQP::ProtocolDefinitions::Class;

use Moose;
use Parse::AMQP::ProtocolDefinitions::Chassis;

with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';


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

has chassis => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

no Moose;
__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'class'}
sub valid_attrs {qw(handler index label)}

##############################

sub parse {
  my ($self, $elem) = @_;

  $self->chassis(Parse::AMQP::ProtocolDefinitions::Chassis->parse_all($elem));
}

1;
