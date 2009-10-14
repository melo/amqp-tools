package Parse::AMQP::ProtocolDefinitions::Domain;

use Moose;
use Parse::AMQP::ProtocolDefinitions::Assert;

with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasRules',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';


has type => (
  isa => 'Str',
  is  => 'rw',
);

has label => (
  isa => 'Str',
  is  => 'rw',
);

has assertions => (
  isa     => 'ArrayRef',
  is      => 'rw',
  default => sub { [] },
);

no Moose;
__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'domain'}
sub valid_attrs {qw( type label)}

##############################

sub parse {
  my ($self, $elem) = @_;

  $self->assertions(Parse::AMQP::ProtocolDefinitions::Assert->parse_all($elem));
}

1;
