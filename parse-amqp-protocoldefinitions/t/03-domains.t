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

  my $cs = $amqp->domains;
  ok($cs);
  is(scalar(keys %$cs), $spec->{t_domains});

  ## Some random testing
  my $c = $cs->{'delivery-tag'};
  ok($c);
  is($c->name,  'delivery-tag');
  is($c->type,  'longlong');
  is($c->label, 'server-assigned delivery tag');
  like($c->doc, qr/The server-assigned and channel-specific delivery tag/);
  is($c->parent, $amqp, "... not parentless, I like having a father");
  is(
    $c->sys,
    'Parse::AMQP::ProtocolDefinitions',
    '... but my sys is still the proper one'
  );

  my $rs = $c->rules;
  is(scalar(keys %$rs), 2);
  my $r = $rs->{'channel-local'};
  ok($r);
  like($r->doc, qr/a client MUST NOT receive a message on/);
  is($r->parent, $c,      "... not parentless, I like having a father");
  is($r->sys,    $c->sys, '... but my sys is still the proper one');

  $c = $cs->{'class-id'};
  ok($c);
  is($c->name, 'class-id');
  is($c->type, 'short');
  ok(!defined($c->label));
  ok(!defined($c->doc));
  is(scalar(keys %{$c->rules}), 0);

  $c = $cs->{'exchange-name'};
  ok($c);
  is($c->name,  'exchange-name');
  is($c->type,  'shortstr');
  is($c->label, 'exchange name');
  like($c->doc, qr/The exchange name is a client-selected string that/);
  my $as = $c->assertions;
  is(ref($as), 'ARRAY');
  ok(@$as);
  is($as->[0]->check, 'length');
  is($as->[0]->value, '127');

  if (($spec->{version} gt '000009000')) {
    is($as->[1]->check, 'regexp');
    is($as->[1]->value, '^[a-zA-Z0-9-_.:]*$');
  }

  for my $aa (@$as) {
    is($aa->parent, $c,      "... not parentless, I like having a father");
    is($aa->sys,    $c->sys, '... but my sys is still the proper one');
  }
}

done_testing();
