package Parse::AMQP::ProtocolDefinitions::Base;

use Moose;

has sys => (
  isa        => 'Parse::AMQP::ProtocolDefinitions',
  is         => 'ro',
  lazy_build => 1,
  weak_ref   => 1,
);

has parent => (
  isa      => 'Parse::AMQP::ProtocolDefinitions::Base',
  is       => 'ro',
  weak_ref => 1,
);


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


1;
