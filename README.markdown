AMQP stack for Perl
===================

This repo contains an implementation of the AMQP protocol for Perl.

The following distributions are available:

 * Parse::AMQP::ProtocolDefinitions: parses the AMQP XML-based protocol definitions;
 * Protocol::AMQP: implements all the AMQP protocol logic;
 * AnyEvent::AMQP: implements all the network code using the AnyEvent stack.


**NOTE WELL**: We are using Moose because it makes developing faster. After we have a stable codebase, we will start doing performance testing. *If* Moose turns out to be a bottleneck, we will remove it.

So don't make assumptions that this stack will be Moose-powered forever.


Protocol::AMQP
==============

This class is splitted into several smaller components:

 * Protocol::AMQP::Peer: represents a socket connection to a AMQP peer; handles all the low level network reading and writting, and watches over the socket health;

  .... More to come ....

Testing
=======

During development, we are using OpenAMQ broker. Before our first release, I hope to have this code tested on
other brokers, most notably RabbitMQ.

OpenAMQ is 0.9.1 compliant, and so that is the version that I'm currently testing with. RabbitMQ uses 0.8.


Author
======

Pedro Melo <melo@simplicidade.org>


Copyright & License
===================

Copyright 2009, 2010 Pedro Melo

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
