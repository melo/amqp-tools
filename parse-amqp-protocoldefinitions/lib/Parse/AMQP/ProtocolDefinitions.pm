package Parse::AMQP::ProtocolDefinitions;

use Any::Moose;
use Carp::Clan qw(^Parse::AMQP::ProtocolDefinitions);
use XML::LibXML;

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

no Any::Moose;
__PACKAGE__->meta->make_immutable;

###################################

sub parse {
  my ($class, $xml) = @_;
  
  my $self = $class->new;
  my $doc = XML::LibXML->load_xml(location => $xml);

  $self->_extract_metadata($doc);
  
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
