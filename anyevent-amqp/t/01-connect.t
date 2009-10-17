#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Devel::LeakGuard::Object qw( leakguard );

use AnyEvent;
use AnyEvent::AMQP::Impl::Client;

## Assume localhost connection, default port
my $result;
leakguard {
  my $cv = AE::cv();
  
  my $cln = AnyEvent::AMQP::Impl::Client->new(
    on_connect    => sub { $_[0]->close },
    on_disconnect => sub { $cv->send('done') }
  );

  $cln->connect;
  $result = $cv->recv;
} on_leak => 'die';

is $result, 'done', 'expected result';

done_testing();
