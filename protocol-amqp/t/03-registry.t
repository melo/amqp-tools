#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;

use Protocol::AMQP::Registry;
my $c = 'Protocol::AMQP::Registry';

### generic interface
ok(!defined(Protocol::AMQP::Registry::_fetch));
ok(!defined(Protocol::AMQP::Registry::_fetch('my-class')));
ok(!defined(Protocol::AMQP::Registry::_fetch('my-class', 'id')));

lives_ok sub {
  Protocol::AMQP::Registry::_register('my-class', 'id', {aa => 11});
};

throws_ok sub {
  Protocol::AMQP::Registry::_register('my-class', 'id', {bb => 11});
}, qr/FATAL: double registration for /;

my $v = Protocol::AMQP::Registry::_fetch('my-class', 'id');
cmp_deeply($v, {aa => 11});

my $r = Protocol::AMQP::Registry::_fetch('my-class');
$v = delete $r->{id}{file};
ok($v);
like($v, qr{t/03-registry[.]t$});

cmp_deeply(
  $r,
  { id => {
      id    => 'id',
      type  => 'my-class',
      value => {aa => 11},
      line  => 19,
    }
  }
);

### register frames
lives_ok sub  { $c->register_frame_type(1 => ['aa']) };
throws_ok sub { $c->register_frame_type(1 => ['bb']) },
  qr/FATAL: double registration/;
cmp_deeply($c->fetch_frame_type(1), ['aa']);
ok(!defined($c->fetch_frame_type(2)));


done_testing();
