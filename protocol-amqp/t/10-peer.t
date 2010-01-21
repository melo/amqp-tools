#!perl

use strict;
use warnings;
use lib 't/tlib';
use Test::More;
use Test::Deep;
use Test::Exception;

use Protocol::AMQP::Constants qw( :frame );
use Protocol::AMQP::Util qw( pack_method );

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


done_testing();
