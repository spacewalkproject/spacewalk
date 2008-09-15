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
$ntest=9;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$calcs="

Wed Feb 7 1996 8:00
+1:1:1:1
  1996020809:01:01

Wed Nov 20 1996 noon
+0:5:0:0
  1996112017:00:00

Wed Nov 20 1996 noon
+0:13:0:0
  1996112101:00:00

Wed Nov 20 1996 noon
+3:2:0:0
  1996112314:00:00

Wed Nov 20 1996 noon
-3:2:0:0
  1996111710:00:00

Wed Nov 20 1996 noon
+3:13:0:0
  1996112401:00:00

Wed Nov 20 1996 noon
+6:2:0:0
  1996112614:00:00

Dec 31 1996 noon
+1:2:0:0
  1997010114:00:00

Jan 31 1997 23:59:59
+ 1 sec
  1997020100:00:00

";

print "DateCalc (date,delta,approx)...\n";
&test_Func($ntest,\&DateCalc,$calcs,$runtests,1);

1;
