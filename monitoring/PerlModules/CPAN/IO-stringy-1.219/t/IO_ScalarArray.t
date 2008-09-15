#!/usr/bin/perl -w         #-*-Perl-*-

use lib "./t", "./lib"; 
use IO::ScalarArray;
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
my @sa = @Common::DATA_SA;
my $SAH = IO::ScalarArray->new(\@sa);
$T->ok($SAH, "OPEN: open a scalar on a ref to an array");

# Run standard tests:
Common->test_print($SAH);
Common->test_getc($SAH);
Common->test_getline($SAH);
Common->test_read($SAH);
#Common->test_seek($SAH);

# Run tie tests:
if ($tie_tests) {
    Common->test_tie(TieArgs => ['IO::ScalarArray', []]);
}

# So we know everything went well...
$T->end;








