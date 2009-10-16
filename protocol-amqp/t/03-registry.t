#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;

use Protocol::AMQP::Registry;
my $c = 'Protocol::AMQP::Registry';

### generic interface
ok(!defined($c->_fetch));
ok(!defined($c->_fetch('my-class')));
ok(!defined($c->_fetch('my-class', 'id')));

lives_ok sub {
  $c->_register('my-class', 'id', {aa => 11});
};

throws_ok sub {
  $c->_register('my-class', 'id', {bb => 11});
}, qr/FATAL: double registration for /;

my $v = $c->_fetch('my-class', 'id');
cmp_deeply($v, {aa => 11});

my $r = $c->_fetch('my-class');
$v = delete $r->{id}{file};
ok($v);
like($v, qr{t/03-registry[.]t$});

cmp_deeply(
  $r,
  { id => {
      id => 'id',
      type => 'my-class',
      value => {aa => 11},
      line  => 19,
    }
  }
);

done_testing();
