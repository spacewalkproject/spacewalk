#!/usr/bin/perl

# Runs all the tests found under given a directory or directories
# whose filename matches the pattern "test/Test*.pm".

use strict;

use Getopt::Long;
use File::Find;
use File::Basename;

use NOCpulse::Utils::TestRunner;
use NOCpulse::Log::LogManager;

use base qw(Test::Unit::TestCase);

my @test_packages = ();

my $usage_msg = "Usage: $0 [--help] [--log <pkg=level>] dir_or_file [, dir_or_file...]\n";

sub usage {
   print STDERR @_, "\n";
   print STDERR $usage_msg;
   exit 1;
}

sub help {
   print STDERR "\n", $usage_msg;
   print STDERR "
Runs unit tests. You can run all tests in a directory,
or one test at a time. \@INC is used to find modules.

Examples:
  # Run all tests in /usr/lib/perl5/site_perl/5.005/NOCpulse/
  # This is the default.
  % $0 NOCpulse

  # Run all tests in /usr/lib/perl5/site_perl/5.005/NOCpulse/Probe
  % $0 NOCpulse/Probe

  # Run a single test
  % $0 NOCpulse/Probe/Shell/test/TestShell.pm  

  # Run a single test in a fully-qualified directory
  % $0 /usr/lib/perl5/site_perl/5.005/NOCpulse/test/TestMyStuff.pm  
\n";
   exit 1;
}

@ARGV = ('NOCpulse') unless scalar(@ARGV);

my %args = ();
GetOptions(\%args, ('help', 'log=s%')) or die;

if ($args{help}) {
    help();
}

NOCpulse::Log::LogManager->instance->configure(%{$args{log}});

foreach my $dir_or_file (@ARGV) {
   my $relative_path = ($dir_or_file !~ /^[.\/]/);
   my $is_pm = $dir_or_file =~ /\.pm$/;
   my $dir;
   my $file;
   if ($is_pm) {
      $dir = dirname($dir_or_file);
      $file = basename($dir_or_file);
   } else {
      $dir = $dir_or_file;
   }

   if ($relative_path) {
      foreach my $inc (@INC) {
	 my $fullpath = "$inc/$dir";
	 if (-d "$fullpath") {
	    $dir = $fullpath;
	    last;
	 }
      }
   }

   if (-d $dir) {
       unless ($relative_path) {
           push(@INC, $dir);
       }
   } else {
       if ($relative_path) {
           usage "Cannot find directory $dir in ", join(', ', @INC);
       } else {
           usage "Cannot find directory $dir";
       }
   }
   if ($is_pm) {
       my $pkg = get_package("$dir/$file") or die "Cannot find $dir/$file";
       push (@test_packages, $pkg);
   } else {
       find(sub { my $pkg = get_package(); push (@test_packages, $pkg) if ($pkg); }, $dir);
   }
}

my $suite = Test::Unit::TestSuite->empty_new('All tests');

my $testrunner = NOCpulse::Utils::TestRunner->new();
foreach my $test (sort @test_packages) {
    $suite->add_test(NOCpulse::Utils::NoisyTestSuite->new($test));
}
eval {
    $testrunner->do_run($suite, 0);
};
print STDERR $@ if ($@);

# Returns the package name for a file if it looks like a test module.
sub get_package {
    my $filename = shift;

    my $specific_file = defined $filename;

    $filename ||= $File::Find::name;

    if ($specific_file || $filename =~ /test\/Test.*\.pm$/) {
        # File::Find cd's to each directory, so use the basename if necessary.
        $filename = $specific_file ? $filename : basename($filename);
        open FILE, "< $filename" or die "Cannot open $filename: $!";
        while (<FILE>) {
            if (/^package ([^;]*);/) {
                return $1;
            }
        }
    }
}

package NOCpulse::Utils::NoisyTestSuite;

use strict;

use base qw(Test::Unit::TestSuite);

sub run {
    my $self = shift;
    print "\n", $self->name, "\n";
    return $self->SUPER::run(@_);
}
