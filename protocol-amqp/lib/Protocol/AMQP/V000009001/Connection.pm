package Protocol::AMQP::V000009001::Connection;

use Moose;
use Protocol::AMQP::Registry;

extends 'Protocol::AMQP::API::Class';

## Connection.Start
Protocol::AMQP::Registry->register_method(
  10, 10,
  [ 10, 10, 'connection_start',
    [qw(version_major version_minor server_properties mechanisms locales)],
    'C C N/a N/a N/a',
    ['server_properties', 'table'],
    ['mechanisms',        'space_separated'],
    ['locales',           'space_separated'],
  ],
);

## Connection.Start_Ok
Protocol::AMQP::Registry->register_method(
  10, 11,
  [ 10, 11, 'connection_start_ok',
    [qw(client_properties mechanism response locale )],
    'N/a C/a N/a C/a',
    ['client_properties', 'table'],
  ],
);


##################################

sub start {
  return shift->{peer}->send_method('connection_start', @_);
}

sub start_ok {
  return shift->{peer}->send_method('connection_start_ok', @_);
}


1;
