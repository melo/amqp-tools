package Parse::AMQP::ProtocolDefinitions::Class;

use Moose;
use Parse::AMQP::ProtocolDefinitions::Method;
use Path::Class qw( dir );

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

sub generate {
  my $self   = shift;
  my $prefix = shift;
  my $dir    = dir(@_);

  my $class = ucfirst($self->name);

  my $fh = $dir->file("$class.pm")->openw;
  $fh->print($self->build_class_class($prefix));
  $fh->close;

  return;
}

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

sub build_class_class {
  my ($self, $prefix) = @_;
  my $package = $self->package;

  ## Start the package
  my $buf = <<EOH;
package $package;

use Moose;
use Protocol::AMQP::Registry;

extends 'Protocol::AMQP::API::Class';


EOH

  # my $classes = $self->classes;
  # for my $class (sort { $a->index <=> $b->index } values %$classes) {
  #   $buf .= $class->build_class_slot("${prefix}::$name");
  # }

  ## End the package
  $buf .= "1;\n";

  # TODO: generate POD

  return $buf;
}


1;
