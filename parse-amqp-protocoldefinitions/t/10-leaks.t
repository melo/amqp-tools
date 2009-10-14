#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::LeakTrace;

require 't/tlib/load_file.pl';

no_leaks_ok {
  my $pd = load_file()
} 'no memory leaks detected';

note('And we are done');
done_testing();
