#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Exception;

use Protocol::AMQP::V000009001;
use Protocol::AMQP::Util qw(
  pack_table unpack_table
  pack_method unpack_method
  trace
);


##################################

## place trace call here, so that line number don't change after each file modification
my $trace_call = sub {
  my $buffer;
  trace(\$buffer, @_);
  return $buffer;
};

my $small_buf = 'a' x 20;
my $big_buf   = 'A' x 60;

my @trace_test_cases = (
  'basic' => {
    input  => ['olas'],
    output => "# [Test::Exception::lives_ok:50] olas\n",
  },

  complex => {
    input  => ['good good', {a => 1}, ' and ', \$small_buf],
    output => qq{# [Test::Exception::lives_ok:50] good good{ a => 1 } and \\"aaaaaaaaaaaaaaaaaaaa" (len 20)\n},
  },

  big => {
    input  => ['oh my, so... ', \$big_buf],
    output => qq{# [Test::Exception::lives_ok:50] oh my, so... \\"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA..." (len 60)\n},
  },
);

while (@trace_test_cases) {
  my ($name, $spec) = splice(@trace_test_cases, 0, 2);
  my $buffer;
  
  lives_ok sub { trace(\$buffer, @{$spec->{input}}) };
  is($buffer, $spec->{output});
}

my $hashref = {a => 1};
my $buffer;
lives_ok sub { trace(\$buffer, $hashref) },
  'trace() will not die while testing for argument respect';
is(ref($hashref), 'HASH', '... and afterwards, our $hashref is still a HASH');
cmp_deeply($hashref, {a => 1}, '... and with the proper content');


##################################

my @tables = (
  "simple" => {
    buf      => "\3abcI\0\0\0\1",
    expected => {abc => {'I', 1}},
  },

  "server_properties_OpenAMQ" => {
    buf =>
      "\4hostS\0\0\0\r0.0.0.0:5672\0\aproductS\0\0\0\17OpenAMQ Server\0\aversionS\0\0\0\x061.3d0\0\tcopyrightS\0\0\0+Copyright (c) 2007-2009 iMatix Corporation\0\bplatformS\0\0\0\5UNIX\0\13informationS\0\0\0\23Production release\0\2idS\0\0\0\x040-4\0\6directI\0\0\0\0",
    expected => {
      copyright   => {S => "Copyright (c) 2007-2009 iMatix Corporation\0"},
      direct      => {I => 0},
      host        => {S => "0.0.0.0:5672\0"},
      id          => {S => "0-4\0"},
      information => {S => "Production release\0"},
      platform    => {S => "UNIX\0"},
      product     => {S => "OpenAMQ Server\0"},
      version     => {S => "1.3d0\0"},
    },
  },
);

while (@tables) {
  my ($name, $spec) = splice(@tables, 0, 2);
  my ($buf, $expected) = ($spec->{buf}, $spec->{expected});

  my $result;
  lives_ok sub { $result = unpack_table($buf) };
  cmp_deeply($result, $expected);

  my $packed;
  lives_ok sub { $packed = pack_table($result) };
  lives_ok sub { $result = unpack_table($packed) };

  cmp_deeply($result, $expected);
}


##################################

my %meth = (
  version_major     => 0,
  version_minor     => 9,
  server_properties => {
    hi   => {s => 'mom'},
    cool => {S => 'dad'},
    nice => {I => 32},
  },
  mechanisms => ['PLAIN'],
  locales    => [qw(en-US pt-PT pt-BR)],
);

## pack Connection.Start
for my $spec ([10, 10], ['connection_start']) {
  my $buf = pack_method(@$spec, \%meth);
  ok($buf, "Properly packed method @$spec");
  my $res = unpack_method(@$spec, $buf);
  ok($res, "... and unpacked it ok");

  cmp_deeply(\%meth, $res->{invocation}, 'Method invocation as expected');
  is($res->{class_id},  10,      'class_id with the proper value');
  is($res->{method_id}, 10,      'method_id with the proper value');
  is($res->{name}, 'connection_start', 'name with the expected value');

  is(ref($res->{meta}), 'ARRAY', 'the meta attribute is an ARRAY');
  is($res->{meta}[0], $res->{class_id},
    '... first element is the class_id');
  is($res->{meta}[1], $res->{method_id},
    '... second element is the method_id');
  is($res->{meta}[2], $res->{name},
    '... and its third element is the method name');
}


done_testing();
