#!perl

use strict;
use warnings;
use Parse::AMQP::ProtocolDefinitions;
use File::Spec::Functions qw( catfile );

Test::More::plan skip_all =>
  'You need ENV AMQP_PROTO_DEFS_DIR with the spec files'
  unless $ENV{AMQP_PROTO_DEFS_DIR};

sub load_specs {
  my @specs = (
    { name        => 'amqp-0.9.0',
      version     => '000009000',
      major       => '0',
      minor       => '9',
      t_constants => 29,
      t_domains   => 32,
      t_classes   => 12,
      filename    => 'amqp-0.9.xml',
    },
    { name        => 'amqp-0.9.1',
      version     => '000009001',
      major       => '0',
      minor       => '9',
      revision    => '1',
      t_constants => 24,
      t_domains   => 24,
      t_classes   => 6,
      filename    => 'amqp-0.9.1.xml',
    },
  );

  my $dir = $ENV{AMQP_PROTO_DEFS_DIR};
  foreach my $spec (@specs) {
    my $path = catfile($dir, $spec->{filename});
    next unless -r $path;

    $spec->{path} = $path;
  }

  return grep { $_->{path} && !$_->{skip} } @specs;
}

1;
