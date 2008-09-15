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

$tests="

1997
10
   1997:1:10:0:0:_0.00

1997
10.5
   1997:1:10:12:0:_0.00

1997
10.510763888888889
   1997:1:10:12:15:30.00

1997
10.510770138888889
   1997:1:10:12:15:30.54

";

print "NthDayOfYear...\n";
&test_Func($ntest,\&Test_NthDayOfYear,$tests,$runtests);

sub Test_NthDayOfYear {
  my(@tmp)=&Date_NthDayOfYear(@_);
  push @tmp,sprintf("%5.2f",pop(@tmp));
  return join(":",@tmp);
}

1;
