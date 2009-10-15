package Parse::AMQP::ProtocolDefinitions::Base;

use Moose;

has sys => (
  isa        => 'Str',
  is         => 'ro',
  lazy_build => 1,
);

has parent => (
  isa      => 'Parse::AMQP::ProtocolDefinitions::Base',
  is       => 'ro',
  weak_ref => 1,
);

has attr_coverage => (
  isa     => 'HashRef',
  is      => 'ro',
  default => sub { {} },
);

has child_coverage => (
  isa     => 'HashRef',
  is      => 'ro',
  default => sub { {} },
);

no Moose;
__PACKAGE__->meta->make_immutable;

##############################

sub _build_sys {
  my ($self) = @_;
  my $parent = $self->parent;

  confess("The 'sys' param is required if 'parent' is missing, ")
    unless $parent;

  my $sys = $parent->sys;
  confess("The 'sys' param is required if 'parent' has no 'sys', ")
    unless $sys;

  return $sys;
}

##############################

sub valid_attrs { }

sub xpath_expr {
  confess('Subclass '
      . (ref($_[0]) || $_[0])
      . ' must implement xpath_expr() method, ');
}

sub parse {
  my ($self, $elem) = @_;

  $self->extract_from($elem);
  $self->finalize($elem);

  return $self;
}

sub extract_from { }

sub finalize {
  my ($self, $elem) = @_;

  ## Make sure our parent knows which nodes we covered
  if (my $parent = $self->parent) {
    $parent->child_coverage->{$self->xpath_expr} = 1;
  }

  # Mark all our attrs as parsed
  my $ac = $self->attr_coverage;
  $ac->{$_} = 1 for ($self->valid_attrs);

  # Check our coverage
  $self->_check_coverage($elem);

  return;
}

sub _check_coverage {
  my ($self, $elem) = @_;

  ### Attrs coverage
  my $ac = $self->attr_coverage;
  foreach my $attr ($elem->attributes) {
    my $an = $attr->nodeName;
    next if exists $ac->{$an};

    confess("Elem $self needs parser for attr '$an', ");
  }

  ### Child nodes coverage
  my $cc = $self->child_coverage;
  foreach my $node ($elem->getChildrenByTagName('*')) {
    my $name = $node->nodeName;
    next if exists $cc->{$name};

    confess("Elem $self needs parser for child '$name', ");
  }

  return;
}

1;
