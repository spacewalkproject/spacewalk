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
$ntest=4;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$calcs="

Mer Nov 20 1996 12h00
il y a 3 jour 2 heures
  1996111510:00:00

Mer Nov 20 1996 12:00
5 heure
  1996112108:00:00

Mer Nov 20 1996 12:00
+0:2:0:0
  1996112014:00:00

Mer Nov 20 1996 12:00
3 jour 2 h
  1996112514:00:00

";

&Date_Init("Language=French","WorkDayBeg=08:00","WorkDayEnd=17h00","EraseHolidays=1");
print "DateCalc (French,date,delta,business 8:00-5:00)...\n";
&test_Func($ntest,\&DateCalc,$calcs,$runtests,2);

1;
