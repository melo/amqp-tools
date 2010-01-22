package Parse::AMQP::ProtocolDefinitions::Roles::ParseUnique;

use Moose::Role;

requires(qw( id xpath_expr parse ));

sub parse_all {
  my ($class, $doc, @args) = @_;
  my $name = $class->xpath_expr;

  my %all;
  for my $elem ($doc->findnodes($name)) {
    my $obj = $class->new(@args);
    $obj->parse($elem);

    my $id = $obj->id;
    confess("Duplicate '$name' with ID '$id'") if $all{$id};

    $all{$id} = $obj;
  }

  return \%all;
}

no Moose::Role;

1;
