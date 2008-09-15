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

$tests="

0:0:1:2:3:4:5
4
%wv %dv %hv %mv %sv : %wh %dh %hh %mh %sh
  1_2_3_4_5_:_1_9_219_13144_788645

0:0:1:2:3:4:5
4
%wd %dd %hd %md %sd
  1.3040_2.1278_3.0681_4.0833_5.0000

0:0:1:2:3:4:5
4
%wt %dt %ht %mt %st
  1.3040_9.1278_219.0681_13144.0833_788645.0000

";

print "FormatDelta...\n";
&test_Func($ntest,\&Delta_Format,$tests,$runtests);

1;

