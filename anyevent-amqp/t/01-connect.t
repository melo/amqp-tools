#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;

use AnyEvent;
use AnyEvent::AMQP::Impl::Client;

my $cv = AE::cv();

## Assume localhost connection, default port
my $cln;
lives_ok sub {
  $cln = AnyEvent::AMQP::Impl::Client->new(
    on_connect    => sub { $_[0]->close },
    on_disconnect => sub { $cv->send('done') }
  );
};
$cln->connect;

is($cv->recv, 'done');

done_testing();
