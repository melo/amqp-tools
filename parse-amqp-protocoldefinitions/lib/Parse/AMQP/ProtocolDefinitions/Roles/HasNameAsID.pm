package Parse::AMQP::ProtocolDefinitions::Roles::HasNameAsID;

use Moose::Role;

requires('valid_attrs');

has name => (
  isa => 'Str',
  is  => 'rw',
);

sub id { $_[0]->name };

around valid_attrs => sub {
  my $orig = shift;
  my ($class) = @_;
  
  my @attrs = $orig->(@_);
  push @attrs, 'name';
  
  return @attrs;
};

no Moose::Role;

1;
