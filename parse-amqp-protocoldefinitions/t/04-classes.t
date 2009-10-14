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
is(ref($ch), 'HASH');
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

my $r = $m->rules;
ok($r);
is(scalar(keys %$r), 1);
$r = $r->{state};
isa_ok($r, 'Parse::AMQP::ProtocolDefinitions::Rule');
is($r->name, 'state');
is($r->on_failure, 'channel-error');
like($r->doc, qr/The client MUST NOT use this method on an already/);
like($r->doc('scenario'), qr/Client opens a channel and then reopens/);

for my $mn (qw( open open-ok close close-ok flow flow-ok )) {
  $m = $cm->{$mn};
  my $chs = $m->chassis;
  ok($chs, "Got chassis for method $mn");
  is(ref($chs), 'HASH', '... proper type');
  
  my @sides;
  push @sides, 'client' unless $mn eq 'open';
  push @sides, 'server' unless $mn eq 'open-ok';

  is(scalar(keys %$chs), scalar(@sides), '... correct number of chasiss');
  foreach my $side (@sides) {
    ok(exists $chs->{$side}, "... on the correct side $side");
    my $ch = $chs->{$side};
    isa_ok($ch, 'Parse::AMQP::ProtocolDefinitions::Chassis', '... proper type $ch');
    is($ch->implement, 'MUST', '... and expected implement attr value');
  }
  
  my $rs = $m->responses;
  ok($rs);
  is(ref($rs), 'HASH');
  my ($r) = values %$rs;
  if ($mn !~ /-ok$/) {
    is(keys %$rs, 1);
    ok($r, "Method $mn has a response");
    isa_ok($r, 'Parse::AMQP::ProtocolDefinitions::Response', '... of the proper type');
    is($r->name, "${mn}-ok", '... and with the expected name (${mn}-ok)');
  }
  else {
    ok(!defined($r), '... and no response');
  }
}

$c = $cs->{basic};
ok($c, 'Got class basic');
$m = $c->methods->{get};
ok($m, '... and method get');
my $rs = $m->responses;
ok($rs, '... have method get responses');
is(scalar(keys %$rs), 2, '... two responses, as expected');
for my $rn (qw( get-ok get-empty )) {
  ok(exists $rs->{$rn}, "...... the '$rn' response is here");
  isa_ok($rs->{$rn}, 'Parse::AMQP::ProtocolDefinitions::Response', '...... and of the proper type');
}

my $fs = $m->fields;
ok($fs, "Got fields for method basic.get");
is(ref($fs), 'ARRAY', '... proper type for field set');
is(scalar(@$fs), 3, '... correct (3) number of fields');
isa_ok($_, 'Parse::AMQP::ProtocolDefinitions::Field', '... field '.$_->name)
  for (@$fs);

is($fs->[0]->name, 'reserved-1', 'Field reserved-1 with proper name');
ok($fs->[0]->reserved, '... it is a reserved field');
is($fs->[0]->type, 'short', '... of type short');
ok(!$fs->[0]->domain, '... so without a domain');
ok(!$fs->[0]->label, '... and without a label');

is($fs->[1]->name, 'queue', 'Field queue with proper name');
ok(!$fs->[1]->reserved, '... it is not a reserved field');
is($fs->[1]->domain, 'queue-name', '... so with a domain, queue-name');
ok(!$fs->[1]->label, '... but no label on this one');
ok(!$fs->[1]->type, '... and no type');
like($fs->[1]->doc, qr/Specifies the name of the queue to get a message from/, '... although we get docs');

is($fs->[2]->name, 'no-ack', 'Field no-ack with proper name');
ok(!$fs->[2]->reserved, '... it is not a reserved field');
is($fs->[2]->domain, 'no-ack', '... so with a domain, no-ack');
ok(!$fs->[2]->label, '... but no label for this one');
ok(!$fs->[2]->type, '... and no type');

done_testing();
