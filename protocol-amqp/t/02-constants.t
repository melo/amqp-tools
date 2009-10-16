#!perl

use strict;
use warnings;
use Test::More;

use Protocol::AMQP::Constants qw( :frame );

is(AMQP_FRAME_METHOD, 1);
is(AMQP_FRAME_HEADER, 2);
is(AMQP_FRAME_BODY, 3);
is(AMQP_FRAME_HEARTBEAT, 4);

done_testing();