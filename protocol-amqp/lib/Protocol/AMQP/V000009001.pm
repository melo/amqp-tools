package Protocol::AMQP::V000009001;

use Moose;
use Protocol::AMQP::Registry;

use Protocol::AMQP::V000009001::Connection;


##################################

Protocol::AMQP::Registry->register_version(
  { major    => '0',
    minor    => '9',
    revision => '1',

    api => 'Protocol::AMQP::V000009001',
  },
);


1;
