#!/usr/bin/perl -w         #-*-Perl-*-

use lib "./t", "./lib"; 
use IO::Lines;
use ExtUtils::TBone;
use Common;


#--------------------
#
# TEST...
#
#--------------------

# Make a tester:
my $T = typical ExtUtils::TBone;
Common->test_init(TBone=>$T);

# Set the counter:
my $tie_tests = (($] >= 5.004) ? 4 : 0);
$T->begin(11 + $tie_tests);

# Open a scalar on a string, containing initial data:
my @la = @Common::DATA_LA;
my $LAH = IO::Lines->new(\@la);
$T->ok($LAH, "OPEN: open a scalar on a ref to an array");

# Run standard tests:
Common->test_print($LAH);
Common->test_getc($LAH);
Common->test_getline($LAH);
Common->test_read($LAH);
#Common->test_seek($LAH);

# Run tie tests:
if ($tie_tests) {
    Common->test_tie(TieArgs => ['IO::Lines', []]);
}

# So we know everything went well...
$T->end;


