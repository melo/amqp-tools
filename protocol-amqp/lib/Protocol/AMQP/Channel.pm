package Protocol::AMQP::Channel;

use Moose;

has 'peer' => (
  isa      => 'Protocol::AMQP::Peer',
  is       => 'ro',
  required => 1,
  handles  => [qw(_send_frame)],
);

with 'Protocol::AMQP::Roles::SendMethod';

1;
