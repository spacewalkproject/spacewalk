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
$ntest=2;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$dates="
# Tests YYMMDD time
1996061800:00:00
    19960618000000

# Tests YYMMDDHHMNSS
19960618000000
    19960618000000
";

print "Date (English,Internal=1)...\n";
&Date_Init("Internal=1");
&test_Func($ntest,\&ParseDate,$dates,$runtests);

1;

