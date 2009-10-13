package Parse::AMQP::ProtocolDefinitions;

use Moose;
use Carp::Clan qw(^Parse::AMQP::ProtocolDefinitions);
use XML::LibXML;

use Parse::AMQP::ProtocolDefinitions::Constant;

has major => (
  isa => 'Int',
  is  => 'rw',
);

has minor => (
  isa => 'Int',
  is  => 'rw',
);

has revision => (
  isa => 'Int',
  is  => 'rw',
);

has port => (
  isa => 'Int',
  is  => 'rw',
);

has constants => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

has class_constant => (
  isa     => 'Str',
  is      => 'ro',
  default => 'Parse::AMQP::ProtocolDefinitions::Constant',
);

no Moose;
__PACKAGE__->meta->make_immutable;

###################################

sub parse {
  my ($class, $xml) = @_;

  my $self = $class->new;
  my $doc = XML::LibXML->load_xml(location => $xml);

  $self->_extract_metadata($doc);
  $self->constants($self->class_constant->parse_all($doc));

  return $self;
}


###################################

sub _extract_metadata {
  my ($self, $doc) = @_;

  my ($amqp) = $doc->findnodes('/amqp');

  for my $attr (qw( major minor revision port )) {
    $self->$attr($amqp->getAttribute($attr));
  }

  return;
}


###################################

sub _fatal { croak(join('', @_, ', ')) }


1;
