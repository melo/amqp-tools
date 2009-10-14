package Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs;

use Moose::Role;

requires('valid_attrs');

after parse => sub {
  my ($self, $elem) = @_;

  for my $attr ($self->valid_attrs) {
    my $slot = $attr;
    $slot =~ s/-/_/g;
    my $value = $elem->getAttribute($attr);
    $self->$slot($value) if defined $value;
  }
};

no Moose::Role;

1;
