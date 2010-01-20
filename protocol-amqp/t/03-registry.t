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


### register methods
lives_ok sub  { $c->register_method(1, 1, ['method_a', 1]) };
throws_ok sub { $c->register_method(1, 1, ['method_b', 1]) },
  qr/FATAL: double registration/;
throws_ok sub { $c->register_method(1, 2, ['method_a', 1]) },
  qr/FATAL: double registration/;
cmp_deeply($c->fetch_method(1, 1), ['method_a', 1]);
cmp_deeply($c->fetch_method('method_a'), ['method_a', 1]);
ok(!defined($c->fetch_method(1, 2)));


### register protocol version
lives_ok sub {
  $c->register_version({major => 0, minor => 9, revision => 1, api => 'API'});
};
cmp_deeply($c->fetch_version('0.9.1'),
  {major => 0, minor => 9, revision => 1, api => 'API', version => '0.9.1'});
ok(!defined($c->fetch_version('0.10.0')));

cmp_deeply(
  $c->fetch_version,
  { '0.9.1' => {
      file => "t/03-registry.t",
      id   => "0.9.1",
      line  => 66,       ## you change lines above me, and this will change...
      type  => "version",
      value => {
        major    => 0,
        minor    => 9,
        revision => 1,
        api      => 'API',
        version  => '0.9.1'
      },
    }
  }
);

my @fail_cases = (
  { spec   => {},
    throws => qr/Missing required attr 'major' in version registration, /,
  },
  { spec => {major => 0},
    throws => qr/Missing required attr 'minor' in version registration, /,
  },
  { spec => {major => 0, minor => 9},
    throws => qr/Missing required attr 'revision' in version registration, /,
  },
  { spec => {major => 0, minor => 9, revision => 1},
    throws => qr/Missing required attr 'api' in version registration, /,
  },
  { spec => {major => 0, minor => 9, revision => 1, api => 'API2'},
    throws => qr/FATAL: double registration for version 0.9.1/,
  },
);

for my $tc (@fail_cases) {
  throws_ok sub { $c->register_version($tc->{spec}) }, $tc->{throws};
}

done_testing();
