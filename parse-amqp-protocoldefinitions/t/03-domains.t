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

$c = $cs->{'class-id'};
ok($c);
is($c->name, 'class-id');
is($c->type, 'short');
ok(!defined($c->label));
ok(!defined($c->doc));

done_testing();