package Parse::AMQP::ProtocolDefinitions::Method;

use Moose;
use Parse::AMQP::ProtocolDefinitions::Response;

with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasRules',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasChassis',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';


has synchronous => (
  isa => 'Bool',
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

has responses => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

no Moose;
__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'method'}
sub valid_attrs {qw(synchronous index label)}

##############################

sub parse {
  my ($self, $elem) = @_;

  $self->responses(
    Parse::AMQP::ProtocolDefinitions::Response->parse_all($elem));
}


1;
