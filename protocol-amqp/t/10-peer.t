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



##################################
my $v;
lives_ok sub { $v = $peer->_pick_best_protocol_version };
ok(!defined $v);


my @test_cases = (
  { best => '0.9.1',
    spec => {
      major    => '0',
      minor    => '9',
      revision => '1',
      api      => 'Protocol::AMQP::V000009001',
    },
  },

  { best => '0.9.1',
    spec => {
      major    => '0',
      minor    => '9',
      revision => '0',
      api      => 'Protocol::AMQP::V000009001',
    },
  },

  { best => '0.10.0',
    spec => {
      major    => '0',
      minor    => '10',
      revision => '0',
      api      => 'Protocol::AMQP::V000009001',
    },
  },
);

for my $tc (@test_cases) {
  my $spec = $tc->{spec};

  lives_ok sub { Protocol::AMQP::Registry->register_version($spec) };
  lives_ok sub { $v = $peer->_pick_best_protocol_version };
  ok(defined $v);
  is($v->{version}, $tc->{best});
}

done_testing();
