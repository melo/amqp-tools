#!perl

use strict;
use warnings;
use Test::More;

use_ok('Protocol::AMQP::Constants');
use_ok('Protocol::AMQP::Util');

use_ok('Protocol::AMQP::Peer');

done_testing();