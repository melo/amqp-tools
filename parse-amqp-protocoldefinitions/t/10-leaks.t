#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::LeakTrace;

require 't/tlib/load_specs.pl';
my @specs = load_specs();
plan skip_all => 'No active specs found in $ENV{AMQP_PROTO_DEFS_DIR}'
  unless @specs;

SPEC: for my $spec (@specs) {
  no_leaks_ok {
    my $amqp;
    eval { $amqp = Parse::AMQP::ProtocolDefinitions->load($spec->{path}); };
  }
  "no memory leaks detected on spec $spec->{name} from '$spec->{path}'";
}

done_testing();
