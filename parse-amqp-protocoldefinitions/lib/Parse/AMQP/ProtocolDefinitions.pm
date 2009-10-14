package Parse::AMQP::ProtocolDefinitions;

use Moose;
use Carp::Clan qw(^Parse::AMQP::ProtocolDefinitions);
use XML::LibXML;

use Parse::AMQP::ProtocolDefinitions::Class;
use Parse::AMQP::ProtocolDefinitions::Constant;
use Parse::AMQP::ProtocolDefinitions::Domain;

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

has domains => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

has class_domain => (
  isa     => 'Str',
  is      => 'ro',
  default => 'Parse::AMQP::ProtocolDefinitions::Domain',
);

has classes => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

has class_class => (
  isa     => 'Str',
  is      => 'ro',
  default => 'Parse::AMQP::ProtocolDefinitions::Class',
);

no Moose;
__PACKAGE__->meta->make_immutable;

###################################

sub parse {
  my ($class, $xml) = @_;

  my $self = $class->new;
  my $doc = XML::LibXML->load_xml(location => $xml);
  my ($amqp) = $doc->findnodes('/amqp');

  $self->_extract_metadata($doc);
  $self->constants($self->class_constant->parse_all($amqp));
  $self->domains($self->class_domain->parse_all($amqp));
  $self->classes($self->class_class->parse_all($amqp));

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
