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
$ntest=11;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$calcs="

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
  +0:0:52:2:22:30:30

Jan 2 1997 10:30:30
Jan 1 1996 12:00:00
  -0:0:52:2:22:30:30

Jan 1st 1997 00:00:01
Feb 1st 1997 00:00:00
  +0:0:4:2:23:59:59

Jan 1st 1997 00:00:01
Mar 1st 1997 00:00:00
  +0:0:8:2:23:59:59

Jan 1st 1997 00:00:01
Mar 1st 1998 00:00:00
  +0:0:60:3:23:59:59

";

print "DateCalc (date,date,exact)...\n";
&test_Func($ntest,\&DateCalc,$calcs,$runtests,0);

1;
