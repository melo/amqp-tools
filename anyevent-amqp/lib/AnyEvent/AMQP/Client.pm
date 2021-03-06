package AnyEvent::AMQP::Client;

use Moose;
use AnyEvent::AMQP::Impl::Client;

use Protocol::AMQP::V000009001;

extends 'Protocol::AMQP::API::Client';

has '+impl_class' => (
  default => 'AnyEvent::AMQP::Impl::Client',
);

1;
