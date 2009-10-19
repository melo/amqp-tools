#!perl

use strict;
use warnings;
use Test::More;

use Protocol::AMQP::Registry;
use Protocol::AMQP::V000009001;

my $record = Protocol::AMQP::Registry->fetch_version('0.9.1');
ok($record);
is(ref($record), 'HASH');

is($record->{version}, '0.9.1');
is($record->{major}, '0');
is($record->{minor}, '9');
is($record->{revision}, '1');

done_testing();