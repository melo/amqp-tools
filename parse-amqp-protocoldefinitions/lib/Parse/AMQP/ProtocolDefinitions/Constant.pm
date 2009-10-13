package Parse::AMQP::ProtocolDefinitions::Constant;

use Moose;
with
  'Parse::AMQP::ProtocolDefinitions::Roles::NameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation';

has value => (
  isa => 'Int',
  is  => 'rw',
);

has class => (
  isa => 'Str',
  is  => 'rw',
);

no Moose;
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
