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

with 'Parse::AMQP::ProtocolDefinitions::Roles::Parse';
with 'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs';

no Moose;
__PACKAGE__->meta->make_immutable;

###################################

sub valid_attrs {qw(major minor revision port)}

###################################

sub load {
  my ($class, $xml) = @_;

  my $self = $class->new;
  my $doc = XML::LibXML->load_xml(location => $xml);
  my ($elem) = $doc->findnodes('/amqp');

  $self->parse($elem);

  return $self;
}


###################################

sub parse {
  my ($self, $elem) = @_;

  $self->constants($self->class_constant->parse_all($elem, sys => $self));
  $self->domains($self->class_domain->parse_all($elem, sys => $self));
  $self->classes($self->class_class->parse_all($elem, sys => $self));
}

1;
