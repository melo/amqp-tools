package Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation;

use Moose::Role;

has _docs => (
  isa     => 'HashRef',
  is      => 'rw',
  default => sub { {} },
);

sub doc {
  my ($self, $type) = @_;
  my $docs = $self->_docs;

  $type = '<empty>' unless $type;

  return unless exists $docs->{$type};
  return $docs->{$type};
}

around parse => sub {
  my $orig = shift;
  my ($self, $elem) = @_;

  $orig->(@_);

  my $docs = $self->_docs;
  foreach my $doc ($elem->findnodes('doc')) {
    my $type = $doc->getAttribute('type') || '<empty>';
    my $value = $doc->textContent;
    next unless $value;

    $docs->{$type} = $value;
  }
};

no Moose::Role;

1;
