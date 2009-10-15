package Parse::AMQP::ProtocolDefinitions;

use Moose;
use XML::LibXML;

use Parse::AMQP::ProtocolDefinitions::AMQP;

no Moose;
__PACKAGE__->meta->make_immutable;

###################################

sub load {
  my ($class, $xml) = @_;

  my $doc = XML::LibXML->load_xml(location => $xml);
  my ($elem) = $doc->findnodes('/amqp');

  my $amqp = Parse::AMQP::ProtocolDefinitions::AMQP->new(sys => $class);
  $amqp->parse($elem);

  return $amqp;
}


1;
