#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

require 't/tlib/load_file.pl';
my $pd; lives_ok sub { $pd = load_file() };

my $cs = $pd->constants;
ok($cs);
is(scalar(keys %$cs), 24);

## Some random testing
my $c = $cs->{'frame-error'};
ok($c);
is($c->name, 'frame-error');
is($c->value, '501');
is($c->class, 'hard-error');
like($c->doc, qr/sender sent a malformed frame that the recipient could not decode/);
ok(!defined $c->parent, "... no parent, I'm a top level dude");
is($c->sys, $pd, '... and my sys is the proper one');

$c = $cs->{'frame-min-size'};
ok($c);
is($c->name, 'frame-min-size');
is($c->value, '4096');
ok(!defined($c->class));
ok(!defined($c->doc));
ok(!defined $c->parent, "... no parent, I'm a top level dude");
is($c->sys, $pd, '... and my sys is the proper one');

done_testing();
