package NOCpulse::Utils::test::TestModule;

use strict;
use NOCpulse::Object;
use NOCpulse::Module;
use NOCpulse::PlugFrame::Probe;

use base qw(Test::Unit::TestCase);

NOCpulse::Object::SystemIni('/etc/nocpulse/PlugFrame.ini');
my $libDir = NOCpulse::Object::ConfigValue('Plugin', 'probeClassLibraryDirectory');

sub set_up {
   my $self = shift;
   $self->assert(defined($libDir), "Can't get lib dir from PlugFrame.ini");
}

sub test_basic {
   my $self = shift;
   $self->assert(Module::isLoaded("NOCpulse::PlugFrame::Probe"), "Can't find package Probe");
   $self->assert(!Module::isLoaded("NOCpulse::PlugFrame::FOO"), "Can find package Probe");
}

sub test_object {
   my $self = shift;
   my ($status, $errors) = Module::load("Object", undef, ['Elsewhere', 'NOCpulse']);
   $self->assert($status, "Cannot load Object with fallback list: ".join(' ', @$errors));
}

sub test_plugins {
   my $self = shift;
   my ($status, $errors) = Module::load("MySQL", $libDir);
   $self->assert($status, "Can't load MySQL using $libDir: ".join(' ', @$errors));

   ($status, $errors) = Module::load("MySQL", [$libDir]);
   $self->assert($status, "Can't load MySQL with libDir list: ".join(' ', @$errors));

   ($status, $errors) = Module::load("FOO", $libDir);
   $self->assert(! $status, "Can load FOO: ".join(' ', @$errors));
}

sub test_fallback {
   my $self = shift;
   my ($status, $errors) = Module::load("LocalCommandShell", $libDir);
   $self->assert(! $status, "Can load LocalCommandShell with no fallback: ".join(' ', @$errors));

   ($status, $errors) = Module::load("LocalCommandShell", $libDir, 'NOCpulse');
   $self->assert($status, "Cannot load LocalCommandShell with fallback: ".join(' ', @$errors));

   ($status, $errors) = Module::load("LocalCommandShell", $libDir, 'NOCpulse');
   $self->assert($status, "Cannot load already loaded LocalCommandShell: ".join(' ', @$errors));
}

1;
