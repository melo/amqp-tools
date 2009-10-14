package Parse::AMQP::ProtocolDefinitions::Assert;

use Moose;
use Moose::Util::TypeConstraints;

with
  'Parse::AMQP::ProtocolDefinitions::Roles::Parse',
  'Parse::AMQP::ProtocolDefinitions::Roles::ParseSequence',
  'Parse::AMQP::ProtocolDefinitions::Roles::HasValidAttrs';

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

no Moose;
no Moose::Util::TypeConstraints;

__PACKAGE__->meta->make_immutable;


##############################

sub xpath_expr  {'assert'}
sub valid_attrs {qw(check value method field)}

##############################


1;
