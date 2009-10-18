package AnyEvent::AMQP::Impl::Client;

use Moose;
use Protocol::AMQP::Util qw( trace );
use AnyEvent::Handle;

extends 'Protocol::AMQP::Client';

has hdl => (
  isa => 'AnyEvent::Handle',
  is  => 'rw',
);


##################################

sub connect {
  my ($self) = @_;

  trace("Start connect to ", $self->remote_addr, ' port ',
    $self->remote_port);

  my $hdl = AnyEvent::Handle->new(
    connect => [$self->remote_addr, $self->remote_port],

    on_connect => sub { $self->_on_connect_ok() },
    on_read    => sub { $self->_on_read(\($_[0]->{rbuf})) },
    ## TODO: revisit this, it should be handled at the protocol level
    # if we receive an eof it means that we will not read anything else,
    # but it does not mean that we can't still write. The proper
    # solution is to pass this notification to the upper protocol layer,
    # and let it decide if we must signal an error, or just a cleanup
    on_eof     => sub { $self->error('eof') },
    on_error   => sub { $self->error($_[2]) },
  );

  $self->hdl($hdl);
  return;
}

sub write {
  trace('writing ', \$_[1]);
  $_[0]->{hdl}->push_write($_[1]);
}

sub close {
  trace('start sock shutdown');
  $_[0]->{hdl}->push_shutdown;
}

##################################

after cleanup => sub {
  trace('cleanup old connection');

  my $hdl = delete $_[0]{hdl};
  $hdl->destroy;
  return;
};

1;
