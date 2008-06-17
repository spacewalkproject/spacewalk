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
$ntest=1;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs,"ForceDate=1997-03-08-12:30:00");

$dates="

08.04.1999
    1999080400:00:00

";

print "Date (German)...\n";
&Date_Init("Language=German","DateFormat=US","Internal=0");
&test_Func($ntest,\&ParseDate,$dates,$runtests);

1;
