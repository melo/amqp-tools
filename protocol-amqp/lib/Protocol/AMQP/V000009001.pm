package Protocol::AMQP::V000009001;

use Moose;
extends 'Protocol::AMQP::API::Version';

## My version registration
use Protocol::AMQP::Registry;

Protocol::AMQP::Registry->register_version(
  { major    => '0',
    minor    => '9',
    revision => '1',

    api => 'Protocol::AMQP::V000009001',
  }
);


## My API classes
use Protocol::AMQP::V000009001::Connection;

has connection => (
  isa        => 'Protocol::AMQP::V000009001::Connection',
  is         => 'ro',
  lazy_build => 1,
);

sub _build_connection {
  return Protocol::AMQP::V000009001::Connection->new({peer => $_[0]->peer});
}


1;
