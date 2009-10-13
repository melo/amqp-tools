package Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation;

use Moose::Role;

has doc => (
  isa => 'Str',
  is  => 'rw',
);

sub type { return (split(/::/, shift))[-1] }

around parse => sub {
  my $orig = shift;
  my ($class, $elem) = @_;
  
  my $self = $orig->(@_);
  
  if (my $doc = $elem->getChildrenByTagName('doc')) {
    my $value = $elem->textContent;
    $self->doc($value) if defined $value;
  }
  
  return $self;
};

no Moose::Role;

1;
