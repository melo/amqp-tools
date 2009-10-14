package Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs;

use Moose::Role;

requires('valid_attrs');

around parse => sub {
  my $orig = shift;
  my ($self, $elem) = @_;

  $orig->(@_);

  for my $attr ($self->valid_attrs) {
    my $value = $elem->getAttribute($attr);
    $self->$attr($value) if defined $value;
  }
};

no Moose::Role;

1;
