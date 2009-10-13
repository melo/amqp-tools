package Parse::AMQP::ProtocolDefinitions::Constant;

use Moose;
with
  'Parse::AMQP::ProtocolDefinitions::Roles::NameAsID',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation',
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseAllUnique';


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

sub xpath_expr {'/amqp/constant'}

##############################

sub parse {
  my ($class, $elem) = @_;

  my $self = $class->new;

  for my $attr (qw( name value class )) {
    my $value = $elem->getAttribute($attr);
    $self->$attr($value) if defined $value;
  }

  return $self;
}

1;
