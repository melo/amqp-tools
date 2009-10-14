#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

require 't/tlib/load_file.pl';
my $pd; lives_ok sub { $pd = load_file() };

my $cs = $pd->classes;
ok($cs);
is(scalar(keys %$cs), 6);

my $c = $cs->{'channel'};
ok($c);
is($c->name, 'channel');
is($c->index, 20);
is($c->label, 'work with channels');
like($c->doc, qr/channel class provides methods for a client to establish a channel/);
like($c->doc('grammar'), qr/close-channel\s+= C:CLOSE S:CLOSE-OK/);

my $ch = $c->chassis;
ok($ch);
is(ref($cs), 'HASH');
is(scalar(keys %$ch), 2);
ok(exists $ch->{$_}) for (qw( client server ));
isa_ok($_, 'Parse::AMQP::ProtocolDefinitions::Chassis') for values %$ch;
is($ch->{$_}->implement, 'MUST') for (qw( client server ));

done_testing();
