#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::LeakTrace;

require 't/tlib/load_specs.pl';

SPEC: for my $spec (load_specs()) {
  no_leaks_ok {
    my $amqp;
    eval { $amqp = Parse::AMQP::ProtocolDefinitions->load($spec->{path}); };
  }
  "no memory leaks detected on spec $spec->{name} from '$spec->{path}'";
}

done_testing();
