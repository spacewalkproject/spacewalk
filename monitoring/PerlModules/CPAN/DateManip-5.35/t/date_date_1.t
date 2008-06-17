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
$ntest=25;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$calcs="

Wed Jan 10 1996 noon
Wed Jan  7 1998 noon
  +1:11:4:0:0:0:0

Wed Jan  7 1998 noon
Wed Jan 10 1996 noon
  -1:11:4:0:0:0:0

Wed Jan 10 1996 noon
Wed Jan  8 1997 noon
  +0:11:4:1:0:0:0

Wed Jan  8 1997 noon
Wed Jan 10 1996 noon
  -0:11:4:1:0:0:0

Wed May  8 1996 noon
Wed Apr  9 1997 noon
  +0:11:0:1:0:0:0

Wed Apr  9 1997 noon
Wed May  8 1996 noon
  -0:11:0:1:0:0:0

Wed Apr 10 1996 noon
Wed May 14 1997 noon
  +1:1:0:4:0:0:0

Wed May 14 1997 noon
Wed Apr 10 1996 noon
  -1:1:0:4:0:0:0

Wed Jan 10 1996 noon
Wed Feb  7 1996 noon
  +0:0:4:0:0:0:0

Wed Feb  7 1996 noon
Wed Jan 10 1996 noon
  -0:0:4:0:0:0:0

Mon Jan  8 1996 noon
Fri Feb  9 1996 noon
  +0:1:0:1:0:0:0

Fri Feb  9 1996 noon
Mon Jan  8 1996 noon
  -0:1:0:1:0:0:0

Jan 1 1996 12:00:00
Jan 1 1996 14:30:30
  +0:0:0:0:2:30:30

Jan 1 1996 14:30:30
Jan 1 1996 12:00:00
  -0:0:0:0:2:30:30

Jan 1 1996 12:00:00
Jan 2 1996 14:30:30
  +0:0:0:1:2:30:30

Jan 2 1996 14:30:30
Jan 1 1996 12:00:00
  -0:0:0:1:2:30:30

Jan 1 1996 12:00:00
Jan 2 1996 10:30:30
  +0:0:0:0:22:30:30

Jan 2 1996 10:30:30
Jan 1 1996 12:00:00
  -0:0:0:0:22:30:30

Jan 1 1996 12:00:00
Jan 2 1997 10:30:30
  +1:0:0:0:22:30:30

Jan 2 1997 10:30:30
Jan 1 1996 12:00:00
  -1:0:0:0:22:30:30

Jan 31 1996 12:00:00
Feb 28 1997 10:30:30
  +1:0:3:6:22:30:30

Feb 28 1997 10:30:30
Jan 31 1996 12:00:00
  -1:0:3:6:22:30:30

Jan 1st 1997 00:00:01
Feb 1st 1997 00:00:00
  +0:0:4:2:23:59:59

Jan 1st 1997 00:00:01
Mar 1st 1997 00:00:00
  +0:1:3:6:23:59:59

Jan 1st 1997 00:00:01
Mar 1st 1998 00:00:00
  +1:1:3:6:23:59:59

";

print "DateCalc (date,date,approx)...\n";
&test_Func($ntest,\&DateCalc,$calcs,$runtests,1);

1;

