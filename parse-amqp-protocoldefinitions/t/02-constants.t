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
is($c->parent, $pd, "... not parentless, I like having a father");
is($c->sys, 'Parse::AMQP::ProtocolDefinitions', '... but my sys is still the proper one');

$c = $cs->{'frame-min-size'};
ok($c);
is($c->name, 'frame-min-size');
is($c->value, '4096');
ok(!defined($c->class));
ok(!defined($c->doc));
is($c->parent, $pd, "... not parentless, I like having a father");
is($c->sys, 'Parse::AMQP::ProtocolDefinitions', '... but my sys is still the proper one');

done_testing();
