#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Deep;
use Test::Exception;

use FakePeer;    ## has write() buffering
my $peer = FakePeer->new;

##################################
my $v;
lives_ok sub { $v = $peer->_pick_best_protocol_version };
ok(!defined $v, 'No versions registered, so no "best version" available');


my @test_cases = (
  { best => '0.7.2',
    spec => {
      major    => '0',
      minor    => '7',
      revision => '2',
      api      => 'Protocol::AMQP::V000007002',
    },
  },

  { best => '0.7.2',
    spec => {
      major    => '0',
      minor    => '7',
      revision => '0',
      api      => 'Protocol::AMQP::V000007000',
    },
  },

  { best => '0.7.9',
    spec => {
      major    => '0',
      minor    => '7',
      revision => '9',
      api      => 'Protocol::AMQP::V000007009',
    },
  },
);

for my $tc (@test_cases) {
  my $spec = $tc->{spec};

  lives_ok sub { Protocol::AMQP::Registry->register_version($spec) },
    "Register version $spec->{api} ok";
  lives_ok sub { $v = $peer->_pick_best_protocol_version },
    '_pick_best_protocol_version() lived through it';
  ok(defined $v, '... and gaves us a defined answer');
  is($v->{version}, $tc->{best}, "... that matches our expected answer, $tc->{best}");
}


##################################
ok(!defined($peer->parser), 'Non-connected peers have no parser');
lives_ok sub {
  $peer->parser([sub { }]);
  },
  'Set parser ok';
ok(defined($peer->parser), '... correct, it has parser now');
lives_ok sub { $peer->clear_parser }, 'Clear parser ok';
ok(!defined($peer->parser), '... and the parser is gone again');

lives_ok sub { $peer->_on_connect_ok; $peer->clear_write_buffer },
  "Init'ed FakePeer ok";
ok(defined($peer->parser), 'Now we have a parser, after connect');


###################################
require Protocol::AMQP::V000009001;
my $start_ok = {
  client_properties => {
    product => 'Perl Protocol::AMQP::Client',
    version => '0.001',
    contact => 'http://search.cpan.org/dist/Protocol-AMQP',
  },
  mechanism => 'PLAIN',
  locale    => 'en-US',
  response  => "\0guest\0guest",
};

my $frame = $peer->send_method('connection_start_ok', $start_ok);
ok($frame, 'Got a frame length(' . length($frame) . ')');

lives_ok sub { $peer->_on_read(\$frame) }, '_on_read() was able to take it';
is($frame, '', '... and consume all the bytes in the network buffer');

cmp_deeply(
  $peer->last_method,
  { class_id   => 10,
    invocation => {
      client_properties => {
        contact => {S => "http://search.cpan.org/dist/Protocol-AMQP"},
        product => {S => "Perl Protocol::AMQP::Client"},
        version => {S => "0.001"},
      },
      locale    => "en-US",
      mechanism => "PLAIN",
      response  => "\0guest\0guest",
    },
    meta      => ignore(),
    method_id => 11,
    name      => "connection_start_ok",
  },
  '... and the parsed method is the expected one'
);


###################################
my ($channel1, $channel2);
lives_ok sub { $channel1 = $peer->open_channel }, 'Created a channel';
isa_ok($channel1, 'Protocol::AMQP::Channel',
  'Got a valid channel with id ' . $channel1->channel);

lives_ok sub { $channel2 = $peer->open_channel }, 'Created another channel';
isa_ok($channel2, 'Protocol::AMQP::Channel',
  'Got a valid channel with id ' . $channel2->channel);

isnt($channel1->channel, $channel2->channel, 'IDs are different');

my $channel1_id = $channel1->channel;
lives_ok sub { $peer->close_channel($channel1) }, 'Closed first channel ok';
lives_ok sub { $channel1 = $peer->open_channel },
  'Created yet another channel';
isa_ok($channel1, 'Protocol::AMQP::Channel',
  'Got a valid channel with id ' . $channel1->channel);
is($channel1->channel, $channel1_id, 'ID was reused from closed channel');

throws_ok sub { $peer->open_channel($channel1->channel) },
  qr{Channel ID \d+ already taken, },
  'Fail attempt to open a channel with an open channel_id';

my $closed;
lives_ok sub { $closed = $peer->close_channel($channel1) },
  'Closed first channel ok';
ok($closed, '... returns true');
is($closed->channel, $channel1->channel,
  '... and the expected closed channel');

lives_ok sub { $closed = $peer->close_channel($channel2->channel) },
  'Closed second channel by ID ok';
ok($closed, '... returns true');
is($closed->channel, $channel2->channel,
  '... and the expected closed channel');

lives_ok sub { $closed = $peer->close_channel($channel2->channel) },
  'Closing an already closed channel does nothing';
ok(!defined($closed), '... returns false');


done_testing();
