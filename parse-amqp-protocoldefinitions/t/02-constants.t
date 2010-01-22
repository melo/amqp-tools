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

  my $cs = $amqp->constants;
  ok($cs);
  is(scalar(keys %$cs), $spec->{t_constants});

  ## Some random testing
  my $c = $cs->{'frame-error'};
  ok($c);
  is($c->name,  'frame-error');
  is($c->value, '501');
  is($c->class, 'hard-error');
  like($c->doc,
    qr/(sender|client) sent a malformed frame that the (recipient|server) could not decode/
  );
  is($c->parent, $amqp, "... not parentless, I like having a father");
  is(
    $c->sys,
    'Parse::AMQP::ProtocolDefinitions',
    '... but my sys is still the proper one'
  );

  $c = $cs->{'frame-min-size'};
  ok($c);
  is($c->name,  'frame-min-size');
  is($c->value, '4096');
  ok(!defined($c->class));
  ok(!defined($c->doc));
  is($c->parent, $amqp, "... not parentless, I like having a father");
  is(
    $c->sys,
    'Parse::AMQP::ProtocolDefinitions',
    '... but my sys is still the proper one'
  );
}

done_testing();
