package Parse::AMQP::ProtocolDefinitions::Roles::ParseAllUnique;

use Moose::Role;

requires(qw( id type xpath_expr ));

sub parse_all {
  my ($class, $doc) = @_;
  my $type = $class->type;
  my %all;
  
  for my $elem ($doc->findnodes($class->xpath_expr)) {
    my $obj = $class->parse($elem);
    my $id = $obj->id;
    _fatal("Duplicate '$type' with ID '$id'") if $all{$id};

    $all{$id} = $obj;
  }
  
  return \%all;
}

no Moose::Role;

1;
