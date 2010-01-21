package Protocol::AMQP::Roles::SendMethod;

use Moose::Role;
use Protocol::AMQP::Util qw( pack_method trace );
use Protocol::AMQP::Constants qw( AMQP_FRAME_METHOD );

requires '_send_frame';

has 'channel' => (
  isa      => 'Int',
  is       => 'ro',
  default  => 0,
  required => 1,
);

sub send_method {
  my $self = shift;
  my $chan = $self->channel;
  
  trace('Sending method ', \@_, " on channel $chan");
  
  return $self->_send_frame(AMQP_FRAME_METHOD, $chan, pack_method(@_));
}

1;
