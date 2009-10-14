#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

require 't/tlib/load_file.pl';
my $pd; lives_ok sub { $pd = load_file() };

my $cs = $pd->domains;
ok($cs);
is(scalar(keys %$cs), 24);

## Some random testing
my $c = $cs->{'delivery-tag'};
ok($c);
is($c->name, 'delivery-tag');
is($c->type, 'longlong');
is($c->label, 'server-assigned delivery tag');
like($c->doc, qr/The server-assigned and channel-specific delivery tag/);
ok(!defined $c->parent, "... no parent, I'm a top level dude");
is($c->sys, $pd, '... and my sys is the proper one');

my $rs = $c->rules;
is(scalar(keys %$rs), 2);
my $r = $rs->{'channel-local'};
ok($r);
like($r->doc, qr/a client MUST NOT receive a message on/);
is($r->parent, $c, "... not a bastard, I like having a father");
is($r->sys, $pd, '... but my sys is still the proper one');

$c = $cs->{'class-id'};
ok($c);
is($c->name, 'class-id');
is($c->type, 'short');
ok(!defined($c->label));
ok(!defined($c->doc));
is(scalar(keys %{$c->rules}), 0);

$c = $cs->{'exchange-name'};
ok($c);
is($c->name, 'exchange-name');
is($c->type, 'shortstr');
is($c->label, 'exchange name');
like($c->doc, qr/The exchange name is a client-selected string that/);
my $as = $c->assertions;
ok($as);
is(scalar(@$as), 2);
is($as->[0]->check, 'length');
is($as->[0]->value, '127');
is($as->[1]->check, 'regexp');
is($as->[1]->value, '^[a-zA-Z0-9-_.:]*$');
for my $aa (@$as) {
  is($aa->parent, $c, "... not a bastard, I like having a father");
  is($aa->sys, $pd, '... but my sys is still the proper one');
}

done_testing();
