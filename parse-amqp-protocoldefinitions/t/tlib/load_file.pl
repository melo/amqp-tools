#!perl

use strict;
use warnings;
use Parse::AMQP::ProtocolDefinitions;

plan skip_all => 'You need ENV AMQP_PROTO_DEFS_FILE'
  unless $ENV{AMQP_PROTO_DEFS_FILE};

sub load_file {
  return Parse::AMQP::ProtocolDefinitions->load($ENV{AMQP_PROTO_DEFS_FILE})
}

1;
