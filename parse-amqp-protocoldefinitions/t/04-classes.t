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

my $cm = $c->methods;
ok($ch);
is(ref($cs), 'HASH');
is(scalar(keys %$cm), 6);
ok(exists $cm->{$_})
  for (qw( open open-ok close close-ok flow flow-ok ));
isa_ok($_, 'Parse::AMQP::ProtocolDefinitions::Method')
  for values %$cm;
ok($cm->{$_}->synchronous, "method '$_' is synchronous")
  for (qw( open open-ok close close-ok flow ));
ok(!$cm->{'flow-ok'}->synchronous, "method 'flow-ok' is NOT synchronous");

my $m = $cm->{open};
ok($m);
is($m->index, 10);
is($m->label, 'open a channel for use');
like($m->doc, qr/This method opens a channel to the server/);

done_testing();
