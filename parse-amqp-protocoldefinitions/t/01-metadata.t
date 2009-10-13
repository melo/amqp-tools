#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Parse::AMQP::ProtocolDefinitions;

plan skip_all => 'You need ENV AMQP_PROTO_DEFS_FILE'
  unless $ENV{AMQP_PROTO_DEFS_FILE};

my $pd;
lives_ok sub {
  $pd = Parse::AMQP::ProtocolDefinitions->parse($ENV{AMQP_PROTO_DEFS_FILE});
};

is($pd->major,    0);
is($pd->minor,    9);
is($pd->revision, 1);
is($pd->port,     5672);

done_testing();
