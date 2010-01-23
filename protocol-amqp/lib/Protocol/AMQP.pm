package Protocol::AMQP;

1;

=encoding utf8

=head NAME

Protocol::AMQP - Implementation of the AMQP protocol, without the
network parts


=head1 STATUS

The code is under active development, no stable versions where
released yet.

APIs are stil subject to changes.


=head1 SYNOPSIS

    ## Protocol::AMQP is not to be used directly
    ## Checkout AnyEvent::AMQP, and (future) Net::AMQP2


=head1 DESCRIPTION

The L<Protocol::AMQP> classes are an abstract implementation of the AMQP
protocol stack.

All the protocol negotiation, framing, and method dispatching logic is
implemented inside, but we don't provide a networking core.

This allows you to write several implementations, some using
asynchronous modules like L<AnyEvent|AnyEvent>, L<POE|POE>, or even
L<Danga::Socket|Danga::Socket>, and others using more classical
synchronous methods.

In this document we will map all the classes under the
L<Protocol::AMQP|Protocol::AMQP> namespace and provide short
descriptions of what each one does, and how it should be used. Think
of this as a table of contents, from where you can jump to any
particular chapter.


=head1 HELPER CLASSES

There are three helper classes:
L<Protocol::AMQP::Registry|Protocol::AMQP::Registry>,
L<Protocol::AMQP::Util|Protocol::AMQP::Util> and
L<Protocol::AMQP::Constants|Protocol::AMQP::Constants>.


=head2 Protocol::AMQP::Registry

B<Status:> this class will probably go away before the 1.0 release. We
will probably move this funcionality to each peer instance, so that you
can have different peers with different protocol versions supported.

This class provides APIs to register the main three types of information
we deal with:

=over 4

=item protocol versions

L<Protocol::AMQP|Protocol::AMQP> supports several AMQP versions. Right
now we are working with 0.9.1, but we expect to ship with support for
0.8.0, 0.9.0, and 0.9.1.

We also plan on supporting 0.10.0 as soon as it is available.

To keep track of which versions we know about (each client must decide
which versions to use dynamically), and to provide protocol version
negotiation, the L<Protocol::AMQP::Registry|Protocol::AMQP::Registry>
provides an API to register loaded versions of the AMQP protocol.

=item frame types

The AMQP protocol is based on frames and there are several types of
frames (right now the protocol defines 4 types).

L<Protocol::AMQP::Registry|Protocol::AMQP::Registry> keeps track of the
known types.

=item methods

Metadata registry based on class_id/method_id and protocol version.

For each method we register all the information needed to pack and
unpack the method frame structure.

=back


=head2 Protocol::AMQP::Util

A small library of useful functions to pack/unpack methods and tables,
and tracing functions.


=head2 Protocol::AMQP::Constants

B<Status:> mostly likely to go away. We don't have that many constants
that need to be available from other classes.

A set of important constants for the AMQP protocol.


=head1 SEE ALSO

L<AnyEvent::AMQP|AnyEvent::AMQP>


=head1 AUTHOR

Pedro Melo, C<< <melo@simplicidade.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2010 Pedro Melo

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
