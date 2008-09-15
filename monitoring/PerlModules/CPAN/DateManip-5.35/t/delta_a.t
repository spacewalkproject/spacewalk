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
$ntest=30;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$deltas="

# Test weeks
+ 4 week 3 day
    +0:0:4:3:0:0:0

+ 4 wk 3 day 20:30
    +0:0:4:3:0:20:30

+ 15mn
    +0:0:0:0:0:15:0

+ 15 mn
    +0:0:0:0:0:15:0

15 mn
    +0:0:0:0:0:15:0

+15 mn
    +0:0:0:0:0:15:0

+15mn
    +0:0:0:0:0:15:0

+ 35  y 10 month 15mn
    +35:10:0:0:0:15:0

+ 35  y 10m15mn
    +35:10:0:0:0:15:0

+ 35year 10:0:0:0:15:0
    +35:10:0:0:0:15:0

+ 35  y -10 month 15mn
    +34:2:-0:0:0:15:0

+35:-10:0:0:0:15:0
    +34:2:-0:0:0:15:0

+ 35  y10 month12:40
    +35:10:0:0:0:12:40

+35  y 10 month 1:12:40
    +35:10:0:0:1:12:40

+35x 10 month
    nil

+ 35  y -10 month 1:12:40
    +34:2:-0:0:1:12:40

1:2:3:4:5:6:7
    +1:2:3:4:5:6:7

in 1:2:3:4:5:6:7
    +1:2:3:4:5:6:7

1:2:3:4:5:6:7 ago
    -1:2:3:4:5:6:7

-1:2:3:4:5:6:7
    -1:2:3:4:5:6:7

1::3:4:5:6:7ago
    -1:0:3:4:5:6:7

# Test normalization of deltas
+1:+1:+1:+1
    +0:0:0:1:1:1:1

+1:+1:+1:-1
    +0:0:0:1:1:0:59

+1:+1:-1:+1
    +0:0:0:1:0:59:1

+1:-1:+1:+1
    +0:0:0:0:23:1:1

+1:+1:-1:-1
    +0:0:0:1:0:58:59

+1:-1:+1:-1
    +0:0:0:0:23:0:59

+1:-1:-1:+1
    +0:0:0:0:22:59:1

-0:1:+0:0:0:0:0
    -0:1:0:0:0:0:0

-0:0:1:+0:-0:0:0
    -0:0:1:0:0:0:0
";

print "Delta...\n";
&test_Func($ntest,\&ParseDateDelta,$deltas,$runtests);

1;
