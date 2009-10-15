package Parse::AMQP::ProtocolDefinitions::Roles::HasRules;

use Moose::Role;
use Parse::AMQP::ProtocolDefinitions::Rule;

has rules => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

after extract_from => sub {
  my ($self, $elem) = @_;

  $self->rules(Parse::AMQP::ProtocolDefinitions::Rule->parse_all($elem, parent => $self));
};

no Moose::Role;

1;
