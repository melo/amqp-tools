#!perl

use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Exception;

use Protocol::AMQP::Util qw( pack_table unpack_table );

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


done_testing();
