package Parse::AMQP::ProtocolDefinitions::Assert;

use Moose;
use Moose::Util::TypeConstraints;


extends 'Parse::AMQP::ProtocolDefinitions::Base';

enum 'AssertCheck', qw( notnull length regexp le ne );

has check => (
  isa => 'AssertCheck',
  is  => 'rw',  
);

## For 'length' and 'regexp', value
has value => (
  isa => 'Str',
  is  => 'rw',  
);

## For 'le', method and field
has method => (
  isa => 'Str',
  is  => 'rw',  
);

has field => (
  isa => 'Str',
  is  => 'rw',
);

with 'Parse::AMQP::ProtocolDefinitions::Roles::Parse';
with
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseSequence',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs';

no Moose;
no Moose::Util::TypeConstraints;

__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'assert'}
sub valid_attrs {qw(check value method field)}

##############################


1;
