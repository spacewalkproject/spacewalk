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
$ntest=3;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$calcs="

Wed Nov 20 1996 noon
+0:5:0:0
  1996112108:30:00

Wed Nov 20 1996 noon
+3:7:0:0
  1996112610:30:00

Mar 31 1997 16:59:59
+ 1 sec
  1997040108:30:00

";

&Date_Init("WorkDayBeg=08:30","WorkDayEnd=17:00");
print "DateCalc (date,delta,business 8:30-5:00)...\n";
&test_Func($ntest,\&DateCalc,$calcs,$runtests,2);

1;
