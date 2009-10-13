package Parse::AMQP::ProtocolDefinitions::Constant;

use Any::Moose;

has name => (
  isa => 'Str',
  is  => 'rw',
);

has value => (
  isa => 'Int',
  is  => 'rw',
);

has class => (
  isa => 'Str',
  is  => 'rw',
);

has doc => (
  isa => 'Str',
  is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

##############################

sub parse {
  my ($class, $elem) = @_;
  
  my $self = $class->new;

  for my $attr (qw( name value class )) {
    my $value = $elem->getAttribute($attr);
    $self->$attr($value) if defined $value;
  }

  if (my $doc = $elem->getChildrenByTagName('doc')) {
    my $value = $elem->textContent;
    $self->doc($value) if defined $value;
  }
  
  return $self;
}

1;
