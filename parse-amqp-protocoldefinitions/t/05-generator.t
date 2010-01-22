#!perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use File::Temp qw( tempdir );
use Path::Class qw( dir );

require 't/tlib/load_specs.pl';
my @specs = load_specs('000009001');
plan skip_all => 'No active specs found in $ENV{AMQP_PROTO_DEFS_DIR}'
  unless @specs;

my $amqp;
lives_ok
  sub { $amqp = Parse::AMQP::ProtocolDefinitions->load($specs[0]{path}) };

is($amqp->package_basename, 'V000009001',
  'Proper basename for version 0.9.1');
is($amqp->package_filename, 'V000009001.pm',
  'Proper filename for version 0.9.1');
is($amqp->package('xpto'),
  'xpto::V000009001', 'Proper package with xpto prefix for version 0.9.1');


my $class_pm;
lives_ok sub { $class_pm = $amqp->build_version_class('xpto') },
  'Generated version class file ok';
test_version_file_content($class_pm);

my $tmpdir = dir(tempdir(CLEANUP => 1));
lives_ok sub { $amqp->generate('xpto', $tmpdir) },
  'Wrote version package file to disk';
$class_pm = $tmpdir->file($amqp->package_filename)->slurp;
test_version_file_content($class_pm);


for my $class (values %{$amqp->classes}) {
  lives_ok sub { $class_pm = $class->build_class_class('xpto') },
    'Generated class class file ok';
  test_class_file_content($class, $class_pm);

  lives_ok sub { $class->generate('xpto', $tmpdir) },
    'Wrote class package file to disk';
  $class_pm = $tmpdir->file($class->package_filename)->slurp;
  test_class_file_content($class, $class_pm);
}


done_testing();


###################################
sub test_version_file_content {
  my ($class_pm) = @_;

  like($class_pm, qr/^package xpto::V000009001/m, '... package name ok');
  like(
    $class_pm,
    qr/^extends 'Protocol::AMQP::API::Version';/m,
    '... extends the proper class'
  );
  like(
    $class_pm,
    qr/^Protocol::AMQP::Registry->register_version/m,
    '... calls the registry method'
  );
  like(
    $class_pm,
    qr/^\s+api => 'xpto::V000009001',/m,
    '... registers the proper version'
  );

  for my $class (qw(connection channel exchange queue basic tx)) {
    my $package = 'xpto::V000009001::' . ucfirst($class);
    like(
      $class_pm,
      qr/^use $package;/m,
      '... Make sure we load the proper class class'
    );
    like(
      $class_pm,
      qr/^has '$class' => \(/m,
      '...... slot created with class name'
    );
    like(
      $class_pm,
      qr/^\s*isa\s*=> '$package',/m,
      '...... slot with proper type constraint'
    );
    like(
      $class_pm,
      qr/^sub _build_$class \{/m,
      "...... builder sub found for class $class"
    );
    like(
      $class_pm,
      qr/^\s+return ${package}->new/m,
      "...... found class instance constructor call"
    );
  }
}

sub test_class_file_content {
  my ($class, $class_pm) = @_;
  my $package = $class->package('xpto');

  like($class_pm, qr/^package $package;/m, "Test package $package");
  like(
    $class_pm,
    qr/^use Protocol::AMQP::Registry;/m,
    "... make sure we use our registry class"
  );
  like(
    $class_pm,
    qr/^extends 'Protocol::AMQP::API::Class';/m,
    '... extends the proper class'
  );
}
