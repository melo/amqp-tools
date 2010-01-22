package Protocol::AMQP::Client;
our $VERSION = '0.001';

use Moose;
extends 'Protocol::AMQP::Peer';

##################################

sub handle_method {
  my ($self, $meth) = @_;
  my $api  = $self->api;
  my $name = $meth->{name};
  my $data = $meth->{invocation};

  if ($name eq 'connection_start') {
    $api->connection->start_ok(
      { client_properties => {
          product => __PACKAGE__,
          version => $VERSION,
          contact => 'http://search.cpan.org/dist/Protocol-AMQP',
        },
        mechanism => 'PLAIN',
        locale    => 'en-US',
        response  => "\0guest\0guest",
      }
    );
  }
  elsif ($name eq 'connection_tune') {
    $api->connection->tune_ok(
      { channel_max => $data->{channel_max},
        frame_max   => $data->{frame_max},
        heartbeat   => $data->{heartbeat},
      }
    );

    $self->user_on_connect_cb();
  }
}


1;
