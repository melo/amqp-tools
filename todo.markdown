Basic TODO list
===============

 * Peer's on_connect_cb call must include the ngotiated API object;
 * add on_method callback to peer and make Client implement the initial
   negotiation
 * add support for channels: probably mode send_method() from Peer to a
   Role, and compose that into Peer and Channel;

 * create script to generate the Vddddddddd classes and its friends;

 * EOF handling should be inside P::A::Client: network implementations
   don't have enough information to do a good job;

 * support split_by_spaces as a {pack,unpack}_method fix;
