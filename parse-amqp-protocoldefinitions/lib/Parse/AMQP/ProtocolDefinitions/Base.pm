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

sub finalize { }

1;
