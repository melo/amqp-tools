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

with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasChassis',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasRules',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasFields',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';

no Moose;
__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'class'}
sub valid_attrs {qw(handler index label)}

##############################

sub extract_from {
  my ($self, $elem) = @_;

  $self->methods(
    Parse::AMQP::ProtocolDefinitions::Method->parse_all(
      $elem, parent => $self
    )
  );
}


###################################

sub build_class_slot {
  my ($self, $prefix) = @_;
  my $name = $self->name;
  my $package = join('::', ${prefix}, ucfirst($name));
  
  return <<EOS;
use $package;

has '$name' => (
  isa        => '$package',
  is         => 'ro',
  lazy_build => 1,
);

sub _build_$name {
  return $package->new({peer => \$_[0]->peer});
}


EOS
}


1;
