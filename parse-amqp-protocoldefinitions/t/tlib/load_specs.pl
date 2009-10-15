#!perl

use strict;
use warnings;
use Parse::AMQP::ProtocolDefinitions;
use File::Spec::Functions qw( catfile );

Test::More::plan skip_all => 'You need ENV AMQP_PROTO_DEFS_DIR with the spec files'
  unless $ENV{AMQP_PROTO_DEFS_DIR};

sub load_specs {
  my @specs = (
    {
      name  => 'amqp-0.9.1',
      major => '0',
      minor => '9',
      revision => '1',
      filename => 'amqp-0.9.1.xml',
    },
  );
  
  my $dir = $ENV{AMQP_PROTO_DEFS_DIR};
  foreach my $spec (@specs) {
    my $path = catfile($dir, $spec->{filename});
    next unless -r $path;
    
    $spec->{path} = $path;
  }
  
  return grep { $_->{path} && ! $_->{skip} } @specs;
}

1;
