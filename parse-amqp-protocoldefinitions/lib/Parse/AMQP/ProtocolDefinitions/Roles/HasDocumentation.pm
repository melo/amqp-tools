package Parse::AMQP::ProtocolDefinitions::Roles::HasDocumentation;

use Moose::Role;

requires('child_coverage');

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

after extract_from => sub {
  my ($self, $elem) = @_;
  $self->child_coverage->{doc} = 1;

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
