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
$ntest=89;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs,"ForceDate=1997-03-08-12:30:00");

($currS,$currMN,$currH,$currD,$currM,$currY)=("00","30","12","08","03","1997");

$today="$currY$currM$currD$currH:$currMN:$currS";
#$todaydate="$currY$currM$currD";
$yesterday="$currY$currM". $currD-1 ."$currH:$currMN:$currS";
$tomorrow ="$currY$currM". $currD+1 ."$currH:$currMN:$currS";

$dates="

aujourd'hui
    >Ignore failure on a slow computer.
    ~$today

maintenant
    >Ignore failure on a slow computer.
    ~$today

hier
    >Ignore failure on a slow computer or on the 1st day of the month.
    ~$yesterday

demain
    >Ignore failure on a slow computer or on the last day of the month.
    ~$tomorrow

dernier mar en Juin 96
    1996062500:00:00

dernier mar de Juin
    1997062400:00:00

premier mar de Juin 1996
    1996060400:00:00

premier mar de Juin
    1997060300:00:00

3e mardi de Juin 96
    1996061800:00:00

3e mardi de Juin 96 a 12:00
    1996061812:00:00

3e mardi de Juin 96 a 10:30 du matin
    1996061810:30:00

3e mardi de Juin 96 a 10:30 du soir
    1996061822:30:00


DeC 10  65
    1965121000:00:00

DeC 10  1965
    1965121000:00:00

Decembre 10  65
    1965121000:00:00

Decembre 10  1965
    1965121000:00:00

Decembre10  1965
    1965121000:00:00

Decembre10  1965 12:00
    1965121012:00:00

Decembre-10-1965 12:00
    1965121012:00:00

Decembre/10/1965/12:00
    1965121012:00:00

Decembre/10/12:00
    1997121012:00:00

12:00Decembre10  1965
    1965121012:00:00

12:00 Decembre10  1965
    1965121012:00:00

12:00-Decembre-10-1965
    1965121012:00:00

12:00 Decembre-10-1965
    1965121012:00:00

10 DeC   65
    1965121000:00:00

10 DeC  1965
    1965121000:00:00

10 Decembre   65
    1965121000:00:00

10 Decembre  1965
    1965121000:00:00

10DeC65
    1965121000:00:00

10DeC1965
    1965121000:00:00

10Decembre65
    1965121000:00:00

10Decembre  1965
    1965121000:00:00

DeC  10  4:50
    $currY 121004:50:00

Decembre  10  4:50
    $currY 121004:50:00

DeC  10  4:50:40
    $currY 121004:50:40

Decembre  10  4:50:42
    $currY 121004:50:42

10  DeC  4:50
    $currY 121004:50:00

10  Decembre  4:50
    $currY 121004:50:00

10DeC 4:50
    $currY 121004:50:00

10Decembre 4:50
    $currY 121004:50:00

10  DeC  4:50:51
    $currY 121004:50:51

10  Decembre  4:50:52
    $currY 121004:50:52

10DeC 4:50:53
    $currY 121004:50:53

10Decembre 4:50:54
    $currY 121004:50:54

10Decembre95 4:50:54
    1995121004:50:54

Dec10/65 4:50:53
    1965121004:50:53

Dec101965 4:50:53
    1965121004:50:53

4:50  DeC  10
    $currY 121004:50:00

4:50  Decembre  10
    $currY 121004:50:00

4:50:40  DeC  10
    $currY 121004:50:40

4:50:42  Decembre  10
    $currY 121004:50:42

4:50  10  DeC
    $currY 121004:50:00

4:50  10  Decembre
    $currY 121004:50:00

4:50 10DeC
    $currY 121004:50:00

4:50 10Decembre
    $currY 121004:50:00

4:50:51  10  DeC
    $currY 121004:50:51

4:50:52  10  Decembre
    $currY 121004:50:52

4:50:53 10DeC
    $currY 121004:50:53

4:50:54  10Decembre
    $currY 121004:50:54

4:50:54Decembre10
    $currY 121004:50:54

4:50:54Decembre10/65
    1965121004:50:54

DeC 1 5:30
    $currY 120105:30:00

DeC 10 05:30
    $currY 121005:30:00

DeC 10 05:30:11
    $currY 121005:30:11

DeC 1 65
    1965120100:00:00

DeC 1 1965
    1965120100:00:00

Decembre 1 5:30
    $currY 120105:30:00

Decembre 10 05:30
    $currY 121005:30:00

Decembre 10 05h30:12
    $currY 121005:30:12

Decembre 1 65
    1965120100:00:00

Decembre 1 1965
    1965120100:00:00

5:30 DeC 1
    $currY 120105:30:00

05:30 DeC 10
    $currY 121005:30:00

05:30:11 DeC 10
    $currY 121005:30:11

5:30 Decembre 1
    $currY 120105:30:00

05:30 Decembre 10
    $currY 121005:30:00

05:30:12 du matin Decembre 10
    $currY 121005:30:12

05:30:12 du soir Decembre 10
    $currY 121017:30:12

1 DeC 65
    1965120100:00:00

1 DeC 1965
    1965120100:00:00

1 Decembre 65
    1965120100:00:00

1 Decembre 1965
    1965120100:00:00

12 1 65
    1965120100:00:00

12 1 1965
    1965120100:00:00

2 29 92
    1992022900:00:00

2 29 90
    nil

1er DeC 65
    1965120100:00:00

DeC premier 1965
    1965120100:00:00
";

print "Date (French)...\n";
&Date_Init("Language=French","DateFormat=US","Internal=0");
&test_Func($ntest,\&ParseDate,$dates,$runtests);

1;
