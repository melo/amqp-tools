package Protocol::AMQP::API::Class;

use Moose;

has peer => (
  isa      => 'Protocol::AMQP::Peer',
  is       => 'ro',
  weak_ref => 1,
  required => 1,
);

1;
