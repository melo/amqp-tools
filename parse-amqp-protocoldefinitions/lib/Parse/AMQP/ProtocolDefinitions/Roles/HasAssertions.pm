package Parse::AMQP::ProtocolDefinitions::Roles::HasAssertions;

use Moose::Role;
use Parse::AMQP::ProtocolDefinitions::Assert;

has assertions => (
  isa     => 'ArrayRef',
  is      => 'rw',
  default => sub { [] },
);

after parse => sub {
  my ($self, $elem) = @_;

  $self->assertions(Parse::AMQP::ProtocolDefinitions::Assert->parse_all($elem));
};

no Moose::Role;

1;
