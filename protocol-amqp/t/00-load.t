#!perl

use strict;
use warnings;
use Test::More;

use_ok('Protocol::AMQP::Registry');
use_ok('Protocol::AMQP::Constants');
use_ok('Protocol::AMQP::Util');

use_ok('Protocol::AMQP::Peer');

use_ok('Protocol::AMQP::Client');

done_testing();