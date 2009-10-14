package Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique;

use Moose::Role;

requires(qw( id type_name xpath_expr ));

sub parse {}

sub parse_all {
  my ($class, $doc) = @_;
  my $type = $class->type_name;
  my %all;
  
  for my $elem ($doc->findnodes($class->xpath_expr)) {
    my $obj = $class->new;
    $obj->parse($elem);
    my $id = $obj->id;
    _fatal("Duplicate '$type' with ID '$id'") if $all{$id};

    $all{$id} = $obj;
  }
  
  return \%all;
}

no Moose::Role;

1;
