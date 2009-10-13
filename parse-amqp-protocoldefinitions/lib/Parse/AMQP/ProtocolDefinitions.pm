package Parse::AMQP::ProtocolDefinitions;

use Any::Moose;
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
  isa => 'HashRef',
  is  => 'ro',
  default => sub { {} },
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

###################################

sub parse {
  my ($class, $xml) = @_;
  
  my $self = $class->new;
  my $doc = XML::LibXML->load_xml(location => $xml);

  $self->_extract_metadata($doc);
  $self->_extract_constants($doc);
  
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

sub _extract_constants {
  my ($self, $doc) = @_;
  my $cs = $self->constants;
  
  for my $elem ($doc->findnodes('/amqp/constant')) {
    my $c = Parse::AMQP::ProtocolDefinitions::Constant->parse($elem);

    my $name = $c->name;
    _fatal("Duplicate constant '$name'") if $cs->{$name};

    $cs->{$name} = $c;
  }
  
  return;
}


###################################

sub _fatal { croak(join('', @_, ', ')) }


1;
