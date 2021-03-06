package Parse::AMQP::ProtocolDefinitions::Roles::ParseSequence;

use Moose::Role;

requires(qw( xpath_expr parse ));

sub parse_all {
  my ($class, $doc, @args) = @_;
  my $name = $class->xpath_expr;

  my @all;
  for my $elem ($doc->findnodes($name)) {
    my $obj = $class->new(@args);
    $obj->parse($elem);
    push @all, $obj;
  }

  return \@all;
}

no Moose::Role;

1;
