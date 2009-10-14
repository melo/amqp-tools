package Parse::AMQP::ProtocolDefinitions::Roles::ParseSequence;

use Moose::Role;

requires(qw( xpath_expr parse ));

sub parse_all {
  my ($class, $doc) = @_;
  my @all;
  
  for my $elem ($doc->findnodes($class->xpath_expr)) {
    my $obj = $class->new;
    $obj->parse($elem);
    push @all, $obj;
  }
  
  return \@all;
}

no Moose::Role;

1;
