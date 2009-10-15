#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

require 't/tlib/load_specs.pl';
my @specs = load_specs();
plan skip_all => 'No active specs found in $ENV{AMQP_PROTO_DEFS_DIR}'
  unless @specs;

SPEC: for my $spec (@specs) {
  my $amqp;
  lives_ok sub {
    $amqp = Parse::AMQP::ProtocolDefinitions->load($spec->{path});
  }, "Loading spec $spec->{name} from '$spec->{path}'";
  next SPEC unless $amqp;

  is($amqp->major,    $spec->{major});
  is($amqp->minor,    $spec->{minor});
  is($amqp->revision, $spec->{revision}) if $spec->{revision};
  is($amqp->port,     5672);
  ok($amqp->comment);
}

done_testing();
