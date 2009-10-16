package Protocol::AMQP::Constants;

use strict;
use warnings;
use parent qw( Exporter );

sub AMQP_FRAME_METHOD ()    {1}
sub AMQP_FRAME_HEADER ()    {2}
sub AMQP_FRAME_BODY ()      {3}
sub AMQP_FRAME_HEARTBEAT () {4}

%Protocol::AMQP::Constants::EXPORT_TAGS = (
  frame => [
    qw(
      AMQP_FRAME_METHOD AMQP_FRAME_HEADER
      AMQP_FRAME_BODY AMQP_FRAME_HEARTBEAT
      )
  ],
);
@Protocol::AMQP::Constants::EXPORT_OK =
  ((map {@$_} values %Protocol::AMQP::Constants::EXPORT_TAGS));
$Protocol::AMQP::Constants::EXPORT_TAGS{all} =
  [@Protocol::AMQP::Constants::EXPORT_OK];

1;
