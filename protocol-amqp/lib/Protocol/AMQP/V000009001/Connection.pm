package Protocol::AMQP::V000009001::Connection;

use strict;
use warnings;

use Protocol::AMQP::Registry;
use Protocol::AMQP::Util qw( pack_table unpack_table );

## Connection.Start
Protocol::AMQP::Registry->register_method(
  10, 10, [
    'connection_start',
    [qw(version_major version_minor server_properties mechanisms locales)],
    'C C N/a N/a N/a',
    ['server_properties', \&unpack_table, \&pack_table],
  ],
);

1;
