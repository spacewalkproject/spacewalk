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
&Date_Init(@Date::Manip::TestArgs,"DeltaSigns=1");

$deltas="

1:2:3:4:5:6:7
    +1:+2:+3:+4:+5:+6:+7

-1:2:3:4:5:6:7
    -1:-2:-3:-4:-5:-6:-7

35x
    nil

+0
    +0:+0:+0:+0:+0:+0:+0

";

print "Delta (signs)...\n";
&test_Func($ntest,\&ParseDateDelta,$deltas,$runtests);

1;
