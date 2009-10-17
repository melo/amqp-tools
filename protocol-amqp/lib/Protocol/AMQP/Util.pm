package Protocol::AMQP::Util;

use strict;
use warnings;
use parent qw( Exporter );
use Carp qw( confess );
use Protocol::AMQP::Registry;

@Protocol::AMQP::Util::EXPORT_OK = qw(
  pack_table unpack_table
  pack_method unpack_method
);

##################################

my %type_table = (
  'V' => [''],

  't' => ['C',  1],
  'b' => ['C',  1],
  'B' => ['C',  1],
  'U' => ['n',  2],
  'u' => ['n',  2],
  'I' => ['N',  4],
  'i' => ['N',  4],
  'L' => ['NN', 8],
  'l' => ['NN', 8],
  'T' => ['NN', 8],

  'S' => ['N/a', -4],
  's' => ['C/a', -1],

  'F' => ['N/a', \&unpack_table, \&pack_table],
);

sub pack_table {
  my ($table) = @_;
  my @fields;

  ## TODO: fix signed values
  ## TODO: implement field-array - how to reuse this next table?

  while (my ($f, $cv) = each %$table) {
    next unless $cv;
    confess("Invalid value '$cv', needs to be a hashref, ")
      unless ref($cv) && ref($cv) eq 'HASH';

    my ($ot, $v) = %$cv;
    my ($t, $sp);
    do {
      $t  = $sp;
      $t  = $ot unless $t;
      $sp = $type_table{$t};
    } until !defined($sp) || ref($sp);
    confess("Invalid table field-type '$ot'/'$t', ") unless $sp;

    my ($format, undef, $pack) = @$sp;
    next unless $format;

    $v = $pack->($v) if $pack;
    push @fields, pack("C/a a $format", $f, $t, ref($v) ? @$v : $v);
  }

  ## TODO: validate fields, connection exception if not valid (see 4.2.5.5)

  return join('', @fields);
}

sub unpack_table {
  my ($buf) = @_;
  my %table;

  while ($buf) {
    my ($name, $t) = unpack("C/a a", $buf);

    my $offset = length($name) + 2;
    my $value;

    ## TODO: fix signed values
    ## TODO: implement field-array - how to reuse this next table?

    confess("AMQP: invalid table field-value '$t'")
      unless exists $type_table{$t};

    my $rule = $type_table{$t};
    my ($format, $delta) = @$rule;

    if ($format) {
      my @v = unpack($format, substr($buf, $offset));
      if   (@v > 1) { $value = \@v }
      else          { $value = $v[0] }

      if (ref $delta) {
        $offset += length($value);
        $value = $delta->($value);
      }
      elsif ($delta < 0) {
        $offset += length($value) - $delta;
      }
      else {
        $offset += $delta;
      }
    }

    $table{$name} = {$t => $value};
    substr($buf, 0, $offset, '');
  }

  ## TODO: validate fields, connection exception if not valid (see 4.2.5.5)

  return \%table;
}


##################################

sub pack_method {
  my ($class_id, $meth_id, %args) = @_;

  my $meth_info = Protocol::AMQP::Registry->fetch_method($class_id, $meth_id);
  Carp::confess("Method not found class $class_id method $meth_id, ")
    unless $meth_info;
  my ($name, $fields, $format, @fixes) = @$meth_info;

  for my $fix (@fixes) {
    my ($f, undef, $pack) = @$fix;
    $args{$f} = $pack->($args{$f});
  }
  my $buf = pack($format, @args{@$fields});

  _trace("Packed $name(): ", \$buf);

  return $buf;
}

sub unpack_method {
  my ($class_id, $meth_id, $buf) = @_;

  my $meth_info = Protocol::AMQP::Registry->fetch_method($class_id, $meth_id);
  Carp::confess("Method not found class $class_id method $meth_id, ")
    unless $meth_info;
  my ($name, $fields, $format, @fixes) = @$meth_info;

  my %invoc;
  @invoc{@$fields} = unpack($format, $buf);
  for my $fix (@fixes) {
    my ($f, $unpack) = @$fix;
    $invoc{$f} = $unpack->($invoc{$f});
  }

  _trace("Found $name(): ", \%invoc);

  return {
    name       => $name,
    class_id   => $class_id,
    method_id  => $meth_id,
    invocation => \%invoc,
    meta       => $meth_info,
  };
}


##################################

use Data::Dump ();

sub _trace {
  my ($line) = (caller(0))[2];
  my ($sub)  = (caller(1))[3];

  my @args;
  foreach my $arg (@_) {
    if (my $type = ref $arg) {
      if ($type eq 'SCALAR') {
        my $partial = $$arg;
        my $len = length($partial);
        substr($partial, 45, $len, '...')        if $len > 45;
        push @args, Data::Dump::pp(\$partial), " (len $len)";
        next;
      }
      
      $arg = Data::Dump::pp($arg);
    }
    push @args, $arg;
  }
  
  my $pad = ' ';
  foreach my $l (split(/\015?\012/, join('', @args))) {
    print STDERR "# [$sub:$line]$pad$l\n";
    $pad = '+   ';
  }

  return;
}

1;
