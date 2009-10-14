#!perl

use strict;
use warnings;
use Test::More;

use_ok('Parse::AMQP::ProtocolDefinitions::Assert');
use_ok('Parse::AMQP::ProtocolDefinitions::Chassis');
use_ok('Parse::AMQP::ProtocolDefinitions::Method');
use_ok('Parse::AMQP::ProtocolDefinitions::Rule');
use_ok('Parse::AMQP::ProtocolDefinitions::Class');
use_ok('Parse::AMQP::ProtocolDefinitions::Constant');
use_ok('Parse::AMQP::ProtocolDefinitions::Domain');
use_ok('Parse::AMQP::ProtocolDefinitions');

done_testing();