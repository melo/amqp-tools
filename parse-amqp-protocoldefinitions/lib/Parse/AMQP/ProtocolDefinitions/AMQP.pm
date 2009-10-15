package Parse::AMQP::ProtocolDefinitions::AMQP;

use Moose;
use Parse::AMQP::ProtocolDefinitions::Class;
use Parse::AMQP::ProtocolDefinitions::Constant;
use Parse::AMQP::ProtocolDefinitions::Domain;

extends 'Parse::AMQP::ProtocolDefinitions::Base';

has major => (
  isa => 'Int',
  is  => 'rw',
);

has minor => (
  isa => 'Int',
  is  => 'rw',
);

has revision => (
  isa => 'Int',
  is  => 'rw',
);

has port => (
  isa => 'Int',
  is  => 'rw',
);

has constants => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

has domains => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

has classes => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

with 'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs';

no Moose;
__PACKAGE__->meta->make_immutable;

###################################

sub xpath_expr  {'amqp'}
sub valid_attrs {qw(major minor revision port)}

###################################

sub extract_from {
  my ($self, $elem) = @_;

  $self->constants(
    Parse::AMQP::ProtocolDefinitions::Constant->parse_all(
      $elem, parent => $self
    )
  );
  $self->domains(
    Parse::AMQP::ProtocolDefinitions::Domain->parse_all(
      $elem, parent => $self
    )
  );
  $self->classes(
    Parse::AMQP::ProtocolDefinitions::Class->parse_all(
      $elem, parent => $self
    )
  );
}

1;
