#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Deep;
use Test::Exception;

use FakePeer;    ## has write() buffering
my $peer = FakePeer->new;

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


##################################
my $v;
lives_ok sub { $v = $peer->_pick_best_protocol_version };
ok(!defined $v, 'No versions registered, so no "best version" available');


my @test_cases = (
  { best => '0.9.2',
    spec => {
      major    => '0',
      minor    => '9',
      revision => '2',
      api      => 'Protocol::AMQP::V000009002',
    },
  },

  { best => '0.9.2',
    spec => {
      major    => '0',
      minor    => '9',
      revision => '0',
      api      => 'Protocol::AMQP::V000009000',
    },
  },

  { best => '0.10.0',
    spec => {
      major    => '0',
      minor    => '10',
      revision => '0',
      api      => 'Protocol::AMQP::V000010001',
    },
  },
);

for my $tc (@test_cases) {
  my $spec = $tc->{spec};

  lives_ok sub { Protocol::AMQP::Registry->register_version($spec) },
    'Register version $spec->{spec}{api} ok';
  lives_ok sub { $v = $peer->_pick_best_protocol_version },
    '_pick_best_protocol_version() lived through it';
  ok(defined $v, '... and gaves us a defined answer');
  is($v->{version}, $tc->{best}, '... that matches our expected answer');
}


###################################
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

require Protocol::AMQP::V000009001;
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


done_testing();
