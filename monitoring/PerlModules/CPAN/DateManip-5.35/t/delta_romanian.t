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
$ntest=21;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs);

$calcs="

Mie Febr 7 1996 8:00
+1:1:1:1
  1996020809:01:01

Mie Nov 20 1996 amiaza 
+0:5:0:0
  1996112017:00:00

Mie Nov 20 1996 amiaza 
+0:13:0:0
  1996112101:00:00

Mie Nov 20 1996 amiaza 
+3:2:0:0
  1996112314:00:00

Mie Nov 20 1996 amiaza 
-3:2:0:0
  1996111710:00:00

Mie Nov 20 1996 amiaza 
+3:13:0:0
  1996112401:00:00

Mie Nov 20 1996 amiaza 
+6:2:0:0
  1996112614:00:00

Dec 31 1996 amiaza 
+1:2:0:0
  1997010114:00:00

Ian 31 1997 23:59:59
+ 1 sec
  1997020100:00:00

Mie Feb 7 1996 8:00
+1:1:1:1
  1996020809:01:01

Mie Nov 20 1996 amiaza 
+0:2:0:0
  1996112014:00:00

Mie Nov 20 1996 amiaza 
+3:7:0:0
  1996112319:00:00

Dec 30 1996 amiaza 
+1:2:0:0
  1996123114:00:00

Mart 31 1997 23:59:59
+ 1 sec
  1997040100:00:00

Mie Nov 20 1996 amiaza 
+0:0:1:0:0:0:0
  1996112712:00:00

Mie Nov 20 1996 19:00
5 ore 
  1996112100:00:00

Mie Nov 20 1996 12:00
+0:2:0:0
  1996112014:00:00

Mie Nov 20 1996 12:00
3 zile 2 h
  1996112314:00:00

Mie Nov 20 1996 12:00
in urma 3 zile 2 ore 
  1996111710:00:00

Mie Nov 20 1996 12:00
5 ore
  1996112017:00:00

Mie Nov 20 1996 12:00
3 zile 2 h
  1996112314:00:00

";

&Date_Init("Language=Romanian");
print "DateCalc (Romanian,delta)...\n";
&test_Func($ntest,\&DateCalc,$calcs,$runtests,0);

1;
