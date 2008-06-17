#!/usr/bin/perl -w         #-*-Perl-*-

use lib "./t", "./lib"; 
use IO::Scalar;
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
my $par_tests = 9;
$T->begin(14 + $tie_tests + $par_tests);

# Open a scalar on a string, containing initial data:
my $s = $Common::DATA_S;
my $SH = IO::Scalar->new(\$s);
$T->ok($SH, "OPEN: open a scalar on a ref to a string");

# Run standard tests:
Common->test_print($SH);
$T->ok(($s eq $Common::FDATA_S), "FULL",
       S=>$s, F=>$Common::FDATA_S);
Common->test_getc($SH);
Common->test_getline($SH);
Common->test_read($SH);
Common->test_seek($SH);

# Run tie tests:
if ($tie_tests) {
    Common->test_tie(TieArgs => ['IO::Scalar']);
}

# Try $/ tests:
if (1) {
    my @lines = ("par 1, line 1\n",
		 "par 1, line 2\n",
		 "\n",
		 "\n",
		 "\n",
		 "\n",
		 "par 2, line 1\n",
		 "\n",
		 "par 3, line 1\n",
		 "par 3, line 2\n",
		 "par 3, line 3");
    my $all = join '', @lines;

    ### Slurp everything:
    {
	$SH = IO::Scalar->new(\"$all");
        $SH->use_RS(1);
        local $/ = undef;
        $T->ok_eq($SH->getline, $all,
                  "RECORDS: Slurp everything");
    }

    ### Read a little, slurp the rest:
    {
	$SH = IO::Scalar->new(\"$all");
        $SH->use_RS(1);
        $T->ok_eq($SH->getline, $lines[0],
		  "RECORDS: get first line");
        local $/ = undef;
        $T->ok_eq($SH->getline, join('', @lines[1..$#lines]),
		  "RECORDS: slurp the rest");
    }

    ### Read paragraph by paragraph:
    {
	$SH = IO::Scalar->new(\"$all");
        $SH->use_RS(1);
        local $/ = "";
        $T->ok_eq($SH->getline, join('', @lines[0..2]),
                  "RECORDS: first par");
        $T->ok_eq($SH->getline, join('', @lines[6..7]),
                  "RECORDS: second par");
        $T->ok_eq($SH->getline, join('', @lines[8..10]),
                  "RECORDS: third par");
    }

    ### Read record by record:
    {
	$SH = IO::Scalar->new(\"$all");
        $SH->use_RS(1);
        local $/ = "1,";
        $T->ok_eq($SH->getline, "par 1,",
                  "RECORDS: first rec");
        $T->ok_eq($SH->getline, " line 1\npar 1,",
                  "RECORDS: second rec");
    }

    ### Read line by line:
    {
	$SH = IO::Scalar->new(\"$all");
        local $/ = "1,";
        $T->ok_eq($SH->getline, $lines[0],
                  "RECORDS W/O RS: first rec");
    }

}

# So we know everything went well...
$T->end;








