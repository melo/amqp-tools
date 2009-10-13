#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

require 't/tlib/load_file.pl';
my $pd; lives_ok sub { $pd = load_file() };

is($pd->major,    0);
is($pd->minor,    9);
is($pd->revision, 1);
is($pd->port,     5672);

done_testing();
