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
$ntest=196;

print "1..$ntest\n"  if (! $runtests);
&Date_Init(@Date::Manip::TestArgs,"ForceDate=1997-03-08-12:30:00");

($currS,$currMN,$currH,$currD,$currM,$currY)=("00","30","12","08","03","1997");

$today="$currY$currM$currD$currH:$currMN:$currS";
$todaydate    ="$currY$currM$currD";
$yesterdaydate="$currY$currM". $currD-1;
$tomorrowdate ="$currY$currM". $currD+1;
$yesterday    ="$yesterdaydate$currH:$currMN:$currS";
$tomorrow     ="$tomorrowdate$currH:$currMN:$currS";

$dates="

# Test built in strings like today and yesterday.  A few may fail on a
# slow computer.  On the 1st or last day of the month, the yesterday/today
# test will fail because of the simplicity of the test.
acum
    >Ignore failure on a slow computer.
    ~$today

astazi
    >Ignore failure on a slow computer.
    ~$today

ieri
    >Ignore failure on a slow computer or on the 1st day of the month.
    ~$yesterday

miine
    >Ignore failure on a slow computer or on the last day of the month.
    ~$tomorrow

astazi la 4:00
    $todaydate 04:00:00

astazi la 4:00 pm
    $todaydate 16:00:00

astazi la 16:00:00
    $todaydate 16:00:00

astazi la 12:00 am
    $todaydate 00:00:00

astazi la 12:00 GMT
    $todaydate 07:00:00

astazi la 4:00 PST
    $todaydate 07:00:00

astazi la 4:00 -0800
    $todaydate 07:00:00

astazi la amiaza
    $todaydate 12:00:00

miine la amiaza 
    >Ignore failure on a slow computer or on the last day of the month.
    $tomorrowdate 12:00:00

1 luna in urma 
    1997020812:30:00

# Test weeks
a 22-a duminica
    1997060100:00:00

1997023
    1997012300:00:00

1997035
    1997020400:00:00

97-035
    1997020400:00:00

97035
    1997020400:00:00

a douazecisidoua duminica 1996
    1996060200:00:00

22 duminica in 1996
    1996060200:00:00

a 22-a duminica 12:00
    1997060112:00:00

a 22-a duminica la 12:00
    1997060112:00:00

a 22-a duminica la 12:00 EST
    1997060112:00:00

a 22-a duminica in 1996 la 12:00 EST
    1996060212:00:00

duminica saptamina 1 1999
    1999011000:00:00

joi saptamina 0 1999
    1998123100:00:00

prima joi in 1999
    1999010700:00:00

prima duminica in 1999
    1999010300:00:00

duminica saptamina 22
    1997060100:00:00

duminica saptamina a douazecisidoua 1996
    1996060200:00:00

duminica sapt 22 in 1996
    1996060200:00:00

duminica saptamina 22 12:00
    1997060112:00:00

duminica saptamina 22  12:00
    1997060112:00:00

duminica saptamina 22 la 12:00 EST
    1997060112:00:00

duminica saptamina 22 in 1996 la 12:00 EST
    1996060212:00:00

duminica 22 saptamini 
    1997060100:00:00

duminica a douazecisidoua saptamina 1996
    1996060200:00:00

duminica 22 sapt in 1996
    1996060200:00:00

duminica saptamina 22 12:00
    1997060112:00:00

duminica saptamina 22 la 12:00
    1997060112:00:00

duminica saptamina 22 la 12:00 EST
    1997060112:00:00

duminica saptamina 22 in 1996 la 12:00 EST
    1996060212:00:00

# Tests 'which day in mon' formats
ultima marti in iun 96
    1996062500:00:00

ultima marti din iunie
    1997062400:00:00

prima marti in iun 1996
    1996060400:00:00

prima marti in iunie
    1997060300:00:00

a 3-a marti in iun 96
    1996061800:00:00

a 3-a marti in iun 96 la 12:00:00
    1996061812:00:00

a 3-a marti in iun 96 la 10:30am
    1996061810:30:00

a 3-a marti in iun 96 la 10:30 pm
    1996061822:30:00

a 3-a marti in iun 96 la 10:30 pm GMT
    1996061817:30:00

a 3-a marti in iun 96 la 10:30 pm CET
    1996061816:30:00

# Tests Date Time
#       Date%Time
# Date=mm%dd
12/10/65 la 5:30:25
    1965121005:30:25

12-10-65 la 5:30:25
    1965121005:30:25

12  10  65 la 5:30:25
    1965121005:30:25

12  10  1965 la 5:30:25
    1965121005:30:25

12.10.1965 05:61
    nil

12.10.1965 05:30:61
    nil

12/10
    $currY 121000:00:00

12/10 05:30
    $currY 121005:30:00

12/10 la 05:30:25
    $currY 121005:30:25

12/10 la 05:30:25 GMT
    $currY 121000:30:25

12/10  5:30
    $currY 121005:30:00

12/10  05:30
    $currY 121005:30:00

12-10  5:30
    $currY 121005:30:00

12.10  05:30
    $currY 121005:30:00

12 10  05:30
    $currY 121005:30:00

2 29 92
    1992022900:00:00

2 29 90
    nil

# Tests Date Time
#       Date%Time
# Date=mmm%dd

Dec/10/1965
    1965121000:00:00

Decembrie/10/65
    1965121000:00:00

Dec-10-65
    1965121000:00:00

Dec 10 65
    1965121000:00:00

DecEMBRIE10 65
    1965121000:00:00

Decembrie/10/65 5:30:25
    1965121005:30:25

Dec/10/65/5:30 pm
    1965121017:30:00

Dec/10/65/5:30 pm GMT
   1965121012:30:00

Dec/10/65 la 5:30:25
    1965121005:30:25

Dec-10-1965 5:30:25
    1965121005:30:25

Decembrie-10-65 5:30:25
    1965121005:30:25

Dec-10-65-5:30 pm
    1965121017:30:00

Dec-10-65 la 5:30:25
    1965121005:30:25

Dec  10  65 5:30:25
    1965121005:30:25

Dec  10  65  5:30 pm
    1965121017:30:00

Decembrie  10  65 la 5:30:25
    1965121005:30:25

Dec  10  1965 la 5:30:25
    1965121005:30:25

Dec-10-1965 05:61
    nil

Dec-10-1965 05:30:61
    nil

Decembrie/10
    $currY 121000:00:00

Dec/10 05:30
    $currY 121005:30:00

Dec/10 la 05:30:25
    $currY 121005:30:25

Dec/10 la 05:30:25 GMT
   $currY 121000:30:25

Dec/10  5:30
    $currY 121005:30:00

Dec/10  05:30
    $currY 121005:30:00

Dec-10  5:30
    $currY 121005:30:00

Dec-10  05:30
    $currY 121005:30:00

Decembrie10  05:30
    $currY 121005:30:00

DeC intii 1965
    1965120100:00:00

# Tests Date Time
#       Date%Time
# Date=dd%mmm

10/Dec/1965
    1965121000:00:00

10/Decembrie/65
    1965121000:00:00

10-Dec-65
    1965121000:00:00

10 Dec 65
    1965121000:00:00

10/Decembrie/65 5:30:25
    1965121005:30:25

10/Dec/65/5:30 pm
    1965121017:30:00

10/Dec/65/5:30 pm GMT
   1965121012:30:00

10/Dec/65 la 5:30:25
    1965121005:30:25

10-Dec-1965 5:30:25
    1965121005:30:25

10-Decembrie-65 5:30:25
    1965121005:30:25

10-Dec-65-5:30 pm
    1965121017:30:00

10-Dec-65 la 5:30:25
    1965121005:30:25

10  Dec   65 5:30:25
    1965121005:30:25

10  Dec 65  5:30 pm
    1965121017:30:00

10Decembrie  65 la 5:30:25
    1965121005:30:25

10 Dec  1965 la 5:30:25
    1965121005:30:25

10Dec  1965 la 5:30:25
    1965121005:30:25

10 Dec1965 la 5:30:25
    1965121005:30:25

10Dec1965 la 5:30:25
    1965121005:30:25

10-Dec-1965 05:61
    nil

10-Dec-1965 05:30:61
    nil

10/Decembrie
    $currY 121000:00:00

10/Dec 05:30
    $currY 121005:30:00

10/Dec la 05:30:25
    $currY 121005:30:25

10-Dec la 05:30:25 GMT
   $currY 121000:30:25

10-Dec  5:30
    $currY 121005:30:00

10/Dec  05:30
    $currY 121005:30:00

10Decembrie 05:30
    $currY 121005:30:00

Intii DeC 65
    1965120100:00:00

# Tests time only formats
5:30
    $todaydate 05:30:00

5:30:02
    $todaydate 05:30:02

15:30:00
    $todaydate 15:30:00

# Tests TimeDate
#       Time%Date
5:30 pm 12/10/65
    1965121017:30:00

5:30 pm GMT 12/10/65
    1965121012:30:00

5:30:25/12/10/65
    1965121005:30:25

5:30:25 12-10-1965
    1965121005:30:25

5:30:25 12-10-65
    1965121005:30:25

5:30 pm 12-10-65
    1965121017:30:00

5:30:25/12-10-65
    1965121005:30:25

5:30:25 12  10  65
    1965121005:30:25

5:30 pm 12  10  65
    1965121017:30:00

5:30 pm GMT 12  10  65
    1965121012:30:00

5:30:25 12  10  1965
    1965121005:30:25

05:61 12-10-1965
    nil

05:30:61 12-10-1965
    nil

05:30 12/10
    $currY 121005:30:00

05:30/12/10
    $currY 121005:30:00

05:30:25 12/10
    $currY 121005:30:25

05:30:25/12-10
    $currY 121005:30:25

05:30:25 GMT 12/10
    $currY 121000:30:25

5:30 12/10
    $currY 121005:30:00

05:30 12/10
    $currY 121005:30:00

5:30 12-10
    $currY 121005:30:00

05:30 12-10
    $currY 121005:30:00

05:30 12 10
    $currY 121005:30:00

# Tests TimeDate
#       Time%Date
# Date=mmm%dd, dd%mmm

4:50  DeC  10
    $currY 121004:50:00

4:50  DeCembrie  10
    $currY 121004:50:00

4:50:40  DeC  10
    $currY 121004:50:40

4:50:42  DeCembrie  10
    $currY 121004:50:42

4:50  10  DeC
    $currY 121004:50:00

4:50  10  DeCembrie
    $currY 121004:50:00

4:50 10DeC
    $currY 121004:50:00

4:50 10DeCembrie
    $currY 121004:50:00

4:50:51  10  DeC
    $currY 121004:50:51

4:50:52  10  DeCembrie
    $currY 121004:50:52

4:50:53 10DeC
    $currY 121004:50:53

4:50:54  10DeCembrie
    $currY 121004:50:54

4:50:54DeCembrie10
    $currY 121004:50:54

4:50:54DeCembrie10/65
    1965121004:50:54

4:50:54DeCembrie1965
    1965120104:50:54

Sept 1995
    1995090100:00:00

1995 septembrie
    1995090100:00:00

5:30 DeC 1
    $currY 120105:30:00

05:30 DeC 10
    $currY 121005:30:00

05:30:11 DeC 10
    $currY 121005:30:11

5:30 DeCembrie 1
    $currY 120105:30:00

05:30 DeCembrie 10
    $currY 121005:30:00

05:30:12 DeCembrie 10
    $currY 121005:30:12

# Test ctime formats
DeCembrie 10 05:30:12 1996
    1996121005:30:12

DeC10 05:30:12 96
    1996121005:30:12

# Test some tricky timezone conversions
Febr 28 1997 23:00-0900
    1997030103:00:00

Febr 27 1997 23:00-0900
    1997022803:00:00

Febr 01 1997 01:00-0100
    1997013121:00:00

Febr 02 1997 01:00-0100
    1997020121:00:00

Febr 02 1997 01:00+0100
    1997020119:00:00

Febr 02 1997 01:00+01
    1997020119:00:00

Febr 02 1997 01:00+01:00
    1997020119:00:00

19970202010000+0100
    1997020119:00:00

# More tests...
ultima zi din octombrie 1997
    1997103100:00:00

epoch 400000
    1970010510:06:40

19980102030405 EST
    1998010203:04:05

19980102030405E
    1998010203:04:05

Luni, 19 ian 1998 08:11:34 +1030
    1998011816:41:34

Marti, 26 Mai 1998 13:23:15 -0500 (EST)
    1998052613:23:15

Dec101965
    1965121000:00:00

10Dec1965
    1965121000:00:00

101965Dec
    1965121000:00:00

";

print "Date (Romanian)...\n";
&Date_Init("Language=Romanian","DateFormat=US","Internal=0");
&test_Func($ntest,\&ParseDate,$dates,$runtests);

1;
