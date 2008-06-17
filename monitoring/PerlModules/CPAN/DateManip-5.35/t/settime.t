#!/usr/local/bin/perl -w

require 5.001;
use Date::Manip;
@Date::Manip::TestArgs=();
$runtests=shift(@ARGV);
if ( -f "t/test.pl" ) {
  require "t/test.pl";
} elsif ( -f "test.pl" ) {
  require "test.pl";
} else {
  die "ERROR: cannot find test.pl\n";
}
$ntest=5;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$tests="

Jan 1, 1996  at 10:30
12:40
   1996010112:40:00

1996010110:30:40
12:40:50
   1996010112:40:50

1996010110:30:40
12:40
   1996010112:40:00

1996010110:30:40
12
40
   1996010112:40:00

1996010110:30:40
12
40
50
   1996010112:40:50

";

print "SetTime...\n";
&test_Func($ntest,\&Date_SetTime,$tests,$runtests);

1;
