package Protocol::AMQP::Registry;

use strict;
use warnings;
use Carp qw( confess );

##################################

sub register_frame_type { shift; _register('frames', @_) }
sub fetch_frame_type { shift; _fetch('frames', @_) }

sub register_method {
  shift;
  _register('meths', ["$_[0]-$_[1]", $_[2][0]], $_[2]);
}
sub fetch_method { shift; _fetch('meths', join('-', @_)) }

sub register_version {
  my ($class, $spec) = @_;;
  
  for my $attr (qw( major minor revision api )) {
    confess("Missing required attr '$attr' in version registration, ")
      unless defined $spec->{$attr};
  }
  my $version = join('.', @{$spec}{qw(major minor revision)});
  $spec->{version} = $version;
  
  _register('version', $version, $spec);
}
sub fetch_version { shift; _fetch('version', @_) }


##################################

my %registry;

sub _register {
  my ($type, $ids, $value) = @_;
  my ($file, $line) = (caller(1))[1, 2];
  $ids = [$ids] unless ref($ids) eq 'ARRAY';

  for my $id (@$ids) {
    if (my $prev = $registry{$type}{$id}) {
      confess("FATAL: double registration for $type $id at $file "
          . "line $line (previous was at $prev->{file} line $prev->{line})");
    }
  }

  for my $id (@$ids) {
    $registry{$type}{$id} = {
      type  => $type,
      id    => $id,
      value => $value,
      file  => $file,
      line  => $line,
    };
  }
}

sub _fetch {
  my ($type, $id) = @_;

  return unless $type;

  return unless exists $registry{$type};
  my $cr = $registry{$type};

  return $cr unless defined $id;
  return unless exists $cr->{$id};

  return $cr->{$id}{value};
}

1;
