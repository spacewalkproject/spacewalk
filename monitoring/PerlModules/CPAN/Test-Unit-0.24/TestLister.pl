#!/usr/bin/perl -w

use strict;

use Getopt::Long;
use Test::Unit::Loader;

my %opts = ();
GetOptions(\%opts, 'help', 'testcases');
usage() if $opts{help};

foreach my $test (@ARGV) {
    my $suite = Test::Unit::Loader::load($test);
    print join '', @{ $suite->list($opts{testcases}) };
}
 
sub usage {
    die <<EOF;
Usage: $0 [ OPTIONS ] <TEST> [ <TEST> ... ]

Options:
   --testcases, -t   List testcases contained in (sub)suites
   --help, -h

Tests can be package names or file names.
EOF
}
