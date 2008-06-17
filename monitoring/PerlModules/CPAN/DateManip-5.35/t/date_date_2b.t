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
$ntest=10;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$calcs="

Wed Jan 10 1996 noon
Wed Feb  7 1996 noon
  +0:0:0:19:0:0:0

Wed Feb  7 1996 noon
Wed Jan 10 1996 noon
  -0:0:0:19:0:0:0

Tue Jan  9 1996 12:00:00
Tue Jan  9 1996 14:30:30
  +0:0:0:0:2:30:30

Tue Jan  9 1996 14:30:30
Tue Jan  9 1996 12:00:00
  -0:0:0:0:2:30:30

Tue Jan  9 1996 12:00:00
Wed Jan 10 1996 14:30:30
  +0:0:0:1:2:30:30

Wed Jan 10 1996 14:30:30
Tue Jan  9 1996 12:00:00
  -0:0:0:1:2:30:30

Tue Jan  9 1996 12:00:00
Wed Jan 10 1996 10:30:30
  +0:0:0:0:7:30:30

Wed Jan 10 1996 10:30:30
Tue Jan  9 1996 12:00:00
  -0:0:0:0:7:30:30

Mon Dec 30 1996 noon
Mon Jan  6 1997 noon
  +0:0:0:4:0:0:0

Mon Jan  6 1997 noon
Mon Dec 30 1996 noon
  -0:0:0:4:0:0:0

";

&Date_Init("WorkDayBeg=8:00","WorkDayEnd=17:00");
print "DateCalc (date,date,business 8:00-5:00)...\n";
&test_Func($ntest,\&DateCalc,$calcs,$runtests,3);

1;
