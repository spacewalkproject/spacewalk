package Date::Manip;

# Copyright (c) 1995-1999 Sullivan Beck.  All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

###########################################################################
###########################################################################

use vars qw($OS %Lang %Holiday %Curr %Cnf %Zone);


# Determine the type of OS...
$OS="Unix";
$OS="Windows"  if ((defined $^O and
                    $^O =~ /MSWin32/i ||
                    $^O =~ /Windows_95/i ||
                    $^O =~ /Windows_NT/i) ||
                   (defined $ENV{OS} and
                    $ENV{OS} =~ /MSWin32/i ||
                    $ENV{OS} =~ /Windows_95/i ||
                    $ENV{OS} =~ /Windows_NT/i));
$OS="Mac"      if ((defined $^O and
                    $^O =~ /MacOS/i) ||
                   (defined $ENV{OS} and
                    $ENV{OS} =~ /MacOS/i));
$OS="MPE"      if (defined $^O and
                   $^O =~ /MPE/i);
$OS="OS2"      if (defined $^O and
                   $^O =~ /os2/i);
$OS="VMS"      if (defined $^O and
                   $^O =~ /VMS/i);

###########################################################################
# CUSTOMIZATION
###########################################################################
#
# See the section of the POD documentation section CUSTOMIZING DATE::MANIP
# below for a complete description of each of these variables.


# Location of a the global config file.  Tilde (~) expansions are allowed.
# This should be set in Date_Init arguments.
$Cnf{"GlobalCnf"}="";
$Cnf{"IgnoreGlobalCnf"}="";

# Name of a personal config file and the path to search for it.  Tilde (~)
# expansions are allowed.  This should be set in Date_Init arguments or in
# the global config file.

if ($OS eq "Windows") {
  $Cnf{"PathSep"}         = ";";
  $Cnf{"PersonalCnf"}     = "Manip.cnf";
  $Cnf{"PersonalCnfPath"} = ".";

} elsif ($OS eq "MPE") {
  $Cnf{"PathSep"}         = ":";
  $Cnf{"PersonalCnf"}     = "Manip.cnf";
  $Cnf{"PersonalCnfPath"} = ".";

} elsif ($OS eq "OS2") {
  $Cnf{"PathSep"}         = ":";
  $Cnf{"PersonalCnf"}     = "Manip.cnf";
  $Cnf{"PersonalCnfPath"} = ".";

} elsif ($OS eq "Mac") {
  $Cnf{"PathSep"}         = ":";
  $Cnf{"PersonalCnf"}     = "Manip.cnf";
  $Cnf{"PersonalCnfPath"} = ".";

} elsif ($OS eq "VMS") {
  # VMS doesn't like files starting with "."
  $Cnf{"PathSep"}         = ":";
  $Cnf{"PersonalCnf"}     = "Manip.cnf";
  $Cnf{"PersonalCnfPath"} = ".:~";

} else {
  # Unix
  $Cnf{"PathSep"}         = ":";
  $Cnf{"PersonalCnf"}     = ".DateManip.cnf";
  $Cnf{"PersonalCnfPath"} = ".:~";
}

### Date::Manip variables set in the global or personal config file

# Which language to use when parsing dates.
$Cnf{"Language"}="English";

# 12/10 = Dec 10 (US) or Oct 12 (anything else)
$Cnf{"DateFormat"}="US";

# Local timezone
$Cnf{"TZ"}="";

# Timezone to work in (""=local, "IGNORE", or a timezone)
$Cnf{"ConvTZ"}="";

# Date::Manip internal format (0=YYYYMMDDHH:MN:SS, 1=YYYYHHMMDDHHMNSS)
$Cnf{"Internal"}=0;

# First day of the week (1=monday, 7=sunday).  ISO 8601 says monday.
$Cnf{"FirstDay"}=1;

# First and last day of the work week  (1=monday, 7=sunday)
$Cnf{"WorkWeekBeg"}=1;
$Cnf{"WorkWeekEnd"}=5;

# If non-nil, a work day is treated as 24 hours long (WorkDayBeg/WorkDayEnd
# ignored)
$Cnf{"WorkDay24Hr"}=0;

# Start and end time of the work day (any time format allowed, seconds
# ignored)
$Cnf{"WorkDayBeg"}="08:00";
$Cnf{"WorkDayEnd"}="17:00";

# If "today" is a holiday, we look either to "tomorrow" or "yesterday" for
# the nearest business day.  By default, we'll always look "tomorrow"
# first.
$Cnf{"TomorrowFirst"}=1;

# Erase the old holidays
$Cnf{"EraseHolidays"}="";

# Set this to non-zero to be produce completely backwards compatible deltas
$Cnf{"DeltaSigns"}=0;

# If this is 0, use the ISO 8601 standard that Jan 4 is in week 1.  If 1,
# make week 1 contain Jan 1.
$Cnf{"Jan1Week1"}=0;

# 2 digit years fall into the 100 year period given by [ CURR-N,
# CURR+(99-N) ] where N is 0-99.  Default behavior is 89, but other useful
# numbers might be 0 (forced to be this year or later) and 99 (forced to be
# this year or earlier).  It can also be set to "c" (current century) or
# "cNN" (i.e.  c18 forces the year to bet 1800-1899).  Also accepts the
# form cNNNN to give the 100 year period NNNN to NNNN+99.
$Cnf{"YYtoYYYY"}=89;

# Set this to 1 if you want a long-running script to always update the
# timezone.  This will slow Date::Manip down.  Read the POD documentation.
$Cnf{"UpdateCurrTZ"}=0;

# Use an international character set.
$Cnf{"IntCharSet"}=0;

# Use this to force the current date to be set to this:
$Cnf{"ForceDate"}="";

###########################################################################

require 5.000;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
   DateManipVersion
   Date_Init
   ParseDateString
   ParseDate
   ParseRecur
   Date_Cmp
   DateCalc
   ParseDateDelta
   UnixDate
   Delta_Format
   Date_GetPrev
   Date_GetNext
   Date_SetTime
   Date_SetDateField
   Date_IsHoliday

   Date_DaysInMonth
   Date_DayOfWeek
   Date_SecsSince1970
   Date_SecsSince1970GMT
   Date_DaysSince1BC
   Date_DayOfYear
   Date_DaysInYear
   Date_WeekOfYear
   Date_LeapYear
   Date_DaySuffix
   Date_ConvTZ
   Date_TimeZone
   Date_IsWorkDay
   Date_NextWorkDay
   Date_PrevWorkDay
   Date_NearestWorkDay
   Date_NthDayOfYear

   Date_DaysSince999
);
use strict;
use integer;
use Carp;
use Cwd;
use IO::File;
require VMS::Filespec  if ($OS eq "VMS");

use vars qw($VERSION);
$VERSION="5.35";

########################################################################
########################################################################

$Curr{"InitLang"}      = 1;     # Whether a language is being init'ed
$Curr{"InitDone"}      = 0;     # Whether Init_Date has been called
$Curr{"InitFilesRead"} = 0;
$Curr{"ResetWorkDay"}  = 1;
$Curr{"Debug"}         = "";
$Curr{"DebugVal"}      = "";

$Holiday{"year"}   = 0;
$Holiday{"dates"}  = {};
$Holiday{"desc"}   = {};

########################################################################
########################################################################
# THESE ARE THE MAIN ROUTINES
########################################################################
########################################################################

# Get rid of a problem with old versions of perl
no strict "vars";
# This sorts from longest to shortest element
sub sortByLength {
  return (length $b <=> length $a);
}
use strict "vars";

sub DateManipVersion {
  print "DEBUG: DateManipVersion\n"  if ($Curr{"Debug"} =~ /trace/);
  return $VERSION;
}

sub Date_Init {
  print "DEBUG: Date_Init\n"  if ($Curr{"Debug"} =~ /trace/);
  $Curr{"Debug"}="";

  my(@args)=@_;
  $Curr{"InitDone"}=1;
  local($_)=();
  my($internal,$firstday)=();
  my($var,$val,$file,@tmp)=();

  # InitFilesRead = 0    : no conf files read yet
  #                 1    : global read, no personal read
  #                 2    : personal read

  $Cnf{"EraseHolidays"}=0;
  foreach (@args) {
    s/\s*$//;
    s/^\s*//;
    /^(\S+) \s* = \s* (.+)$/x;
    ($var,$val)=($1,$2);
    if ($var =~ /^GlobalCnf$/i) {
      $Cnf{"GlobalCnf"}=$val;
      if ($val) {
        $Curr{"InitFilesRead"}=0;
        &EraseHolidays();
      }
    } elsif ($var =~ /^PathSep$/i) {
      $Cnf{"PathSep"}=$val;
    } elsif ($var =~ /^PersonalCnf$/i) {
      $Cnf{"PersonalCnf"}=$val;
      $Curr{"InitFilesRead"}=1  if ($Curr{"InitFilesRead"}==2);
    } elsif ($var =~ /^PersonalCnfPath$/i) {
      $Cnf{"PersonalCnfPath"}=$val;
      $Curr{"InitFilesRead"}=1  if ($Curr{"InitFilesRead"}==2);
    } elsif ($var =~ /^IgnoreGlobalCnf$/i) {
      $Curr{"InitFilesRead"}=1  if ($Curr{"InitFilesRead"}==0);
      $Cnf{"IgnoreGlobalCnf"}=1;
    } elsif ($var =~ /^EraseHolidays$/i) {
      &EraseHolidays();
    } else {
      push(@tmp,$_);
    }
  }
  @args=@tmp;

  # Read global config file
  if ($Curr{"InitFilesRead"}<1  &&  ! $Cnf{"IgnoreGlobalCnf"}) {
    $Curr{"InitFilesRead"}=1;

    if ($Cnf{"GlobalCnf"}) {
      $file=&ExpandTilde($Cnf{"GlobalCnf"});
      &Date_InitFile($file)  if ($file);
    }
  }

  # Read personal config file
  if ($Curr{"InitFilesRead"}<2) {
    $Curr{"InitFilesRead"}=2;

    if ($Cnf{"PersonalCnf"}  and  $Cnf{"PersonalCnfPath"}) {
      $file=&SearchPath($Cnf{"PersonalCnf"},$Cnf{"PersonalCnfPath"},"r");
      &Date_InitFile($file)  if ($file);
    }
  }

  foreach (@args) {
    s/\s*$//;
    s/^\s*//;
    /^(\S+) \s* = \s* (.+)$/x;
    ($var,$val)=($1,$2);
    &Date_SetConfigVariable($var,$val);
  }

  confess "ERROR: Unknown FirstDay in Date::Manip.\n"
    if (! &IsInt($Cnf{"FirstDay"},1,7));
  confess "ERROR: Unknown WorkWeekBeg in Date::Manip.\n"
    if (! &IsInt($Cnf{"WorkWeekBeg"},1,7));
  confess "ERROR: Unknown WorkWeekEnd in Date::Manip.\n"
    if (! &IsInt($Cnf{"WorkWeekEnd"},1,7));
  confess "ERROR: Invalid WorkWeek in Date::Manip.\n"
    if ($Cnf{"WorkWeekEnd"} <= $Cnf{"WorkWeekBeg"});

  my(%lang,
     $tmp,%tmp,$tmp2,@tmp2,
     $i,$j,@tmp3,
     $zonesrfc,@zones)=();

  my($L)=$Cnf{"Language"};

  if ($Curr{"InitLang"}) {
    $Curr{"InitLang"}=0;

    if ($L eq "English") {
      &Date_Init_English(\%lang);

    } elsif ($L eq "French") {
      &Date_Init_French(\%lang);

    } elsif ($L eq "Swedish") {
      &Date_Init_Swedish(\%lang);

    } elsif ($L eq "German") {
      &Date_Init_German(\%lang);

    } elsif ($L eq "Polish") {
      &Date_Init_Polish(\%lang);

    } elsif ($L eq "Dutch"  ||
             $L eq "Nederlands") {
      &Date_Init_Dutch(\%lang);

    } elsif ($L eq "Spanish") {
      &Date_Init_Spanish(\%lang);

    } elsif ($L eq "Portuguese") {
      &Date_Init_Portuguese(\%lang);

    } elsif ($L eq "Romanian") {
      &Date_Init_Romanian(\%lang);

    } elsif ($L eq "Italian") {
      &Date_Init_Italian(\%lang);

    } else {
      confess "ERROR: Unknown language in Date::Manip.\n";
    }

    #  variables for months
    #   Month   = "(jan|january|feb|february ... )"
    #   MonL    = [ "Jan","Feb",... ]
    #   MonthL  = [ "January","February", ... ]
    #   MonthH  = { "january"=>1, "jan"=>1, ... }

    $Lang{$L}{"MonthH"}={};
    $Lang{$L}{"MonthL"}=[];
    $Lang{$L}{"MonL"}=[];
    &Date_InitLists([$lang{"month_name"},
                     $lang{"month_abb"}],
                    \$Lang{$L}{"Month"},"lc,sort,back",
                    [$Lang{$L}{"MonthL"},
                     $Lang{$L}{"MonL"}],
                    [$Lang{$L}{"MonthH"},1]);

    #  variables for day of week
    #   Week   = "(mon|monday|tue|tuesday ... )"
    #   WL     = [ "M","T",... ]
    #   WkL    = [ "Mon","Tue",... ]
    #   WeekL  = [ "Monday","Tudesday",... ]
    #   WeekH  = { "monday"=>1,"mon"=>1,"m"=>1,... }

    $Lang{$L}{"WeekH"}={};
    $Lang{$L}{"WeekL"}=[];
    $Lang{$L}{"WkL"}=[];
    $Lang{$L}{"WL"}=[];
    &Date_InitLists([$lang{"day_name"},
                     $lang{"day_abb"}],
                    \$Lang{$L}{"Week"},"lc,sort,back",
                    [$Lang{$L}{"WeekL"},
                     $Lang{$L}{"WkL"}],
                    [$Lang{$L}{"WeekH"},1]);
    &Date_InitLists([$lang{"day_char"}],
                    "","lc",
                    [$Lang{$L}{"WL"}],
                    [\%tmp,1]);
    %{ $Lang{$L}{"WeekH"} } =
      (%{ $Lang{$L}{"WeekH"} },%tmp);

    #  variables for last
    #   Last      = "(last)"
    #   LastL     = [ "last" ]
    #   Each      = "(each)"
    #   EachL     = [ "each" ]
    #  variables for day of month
    #   DoM       = "(1st|first ... 31st)"
    #   DoML      = [ "1st","2nd",... "31st" ]
    #   DoMH      = { "1st"=>1,"first"=>1, ... "31st"=>31 }
    #  variables for week of month
    #   WoM       = "(1st|first| ... 5th|last)"
    #   WoMH      = { "1st"=>1, ... "5th"=>5,"last"=>-1 }

    $Lang{$L}{"LastL"}=$lang{"last"};
    &Date_InitStrings($lang{"last"},
                      \$Lang{$L}{"Last"},"lc,sort");

    $Lang{$L}{"EachL"}=$lang{"each"};
    &Date_InitStrings($lang{"each"},
                      \$Lang{$L}{"Each"},"lc,sort");

    $Lang{$L}{"DoMH"}={};
    $Lang{$L}{"DoML"}=[];
    &Date_InitLists([$lang{"num_suff"},
                     $lang{"num_word"}],
                    \$Lang{$L}{"DoM"},"lc,sort,back,escape",
                    [$Lang{$L}{"DoML"},
                     \@tmp],
                    [$Lang{$L}{"DoMH"},1]);

    @tmp=();
    foreach $tmp (keys %{ $Lang{$L}{"DoMH"} }) {
      $tmp2=$Lang{$L}{"DoMH"}{$tmp};
      if ($tmp2<6) {
        $Lang{$L}{"WoMH"}{$tmp} = $tmp2;
        push(@tmp,$tmp);
      }
    }
    foreach $tmp (@{ $Lang{$L}{"LastL"} }) {
      $Lang{$L}{"WoMH"}{$tmp} = -1;
      push(@tmp,$tmp);
    }
    &Date_InitStrings(\@tmp,\$Lang{$L}{"WoM"},
                      "lc,sort,back,escape");

    #  variables for AM or PM
    #   AM      = "(am)"
    #   PM      = "(pm)"
    #   AmPm    = "(am|pm)"
    #   AMstr   = "AM"
    #   PMstr   = "PM"

    &Date_InitStrings($lang{"am"},\$Lang{$L}{"AM"},"lc,sort,escape");
    &Date_InitStrings($lang{"pm"},\$Lang{$L}{"PM"},"lc,sort,escape");
    &Date_InitStrings([ @{$lang{"am"}},@{$lang{"pm"}} ],\$Lang{$L}{"AmPm"},
                      "lc,back,sort,escape");
    $Lang{$L}{"AMstr"}=$lang{"am"}[0];
    $Lang{$L}{"PMstr"}=$lang{"pm"}[0];

    #  variables for expressions used in parsing deltas
    #    Yabb   = "(?:y|yr|year|years)"
    #    Mabb   = similar for months
    #    Wabb   = similar for weeks
    #    Dabb   = similar for days
    #    Habb   = similar for hours
    #    MNabb  = similar for minutes
    #    Sabb   = similar for seconds
    #    Repl   = { "abb"=>"replacement" }
    # Whenever an abbreviation could potentially refer to two different
    # strings (M standing for Minutes or Months), the abbreviation must
    # be listed in Repl instead of in the appropriate Xabb values.  This
    # only applies to abbreviations which are substrings of other values
    # (so there is no confusion between Mn and Month).

    &Date_InitStrings($lang{"years"}  ,\$Lang{$L}{"Yabb"}, "lc,sort");
    &Date_InitStrings($lang{"months"} ,\$Lang{$L}{"Mabb"}, "lc,sort");
    &Date_InitStrings($lang{"weeks"}  ,\$Lang{$L}{"Wabb"}, "lc,sort");
    &Date_InitStrings($lang{"days"}   ,\$Lang{$L}{"Dabb"}, "lc,sort");
    &Date_InitStrings($lang{"hours"}  ,\$Lang{$L}{"Habb"}, "lc,sort");
    &Date_InitStrings($lang{"minutes"},\$Lang{$L}{"MNabb"},"lc,sort");
    &Date_InitStrings($lang{"seconds"},\$Lang{$L}{"Sabb"}, "lc,sort");
    $Lang{$L}{"Repl"}={};
    &Date_InitHash($lang{"replace"},undef,"lc",$Lang{$L}{"Repl"});

    #  variables for special dates that are offsets from now
    #    Now      = "(now|today)"
    #    Offset   = "(yesterday|tomorrow)"
    #    OffsetH  = { "yesterday"=>"-0:0:0:1:0:0:0",... ]
    #    Times    = "(noon|midnight)"
    #    TimesH   = { "noon"=>"12:00:00","midnight"=>"00:00:00" }
    #    SepHM    = hour/minute separator
    #    SepMS    = minute/second separator
    #    SepSS    = second/fraction separator

    $Lang{$L}{"TimesH"}={};
    &Date_InitHash($lang{"times"},
                   \$Lang{$L}{"Times"},"lc,sort,back",
                   $Lang{$L}{"TimesH"});
    &Date_InitStrings($lang{"now"},\$Lang{$L}{"Now"},"lc,sort");
    $Lang{$L}{"OffsetH"}={};
    &Date_InitHash($lang{"offset"},
                   \$Lang{$L}{"Offset"},"lc,sort,back",
                   $Lang{$L}{"OffsetH"});
    $Lang{$L}{"SepHM"}=$lang{"sephm"};
    $Lang{$L}{"SepMS"}=$lang{"sepms"};
    $Lang{$L}{"SepSS"}=$lang{"sepss"};

    #  variables for time zones
    #    zones      = regular expression with all zone names (EST)
    #    n2o        = a hash of all parsable zone names with their offsets
    #    tzones     = reguar expression with all tzdata timezones (US/Eastern)
    #    tz2z       = hash of all tzdata timezones to full timezone (EST#EDT)

    $zonesrfc=
      "idlw   -1200 ".  # International Date Line West
      "nt     -1100 ".  # Nome
      "hst    -1000 ".  # Hawaii Standard
      "cat    -1000 ".  # Central Alaska
      "ahst   -1000 ".  # Alaska-Hawaii Standard
      "yst    -0900 ".  # Yukon Standard
      "hdt    -0900 ".  # Hawaii Daylight
      "ydt    -0800 ".  # Yukon Daylight
      "pst    -0800 ".  # Pacific Standard
      "pdt    -0700 ".  # Pacific Daylight
      "mst    -0700 ".  # Mountain Standard
      "mdt    -0600 ".  # Mountain Daylight
      "cst    -0600 ".  # Central Standard
      "cdt    -0500 ".  # Central Daylight
      "est    -0500 ".  # Eastern Standard
      "sat    -0400 ".  # Chile
      "edt    -0400 ".  # Eastern Daylight
      "ast    -0400 ".  # Atlantic Standard
      #"nst   -0330 ".  # Newfoundland Standard      nst=North Sumatra    +0630
      "nft    -0330 ".  # Newfoundland
      #"gst   -0300 ".  # Greenland Standard         gst=Guam Standard    +1000
      #"bst   -0300 ".  # Brazil Standard            bst=British Summer   +0100
      "adt    -0300 ".  # Atlantic Daylight
      "ndt    -0230 ".  # Newfoundland Daylight
      "at     -0200 ".  # Azores
      "wat    -0100 ".  # West Africa
      "gmt    +0000 ".  # Greenwich Mean
      "ut     +0000 ".  # Universal
      "utc    +0000 ".  # Universal (Coordinated)
      "wet    +0000 ".  # Western European
      "cet    +0100 ".  # Central European
      "fwt    +0100 ".  # French Winter
      "met    +0100 ".  # Middle European
      "mewt   +0100 ".  # Middle European Winter
      "swt    +0100 ".  # Swedish Winter
      "bst    +0100 ".  # British Summer             bst=Brazil standard  -0300
      "gb     +0100 ".  # GMT with daylight savings
      "eet    +0200 ".  # Eastern Europe, USSR Zone 1
      "cest   +0200 ".  # Central European Summer
      "fst    +0200 ".  # French Summer
      "ist    +0200 ".  # Israel standard
      "mest   +0200 ".  # Middle European Summer
      "metdst +0200 ".  # An alias for mest used by HP-UX
      "sst    +0200 ".  # Swedish Summer             sst=South Sumatra    +0700
      "bt     +0300 ".  # Baghdad, USSR Zone 2
      "eest   +0300 ".  # Eastern Europe Summer
      "eetedt +0300 ".  # Eastern Europe, USSR Zone 1
      "idt    +0300 ".  # Israel Daylight
      "it     +0330 ".  # Iran
      "zp4    +0400 ".  # USSR Zone 3
      "zp5    +0500 ".  # USSR Zone 4
      "ist    +0530 ".  # Indian Standard
      "zp6    +0600 ".  # USSR Zone 5
      "nst    +0630 ".  # North Sumatra              nst=Newfoundland Std -0330
      #"sst   +0700 ".  # South Sumatra, USSR Zone 6 sst=Swedish Summer   +0200
      "hkt    +0800 ".  # Hong Kong
      "sgt    +0800 ".  # Singapore
      "cct    +0800 ".  # China Coast, USSR Zone 7
      "awst   +0800 ".  # West Australian Standard
      "wst    +0800 ".  # West Australian Standard
      "kst    +0900 ".  # Republic of Korea
      "jst    +0900 ".  # Japan Standard, USSR Zone 8
      "rok    +0900 ".  # Republic of Korea
      "cast   +0930 ".  # Central Australian Standard
      "east   +1000 ".  # Eastern Australian Standard
      "gst    +1000 ".  # Guam Standard, USSR Zone 9 gst=Greenland Std    -0300
      "cadt   +1030 ".  # Central Australian Daylight
      "eadt   +1100 ".  # Eastern Australian Daylight
      "idle   +1200 ".  # International Date Line East
      "nzst   +1200 ".  # New Zealand Standard
      "nzt    +1200 ".  # New Zealand
      "nzdt   +1300 ".  # New Zealand Daylight
      "z +0000 ".
      "a -0100 b -0200 c -0300 d -0400 e -0500 f -0600 g -0700 h -0800 ".
      "i -0900 k -1000 l -1100 m -1200 ".
      "n +0100 o +0200 p +0300 q +0400 r +0500 s +0600 t +0700 u +0800 ".
      "v +0900 w +1000 x +1100 y +1200";

    $Zone{"n2o"} = {};
    ($Zone{"zones"},%{ $Zone{"n2o"} })=
      &Date_Regexp($zonesrfc,"sort,lc,under,back",
                   "keys");

    $tmp=
      "US/Pacific  PST8PDT ".
      "US/Mountain MST7MDT ".
      "US/Central  CST6CDT ".
      "US/Eastern  EST5EDT";

    $Zone{"tz2z"} = {};
    ($Zone{"tzones"},%{ $Zone{"tz2z"} })=
      &Date_Regexp($tmp,"lc,under,back","keys");
    $Cnf{"TZ"}=&Date_TimeZone;

    #  misc. variables
    #    At     = "(?:at)"
    #    Of     = "(?:in|of)"
    #    On     = "(?:on)"
    #    Future = "(?:in)"
    #    Later  = "(?:later)"
    #    Past   = "(?:ago)"
    #    Next   = "(?:next)"
    #    Prev   = "(?:last|previous)"

    &Date_InitStrings($lang{"at"},    \$Lang{$L}{"At"},     "lc,sort");
    &Date_InitStrings($lang{"on"},    \$Lang{$L}{"On"},     "lc,sort");
    &Date_InitStrings($lang{"future"},\$Lang{$L}{"Future"}, "lc,sort");
    &Date_InitStrings($lang{"later"}, \$Lang{$L}{"Later"},  "lc,sort");
    &Date_InitStrings($lang{"past"},  \$Lang{$L}{"Past"},   "lc,sort");
    &Date_InitStrings($lang{"next"},  \$Lang{$L}{"Next"},   "lc,sort");
    &Date_InitStrings($lang{"prev"},  \$Lang{$L}{"Prev"},   "lc,sort");
    &Date_InitStrings($lang{"of"},    \$Lang{$L}{"Of"},     "lc,sort");

    #  calc mode variables
    #    Approx   = "(?:approximately)"
    #    Exact    = "(?:exactly)"
    #    Business = "(?:business)"

    &Date_InitStrings($lang{"exact"},   \$Lang{$L}{"Exact"},   "lc,sort");
    &Date_InitStrings($lang{"approx"},  \$Lang{$L}{"Approx"},  "lc,sort");
    &Date_InitStrings($lang{"business"},\$Lang{$L}{"Business"},"lc,sort");

    ############### END OF LANGUAGE INITIALIZATION
  }

  if ($Curr{"ResetWorkDay"}) {
    my($h1,$m1,$h2,$m2)=();
    if ($Cnf{"WorkDay24Hr"}) {
      ($Curr{"WDBh"},$Curr{"WDBm"})=(0,0);
      ($Curr{"WDEh"},$Curr{"WDEm"})=(24,0);
      $Curr{"WDlen"}=24*60;
      $Cnf{"WorkDayBeg"}="00:00";
      $Cnf{"WorkDayEnd"}="23:59";

    } else {
      confess "ERROR: Invalid WorkDayBeg in Date::Manip.\n"
        if (! (($h1,$m1)=&CheckTime($Cnf{"WorkDayBeg"})));
      $Cnf{"WorkDayBeg"}="$h1:$m1";
      confess "ERROR: Invalid WorkDayEnd in Date::Manip.\n"
        if (! (($h2,$m2)=&CheckTime($Cnf{"WorkDayEnd"})));
      $Cnf{"WorkDayEnd"}="$h2:$m2";

      ($Curr{"WDBh"},$Curr{"WDBm"})=($h1,$m1);
      ($Curr{"WDEh"},$Curr{"WDEm"})=($h2,$m2);

      # Work day length = h1:m1  or  0:len (len minutes)
      $h1=$h2-$h1;
      $m1=$m2-$m1;
      if ($m1<0) {
        $h1--;
        $m1+=60;
      }
      $Curr{"WDlen"}=$h1*60+$m1;
    }
    $Curr{"ResetWorkDay"}=0;
  }

  # current time
  my($s,$mn,$h,$d,$m,$y,$wday,$yday,$isdst,$ampm,$wk)=();
  if ($Cnf{"ForceDate"}=~
      /^(\d{4})-(\d{2})-(\d{2})-(\d{2}):(\d{2}):(\d{2})$/) {
       ($y,$m,$d,$h,$mn,$s)=($1,$2,$3,$4,$5,$6);
  } else {
    ($s,$mn,$h,$d,$m,$y,$wday,$yday,$isdst)=localtime(time);
    $y+=1900;
    $m++;
  }
  &Date_DateCheck(\$y,\$m,\$d,\$h,\$mn,\$s,\$ampm,\$wk);
  $Curr{"Y"}=$y;
  $Curr{"M"}=$m;
  $Curr{"D"}=$d;
  $Curr{"H"}=$h;
  $Curr{"Mn"}=$mn;
  $Curr{"S"}=$s;
  $Curr{"AmPm"}=$ampm;
  $Curr{"Now"}=&Date_Join($y,$m,$d,$h,$mn,$s);

  $Curr{"Debug"}=$Curr{"DebugVal"};

  # If we're in array context, let's return a list of config variables
  # that could be passed to Date_Init to get the same state as we're
  # currently in.
  if (wantarray) {
    # Some special variables that have to be in a specific order
    my(@special)=qw(IgnoreGlobalCnf GlobalCnf PersonalCnf PersonalCnfPath);
    my(%tmp)=map { $_,1 } @special;
    my(@tmp,$key,$val);
    foreach $key (@special) {
      $val=$Cnf{$key};
      push(@tmp,"$key=$val");
    }
    foreach $key (keys %Cnf) {
      next  if (exists $tmp{$key});
      $val=$Cnf{$key};
      push(@tmp,"$key=$val");
    }
    return @tmp;
  }
  return ();
}

sub ParseDateString {
  print "DEBUG: ParseDateString\n"  if ($Curr{"Debug"} =~ /trace/);
  local($_)=@_;
  return ""  if (! $_);

  my($y,$m,$d,$h,$mn,$s,$i,$wofm,$dofw,$wk,$tmp,$z,$num,$err,$iso,$ampm)=();
  my($date,$z2,$delta,$from,$to,$which)=();

  # We only need to reinitialize if we have to determine what NOW is.
  &Date_Init()  if (! $Curr{"InitDone"}  or  $Cnf{"UpdateCurrTZ"});

  my($L)=$Cnf{"Language"};
  my($type)=$Cnf{"DateFormat"};

  # Mode is set in DateCalc.  ParseDate only overrides it if the string
  # contains a mode.
  if      ($Lang{$L}{"Exact"}  &&
           s/$Lang{$L}{"Exact"}//) {
    $Curr{"Mode"}=0;
  } elsif ($Lang{$L}{"Approx"}  &&
           s/$Lang{$L}{"Approx"}//) {
    $Curr{"Mode"}=1;
  } elsif ($Lang{$L}{"Business"}  &&
           s/$Lang{$L}{"Business"}//) {
    $Curr{"Mode"}=2;
  } elsif (! exists $Curr{"Mode"}) {
    $Curr{"Mode"}=0;
  }

  # Unfortunately, some deltas can be parsed as dates.  An example is
  #    1 second  ==  1 2nd  ==  1 2
  # But, some dates can be parsed as deltas.  The most important being:
  #    1998010101:00:00
  # We'll check to see if a "date" can be parsed as a delta.  If so, we'll
  # assume that it is a delta (since they are much simpler, it is much
  # less likely that we'll mistake a delta for a date than vice versa)
  # unless it is an ISO-8601 date.
  #
  # This is important because we are using DateCalc to test whether a
  # string is a date or a delta.  Dates are tested first, so we need to
  # be able to pass a delta into this routine and have it correctly NOT
  # interpreted as a date.
  #
  # We will insist that the string contain something other than digits and
  # colons so that the following will get correctly interpreted as a date
  # rather than a delta:
  #     12:30
  #     19980101

  $delta="";
  $delta=&ParseDateDelta($_)  if (/[^:0-9]/);

  # Put parse in a simple loop for an easy exit.
 PARSE: {
    my(@tmp)=&Date_Split($_);
    if (@tmp) {
      ($y,$m,$d,$h,$mn,$s)=@tmp;
      last PARSE;
    }

    # Fundamental regular expressions

    my($month)=$Lang{$L}{"Month"};          # (jan|january|...)
    my(%month)=%{ $Lang{$L}{"MonthH"} };    # { jan=>1, ... }
    my($week)=$Lang{$L}{"Week"};            # (mon|monday|...)
    my(%week)=%{ $Lang{$L}{"WeekH"} };      # { mon=>1, monday=>1, ... }
    my($wom)=$Lang{$L}{"WoM"};              # (1st|...|fifth|last)
    my(%wom)=%{ $Lang{$L}{"WoMH"} };        # { 1st=>1,... fifth=>5,last=>-1 }
    my($dom)=$Lang{$L}{"DoM"};              # (1st|first|...31st)
    my(%dom)=%{ $Lang{$L}{"DoMH"} };        # { 1st=>1, first=>1, ... }
    my($ampmexp)=$Lang{$L}{"AmPm"};         # (am|pm)
    my($timeexp)=$Lang{$L}{"Times"};        # (noon|midnight)
    my($now)=$Lang{$L}{"Now"};              # (now|today)
    my($offset)=$Lang{$L}{"Offset"};        # (yesterday|tomorrow)
    my($zone)=$Zone{"zones"} . '(?:\s+|$)'; # (edt|est|...)\s+
    my($day)='\s*'.$Lang{$L}{"Dabb"};       # \s*(?:d|day|days)
    my($mabb)='\s*'.$Lang{$L}{"Mabb"};      # \s*(?:mon|month|months)
    my($wkabb)='\s*'.$Lang{$L}{"Wabb"};     # \s*(?:w|wk|week|weeks)
    my($next)='\s*'.$Lang{$L}{"Next"};      # \s*(?:next)
    my($prev)='\s*'.$Lang{$L}{"Prev"};      # \s*(?:last|previous)
    my($past)='\s*'.$Lang{$L}{"Past"};      # \s*(?:ago)
    my($future)='\s*'.$Lang{$L}{"Future"};  # \s*(?:in)
    my($later)='\s*'.$Lang{$L}{"Later"};    # \s*(?:later)
    my($at)=$Lang{$L}{"At"};                # (?:at)
    my($of)='\s*'.$Lang{$L}{"Of"};          # \s*(?:in|of)
    my($on)='(?:\s*'.$Lang{$L}{"On"}.'\s*|\s+)';
                                            # \s*(?:on)\s*    or  \s+
    my($last)='\s*'.$Lang{$L}{"Last"};      # \s*(?:last)
    my($hm)=$Lang{$L}{"SepHM"};             # :
    my($ms)=$Lang{$L}{"SepMS"};             # :
    my($ss)=$Lang{$L}{"SepSS"};             # .

    # Other regular expressions

    my($D4)='(\d{4})';            # 4 digits      (yr)
    my($YY)='(\d{4}|\d{2})';      # 2 or 4 digits (yr)
    my($DD)='(\d{2})';            # 2 digits      (mon/day/hr/min/sec)
    my($D) ='(\d{1,2})';          # 1 or 2 digit  (mon/day/hr)
    my($FS)="(?:$ss\\d+)?";       # fractional secs
    my($sep)='[\/.-]';            # non-ISO8601 m/d/yy separators
    # absolute time zone     +0700 (GMT)
    my($hzone)='(?:[0-1][0-9]|2[0-3])';                    # 00 - 23
    my($mzone)='(?:[0-5][0-9])';                           # 00 - 59
    my($zone2)='(?:\s*([+-](?:'."$hzone$mzone|$hzone:$mzone|$hzone))".
                                                           # +0700 +07:00 -07
      '(?:\s*\([^)]+\))?)';                                # (GMT)

    # A regular expression for the time EXCEPT for the hour part
    my($mnsec)="$hm$DD(?:$ms$DD$FS)?(?:\\s*$ampmexp)?";

    # A special regular expression for /YYYY:HH:MN:SS used by Apache
    my($apachetime)='(/\d{4}):' . "$DD$hm$DD$ms$DD";

    my($time)="";
    $ampm="";
    $date="";

    # Substitute all special time expressions.
    if (/(^|[^a-z])$timeexp($|[^a-z])/i) {
      $tmp=$2;
      $tmp=$Lang{$L}{"TimesH"}{$tmp};
      s/(^|[^a-z])$timeexp($|[^a-z])/$1 $tmp $3/i;
    }

    # Remove some punctuation
    s/[,]/ /g;

    # Make sure that ...7EST works (i.e. a timezone immediately following
    # a digit.
    s/(\d)$zone(\s+|$|[0-9])/$1 $2$3/i;
    $zone = '\s+'.$zone;

    # Remove the time
    $iso=1;
    if (/$D$mnsec/i || /$ampmexp/i) {
      $iso=0;
      $tmp=0;
      $tmp=1  if (/$mnsec$zone2?\s*$/i);
      $tmp=0  if (/$ampmexp/i);
      if (s/$apachetime$zone()/$1 /i  ||
          s/$apachetime$zone2?/$1 /i  ||
          s/(^|[^a-z])$at\s*$D$mnsec$zone()/$1 /i  ||
          s/(^|[^a-z])$at\s*$D$mnsec$zone2?/$1 /i  ||
          s/(^|[^0-9])(\d)$mnsec$zone()/$1 /i ||
          s/(^|[^0-9])(\d)$mnsec$zone2?/$1 /i ||
          (s/()$DD$mnsec$zone()/ /i and (($iso=$tmp) || 1)) ||
          (s/()$DD$mnsec$zone2?/ /i and (($iso=$tmp) || 1))  ||
          s/(^|$at\s*|\s+)$D()()\s*$ampmexp$zone()/ /i  ||
          s/(^|$at\s*|\s+)$D()()\s*$ampmexp$zone2?/ /i  ||
          0
         ) {
        ($h,$mn,$s,$ampm,$z,$z2)=($2,$3,$4,$5,$6,$7);
        if (defined ($z)) {
          if ($z =~ /^[+-]\d{2}:\d{2}$/) {
            $z=~ s/://;
          } elsif ($z =~ /^[+-]\d{2}$/) {
            $z .= "00";
          }
        }
        $time=1;
        &Date_TimeCheck(\$h,\$mn,\$s,\$ampm);
        $y=$m=$d="";
        # We're going to be calling TimeCheck again below (when we check the
        # final date), so get rid of $ampm so that we don't have an error
        # due to "15:30:00 PM".  It'll get reset below.
        $ampm="";
        last PARSE  if (/^\s*$/);
      }
    }
    $time=0  if ($time ne "1");
    s/\s+$//;
    s/^\s+//;

    # Parse ISO 8601 dates now (which may still have a zone stuck to it).
    if ( ($iso && /^[0-9-]+(W[0-9-]+)?$zone?$/i)  ||
         ($iso && /^[0-9-]+(W[0-9-]+)?$zone2?$/i)  ||
         0) {
      # ISO 8601 dates
      s,-, ,g;            # Change all ISO8601 seps to spaces
      s/^\s+//;
      s/\s+$//;

      if (/^$D4\s*$DD\s*$DD\s*$DD(?:$DD(?:$DD\d*)?)?$zone2?$/  ||
          /^$D4\s*$DD\s*$DD\s*$DD(?:$DD(?:$DD\d*)?)?$zone?()$/i  ||
          /^$DD\s+$DD\s*$DD\s*$DD(?:$DD(?:$DD\d*)?)?$zone2?$/  ||
          /^$DD\s+$DD\s*$DD\s*$DD(?:$DD(?:$DD\d*)?)?$zone?()$/i  ||
          0
         ) {
        # ISO 8601 Dates with times
        #    YYYYMMDDHHMNSSFFFF
        #    YYYYMMDDHHMNSS
        #    YYYYMMDDHHMN
        #    YYYYMMDDHH
        #    YY MMDDHHMNSSFFFF
        #    YY MMDDHHMNSS
        #    YY MMDDHHMN
        #    YY MMDDHH
        ($y,$m,$d,$h,$mn,$s,$tmp,$z2)=($1,$2,$3,$4,$5,$6,$7,$8);
        $z=""    if (! $h);
        return ""  if ($tmp  and  $z);
        $z=$tmp    if ($tmp  and  $tmp);
        return ""  if ($time);
        last PARSE;

      } elsif (/^$D4(?:\s*$DD(?:\s*$DD)?)?$/  ||
               /^$DD(?:\s+$DD(?:\s*$DD)?)?$/) {
        # ISO 8601 Dates
        #    YYYYMMDD
        #    YYYYMM
        #    YYYY
        #    YY MMDD
        #    YY MM
        #    YY
        ($y,$m,$d)=($1,$2,$3);
        last PARSE;

      } elsif (/^$YY\s+$D\s+$D/) {
        # YY-M-D
        ($y,$m,$d)=($1,$2,$3);
        last PARSE;

      } elsif (/^$YY\s*W$DD\s*(\d)?$/i) {
        # YY-W##-D
        ($y,$wofm,$dofw)=($1,$2,$3);
        ($y,$m,$d)=&Date_NthWeekOfYear($y,$wofm,$dofw);
        last PARSE;

      } elsif (/^$D4\s*(\d{3})$/ ||
               /^$DD\s*(\d{3})$/) {
        # YYDOY
        ($y,$which)=($1,$2);
        ($y,$m,$d)=&Date_NthDayOfYear($y,$which);
        last PARSE;

      } else {
        return "";
      }
    }

    # All deltas that are not ISO-8601 dates are NOT dates.
    return ""  if ($Curr{"InCalc"}  &&  $delta);
    return &DateCalc_DateDelta($Curr{"Now"},$delta)  if ($delta);

    # Check for some special types of dates (next, prev)
    foreach $from (keys %{ $Lang{$L}{"Repl"} }) {
      $to=$Lang{$L}{"Repl"}{$from};
      s/(^|[^a-z])$from($|[^a-z])/$1$to$2/i;
    }
    if (/$wom/i  ||  /$future/i  ||  /$later/i  ||  /$past/i  ||
        /$next/i  ||  /$prev/i  ||  /^$week$/i  ||  /$wkabb/i) {
      $tmp=0;

      if (/^$wom\s*$week$of\s*$month\s*$YY?$/i) {
        # last friday in October 95
        ($wofm,$dofw,$m,$y)=($1,$2,$3,$4);
        # fix $m, $y
        return ""  if (&Date_DateCheck(\$y,\$m,\$d,\$h,\$mn,\$s,\$ampm,\$wk));
        $dofw=$week{lc($dofw)};
        $wofm=$wom{lc($wofm)};
        # Get the first day of the month
        $date=&Date_Join($y,$m,1,$h,$mn,$s);
        if ($wofm==-1) {
          $date=&DateCalc_DateDelta($date,"+0:1:0:0:0:0:0",\$err,0);
          $date=&Date_GetPrev($date,$dofw,0);
        } else {
          for ($i=0; $i<$wofm; $i++) {
            if ($i==0) {
              $date=&Date_GetNext($date,$dofw,1);
            } else {
              $date=&Date_GetNext($date,$dofw,0);
            }
          }
        }
        last PARSE;

      } elsif (/^$last$day$of\s*$month(?:$of?\s*$YY)?/i) {
        # last day in month
        ($m,$y)=($1,$2);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $y=&Date_FixYear($y)  if (! defined $y  or  length($y)<4);
        $m=$month{lc($m)};
        $d=&Date_DaysInMonth($m,$y);
        last PARSE;

      } elsif (/^$next?\s*$week$/i) {
        # next friday
        # friday
        ($dofw)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&Date_GetNext($Curr{"Now"},$dofw,0,$h,$mn,$s);
        last PARSE;

      } elsif (/^$prev\s*$week$/i) {
        # last friday
        ($dofw)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&Date_GetPrev($Curr{"Now"},$dofw,0,$h,$mn,$s);
        last PARSE;

      } elsif (/^$next$wkabb$/i) {
        # next week
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"+0:0:1:0:0:0:0",\$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;
      } elsif (/^$prev$wkabb$/i) {
        # last week
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"-0:0:1:0:0:0:0",\$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;

      } elsif (/^$next$mabb$/i) {
        # next month
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"+0:1:0:0:0:0:0",\$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;
      } elsif (/^$prev$mabb$/i) {
        # last month
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"-0:1:0:0:0:0:0",\$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;

      } elsif (/^$future\s*(\d+)$day$/i  ||
               /^(\d+)$day$later$/i) {
        # in 2 days
        # 2 days later
        ($num)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"+0:0:0:$num:0:0:0",
                                  \$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;
      } elsif (/^(\d+)$day$past$/i) {
        # 2 days ago
        ($num)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"-0:0:0:$num:0:0:0",
                                 \$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;

      } elsif (/^$future\s*(\d+)$wkabb$/i  ||
               /^(\d+)$wkabb$later$/i) {
        # in 2 weeks
        # 2 weeks later
        ($num)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"+0:0:$num:0:0:0:0",
                                  \$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;
      } elsif (/^(\d+)$wkabb$past$/i) {
        # 2 weeks ago
        ($num)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"-0:0:$num:0:0:0:0",
                                 \$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;

      } elsif (/^$future\s*(\d+)$mabb$/i  ||
               /^(\d+)$mabb$later$/i) {
        # in 2 months
        # 2 months later
        ($num)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"+0:$num:0:0:0:0:0",
                                  \$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;
      } elsif (/^(\d+)$mabb$past$/i) {
        # 2 months ago
        ($num)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"-0:$num:0:0:0:0:0",
                                  \$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;

      } elsif (/^$week$future\s*(\d+)$wkabb$/i  ||
               /^$week\s*(\d+)$wkabb$later$/i) {
        # friday in 2 weeks
        # friday 2 weeks later
        ($dofw,$num)=($1,$2);
        $tmp="+";
      } elsif (/^$week\s*(\d+)$wkabb$past$/i) {
        # friday 2 weeks ago
        ($dofw,$num)=($1,$2);
        $tmp="-";
      } elsif (/^$future\s*(\d+)$wkabb$on$week$/i  ||
               /^(\d+)$wkabb$later$on$week$/i) {
        # in 2 weeks on friday
        # 2 weeks later on friday
        ($num,$dofw)=($1,$2);
        $tmp="+"
      } elsif (/^(\d+)$wkabb$past$on$week$/i) {
        # 2 weeks ago on friday
        ($num,$dofw)=($1,$2);
        $tmp="-";
      } elsif (/^$week\s*$wkabb$/i) {
        # monday week    (British date: in 1 week on monday)
        $dofw=$1;
        $num=1;
        $tmp="+";
      } elsif (/^$now\s*$wkabb$/i) {
        # today week     (British date: 1 week from today)
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},"+0:0:1:0:0:0:0",\$err,0);
        $date=&Date_SetTime($date,$h,$mn,$s)  if (defined $h);
        last PARSE;
      } elsif (/^$offset\s*$wkabb$/i) {
        # tomorrow week  (British date: 1 week from tomorrow)
        ($offset)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $offset=$Lang{$L}{"OffsetH"}{lc($offset)};
        $date=&DateCalc_DateDelta($Curr{"Now"},$offset,\$err,0);
        $date=&DateCalc_DateDelta($date,"+0:0:1:0:0:0:0",\$err,0);
        if ($time) {
          return ""
            if (&Date_DateCheck(\$y,\$m,\$d,\$h,\$mn,\$s,\$ampm,\$wk));
          $date=&Date_SetTime($date,$h,$mn,$s);
        }
        last PARSE;
      }

      if ($tmp) {
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=&DateCalc_DateDelta($Curr{"Now"},
                                  $tmp . "0:0:$num:0:0:0:0",\$err,0);
        $date=&Date_GetPrev($date,$Cnf{"FirstDay"},1);
        $date=&Date_GetNext($date,$dofw,1,$h,$mn,$s);
        last PARSE;
      }
    }

    # Change (2nd, second) to 2
    $tmp=0;
    if (/(^|[^a-z0-9])$dom($|[^a-z0-9])/i) {
      if (/^\s*$dom\s*$/) {
        ($d)=($1);
        $d=$dom{lc($d)};
        $m=$Curr{"M"};
        last PARSE;
      }
      $tmp=lc($2);
      $tmp=$dom{"$tmp"};
      s/(^|[^a-z])$dom($|[^a-z])/$1 $tmp $3/i;
      s/^\s+//;
      s/\s+$//;
    }

    # Another set of special dates (Nth week)
    if (/^$D\s*$week(?:$of?\s*$YY)?$/i) {
      # 22nd sunday in 1996
      ($which,$dofw,$y)=($1,$2,$3);
      $y=$Curr{"Y"}  if (! $y);
      $tmp=&Date_GetNext("$y-01-01",$dofw,0);
      if ($which>1) {
        $tmp=&DateCalc_DateDelta($tmp,"+0:0:".($which-1).":0:0:0:0",\$err,0);
      }
      ($y,$m,$d)=(&Date_Split($tmp))[0..2];
      last PARSE;
    } elsif (/^$week$wkabb\s*$D(?:$of?\s*$YY)?$/i  ||
             /^$week\s*$D$wkabb(?:$of?\s*$YY)?$/i) {
      # sunday week 22 in 1996
      # sunday 22nd week in 1996
      ($dofw,$which,$y)=($1,$2,$3);
      ($y,$m,$d)=&Date_NthWeekOfYear($y,$which,$dofw);
      last PARSE;
    }

    # Get rid of day of week
    if (/(^|[^a-z])$week($|[^a-z])/i) {
      $wk=$2;
      (s/(^|[^a-z])$week,/$1 /i) ||
        s/(^|[^a-z])$week($|[^a-z])/$1 $3/i;
      s/^\s+//;
      s/\s+$//;
    }

    {
      # Non-ISO8601 dates
      s,\s*$sep\s*, ,g;     # change all non-ISO8601 seps to spaces
      s,^\s*,,;             # remove leading/trailing space
      s,\s*$,,;

      if (/^$D\s+$D(?:\s+$YY)?$/) {
        # MM DD YY (DD MM YY non-US)
        ($m,$d,$y)=($1,$2,$3);
        ($m,$d)=($d,$m)  if ($type ne "US");
        last PARSE;

      } elsif (/^$D4\s*$D\s*$D$/) {
        # YYYY MM DD
        ($y,$m,$d)=($1,$2,$3);
        last PARSE;

      } elsif (s/(^|[^a-z])$month($|[^a-z])/$1 $3/i) {
        ($m)=($2);

        if (/^\s*$D(?:\s+$YY)?\s*$/) {
          # mmm DD YY
          # DD mmm YY
          # DD YY mmm
          ($d,$y)=($1,$2);
          last PARSE;

        } elsif (/^\s*$D$D4\s*$/) {
          # mmm DD YYYY
          # DD mmm YYYY
          # DD YYYY mmm
          ($d,$y)=($1,$2);
          last PARSE;

        } elsif (/^\s*$D4\s*$D\s*$/) {
          # mmm YYYY DD
          # YYYY mmm DD
          # YYYY DD mmm
          ($y,$d)=($1,$2);
          last PARSE;

        } elsif (/^\s*$D4\s*$/) {
          # mmm YYYY
          # YYYY mmm
          ($y,$d)=($1,1);
          last PARSE;

        } else {
          return "";
        }

      } elsif (/^epoch\s*(\d+)$/i) {
        $s=$1;
        $date=&DateCalc("1970-01-01 00:00 GMT","+0:0:$s");

      } elsif (/^$now$/i) {
        # now, today
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $date=$Curr{"Now"};
        if ($time) {
          return ""
            if (&Date_DateCheck(\$y,\$m,\$d,\$h,\$mn,\$s,\$ampm,\$wk));
          $date=&Date_SetTime($date,$h,$mn,$s);
        }
        last PARSE;

      } elsif (/^$offset$/i) {
        # yesterday, tomorrow
        ($offset)=($1);
        &Date_Init()  if (! $Cnf{"UpdateCurrTZ"});
        $offset=$Lang{$L}{"OffsetH"}{lc($offset)};
        $date=&DateCalc_DateDelta($Curr{"Now"},$offset,\$err,0);
        if ($time) {
          return ""
            if (&Date_DateCheck(\$y,\$m,\$d,\$h,\$mn,\$s,\$ampm,\$wk));
          $date=&Date_SetTime($date,$h,$mn,$s);
        }
        last PARSE;

      } else {
        return "";
      }
    }
  }

  if (! $date) {
    return ""  if (&Date_DateCheck(\$y,\$m,\$d,\$h,\$mn,\$s,\$ampm,\$wk));
    $date=&Date_Join($y,$m,$d,$h,$mn,$s);
  }
  $date=&Date_ConvTZ($date,$z);
  return $date;
}

sub ParseDate {
  print "DEBUG: ParseDate\n"  if ($Curr{"Debug"} =~ /trace/);
  &Date_Init()  if (! $Curr{"InitDone"});
  my($args,@args,@a,$ref,$date)=();
  @a=@_;

  # @a : is the list of args to ParseDate.  Currently, only one argument
  #      is allowed and it must be a scalar (or a reference to a scalar)
  #      or a reference to an array.

  if ($#a!=0) {
    print "ERROR:  Invalid number of arguments to ParseDate.\n";
    return "";
  }
  $args=$a[0];
  $ref=ref $args;
  if (! $ref) {
    return $args  if (&Date_Split($args));
    @args=($args);
  } elsif ($ref eq "ARRAY") {
    @args=@$args;
  } elsif ($ref eq "SCALAR") {
    return $$args  if (&Date_Split($$args));
    @args=($$args);
  } else {
    print "ERROR:  Invalid arguments to ParseDate.\n";
    return "";
  }
  @a=@args;

  # @args : a list containing all the arguments (dereferenced if appropriate)
  # @a    : a list containing all the arguments currently being examined
  # $ref  : nil, "SCALAR", or "ARRAY" depending on whether a scalar, a
  #         reference to a scalar, or a reference to an array was passed in
  # $args : the scalar or refererence passed in

 PARSE: while($#a>=0) {
    $date=join(" ",@a);
    $date=&ParseDateString($date);
    last  if ($date);
    pop(@a);
  } # PARSE

  splice(@args,0,$#a + 1);
  @$args= @args  if (defined $ref  and  $ref eq "ARRAY");
  $date;
}

sub Date_Cmp {
  my($D1,$D2)=@_;
  my($date1)=&ParseDateString($D1);
  my($date2)=&ParseDateString($D2);
  return $date1 cmp $date2;
}

# **NOTE**
# The calc routines all call parse routines, so it is never necessary to
# call Date_Init in the calc routines.
sub DateCalc {
  print "DEBUG: DateCalc\n"  if ($Curr{"Debug"} =~ /trace/);
  my($D1,$D2,@arg)=@_;
  my($ref,$err,$errref,$mode)=();

  $errref=shift(@arg);
  $ref=0;
  if (defined $errref) {
    if (ref $errref) {
      $mode=shift(@arg);
      $ref=1;
    } else {
      $mode=$errref;
      $errref="";
    }
  }

  my(@date,@delta,$ret,$tmp,$old)=();

  if (defined $mode  and  $mode>=0  and  $mode<=3) {
    $Curr{"Mode"}=$mode;
  } else {
    $Curr{"Mode"}=0;
  }

  $old=$Curr{"InCalc"};
  $Curr{"InCalc"}=1;
  if ($tmp=&ParseDateString($D1)) {
    # If we've already parsed the date, we don't want to do it a second
    # time (so we don't convert timezones twice).
    if (&Date_Split($D1)) {
      push(@date,$D1);
    } else {
      push(@date,$tmp);
    }
  } elsif ($tmp=&ParseDateDelta($D1)) {
    push(@delta,$tmp);
  } else {
    $$errref=1  if ($ref);
    return;
  }

  if ($tmp=&ParseDateString($D2)) {
    if (&Date_Split($D2)) {
      push(@date,$D2);
    } else {
      push(@date,$tmp);
    }
  } elsif ($tmp=&ParseDateDelta($D2)) {
    push(@delta,$tmp);
  } else {
    $$errref=2  if ($ref);
    return;
  }
  $mode=$Curr{"Mode"};
  $Curr{"InCalc"}=$old;

  if ($#date==1) {
    $ret=&DateCalc_DateDate(@date,$mode);
  } elsif ($#date==0) {
    $ret=&DateCalc_DateDelta(@date,@delta,\$err,$mode);
    $$errref=$err  if ($ref);
  } else {
    $ret=&DateCalc_DeltaDelta(@delta,$mode);
  }
  $ret;
}

sub ParseDateDelta {
  print "DEBUG: ParseDateDelta\n"  if ($Curr{"Debug"} =~ /trace/);
  my($args,@args,@a,$ref)=();
  local($_)=();
  @a=@_;

  # @a : is the list of args to ParseDateDelta.  Currently, only one argument
  #      is allowed and it must be a scalar (or a reference to a scalar)
  #      or a reference to an array.

  if ($#a!=0) {
    print "ERROR:  Invalid number of arguments to ParseDateDelta.\n";
    return "";
  }
  $args=$a[0];
  $ref=ref $args;
  if (! $ref) {
    @args=($args);
  } elsif ($ref eq "ARRAY") {
    @args=@$args;
  } elsif ($ref eq "SCALAR") {
    @args=($$args);
  } else {
    print "ERROR:  Invalid arguments to ParseDateDelta.\n";
    return "";
  }
  @a=@args;

  # @args : a list containing all the arguments (dereferenced if appropriate)
  # @a    : a list containing all the arguments currently being examined
  # $ref  : nil, "SCALAR", or "ARRAY" depending on whether a scalar, a
  #         reference to a scalar, or a reference to an array was passed in
  # $args : the scalar or refererence passed in

  my(@colon,@delta,$delta,$dir,$colon,$sign,$val)=();
  my($len,$tmp,$tmp2,$tmpl)=();
  my($from,$to)=();
  my($workweek)=$Cnf{"WorkWeekEnd"}-$Cnf{"WorkWeekBeg"}+1;

  &Date_Init()  if (! $Curr{"InitDone"});
  my($signexp)='([+-]?)';
  my($numexp)='(\d+)';
  my($exp1)="(?: \\s* $signexp \\s* $numexp \\s*)";
  my($yexp,$mexp,$wexp,$dexp,$hexp,$mnexp,$sexp,$i)=();
  $yexp=$mexp=$wexp=$dexp=$hexp=$mnexp=$sexp="()()";
  $yexp ="(?: $exp1 ". $Lang{$Cnf{"Language"}}{"Yabb"} .")?";
  $mexp ="(?: $exp1 ". $Lang{$Cnf{"Language"}}{"Mabb"} .")?";
  $wexp ="(?: $exp1 ". $Lang{$Cnf{"Language"}}{"Wabb"} .")?";
  $dexp ="(?: $exp1 ". $Lang{$Cnf{"Language"}}{"Dabb"} .")?";
  $hexp ="(?: $exp1 ". $Lang{$Cnf{"Language"}}{"Habb"} .")?";
  $mnexp="(?: $exp1 ". $Lang{$Cnf{"Language"}}{"MNabb"}.")?";
  $sexp ="(?: $exp1 ". $Lang{$Cnf{"Language"}}{"Sabb"} ."?)?";
  my($future)=$Lang{$Cnf{"Language"}}{"Future"};
  my($later)=$Lang{$Cnf{"Language"}}{"Later"};
  my($past)=$Lang{$Cnf{"Language"}}{"Past"};

  $delta="";
 PARSE: while (@a) {
    $_ = join(" ", grep {defined;} @a);
    s/\s+$//;

    # Mode is set in DateCalc.  ParseDateDelta only overrides it if the
    # string contains a mode.
    if      ($Lang{$Cnf{"Language"}}{"Exact"} &&
             s/$Lang{$Cnf{"Language"}}{"Exact"}//) {
      $Curr{"Mode"}=0;
    } elsif ($Lang{$Cnf{"Language"}}{"Approx"} &&
             s/$Lang{$Cnf{"Language"}}{"Approx"}//) {
      $Curr{"Mode"}=1;
    } elsif ($Lang{$Cnf{"Language"}}{"Business"} &&
             s/$Lang{$Cnf{"Language"}}{"Business"}//) {
      $Curr{"Mode"}=2;
    } elsif (! exists $Curr{"Mode"}) {
      $Curr{"Mode"}=0;
    }
    $workweek=7  if ($Curr{"Mode"} != 2);

    foreach $from (keys %{ $Lang{$Cnf{"Language"}}{"Repl"} }) {
      $to=$Lang{$Cnf{"Language"}}{"Repl"}{$from};
      s/(^|[^a-z])$from($|[^a-z])/$1$to$2/i;
    }

    # in or ago
    #
    # We need to make sure that $later, $future, and $past don't contain each
    # other... Romanian pointed this out where $past is "in urma" and $future
    # is "in".  When they do, we have to take this into account.
    #   $len  length of best match (greatest wins)
    #   $tmp  string after best match
    #   $dir  direction (prior, after) of best match
    #
    #   $tmp2 string before/after current match
    #   $tmpl length of current match

    $len=0;
    $tmp=$_;
    $dir=1;

    $tmp2=$_;
    if ($tmp2 =~ s/(^|[^a-z])($future)($|[^a-z])/$1 $3/i) {
      $tmpl=length($2);
      if ($tmpl>$len) {
        $tmp=$tmp2;
        $dir=1;
        $len=$tmpl;
      }
    }

    $tmp2=$_;
    if ($tmp2 =~ s/(^|[^a-z])($later)($|[^a-z])/$1 $3/i) {
      $tmpl=length($2);
      if ($tmpl>$len) {
        $tmp=$tmp2;
        $dir=1;
        $len=$tmpl;
      }
    }

    $tmp2=$_;
    if ($tmp2 =~ s/(^|[^a-z])($past)($|[^a-z])/$1 $3/i) {
      $tmpl=length($2);
      if ($tmpl>$len) {
        $tmp=$tmp2;
        $dir=-1;
        $len=$tmpl;
      }
    }

    $_ = $tmp;
    s/\s*$//;

    # the colon part of the delta
    $colon="";
    if (s/($signexp?$numexp?(:($signexp?$numexp)?){1,6})$//) {
      $colon=$1;
      s/\s+$//;
    }
    @colon=split(/:/,$colon);

    # the non-colon part of the delta
    $sign="+";
    @delta=();
    $i=6;
    foreach $exp1 ($yexp,$mexp,$wexp,$dexp,$hexp,$mnexp,$sexp) {
      last  if ($#colon>=$i--);
      $val=0;
      if (s/^$exp1//ix) {
        $val=$2   if ($2);
        $sign=$1  if ($1);
      }
      push(@delta,"$sign$val");
    }
    if (! /^\s*$/) {
      pop(@a);
      next PARSE;
    }

    # make sure that the colon part has a sign
    for ($i=0; $i<=$#colon; $i++) {
      $val=0;
      if ($colon[$i] =~ /^$signexp$numexp?/) {
        $val=$2   if ($2);
        $sign=$1  if ($1);
      }
      $colon[$i] = "$sign$val";
    }

    # combine the two
    push(@delta,@colon);
    if ($dir<0) {
      for ($i=0; $i<=$#delta; $i++) {
        $delta[$i] =~ tr/-+/+-/;
      }
    }

    # form the delta and shift off the valid part
    $delta=join(":",@delta);
    splice(@args,0,$#a+1);
    @$args=@args  if (defined $ref  and  $ref eq "ARRAY");
    last PARSE;
  }

  $delta=&Delta_Normalize($delta,$Curr{"Mode"});
  return $delta;
}

sub UnixDate {
  print "DEBUG: UnixDate\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,@format)=@_;
  local($_)=();
  my($format,%f,$out,@out,$c,$date1,$date2,$tmp)=();
  my($scalar)=();
  $date=&ParseDateString($date);
  return  if (! $date);

  my($y,$m,$d,$h,$mn,$s)=($f{"Y"},$f{"m"},$f{"d"},$f{"H"},$f{"M"},$f{"S"})=
    &Date_Split($date);
  $f{"y"}=substr $f{"Y"},2;
  &Date_Init()  if (! $Curr{"InitDone"});

  if (! wantarray) {
    $format=join(" ",@format);
    @format=($format);
    $scalar=1;
  }

  # month, week
  $_=$m;
  s/^0//;
  $f{"b"}=$f{"h"}=$Lang{$Cnf{"Language"}}{"MonL"}[$_-1];
  $f{"B"}=$Lang{$Cnf{"Language"}}{"MonthL"}[$_-1];
  $_=$m;
  s/^0/ /;
  $f{"f"}=$_;
  $f{"U"}=&Date_WeekOfYear($m,$d,$y,7);
  $f{"W"}=&Date_WeekOfYear($m,$d,$y,1);

  # check week 52,53 and 0
  $f{"G"}=$f{"L"}=$y;
  if ($f{"W"}>=52 || $f{"U"}>=52) {
    my($dd,$mm,$yy)=($d,$m,$y);
    $dd+=7;
    if ($dd>31) {
      $dd-=31;
      $mm=1;
      $yy++;
      if (&Date_WeekOfYear($mm,$dd,$yy,1)==2) {
        $f{"G"}=$yy;
        $f{"W"}=1;
      }
      if (&Date_WeekOfYear($mm,$dd,$yy,7)==2) {
        $f{"L"}=$yy;
        $f{"U"}=1;
      }
    }
  }
  if ($f{"W"}==0) {
    my($dd,$mm,$yy)=($d,$m,$y);
    $dd-=7;
    $dd+=31  if ($dd<1);
    $yy--;
    $mm=12;
    $f{"G"}=$yy;
    $f{"W"}=&Date_WeekOfYear($mm,$dd,$yy,1)+1;
  }
  if ($f{"U"}==0) {
    my($dd,$mm,$yy)=($d,$m,$y);
    $dd-=7;
    $dd+=31  if ($dd<1);
    $yy--;
    $mm=12;
    $f{"L"}=$yy;
    $f{"U"}=&Date_WeekOfYear($mm,$dd,$yy,7)+1;
  }

  $f{"U"}="0".$f{"U"}  if (length $f{"U"} < 2);
  $f{"W"}="0".$f{"W"}  if (length $f{"W"} < 2);

  # day
  $f{"j"}=&Date_DayOfYear($m,$d,$y);
  $f{"j"} = "0" . $f{"j"}   while (length($f{"j"})<3);
  $_=$d;
  s/^0/ /;
  $f{"e"}=$_;
  $f{"w"}=&Date_DayOfWeek($m,$d,$y);
  $f{"v"}=$Lang{$Cnf{"Language"}}{"WL"}[$f{"w"}-1];
  $f{"v"}=" ".$f{"v"}  if (length $f{"v"} < 2);
  $f{"a"}=$Lang{$Cnf{"Language"}}{"WkL"}[$f{"w"}-1];
  $f{"A"}=$Lang{$Cnf{"Language"}}{"WeekL"}[$f{"w"}-1];
  $f{"E"}=&Date_DaySuffix($f{"e"});

  # hour
  $_=$h;
  s/^0/ /;
  $f{"k"}=$_;
  $f{"i"}=$f{"k"}+1;
  $f{"i"}=$f{"k"};
  $f{"i"}=12          if ($f{"k"}==0);
  $f{"i"}=$f{"k"}-12  if ($f{"k"}>12);
  $f{"i"}=$f{"i"}-12  if ($f{"i"}>12);
  $f{"i"}=" ".$f{"i"} if (length($f{"i"})<2);
  $f{"I"}=$f{"i"};
  $f{"I"}=~ s/^ /0/;
  $f{"p"}=$Lang{$Cnf{"Language"}}{"AMstr"};
  $f{"p"}=$Lang{$Cnf{"Language"}}{"PMstr"}  if ($f{"k"}>11);

  # minute, second, timezone
  $f{"o"}=&Date_SecsSince1970($m,$d,$y,$h,$mn,$s);
  $f{"s"}=&Date_SecsSince1970GMT($m,$d,$y,$h,$mn,$s);
  $f{"Z"}=($Cnf{"ConvTZ"} eq "IGNORE" or $Cnf{"ConvTZ"} eq "" ?
           $Cnf{"TZ"} : $Cnf{"ConvTZ"});
  $f{"z"}=$Zone{"n2o"}{lc $f{"Z"}};

  # date, time
  $f{"c"}=qq|$f{"a"} $f{"b"} $f{"e"} $h:$mn:$s $y|;
  $f{"C"}=$f{"u"}=
    qq|$f{"a"} $f{"b"} $f{"e"} $h:$mn:$s $f{"z"} $y|;
  $f{"g"}=qq|$f{"a"}, $d $f{"b"} $y $h:$mn:$s $f{"z"}|;
  $f{"D"}=$f{"x"}=qq|$m/$d/$f{"y"}|;
  $f{"r"}=qq|$f{"I"}:$mn:$s $f{"p"}|;
  $f{"R"}=qq|$h:$mn|;
  $f{"T"}=$f{"X"}=qq|$h:$mn:$s|;
  $f{"V"}=qq|$m$d$h$mn$f{"y"}|;
  $f{"Q"}="$y$m$d";
  $f{"q"}=qq|$y$m$d$h$mn$s|;
  $f{"P"}=qq|$y$m$d$h:$mn:$s|;
  $f{"F"}=qq|$f{"A"}, $f{"B"} $f{"e"}, $f{"Y"}|;
  if ($f{"W"}==0) {
    $y--;
    $tmp=&Date_WeekOfYear(12,31,$y,1);
    $tmp="0$tmp"  if (length($tmp) < 2);
    $f{"J"}=qq|$y-W$tmp-$f{"w"}|;
  } else {
    $f{"J"}=qq|$f{"G"}-W$f{"W"}-$f{"w"}|;
  }
  $f{"K"}=qq|$y-$f{"j"}|;
  # %l is a special case.  Since it requires the use of the calculator
  # which requires this routine, an infinite recursion results.  To get
  # around this, %l is NOT determined every time this is called so the
  # recursion breaks.

  # other formats
  $f{"n"}="\n";
  $f{"t"}="\t";
  $f{"%"}="%";
  $f{"+"}="+";

  foreach $format (@format) {
    $format=reverse($format);
    $out="";
    while ($format ne "") {
      $c=chop($format);
      if ($c eq "%") {
        $c=chop($format);
        if ($c eq "l") {
          &Date_Init();
          $date1=&DateCalc_DateDelta($Curr{"Now"},"-0:6:0:0:0:0:0");
          $date2=&DateCalc_DateDelta($Curr{"Now"},"+0:6:0:0:0:0:0");
          if (&Date_Cmp($date,$date1)>1  &&  &Date_Cmp($date,$date2)>1) {
            $f{"l"}=qq|$f{"b"} $f{"e"} $h:$mn|;
          } else {
            $f{"l"}=qq|$f{"b"} $f{"e"}  $f{"Y"}|;
          }
          $out .= $f{"$c"};
        } elsif (exists $f{"$c"}) {
          $out .= $f{"$c"};
        } else {
          $out .= $c;
        }
      } else {
        $out .= $c;
      }
    }
    push(@out,$out);
  }
  if ($scalar) {
    return $out[0];
  } else {
    return (@out);
  }
}

# Can't be in "use integer" because we're doing decimal arithmatic
no integer;
sub Delta_Format {
  print "DEBUG: Delta_Format\n"  if ($Curr{"Debug"} =~ /trace/);
  my($delta,$dec,@format)=@_;
  $delta=&ParseDateDelta($delta);
  return ""  if (! $delta);
  my(@out,%f,$out,$c1,$c2,$scalar,$format)=();
  local($_)=$delta;
  my($y,$M,$w,$d,$h,$m,$s)=&Delta_Split($delta);
  # Get rid of positive signs.
  ($y,$M,$w,$d,$h,$m,$s)=map { 1*$_; }($y,$M,$w,$d,$h,$m,$s);

  if (defined $dec  &&  $dec>0) {
    $dec="%." . ($dec*1) . "f";
  } else {
    $dec="%f";
  }

  if (! wantarray) {
    $format=join(" ",@format);
    @format=($format);
    $scalar=1;
  }

  # Length of each unit in seconds
  my($sl,$ml,$hl,$dl,$wl)=();
  $sl = 1;
  $ml = $sl*60;
  $hl = $ml*60;
  $dl = $hl*24;
  $wl = $dl*7;

  # The decimal amount of each unit contained in all smaller units
  my($yd,$Md,$sd,$md,$hd,$dd,$wd)=();
  $yd = $M/12;
  $Md = 0;

  $wd = ($d*$dl + $h*$hl + $m*$ml + $s*$sl)/$wl;
  $dd =          ($h*$hl + $m*$ml + $s*$sl)/$dl;
  $hd =                   ($m*$ml + $s*$sl)/$hl;
  $md =                            ($s*$sl)/$ml;
  $sd = 0;

  # The amount of each unit contained in higher units.
  my($yh,$Mh,$sh,$mh,$hh,$dh,$wh)=();
  $yh = 0;
  $Mh = ($yh+$y)*12;

  $wh = 0;
  $dh = ($wh+$w)*7;
  $hh = ($dh+$d)*24;
  $mh = ($hh+$h)*60;
  $sh = ($mh+$m)*60;

  # Set up the formats

  $f{"yv"} = $y;
  $f{"Mv"} = $M;
  $f{"wv"} = $w;
  $f{"dv"} = $d;
  $f{"hv"} = $h;
  $f{"mv"} = $m;
  $f{"sv"} = $s;

  $f{"yh"} = $y+$yh;
  $f{"Mh"} = $M+$Mh;
  $f{"wh"} = $w+$wh;
  $f{"dh"} = $d+$dh;
  $f{"hh"} = $h+$hh;
  $f{"mh"} = $m+$mh;
  $f{"sh"} = $s+$sh;

  $f{"yd"} = sprintf($dec,$y+$yd);
  $f{"Md"} = sprintf($dec,$M+$Md);
  $f{"wd"} = sprintf($dec,$w+$wd);
  $f{"dd"} = sprintf($dec,$d+$dd);
  $f{"hd"} = sprintf($dec,$h+$hd);
  $f{"md"} = sprintf($dec,$m+$md);
  $f{"sd"} = sprintf($dec,$s+$sd);

  $f{"yt"} = sprintf($dec,$yh+$y+$yd);
  $f{"Mt"} = sprintf($dec,$Mh+$M+$Md);
  $f{"wt"} = sprintf($dec,$wh+$w+$wd);
  $f{"dt"} = sprintf($dec,$dh+$d+$dd);
  $f{"ht"} = sprintf($dec,$hh+$h+$hd);
  $f{"mt"} = sprintf($dec,$mh+$m+$md);
  $f{"st"} = sprintf($dec,$sh+$s+$sd);

  $f{"%"}  = "%";

  foreach $format (@format) {
    $format=reverse($format);
    $out="";
  PARSE: while ($format) {
      $c1=chop($format);
      if ($c1 eq "%") {
        $c1=chop($format);
        if (exists($f{$c1})) {
          $out .= $f{$c1};
          next PARSE;
        }
        $c2=chop($format);
        if (exists($f{"$c1$c2"})) {
          $out .= $f{"$c1$c2"};
          next PARSE;
        }
        $out .= $c1;
        $format .= $c2;
      } else {
        $out .= $c1;
      }
    }
    push(@out,$out);
  }
  if ($scalar) {
    return $out[0];
  } else {
    return (@out);
  }
}
use integer;

sub ParseRecur {
  print "DEBUG: ParseRecur\n"  if ($Curr{"Debug"} =~ /trace/);
  &Date_Init()  if (! $Curr{"InitDone"});

  my($recur,$dateb,$date0,$date1,$flag)=@_;
  local($_)=$recur;

  my($recur_0,$recur_1,@recur0,@recur1)=();
  my(@tmp,$tmp,$each,$num,$y,$m,$d,$w,$h,$mn,$s,$delta,$y0,$y1,$yb)=();
  my($yy,$n,$dd,@d,@tmp2,$date,@date,@w,@tmp3,@m,@y,$tmp2,$d2,@flags)=();

  # $date0, $date1, $dateb, $flag : passed in (these are always the final say
  #                                 in determining whether a date matches a
  #                                 recurrence IF they are present.
  # $date_b, $date_0, $date_1     : if a value can be determined from the
  # $flag_t                         recurrence, they are stored here.
  #
  # If values can be determined from the recurrence AND are passed in, the
  # following are used:
  #    max($date0,$date_0)    i.e. the later of the two dates
  #    min($date1,$date_1)    i.e. the earlier of the two dates
  #
  # The base date that is used is the first one defined from
  #    $dateb $date_b
  # The base date is only used if necessary (as determined by the recur).
  # For example, "every other friday" requires a base date, but "2nd
  # friday of every month" doesn't.

  my($date_b,$date_0,$date_1,$flag_t);

  #
  # Check the arguments passed in.
  #

  $date0=""  if (! defined $date0);
  $date1=""  if (! defined $date1);
  $dateb=""  if (! defined $dateb);
  $flag =""  if (! defined $flag);

  if ($dateb) {
    $dateb=&ParseDateString($dateb);
    return ""  if (! $dateb);
  }
  if ($date0) {
    $date0=&ParseDateString($date0);
    return ""  if (! $date0);
  }
  if ($date1) {
    $date1=&ParseDateString($date1);
    return ""  if (! $date1);
  }

  #
  # Parse the recur.  $date_b, $date_0, and $date_e are values obtained
  # from the recur.
  #

  @tmp=&Recur_Split($_);

  if (@tmp) {
    ($recur_0,$recur_1,$flag_t,$date_b,$date_0,$date_1)=@tmp;
    $recur_0 = ""  if (! defined $recur_0);
    $recur_1 = ""  if (! defined $recur_1);
    $flag_t  = ""  if (! defined $flag_t);
    $date_b  = ""  if (! defined $date_b);
    $date_0  = ""  if (! defined $date_0);
    $date_1  = ""  if (! defined $date_1);

    @recur0 = split(/:/,$recur_0);
    @recur1 = split(/:/,$recur_1);
    return ""  if ($#recur0 + $#recur1 + 2 != 7);

    if ($date_b) {
      $date_b=&ParseDateString($date_b);
      return ""  if (! $date_b);
    }
    if ($date_0) {
      $date_0=&ParseDateString($date_0);
      return ""  if (! $date_0);
    }
    if ($date_1) {
      $date_1=&ParseDateString($date_1);
      return ""  if (! $date_1);
    }

  } else {

    my($mmm)='\s*'.$Lang{$Cnf{"Language"}}{"Month"};  # \s*(jan|january|...)
    my(%mmm)=%{ $Lang{$Cnf{"Language"}}{"MonthH"} };  # { jan=>1, ... }
    my($wkexp)='\s*'.$Lang{$Cnf{"Language"}}{"Week"}; # \s*(mon|monday|...)
    my(%week)=%{ $Lang{$Cnf{"Language"}}{"WeekH"} };  # { monday=>1, ... }
    my($day)='\s*'.$Lang{$Cnf{"Language"}}{"Dabb"};   # \s*(?:d|day|days)
    my($month)='\s*'.$Lang{$Cnf{"Language"}}{"Mabb"}; # \s*(?:mon|month|months)
    my($week)='\s*'.$Lang{$Cnf{"Language"}}{"Wabb"};  # \s*(?:w|wk|week|weeks)
    my($daysexp)=$Lang{$Cnf{"Language"}}{"DoM"};      # (1st|first|...31st)
    my(%dayshash)=%{ $Lang{$Cnf{"Language"}}{"DoMH"} };
                                                      # { 1st=>1,first=>1,...}
    my($of)='\s*'.$Lang{$Cnf{"Language"}}{"Of"};      # \s*(?:in|of)
    my($lastexp)=$Lang{$Cnf{"Language"}}{"Last"};     # (?:last)
    my($each)=$Lang{$Cnf{"Language"}}{"Each"};        # (?:each|every)

    my($D)='\s*(\d+)';
    my($Y)='\s*(\d{4}|\d{2})';

    # Change 1st to 1
    if (/(^|[^a-z])$daysexp($|[^a-z])/i) {
      $tmp=lc($2);
      $tmp=$dayshash{"$tmp"};
      s/(^|[^a-z])$daysexp($|[^a-z])/$1 $tmp $3/i;
    }
    s/\s*$//;

    # Get rid of "each"
    if (/(^|[^a-z])$each($|[^a-z])/i) {
      s/(^|[^a-z])$each($|[^a-z])/$1 $2/i;
      $each=1;
    } else {
      $each=0;
    }

    if ($each) {

      if (/^$D?$day(?:$of$mmm?$Y)?$/i ||
          /^$D?$day(?:$of$mmm())?$/i) {
        # every [2nd] day in [june] 1997
        # every [2nd] day [in june]
        ($num,$m,$y)=($1,$2,$3);
        $num=1 if (! defined $num);
        $m=""  if (! defined $m);
        $y=""  if (! defined $y);

        $y=$Curr{"Y"}  if (! $y);
        if ($m) {
          $m=$mmm{lc($m)};
          $date_0=&Date_Join($y,$m,1,0,0,0);
          $date_1=&DateCalc_DateDelta($date_0,"+0:1:0:0:0:0:0",0);
        } else {
          $date_0=&Date_Join($y,  1,1,0,0,0);
          $date_1=&Date_Join($y+1,1,1,0,0,0);
        }
        $date_b=&DateCalc($date_0,"-0:0:0:1:0:0:0",0);
        @recur0=(0,0,0,$num,0,0,0);
        @recur1=();

      } elsif (/^$D$day?$of$month(?:$of?$Y)?$/) {
        # 2nd [day] of every month [in 1997]
        ($num,$y)=($1,$2);
        $y=$Curr{"Y"}  if (! $y);

        $date_0=&Date_Join($y,  1,1,0,0,0);
        $date_1=&Date_Join($y+1,1,1,0,0,0);
        $date_b=$date_0;

        @recur0=(0,1,0);
        @recur1=($num,0,0,0);

      } elsif (/^$D$wkexp$of$month(?:$of?$Y)?$/ ||
               /^($lastexp)$wkexp$of$month(?:$of?$Y)?$/) {
        # 2nd tuesday of every month [in 1997]
        # last tuesday of every month [in 1997]
        ($num,$d,$y)=($1,$2,$3);
        $y=$Curr{"Y"}  if (! $y);
        $d=$week{lc($d)};
        $num=-1  if ($num !~ /^$D$/);

        $date_0=&Date_Join($y,1,1,0,0,0);
        $date_1=&Date_Join($y+1,1,1,0,0,0);
        $date_b=$date_0;

        @recur0=(0,1);
        @recur1=($num,$d,0,0,0);

      } elsif (/^$D$wkexp(?:$of$mmm?$Y)?$/i ||
               /^$D$wkexp(?:$of$mmm())?$/i) {
        # every 2nd tuesday in june 1997
        ($num,$d,$m,$y)=($1,$2,$3,$4);
        $y=$Curr{"Y"}  if (! $y);
        $num=1 if (! defined $num);
        $m=""  if (! defined $m);
        $d=$week{lc($d)};

        if ($m) {
          $m=$mmm{lc($m)};
          $date_0=&Date_Join($y,$m,1,0,0,0);
          $date_1=&DateCalc_DateDelta($date_0,"+0:1:0:0:0:0:0",0);
        } else {
          $date_0=&Date_Join($y,1,1,0,0,0);
          $date_1=&Date_Join($y+1,1,1,0,0,0);
        }
        $date_b=&DateCalc($date_0,"-0:0:0:1:0:0:0",0);

        @recur0=(0,0,$num);
        @recur1=($d,0,0,0);

      } else {
        return "";
      }

      $date_0=""  if ($date0);
      $date_1=""  if ($date1);
    } else {
      return "";
    }
  }

  #
  # Override with any values passed in
  #

  if ($date0 && $date_0) {
    $date0=( &Date_Cmp($date0,$date_0) > 1  ? $date0 : $date_0);
  } elsif ($date_0) {
    $date0 = $date_0;
  }

  if ($date1 && $date_1) {
    $date1=( &Date_Cmp($date1,$date_1) > 1  ? $date_1 : $date1);
  } elsif ($date_1) {
    $date1 = $date_1;
  }

  $dateb=$date_b  if (! $dateb);

  if ($flag =~ s/^\+//) {
    if ($flag_t) {
      $flag="$flag_t,$flag";
    }
  }
  $flag =$flag_t  if (! $flag  &&  $flag_t);

  if (! wantarray) {
    $tmp  = join(":",@recur0);
    $tmp .= "*" . join(":",@recur1)  if (@recur1);
    $tmp .= "*$flag*$dateb*$date0*$date1";
    return $tmp;
  }
  if (@recur0) {
    return ()  if (! $date0  ||  ! $date1); # dateb is NOT required in all case
  }

  #
  # Some flags affect parsing.
  #

  @flags   = split(/,/,$flag);
  my($MDn) = 0;
  my($MWn) = 7;
  my($f);
  foreach $f (@flags) {
    if ($f =~ /^MW([1-7])$/i) {
      $MWn=$1;
      $MDn=0;

    } elsif ($f =~ /^MD([1-7])$/i) {
      $MDn=$1;
      $MWn=0;

    } elsif ($f =~ /^EASTER$/i) {
      ($y,$m,$w,$d,$h,$mn,$s)=(@recur0,@recur1);
      # We want something that will return Jan 1 for the given years.
      if ($#recur0==-1) {
        @recur1=($y,1,0,1,$h,$mn,$s);
      } elsif ($#recur0<=3) {
        @recur0=($y,0,0,0);
        @recur1=($h,$mn,$s);
      } elsif ($#recur0==4) {
        @recur0=($y,0,0,0,0);
        @recur1=($mn,$s);
      } elsif ($#recur0==5) {
        @recur0=($y,0,0,0,0,0);
        @recur1=($s);
      } else {
        @recur0=($y,0,0,0,0,0,0);
      }
    }
  }

  #
  # Determine the dates referenced by the recur.  Also, fix the base date
  # as necessary for the recurrences which require it.
  #

  ($y,$m,$w,$d,$h,$mn,$s)=(@recur0,@recur1);
  @y=@m=@w=@d=();

  if ($#recur0==-1) {
    # * Y-M-W-D-H-MN-S
    if ($y eq "0") {
      push(@recur0,0);
      shift(@recur1);

    } else {
      @y=&ReturnList($y);
      foreach $y (@y) {
        $y=&FixYear($y)  if (length($y)==2);
        return ()  if (length($y)!=4  ||  ! &IsInt($y));
      }
      @y=sort { $a<=>$b } @y;

      $date0=&ParseDate("0000-01-01")          if (! $date0);
      $date1=&ParseDate("9999-12-31 23:59:59") if (! $date1);

      if ($m eq "0"  and  $w eq "0") {
        # * Y-0-0-0-H-MN-S
        # * Y-0-0-DOY-H-MN-S
        if ($d eq "0") {
          @d=(1);
        } else {
          @d=&ReturnList($d);
          return ()  if (! @d);
          foreach $d (@d) {
            return ()  if (! &IsInt($d,1,366));
          }
          @d=sort { $a<=>$b } (@d);
        }

        @tmp=();
        foreach $yy (@y) {
          foreach $d (@d) {
            ($y,$m,$dd)=&Date_NthDayOfYear($yy,$d);
            push(@tmp, &Date_Join($y,$m,$dd,0,0,0));
          }
        }
        @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

      } elsif ($w eq "0") {
        # * Y-M-0-0-H-MN-S
        # * Y-M-0-DOM-H-MN-S

        @m=&ReturnList($m);
        return ()  if (! @m);
        foreach $m (@m) {
          return ()  if (! &IsInt($m,1,12));
        }
        @m=sort { $a<=>$b } (@m);

        if ($d eq "0") {
          @d=(1);
        } else {
          @d=&ReturnList($d);
          return ()  if (! @d);
          foreach $d (@d) {
            return ()  if (! &IsInt($d,1,31));
          }
          @d=sort { $a<=>$b } (@d);
        }

        @tmp=();
        foreach $y (@y) {
          foreach $m (@m) {
            foreach $d (@d) {
              $date=&Date_Join($y,$m,$d,0,0,0);
              push(@tmp,$date)  if ($d<29 || &Date_Split($date));
            }
          }
        }
        @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

      } elsif ($m eq "0") {
        # * Y-0-WOY-DOW-H-MN-S
        # * Y-0-WOY-0-H-MN-S
        @w=&ReturnList($w);
        return ()  if (! @w);
        foreach $w (@w) {
          return ()  if (! &IsInt($w,1,53));
        }

        if ($d eq "0") {
          @d=($Cnf{"FirstDay"});
        } else {
          @d=&ReturnList($d);
          return ()  if (! @d);
          foreach $d (@d) {
            return ()  if (! &IsInt($d,1,7));
          }
          @d=sort { $a<=>$b } (@d);
        }

        @tmp=();
        foreach $y (@y) {
          foreach $w (@w) {
            $w="0$w"  if (length($w)==1);
            foreach $d (@d) {
              $date=&ParseDateString("$y-W$w-$d");
              push(@tmp,$date);
            }
          }
        }
        @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

      } else {
        # * Y-M-WOM-DOW-H-MN-S
        # * Y-M-WOM-0-H-MN-S

        @m=&ReturnList($m);
        return ()  if (! @m);
        foreach $m (@m) {
          return ()  if (! &IsInt($m,1,12));
        }
        @m=sort { $a<=>$b } (@m);

        @w=&ReturnList($w);

        if ($d eq "0") {
          @d=();
        } else {
          @d=&ReturnList($d);
        }

        @date=&Date_Recur_WoM(\@y,\@m,\@w,\@d,$MWn,$MDn);
        @date=&Date_RecurSetTime($date0,$date1,\@date,$h,$mn,$s);
      }
    }
  }

  if ($#recur0==0) {
    # Y * M-W-D-H-MN-S
    $n=$y;
    $n=1  if ($n==0);

    @m=&ReturnList($m);
    return ()  if (! @m);
    foreach $m (@m) {
      return ()  if (! &IsInt($m,1,12));
    }
    @m=sort { $a<=>$b } (@m);

    if ($m eq "0") {
      # Y * 0-W-D-H-MN-S   (equiv to Y-0 * W-D-H-MN-S)
      push(@recur0,0);
      shift(@recur1);

    } elsif ($w eq "0") {
      # Y * M-0-DOM-H-MN-S
      return ()  if (! $dateb);
      $d=1  if ($d eq "0");

      @d=&ReturnList($d);
      return ()  if (! @d);
      foreach $d (@d) {
        return ()  if (! &IsInt($d,1,31));
      }
      @d=sort { $a<=>$b } (@d);

      # We need to find years that are a multiple of $n from $y(base)
      ($y0)=( &Date_Split($date0) )[0];
      ($y1)=( &Date_Split($date1) )[0];
      ($yb)=( &Date_Split($dateb) )[0];
      @tmp=();
      for ($yy=$y0; $yy<=$y1; $yy++) {
        if (($yy-$yb)%$n == 0) {
          foreach $m (@m) {
            foreach $d (@d) {
              $date=&Date_Join($yy,$m,$d,0,0,0);
              push(@tmp,$date)  if ($d<29 || &Date_Split($date));
            }
          }
        }
      }
      @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

    } else {
      # Y * M-WOM-DOW-H-MN-S
      # Y * M-WOM-0-H-MN-S
      return ()  if (! $dateb);
      @m=&ReturnList($m);
      @w=&ReturnList($w);
      if ($d eq "0") {
        @d=();
      } else {
        @d=&ReturnList($d);
      }

      ($y0)=( &Date_Split($date0) )[0];
      ($y1)=( &Date_Split($date1) )[0];
      ($yb)=( &Date_Split($dateb) )[0];
      @y=();
      for ($yy=$y0; $yy<=$y1; $yy++) {
        if (($yy-$yb)%$n == 0) {
          push(@y,$yy);
        }
      }

      @date=&Date_Recur_WoM(\@y,\@m,\@w,\@d,$MWn,$MDn);
      @date=&Date_RecurSetTime($date0,$date1,\@date,$h,$mn,$s);
    }
  }

  if ($#recur0==1) {
    # Y-M * W-D-H-MN-S

    if ($w eq "0") {
      # Y-M * 0-D-H-MN-S   (equiv to Y-M-0 * D-H-MN-S)
      push(@recur0,0);
      shift(@recur1);

    } elsif ($m==0) {
      # Y-0 * WOY-0-H-MN-S
      # Y-0 * WOY-DOW-H-MN-S
      return ()  if (! $dateb);
      $n=$y;
      $n=1  if ($n==0);

      @w=&ReturnList($w);
      return ()  if (! @w);
      foreach $w (@w) {
        return ()  if (! &IsInt($w,1,53));
      }

      if ($d eq "0") {
        @d=($Cnf{"FirstDay"});
      } else {
        @d=&ReturnList($d);
        return ()  if (! @d);
        foreach $d (@d) {
          return ()  if (! &IsInt($d,1,7));
        }
        @d=sort { $a<=>$b } (@d);
      }

      # We need to find years that are a multiple of $n from $y(base)
      ($y0)=( &Date_Split($date0) )[0];
      ($y1)=( &Date_Split($date1) )[0];
      ($yb)=( &Date_Split($dateb) )[0];
      @tmp=();
      for ($yy=$y0; $yy<=$y1; $yy++) {
        if (($yy-$yb)%$n == 0) {
          foreach $w (@w) {
            $w="0$w"  if (length($w)==1);
            foreach $tmp (@d) {
              $date=&ParseDateString("$yy-W$w-$tmp");
              push(@tmp,$date);
            }
          }
        }
      }
      @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

    } else {
      # Y-M * WOM-0-H-MN-S
      # Y-M * WOM-DOW-H-MN-S
      return ()  if (! $dateb);
      @tmp=(@recur0);
      push(@tmp,0)  while ($#tmp<6);
      $delta=join(":",@tmp);
      @tmp=&Date_Recur($date0,$date1,$dateb,$delta);

      @w=&ReturnList($w);
      @m=();
      if ($d eq "0") {
        @d=();
      } else {
        @d=&ReturnList($d);
      }

      @date=&Date_Recur_WoM(\@tmp,\@m,\@w,\@d,$MWn,$MDn);
      @date=&Date_RecurSetTime($date0,$date1,\@date,$h,$mn,$s);
    }
  }

  if ($#recur0==2) {
    # Y-M-W * D-H-MN-S

    if ($d eq "0") {
      # Y-M-W * 0-H-MN-S
      return ()  if (! $dateb);
      $y=1  if ($y==0 && $m==0 && $w==0);
      $delta="$y:$m:$w:0:0:0:0";
      @tmp=&Date_Recur($date0,$date1,$dateb,$delta);
      @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

    } elsif ($m==0 && $w==0) {
      # Y-0-0 * DOY-H-MN-S
      $y=1  if ($y==0);
      $n=$y;
      return ()  if (! $dateb  &&  $y!=1);

      @d=&ReturnList($d);
      return ()  if (! @d);
      foreach $d (@d) {
        return ()  if (! &IsInt($d,1,366));
      }
      @d=sort { $a<=>$b } (@d);

      # We need to find years that are a multiple of $n from $y(base)
      ($y0)=( &Date_Split($date0) )[0];
      ($y1)=( &Date_Split($date1) )[0];
      ($yb)=( &Date_Split($dateb) )[0];
      @tmp=();
      for ($yy=$y0; $yy<=$y1; $yy++) {
        if (($yy-$yb)%$n == 0) {
          foreach $d (@d) {
            ($y,$m,$dd)=&Date_NthDayOfYear($yy,$d);
            push(@tmp, &Date_Join($y,$m,$dd,0,0,0));
          }
        }
      }
      @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

    } elsif ($w>0) {
      # Y-M-W * DOW-H-MN-S
      return ()  if (! $dateb);
      @tmp=(@recur0);
      push(@tmp,0)  while ($#tmp<6);
      $delta=join(":",@tmp);

      @d=&ReturnList($d);
      return ()  if (! @d);
      foreach $d (@d) {
        return ()  if (! &IsInt($d,1,7));
      }

      # Find out what DofW the basedate is.
      @tmp2=&Date_Split($dateb);
      $tmp=&Date_DayOfWeek($tmp2[1],$tmp2[2],$tmp2[0]);

      @tmp=();
      foreach $d (@d) {
        $date_b=$dateb;
        # Move basedate to DOW
        if ($d != $tmp) {
          if (($tmp>=$Cnf{"FirstDay"} && $d<$Cnf{"FirstDay"}) ||
              ($tmp>=$Cnf{"FirstDay"} && $d>$tmp) ||
              ($tmp<$d && $d<$Cnf{"FirstDay"})) {
            $date_b=&Date_GetNext($date_b,$d);
          } else {
            $date_b=&Date_GetPrev($date_b,$d);
          }
        }
        push(@tmp,&Date_Recur($date0,$date1,$date_b,$delta));
      }
      @tmp=sort(@tmp);
      @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

    } elsif ($m>0) {
      # Y-M-0 * DOM-H-MN-S
      return ()  if (! $dateb);
      @tmp=(@recur0);
      push(@tmp,0)  while ($#tmp<6);
      $delta=join(":",@tmp);

      @d=&ReturnList($d);
      return ()  if (! @d);
      foreach $d (@d) {
        return ()  if (! &IsInt($d,-31,31)  ||  $d==0);
      }
      @d=sort { $a<=>$b } (@d);

      @tmp2=&Date_Recur($date0,$date1,$dateb,$delta);
      @tmp=();
      foreach $date (@tmp2) {
        ($y,$m)=( &Date_Split($date) )[0..1];
        $tmp2=&Date_DaysInMonth($m,$y);
        foreach $d (@d) {
          $d2=$d;
          $d2=$tmp2+1+$d  if ($d<0);
          push(@tmp,&Date_Join($y,$m,$d2,0,0,0))  if ($d2<=$tmp2);
        }
      }
      @tmp=sort (@tmp);
      @date=&Date_RecurSetTime($date0,$date1,\@tmp,$h,$mn,$s);

    } else {
      return ();
    }
  }

  if ($#recur0>2) {
    # Y-M-W-D * H-MN-S
    # Y-M-W-D-H * MN-S
    # Y-M-W-D-H-MN * S
    # Y-M-W-D-H-S
    return ()  if (! $dateb);
    @tmp=(@recur0);
    push(@tmp,0)  while ($#tmp<6);
    $delta=join(":",@tmp);
    return ()  if ($delta !~ /[1-9]/);    # return if "0:0:0:0:0:0:0"
    @date=&Date_Recur($date0,$date1,$dateb,$delta);
    if (@recur1) {
      unshift(@recur1,-1)  while ($#recur1<2);
      @date=&Date_RecurSetTime($date0,$date1,\@date,@recur1);
    } else {
      shift(@date);
      pop(@date);
    }
  }

  #
  # We've got a list of dates.  Operate on them with the flags.
  #

  my($sign,$forw,$today,$df,$db,$mode);
  if (@flags) {
  FLAG: foreach $f (@flags) {
      $f = uc($f);

      if ($f =~ /^(P|N)(D|T)([1-7])$/) {
        @tmp=($1,$2,$3);
        $forw =($tmp[0] eq "P" ? 0 : 1);
        $today=($tmp[1] eq "D" ? 0 : 1);
        $d=$tmp[2];
        @tmp=();
        foreach $date (@date) {
          if ($forw) {
            push(@tmp, &Date_GetNext($date,$d,$today));
          } else {
            push(@tmp, &Date_GetPrev($date,$d,$today));
          }
        }
        @date=@tmp;
        next FLAG;
      }

      if ($f =~ /^(F|B)(D|W)(\d+)$/) {
        @tmp=($1,$2,$3);
        $sign="+";
        $sign="-"  if ($tmp[0] eq "B");
        $mode=0;
        $mode=2    if ($tmp[1] eq "W");
        $tmp=$tmp[2];
        @tmp=();
        foreach $date (@date) {
          push(@tmp, &DateCalc($date,"${sign}0:0:0:${tmp}:0:0:0",$mode));
        }
        @date=@tmp;
        next FLAG;
      }

      if ($f =~ /^CW(N|P|D)$/) {
        $tmp=$1;
        if ($tmp eq "N"  ||  ($tmp eq "D" && $Cnf{"TomorrowFirst"})) {
          $forw=1;
        } else {
          $forw=0;
        }

        @tmp=();
      DATE: foreach $date (@date) {
          $df=$db=$date;
          if (&Date_IsWorkDay($date)) {
            push(@tmp,$date);
            next DATE;
          }
          while (1) {
            if ($forw) {
              $d=$df=&DateCalc($df,"+0:0:0:1:0:0:0");
            } else {
              $d=$db=&DateCalc($db,"-0:0:0:1:0:0:0");
            }
            if (&Date_IsWorkDay($d)) {
              push(@tmp,$d);
              next DATE;
            }
            $forw=1-$forw;
          }
        }
        @date=@tmp;
        next FLAG;
      }

      if ($f eq "EASTER") {
        @tmp=();
        foreach $date (@date) {
          ($y,$m,$d,$h,$mn,$s)=&Date_Split($date);
          ($m,$d)=&Date_Easter($y);
          $date=&Date_Join($y,$m,$d,$h,$mn,$s);
          next  if (&Date_Cmp($date,$date0)<0  ||
                    &Date_Cmp($date,$date1)>0);
          push(@tmp,$date);
        }
        @date=@tmp;
      }
    }
    @date = sort(@date);
  }
  @date;
}

sub Date_GetPrev {
  print "DEBUG: Date_GetPrev\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$dow,$today,$hr,$min,$sec)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  my($y,$m,$d,$h,$mn,$s,$err,$curr_dow,%dow,$num,$delta,$th,$tm,$ts,
     $adjust,$curr)=();

  if (! &Date_Split($date)) {
    $date=&ParseDateString($date);
    return ""  if (! $date);
  }
  $curr=$date;
  ($y,$m,$d)=( &Date_Split($date) )[0..2];

  if ($dow) {
    $curr_dow=&Date_DayOfWeek($m,$d,$y);
    %dow=%{ $Lang{$Cnf{"Language"}}{"WeekH"} };
    if (&IsInt($dow)) {
      return ""  if ($dow<1  ||  $dow>7);
    } else {
      return ""  if (! exists $dow{lc($dow)});
      $dow=$dow{lc($dow)};
    }
    if ($dow == $curr_dow) {
      $date=&DateCalc_DateDelta($date,"-0:0:1:0:0:0:0",\$err,0)  if (! $today);
      $adjust=1  if ($today==2);
    } else {
      $dow -= 7  if ($dow>$curr_dow); # make sure previous day is less
      $num = $curr_dow - $dow;
      $date=&DateCalc_DateDelta($date,"-0:0:0:$num:0:0:0",\$err,0);
    }
    $date=&Date_SetTime($date,$hr,$min,$sec)  if (defined $hr);
    $date=&DateCalc_DateDelta($date,"-0:0:1:0:0:0:0",\$err,0)
      if ($adjust  &&  &Date_Cmp($date,$curr)>0);

  } else {
    ($h,$mn,$s)=( &Date_Split($date) )[3..5];
    ($th,$tm,$ts)=&Date_ParseTime($hr,$min,$sec);
    if ($hr) {
      ($hr,$min,$sec)=($th,$tm,$ts);
      $delta="-0:0:0:1:0:0:0";
    } elsif ($min) {
      ($hr,$min,$sec)=($h,$tm,$ts);
      $delta="-0:0:0:0:1:0:0";
    } elsif ($sec) {
      ($hr,$min,$sec)=($h,$mn,$ts);
      $delta="-0:0:0:0:0:1:0";
    } else {
      confess "ERROR: invalid arguments in Date_GetPrev.\n";
    }

    $d=&Date_SetTime($date,$hr,$min,$sec);
    if ($today) {
      $d=&DateCalc_DateDelta($d,$delta,\$err,0)  if (&Date_Cmp($d,$date)>0);
    } else {
      $d=&DateCalc_DateDelta($d,$delta,\$err,0)  if (&Date_Cmp($d,$date)>=0);
    }
    $date=$d;
  }
  return $date;
}

sub Date_GetNext {
  print "DEBUG: Date_GetNext\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$dow,$today,$hr,$min,$sec)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  my($y,$m,$d,$h,$mn,$s,$err,$curr_dow,%dow,$num,$delta,$th,$tm,$ts,
     $adjust,$curr)=();

  if (! &Date_Split($date)) {
    $date=&ParseDateString($date);
    return ""  if (! $date);
  }
  $curr=$date;
  ($y,$m,$d)=( &Date_Split($date) )[0..2];

  if ($dow) {
    $curr_dow=&Date_DayOfWeek($m,$d,$y);
    %dow=%{ $Lang{$Cnf{"Language"}}{"WeekH"} };
    if (&IsInt($dow)) {
      return ""  if ($dow<1  ||  $dow>7);
    } else {
      return ""  if (! exists $dow{lc($dow)});
      $dow=$dow{lc($dow)};
    }
    if ($dow == $curr_dow) {
      $date=&DateCalc_DateDelta($date,"+0:0:1:0:0:0:0",\$err,0)  if (! $today);
      $adjust=1  if ($today==2);
    } else {
      $curr_dow -= 7  if ($curr_dow>$dow); # make sure next date is greater
      $num = $dow - $curr_dow;
      $date=&DateCalc_DateDelta($date,"+0:0:0:$num:0:0:0",\$err,0);
    }
    $date=&Date_SetTime($date,$hr,$min,$sec)  if (defined $hr);
    $date=&DateCalc_DateDelta($date,"+0:0:1:0:0:0:0",\$err,0)
      if ($adjust  &&  &Date_Cmp($date,$curr)<0);

  } else {
    ($h,$mn,$s)=( &Date_Split($date) )[3..5];
    ($th,$tm,$ts)=&Date_ParseTime($hr,$min,$sec);
    if ($hr) {
      ($hr,$min,$sec)=($th,$tm,$ts);
      $delta="+0:0:0:1:0:0:0";
    } elsif ($min) {
      ($hr,$min,$sec)=($h,$tm,$ts);
      $delta="+0:0:0:0:1:0:0";
    } elsif ($sec) {
      ($hr,$min,$sec)=($h,$mn,$ts);
      $delta="+0:0:0:0:0:1:0";
    } else {
      confess "ERROR: invalid arguments in Date_GetNext.\n";
    }

    $d=&Date_SetTime($date,$hr,$min,$sec);
    if ($today) {
      $d=&DateCalc_DateDelta($d,$delta,\$err,0)  if (&Date_Cmp($d,$date)<0);
    } else {
      $d=&DateCalc_DateDelta($d,$delta,\$err,0)  if (&Date_Cmp($d,$date)<1);
    }
    $date=$d;
  }

  return $date;
}

sub Date_IsHoliday {
  print "DEBUG: Date_IsHoliday\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  $date=&ParseDateString($date);
  return undef  if (! $date);
  $date=&Date_SetTime($date,0,0,0);
  my($y)=(&Date_Split($date))[0];
  return undef  if (! exists $Holiday{"dates"}{$y}{$date});
  my($name)=$Holiday{"dates"}{$y}{$date};
  return ""   if (! $name);
  $name;
}

###
# NOTE: The following routines may be called in the routines below with very
#       little time penalty.
###
sub Date_SetTime {
  print "DEBUG: Date_SetTime\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$h,$mn,$s)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  my($y,$m,$d)=();

  if (! &Date_Split($date)) {
    $date=&ParseDateString($date);
    return ""  if (! $date);
  }

  ($y,$m,$d)=( &Date_Split($date) )[0..2];
  ($h,$mn,$s)=&Date_ParseTime($h,$mn,$s);

  my($ampm,$wk);
  return ""  if (&Date_DateCheck(\$y,\$m,\$d,\$h,\$mn,\$s,\$ampm,\$wk));
  &Date_Join($y,$m,$d,$h,$mn,$s);
}

sub Date_SetDateField {
  print "DEBUG: Date_SetDateField\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$field,$val,$nocheck)=@_;
  my($y,$m,$d,$h,$mn,$s)=();
  $nocheck=0  if (! defined $nocheck);

  ($y,$m,$d,$h,$mn,$s)=&Date_Split($date);

  if (! $y) {
    $date=&ParseDateString($date);
    return "" if (! $date);
    ($y,$m,$d,$h,$mn,$s)=&Date_Split($date);
  }

  if      (lc($field) eq "y") {
    $y=$val;
  } elsif (lc($field) eq "m") {
    $m=$val;
  } elsif (lc($field) eq "d") {
    $d=$val;
  } elsif (lc($field) eq "h") {
    $h=$val;
  } elsif (lc($field) eq "mn") {
    $mn=$val;
  } elsif (lc($field) eq "s") {
    $s=$val;
  } else {
    confess "ERROR: Date_SetDateField: invalid field: $field\n";
  }

  $date=&Date_Join($y,$m,$d,$h,$mn,$s);
  return $date  if ($nocheck  ||  &Date_Split($date));
  return "";
}

########################################################################
# OTHER SUBROUTINES
########################################################################
# NOTE: These routines should not call any of the routines above as
#       there will be a severe time penalty (and the possibility of
#       infinite recursion).  The last couple routines above are
#       exceptions.
# NOTE: Date_Init is a special case.  It should be called (conditionally)
#       in every routine that uses any variable from the Date::Manip
#       namespace.
########################################################################

sub Date_DaysInMonth {
  print "DEBUG: Date_DaysInMonth\n"  if ($Curr{"Debug"} =~ /trace/);
  my($m,$y)=@_;
  $y=&Date_FixYear($y)  if (length($y)!=4);
  my(@d_in_m)=(0,31,28,31,30,31,30,31,31,30,31,30,31);
  $d_in_m[2]=29  if (&Date_LeapYear($y));
  return $d_in_m[$m];
}

sub Date_DayOfWeek {
  print "DEBUG: Date_DayOfWeek\n"  if ($Curr{"Debug"} =~ /trace/);
  my($m,$d,$y)=@_;
  $y=&Date_FixYear($y)  if (length($y)!=4);
  my($dayofweek,$dec31)=();

  $dec31=5;                     # Dec 31, 1BC was Friday
  $dayofweek=(&Date_DaysSince1BC($m,$d,$y)+$dec31) % 7;
  $dayofweek=7  if ($dayofweek==0);
  return $dayofweek;
}

# Can't be in "use integer" because the numbers are too big.
no integer;
sub Date_SecsSince1970 {
  print "DEBUG: Date_SecsSince1970\n"  if ($Curr{"Debug"} =~ /trace/);
  my($m,$d,$y,$h,$mn,$s)=@_;
  $y=&Date_FixYear($y)  if (length($y)!=4);
  my($sec_now,$sec_70)=();
  $sec_now=(&Date_DaysSince1BC($m,$d,$y)-1)*24*3600 + $h*3600 + $mn*60 + $s;
# $sec_70 =(&Date_DaysSince1BC(1,1,1970)-1)*24*3600;
  $sec_70 =62167219200;
  return ($sec_now-$sec_70);
}

sub Date_SecsSince1970GMT {
  print "DEBUG: Date_SecsSince1970GMT\n"  if ($Curr{"Debug"} =~ /trace/);
  my($m,$d,$y,$h,$mn,$s)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  $y=&Date_FixYear($y)  if (length($y)!=4);

  my($sec)=&Date_SecsSince1970($m,$d,$y,$h,$mn,$s);
  return $sec   if ($Cnf{"ConvTZ"} eq "IGNORE");

  my($tz)=$Cnf{"ConvTZ"};
  $tz=$Cnf{"TZ"}  if (! $tz);
  $tz=$Zone{"n2o"}{lc($tz)}  if ($tz !~ /^[+-]\d{4}$/);

  my($tzs)=1;
  $tzs=-1 if ($tz<0);
  $tz=~/.(..)(..)/;
  my($tzh,$tzm)=($1,$2);
  $sec - $tzs*($tzh*3600+$tzm*60);
}
use integer;

#####
# This is deprecated and will be removed.
#####
sub Date_DaysSince999 {
  print "DEBUG: Date_DaysSince999\n"  if ($Curr{"Debug"} =~ /trace/);
  my($m,$d,$y)=@_;
  $y=&Date_FixYear($y)  if (length($y)!=4);
  my($Ny,$N4,$N100,$N400,$dayofyear,$days)=();
  my($cc,$yy)=();

  $y=~ /(\d{2})(\d{2})/;
  ($cc,$yy)=($1,$2);

  # Number of full years since Dec 31, 0999
  $Ny=$y-1000;

  # Number of full 4th years (incl. 1000) since Dec 31, 0999
  $N4=($Ny-1)/4 + 1;
  $N4=0         if ($y==1000);

  # Number of full 100th years (incl. 1000)
  $N100=$cc-9;
  $N100--       if ($yy==0);

  # Number of full 400th years
  $N400=($N100+1)/4;  # BUG!!!

  $dayofyear=&Date_DayOfYear($m,$d,$y);
  $days= $Ny*365 + $N4 - $N100 + $N400 + $dayofyear;

  return $days;
}

sub Date_DaysSince1BC {
  print "DEBUG: Date_DaysSince1BC\n"  if ($Curr{"Debug"} =~ /trace/);
  my($m,$d,$y)=@_;
  $y=&Date_FixYear($y)  if (length($y)!=4);
  my($Ny,$N4,$N100,$N400,$dayofyear,$days)=();
  my($cc,$yy)=();

  $y=~ /(\d{2})(\d{2})/;
  ($cc,$yy)=($1,$2);

  # Number of full years since Dec 31, 1BC (counting the year 0000).
  $Ny=$y;

  # Number of full 4th years (incl. 0000) since Dec 31, 1BC
  $N4=($Ny-1)/4 + 1;
  $N4=0         if ($y==0);

  # Number of full 100th years (incl. 0000)
  $N100=$cc + 1;
  $N100=0       if ($y==0);

  # Number of full 400th years (incl. 0000)
  $N400=($N100-1)/4 + 1;
  $N400=0       if ($y==0);

  $dayofyear=&Date_DayOfYear($m,$d,$y);
  $days= $Ny*365 + $N4 - $N100 + $N400 + $dayofyear;

  return $days;
}

sub Date_DayOfYear {
  print "DEBUG: Date_DayOfYear\n"  if ($Curr{"Debug"} =~ /trace/);
  my($m,$d,$y)=@_;
  $y=&Date_FixYear($y)  if (length($y)!=4);
  # DinM    = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  my(@days) = ( 0, 31, 59, 90,120,151,181,212,243,273,304,334,365);
  my($ly)=0;
  $ly=1  if ($m>2 && &Date_LeapYear($y));
  return ($days[$m-1]+$d+$ly);
}

sub Date_DaysInYear {
  print "DEBUG: Date_DaysInYear\n"  if ($Curr{"Debug"} =~ /trace/);
  my($y)=@_;
  $y=&Date_FixYear($y)  if (length($y)!=4);
  return 366  if (&Date_LeapYear($y));
  return 365;
}

sub Date_WeekOfYear {
  print "DEBUG: Date_WeekOfYear\n"  if ($Curr{"Debug"} =~ /trace/);
  my($m,$d,$y,$f)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  $y=&Date_FixYear($y)  if (length($y)!=4);

  my($day,$dow,$doy)=();
  $doy=&Date_DayOfYear($m,$d,$y);

  # The current DayOfYear and DayOfWeek
  if ($Cnf{"Jan1Week1"}) {
    $day=1;
  } else {
    $day=4;
  }
  $dow=&Date_DayOfWeek(1,$day,$y);

  # Move back to the first day of week 1.
  $f-=7  if ($f>$dow);
  $day-= ($dow-$f);

  return 0  if ($day>$doy);      # Day is in last week of previous year
  return (($doy-$day)/7 + 1);
}

sub Date_LeapYear {
  print "DEBUG: Date_LeapYear\n"  if ($Curr{"Debug"} =~ /trace/);
  my($y)=@_;
  $y=&Date_FixYear($y)  if (length($y)!=4);
  return 0 unless $y % 4 == 0;
  return 1 unless $y % 100 == 0;
  return 0 unless $y % 400 == 0;
  return 1;
}

sub Date_DaySuffix {
  print "DEBUG: Date_DaySuffix\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  return $Lang{$Cnf{"Language"}}{"DoML"}[$d-1];
}

sub Date_ConvTZ {
  print "DEBUG: Date_ConvTZ\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$from,$to)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  my($gmt)=();

  if (! $from) {

    if (! $to) {
      # TZ -> ConvTZ
      return $date  if ($Cnf{"ConvTZ"} eq "IGNORE" or ! $Cnf{"ConvTZ"});
      $from=$Cnf{"TZ"};
      $to=$Cnf{"ConvTZ"};

    } else {
      # ConvTZ,TZ -> $to
      $from=$Cnf{"ConvTZ"};
      $from=$Cnf{"TZ"}  if (! $from);
    }

  } else {

    if (! $to) {
      # $from -> ConvTZ,TZ
      return $date  if ($Cnf{"ConvTZ"} eq "IGNORE");
      $to=$Cnf{"ConvTZ"};
      $to=$Cnf{"TZ"}  if (! $to);

    } else {
      # $from -> $to
    }
  }

  $to=$Zone{"n2o"}{lc($to)}
    if (exists $Zone{"n2o"}{lc($to)});
  $from=$Zone{"n2o"}{lc($from)}
    if (exists $Zone{"n2o"}{lc($from)});
  $gmt=$Zone{"n2o"}{"gmt"};

  return $date  if ($from !~ /^[+-]\d{4}$/ or $to !~ /^[+-]\d{4}$/);
  return $date  if ($from eq $to);

  my($s1,$h1,$m1,$s2,$h2,$m2,$d,$h,$m,$sign,$delta,$err,$yr,$mon,$sec)=();
  # We're going to try to do the calculation without calling DateCalc.
  ($yr,$mon,$d,$h,$m,$sec)=&Date_Split($date);

  # Convert $date from $from to GMT
  $from=~/([+-])(\d{2})(\d{2})/;
  ($s1,$h1,$m1)=($1,$2,$3);
  $s1= ($s1 eq "-" ? "+" : "-");   # switch sign
  $sign=$s1 . "1";     # + or - 1

  # and from GMT to $to
  $to=~/([+-])(\d{2})(\d{2})/;
  ($s2,$h2,$m2)=($1,$2,$3);

  if ($s1 eq $s2) {
    # Both the same sign
    $m+= $sign*($m1+$m2);
    $h+= $sign*($h1+$h2);
  } else {
    $sign=($s2 eq "-" ? +1 : -1)  if ($h1<$h2  ||  ($h1==$h2 && $m1<$m2));
    $m+= $sign*($m1-$m2);
    $h+= $sign*($h1-$h2);
  }

  if ($m>59) {
    $h+= $m/60;
    $m-= ($m/60)*60;
  } elsif ($m<0) {
    $h+= ($m/60 - 1);
    $m-= ($m/60 - 1)*60;
  }

  if ($h>23) {
    $delta=$h/24;
    $h -= $delta*24;
    if (($d + $delta) > 28) {
      $date=&Date_Join($yr,$mon,$d,$h,$m,$sec);
      return &DateCalc_DateDelta($date,"+0:0:0:$delta:0:0:0",\$err,0);
    }
    $d+= $delta;
  } elsif ($h<0) {
    $delta=-$h/24 + 1;
    $h += $delta*24;
    if (($d - $delta) < 1) {
      $date=&Date_Join($yr,$mon,$d,$h,$m,$sec);
      return &DateCalc_DateDelta($date,"-0:0:0:$delta:0:0:0",\$err,0);
    }
    $d-= $delta;
  }
  return &Date_Join($yr,$mon,$d,$h,$m,$sec);
}

sub Date_TimeZone {
  print "DEBUG: Date_TimeZone\n"  if ($Curr{"Debug"} =~ /trace/);
  my($null,$tz,@tz,$std,$dst,$time,$isdst,$tmp,$in)=();
  &Date_Init()  if (! $Curr{"InitDone"});

  # Get timezones from all of the relevant places

  push(@tz,$Cnf{"TZ"})  if (defined $Cnf{"TZ"});  # TZ config var
  push(@tz,$ENV{"TZ"})  if (exists $ENV{"TZ"});   # TZ environ var
  # Microsoft operating systems don't have a date command built in.  Try
  # to trap all the various ways of knowing we are on one of these systems:
  unless (($^X =~ /perl\.exe$/i) or
          $OS eq "Windows") {
    $tz = `date`;
    chomp($tz);
    $tz=(split(/\s+/,$tz))[4];
    push(@tz,$tz);
  }
  push(@tz,$main::TZ)         if (defined $main::TZ);         # $main::TZ
  if (-s "/etc/TIMEZONE") {                                   # /etc/TIMEZONE
    $in=new IO::File;
    $in->open("/etc/TIMEZONE","r");
    while (! eof($in)) {
      $tmp=<$in>;
      if ($tmp =~ /^TZ\s*=\s*(.*?)\s*$/) {
        push(@tz,$1);
        last;
      }
    }
    $in->close;
  }

  # Now parse each one to find the first valid one.
  foreach $tz (@tz) {
    return uc($tz)
      if (defined $Zone{"n2o"}{lc($tz)} or $tz=~/^[+-]\d{4}/);

    # Handle US/Eastern format
    if ($tz =~ /^$Zone{"tzones"}$/i) {
      $tmp=lc $1;
      $tz=$Zone{"tz2z"}{$tmp};
    }

    # Handle STD#DST# format (and STD-#DST-# formats)
    if ($tz =~ /^([a-z]+)-?\d([a-z]+)-?\d?$/i) {
      ($std,$dst)=($1,$2);
      next  if (! defined $Zone{"n2o"}{lc($std)} or
                ! defined $Zone{"n2o"}{lc($dst)});
      $time = time();
      ($null,$null,$null,$null,$null,$null,$null,$null,$isdst) =
        localtime($time);
      return uc($dst)  if ($isdst);
      return uc($std);
    }
  }

  confess "ERROR: Date::Manip unable to determine TimeZone.\n";
}

# Returns 1 if $date is a work day.  If $time is non-zero, the time is
# also checked to see if it falls within work hours.
sub Date_IsWorkDay {
  print "DEBUG: Date_IsWorkDay\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$time)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  $date=&ParseDateString($date);
  my($d)=$date;
  $d=&Date_SetTime($date,$Cnf{"WorkDayBeg"})  if (! $time);

  my($y,$mon,$day,$tmp,$h,$m,$dow)=();
  ($y,$mon,$day,$h,$m,$tmp)=&Date_Split($d);
  $dow=&Date_DayOfWeek($mon,$day,$y);

  return 0  if ($dow<$Cnf{"WorkWeekBeg"} or
                $dow>$Cnf{"WorkWeekEnd"} or
                "$h:$m" lt $Cnf{"WorkDayBeg"} or
                "$h:$m" gt $Cnf{"WorkDayEnd"});

  &Date_UpdateHolidays($y)  if (! exists $Holiday{"dates"}{$y});
  $d=&Date_SetTime($date,"00:00:00");
  return 0  if (exists $Holiday{"dates"}{$y}{$d});
  1;
}

# Finds the day $off work days from now.  If $time is passed in, we must
# also take into account the time of day.
#
# If $time is not passed in, day 0 is today (if today is a workday) or the
# next work day if it isn't.  In any case, the time of day is unaffected.
#
# If $time is passed in, day 0 is now (if now is part of a workday) or the
# start of the very next work day.
sub Date_NextWorkDay {
  print "DEBUG: Date_NextWorkDay\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$off,$time)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  $date=&ParseDateString($date);
  my($err)=();

  if (! &Date_IsWorkDay($date,$time)) {
    if ($time) {
      while (1) {
        $date=&Date_GetNext($date,undef,0,$Cnf{"WorkDayBeg"});
        last  if (&Date_IsWorkDay($date,$time));
      }
    } else {
      while (1) {
        $date=&DateCalc_DateDelta($date,"+0:0:0:1:0:0:0",\$err,0);
        last  if (&Date_IsWorkDay($date,$time));
      }
    }
  }

  while ($off>0) {
    while (1) {
      $date=&DateCalc_DateDelta($date,"+0:0:0:1:0:0:0",\$err,0);
      last  if (&Date_IsWorkDay($date,$time));
    }
    $off--;
  }

  return $date;
}

# Finds the day $off work days before now.  If $time is passed in, we must
# also take into account the time of day.
#
# If $time is not passed in, day 0 is today (if today is a workday) or the
# previous work day if it isn't.  In any case, the time of day is unaffected.
#
# If $time is passed in, day 0 is now (if now is part of a workday) or the
# end of the previous work period.  Note that since the end of a work day
# will automatically be turned into the start of the next one, this time
# may actually be treated as AFTER the current time.
sub Date_PrevWorkDay {
  print "DEBUG: Date_PrevWorkDay\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$off,$time)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  $date=&ParseDateString($date);
  my($err)=();

  if (! &Date_IsWorkDay($date,$time)) {
    if ($time) {
      while (1) {
        $date=&Date_GetPrev($date,undef,0,$Cnf{"WorkDayEnd"});
        last  if (&Date_IsWorkDay($date,$time));
      }
      while (1) {
        $date=&Date_GetNext($date,undef,0,$Cnf{"WorkDayBeg"});
        last  if (&Date_IsWorkDay($date,$time));
      }
    } else {
      while (1) {
        $date=&DateCalc_DateDelta($date,"-0:0:0:1:0:0:0",\$err,0);
        last  if (&Date_IsWorkDay($date,$time));
      }
    }
  }

  while ($off>0) {
    while (1) {
      $date=&DateCalc_DateDelta($date,"-0:0:0:1:0:0:0",\$err,0);
      last  if (&Date_IsWorkDay($date,$time));
    }
    $off--;
  }

  return $date;
}

# This finds the nearest workday to $date.  If $date is a workday, it
# is returned.
sub Date_NearestWorkDay {
  print "DEBUG: Date_NearestWorkDay\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date,$tomorrow)=@_;
  &Date_Init()  if (! $Curr{"InitDone"});
  $date=&ParseDateString($date);
  my($a,$b,$dela,$delb,$err)=();
  $tomorrow=$Cnf{"TomorrowFirst"}  if (! defined $tomorrow);

  return $date  if (&Date_IsWorkDay($date));

  # Find the nearest one.
  if ($tomorrow) {
    $dela="+0:0:0:1:0:0:0";
    $delb="-0:0:0:1:0:0:0";
  } else {
    $dela="-0:0:0:1:0:0:0";
    $delb="+0:0:0:1:0:0:0";
  }
  $a=$b=$date;

  while (1) {
    $a=&DateCalc_DateDelta($a,$dela,\$err);
    return $a  if (&Date_IsWorkDay($a));
    $b=&DateCalc_DateDelta($b,$delb,\$err);
    return $b  if (&Date_IsWorkDay($b));
  }
}

# &Date_NthDayOfYear($y,$n);
#   Returns a list of (YYYY,MM,DD,HH,MM,SS) for the Nth day of the year.
sub Date_NthDayOfYear {
  no integer;
  print "DEBUG: Date_NthDayOfYear\n"  if ($Curr{"Debug"} =~ /trace/);
  my($y,$n)=@_;
  $y=$Curr{"Y"}  if (! $y);
  $n=1       if (! defined $n  or  $n eq "");
  $n+=0;     # to turn 023 into 23
  $y=&Date_FixYear($y)  if (length($y)<4);
  my $leap=&Date_LeapYear($y);
  return ()  if ($n<1);
  return ()  if ($n >= ($leap ? 367 : 366));

  my(@d_in_m)=(31,28,31,30,31,30,31,31,30,31,30,31);
  $d_in_m[1]=29  if ($leap);

  # Calculate the hours, minutes, and seconds into the day.
  my $remain=($n - int($n))*24;
  my $h=int($remain);
  $remain=($remain - $h)*60;
  my $mn=int($remain);
  $remain=($remain - $mn)*60;
  my $s=$remain;

  # Calculate the month and the day.
  my($m,$d)=(0,0);
  while ($n>0) {
    $m++;
    if ($n<=$d_in_m[0]) {
      $d=int($n);
      $n=0;
    } else {
      $n-= $d_in_m[0];
      shift(@d_in_m);
    }
  }

  ($y,$m,$d,$h,$mn,$s);
}

########################################################################
# NOT FOR EXPORT
########################################################################

# This is used in Date_Init to fill in a hash based on international
# data.  It takes a list of keys and values and returns both a hash
# with these values and a regular expression of keys.
#
# IN:
#   $data   = [ key1 val1 key2 val2 ... ]
#   $opts   = lc     : lowercase the keys in the regexp
#             sort   : sort (by length) the keys in the regexp
#             back   : create a regexp with a back reference
#             escape : escape all strings in the regexp
#
# OUT:
#   $regexp = '(?:key1|key2|...)'
#   $hash   = { key1=>val1 key2=>val2 ... }

sub Date_InitHash {
  print "DEBUG: Date_InitHash\n"  if ($Curr{"Debug"} =~ /trace/);
  my($data,$regexp,$opts,$hash)=@_;
  my(@data)=@$data;
  my($key,$val,@list)=();

  # Parse the options
  my($lc,$sort,$back,$escape)=(0,0,0,0);
  $lc=1     if ($opts =~ /lc/i);
  $sort=1   if ($opts =~ /sort/i);
  $back=1   if ($opts =~ /back/i);
  $escape=1 if ($opts =~ /escape/i);

  # Create the hash
  while (@data) {
    ($key,$val,@data)=@data;
    $key=lc($key)  if ($lc);
    $$hash{$key}=$val;
  }

  # Create the regular expression
  if ($regexp) {
    @list=keys(%$hash);
    @list=sort sortByLength(@list)  if ($sort);
    if ($escape) {
      foreach $val (@list) {
        $val="\Q$val\E";
      }
    }
    if ($back) {
      $$regexp="(" . join("|",@list) . ")";
    } else {
      $$regexp="(?:" . join("|",@list) . ")";
    }
  }
}

# This is used in Date_Init to fill in regular expressions, lists, and
# hashes based on international data.  It takes a list of lists which have
# to be stored as regular expressions (to find any element in the list),
# lists, and hashes (indicating the location in the lists).
#
# IN:
#   $data   = [ [ [ valA1 valA2 ... ][ valA1' valA2' ... ] ... ]
#               [ [ valB1 valB2 ... ][ valB1' valB2' ... ] ... ]
#               ...
#               [ [ valZ1 valZ2 ... ] [valZ1' valZ1' ... ] ... ] ]
#   $lists  = [ \@listA \@listB ... \@listZ ]
#   $opts   = lc     : lowercase the values in the regexp
#             sort   : sort (by length) the values in the regexp
#             back   : create a regexp with a back reference
#             escape : escape all strings in the regexp
#   $hash   = [ \%hash, TYPE ]
#             TYPE 0 : $hash{ valBn=>n-1 }
#             TYPE 1 : $hash{ valBn=>n }
#
# OUT:
#   $regexp = '(?:valA1|valA2|...|valB1|...)'
#   $lists  = [ [ valA1 valA2 ... ]         # only the 1st list (or
#               [ valB1 valB2 ... ] ... ]   # 2nd for int. characters)
#   $hash

sub Date_InitLists {
  print "DEBUG: Date_InitLists\n"  if ($Curr{"Debug"} =~ /trace/);
  my($data,$regexp,$opts,$lists,$hash)=@_;
  my(@data)=@$data;
  my(@lists)=@$lists;
  my($i,@ele,$ele,@list,$j,$tmp)=();

  # Parse the options
  my($lc,$sort,$back,$escape)=(0,0,0,0);
  $lc=1     if ($opts =~ /lc/i);
  $sort=1   if ($opts =~ /sort/i);
  $back=1   if ($opts =~ /back/i);
  $escape=1 if ($opts =~ /escape/i);

  # Set each of the lists
  if (@lists) {
    confess "ERROR: Date_InitLists: lists must be 1 per data\n"
      if ($#lists != $#data);
    for ($i=0; $i<=$#data; $i++) {
      @ele=@{ $data[$i] };
      if ($Cnf{"IntCharSet"} && $#ele>0) {
        @{ $lists[$i] } = @{ $ele[1] };
      } else {
        @{ $lists[$i] } = @{ $ele[0] };
      }
    }
  }

  # Create the hash
  my($hashtype,$hashsave,%hash)=();
  if (@$hash) {
    ($hash,$hashtype)=@$hash;
    $hashsave=1;
  } else {
    $hashtype=0;
    $hashsave=0;
  }
  for ($i=0; $i<=$#data; $i++) {
    @ele=@{ $data[$i] };
    foreach $ele (@ele) {
      @list = @{ $ele };
      for ($j=0; $j<=$#list; $j++) {
        $tmp=$list[$j];
        next  if (! $tmp);
        $tmp=lc($tmp)  if ($lc);
        $hash{$tmp}= $j+$hashtype;
      }
    }
  }
  %$hash = %hash  if ($hashsave);

  # Create the regular expression
  if ($regexp) {
    @list=keys(%hash);
    @list=sort sortByLength(@list)  if ($sort);
    if ($escape) {
      foreach $ele (@list) {
        $ele="\Q$ele\E";
      }
    }
    if ($back) {
      $$regexp="(" . join("|",@list) . ")";
    } else {
      $$regexp="(?:" . join("|",@list) . ")";
    }
  }
}

# This is used in Date_Init to fill in regular expressions and lists based
# on international data.  This takes a list of strings and returns a regular
# expression (to find any one of them).
#
# IN:
#   $data   = [ string1 string2 ... ]
#   $opts   = lc     : lowercase the values in the regexp
#             sort   : sort (by length) the values in the regexp
#             back   : create a regexp with a back reference
#             escape : escape all strings in the regexp
#
# OUT:
#   $regexp = '(string1|string2|...)'

sub Date_InitStrings {
  print "DEBUG: Date_InitStrings\n"  if ($Curr{"Debug"} =~ /trace/);
  my($data,$regexp,$opts)=@_;
  my(@list)=@{ $data };

  # Parse the options
  my($lc,$sort,$back,$escape)=(0,0,0,0);
  $lc=1     if ($opts =~ /lc/i);
  $sort=1   if ($opts =~ /sort/i);
  $back=1   if ($opts =~ /back/i);
  $escape=1 if ($opts =~ /escape/i);

  # Create the regular expression
  my($ele)=();
  @list=sort sortByLength(@list)  if ($sort);
  if ($escape) {
    foreach $ele (@list) {
      $ele="\Q$ele\E";
    }
  }
  if ($back) {
    $$regexp="(" . join("|",@list) . ")";
  } else {
    $$regexp="(?:" . join("|",@list) . ")";
  }
  $$regexp=lc($$regexp)  if ($lc);
}

# items is passed in (either as a space separated string, or a reference to
# a list) and a regular expression which matches any one of the items is
# prepared.  The regular expression will be of one of the forms:
#   "(a|b)"       @list not empty, back option included
#   "(?:a|b)"     @list not empty
#   "()"          @list empty,     back option included
#   ""            @list empty
# $options is a string which contains any of the following strings:
#   back     : the regular expression has a backreference
#   opt      : the regular expression is optional and a "?" is appended in
#              the first two forms
#   optws    : the regular expression is optional and may be replaced by
#              whitespace
#   optWs    : the regular expression is optional, but if not present, must
#              be replaced by whitespace
#   sort     : the items in the list are sorted by length (longest first)
#   lc       : the string is lowercased
#   under    : any underscores are converted to spaces
#   pre      : it may be preceded by whitespace
#   Pre      : it must be preceded by whitespace
#   PRE      : it must be preceded by whitespace or the start
#   post     : it may be followed by whitespace
#   Post     : it must be followed by whitespace
#   POST     : it must be followed by whitespace or the end
# Spaces due to pre/post options will not be included in the back reference.
#
# If $array is included, then the elements will also be returned as a list.
# $array is a string which may contain any of the following:
#   keys     : treat the list as a hash and only the keys go into the regexp
#   key0     : treat the list as the values of a hash with keys 0 .. N-1
#   key1     : treat the list as the values of a hash with keys 1 .. N
#   val0     : treat the list as the keys of a hash with values 0 .. N-1
#   val1     : treat the list as the keys of a hash with values 1 .. N

#    &Date_InitLists([$lang{"month_name"},$lang{"month_abb"}],
#             [\$Month,"lc,sort,back"],
#             [\@Month,\@Mon],
#             [\%Month,1]);

# This is used in Date_Init to prepare regular expressions.  A list of
# items is passed in (either as a space separated string, or a reference to
# a list) and a regular expression which matches any one of the items is
# prepared.  The regular expression will be of one of the forms:
#   "(a|b)"       @list not empty, back option included
#   "(?:a|b)"     @list not empty
#   "()"          @list empty,     back option included
#   ""            @list empty
# $options is a string which contains any of the following strings:
#   back     : the regular expression has a backreference
#   opt      : the regular expression is optional and a "?" is appended in
#              the first two forms
#   optws    : the regular expression is optional and may be replaced by
#              whitespace
#   optWs    : the regular expression is optional, but if not present, must
#              be replaced by whitespace
#   sort     : the items in the list are sorted by length (longest first)
#   lc       : the string is lowercased
#   under    : any underscores are converted to spaces
#   pre      : it may be preceded by whitespace
#   Pre      : it must be preceded by whitespace
#   PRE      : it must be preceded by whitespace or the start
#   post     : it may be followed by whitespace
#   Post     : it must be followed by whitespace
#   POST     : it must be followed by whitespace or the end
# Spaces due to pre/post options will not be included in the back reference.
#
# If $array is included, then the elements will also be returned as a list.
# $array is a string which may contain any of the following:
#   keys     : treat the list as a hash and only the keys go into the regexp
#   key0     : treat the list as the values of a hash with keys 0 .. N-1
#   key1     : treat the list as the values of a hash with keys 1 .. N
#   val0     : treat the list as the keys of a hash with values 0 .. N-1
#   val1     : treat the list as the keys of a hash with values 1 .. N
sub Date_Regexp {
  print "DEBUG: Date_Regexp\n"  if ($Curr{"Debug"} =~ /trace/);
  my($list,$options,$array)=@_;
  my(@list,$ret,%hash,$i)=();
  local($_)=();
  $options=""  if (! defined $options);
  $array=""    if (! defined $array);

  my($sort,$lc,$under)=(0,0,0);
  $sort =1  if ($options =~ /sort/i);
  $lc   =1  if ($options =~ /lc/i);
  $under=1  if ($options =~ /under/i);
  my($back,$opt,$pre,$post,$ws)=("?:","","","","");
  $back =""          if ($options =~ /back/i);
  $opt  ="?"         if ($options =~ /opt/i);
  $pre  ='\s*'       if ($options =~ /pre/);
  $pre  ='\s+'       if ($options =~ /Pre/);
  $pre  ='(?:\s+|^)' if ($options =~ /PRE/);
  $post ='\s*'       if ($options =~ /post/);
  $post ='\s+'       if ($options =~ /Post/);
  $post ='(?:$|\s+)' if ($options =~ /POST/);
  $ws   ='\s*'       if ($options =~ /optws/);
  $ws   ='\s+'       if ($options =~ /optws/);

  my($hash,$keys,$key0,$key1,$val0,$val1)=(0,0,0,0,0,0);
  $keys =1     if ($array =~ /keys/i);
  $key0 =1     if ($array =~ /key0/i);
  $key1 =1     if ($array =~ /key1/i);
  $val0 =1     if ($array =~ /val0/i);
  $val1 =1     if ($array =~ /val1/i);
  $hash =1     if ($keys or $key0 or $key1 or $val0 or $val1);

  my($ref)=ref $list;
  if (! $ref) {
    $list =~ s/\s*$//;
    $list =~ s/^\s*//;
    $list =~ s/\s+/&&&/g;
  } elsif ($ref eq "ARRAY") {
    $list = join("&&&",@$list);
  } else {
    confess "ERROR: Date_Regexp.\n";
  }

  if (! $list) {
    if ($back eq "") {
      return "()";
    } else {
      return "";
    }
  }

  $list=lc($list)  if ($lc);
  $list=~ s/_/ /g  if ($under);
  @list=split(/&&&/,$list);
  if ($keys) {
    %hash=@list;
    @list=keys %hash;
  } elsif ($key0 or $key1 or $val0 or $val1) {
    $i=0;
    $i=1  if ($key1 or $val1);
    if ($key0 or $key1) {
      %hash= map { $_,$i++ } @list;
    } else {
      %hash= map { $i++,$_ } @list;
    }
  }
  @list=sort sortByLength(@list)  if ($sort);

  $ret="($back" . join("|",@list) . ")";
  $ret="(?:$pre$ret$post)"  if ($pre or $post);
  $ret.=$opt;
  $ret="(?:$ret|$ws)"  if ($ws);

  if ($array and $hash) {
    return ($ret,%hash);
  } elsif ($array) {
    return ($ret,@list);
  } else {
    return $ret;
  }
}

# This will produce a delta with the correct number of signs.  At most two
# signs will be in it normally (one before the year, and one in front of
# the day), but if appropriate, signs will be in front of all elements.
# Also, as many of the signs will be equivalent as possible.
sub Delta_Normalize {
  print "DEBUG: Delta_Normalize\n"  if ($Curr{"Debug"} =~ /trace/);
  my($delta,$mode)=@_;
  return "" if (! $delta);
  return "+0:+0:+0:+0:+0:+0:+0"
    if ($delta =~ /^([+-]?0+:){6}[+-]?0+$/ and $Cnf{"DeltaSigns"});
  return "+0:0:0:0:0:0:0" if ($delta =~ /^([+-]?0+:){6}[+-]?0+$/);

  my($tmp,$sign1,$sign2,$len)=();

  # Calculate the length of the day in minutes
  $len=24*60;
  $len=$Curr{"WDlen"}  if ($mode==2 || $mode==3);

  # We have to get the sign of every component explicitely so that a "-0"
  # or "+0" doesn't get lost by treating it numerically (i.e. "-0:0:2" must
  # be a negative delta).

  my($y,$mon,$w,$d,$h,$m,$s)=&Delta_Split($delta);

  # We need to make sure that the signs of all parts of a delta are the
  # same.  The easiest way to do this is to convert all of the large
  # components to the smallest ones, then convert the smaller components
  # back to the larger ones.

  # Do the year/month part

  $mon += $y*12;                         # convert y to m
  $sign1="+";
  if ($mon<0) {
    $mon *= -1;
    $sign1="-";
  }

  $y    = $mon/12;                       # convert m to y
  $mon -= $y*12;

  $y=0    if ($y eq "-0");               # get around silly -0 problem
  $mon=0  if ($mon eq "-0");

  # Do the wk/day/hour/min/sec part

  {
    # Unfortunately, $s is overflowing for dates more than ~70 years
    # apart.
    no integer;

    if ($mode==3 || $mode==2) {
      $s += $d*$len*60 + $h*3600 + $m*60;        # convert d/h/m to s
    } else {
      $s += ($d+7*$w)*$len*60 + $h*3600 + $m*60; # convert w/d/h/m to s
    }
    $sign2="+";
    if ($s<0) {
      $s*=-1;
      $sign2="-";
    }

    $m  = int($s/60);                    # convert s to m
    $s -= $m*60;
    $d  = int($m/$len);                  # convert m to d
    $m -= $d*$len;

    # The rest should be fine.
  }
  $h  = $m/60;                           # convert m to h
  $m -= $h*60;
  if ($mode == 3 || $mode == 2) {
    $w  = $w*1;                          # get around +0 problem
  } else {
    $w  = $d/7;                          # convert d to w
    $d -= $w*7;
  }

  $w=0    if ($w eq "-0");               # get around silly -0 problem
  $d=0    if ($d eq "-0");
  $h=0    if ($h eq "-0");
  $m=0    if ($m eq "-0");
  $s=0    if ($s eq "-0");

  # Only include two signs if necessary
  $sign1=$sign2  if ($y==0 and $mon==0);
  $sign2=$sign1  if ($w==0 and $d==0 and $h==0 and $m==0 and $s==0);
  $sign2=""  if ($sign1 eq $sign2  and  ! $Cnf{"DeltaSigns"});

  if ($Cnf{"DeltaSigns"}) {
    return "$sign1$y:$sign1$mon:$sign2$w:$sign2$d:$sign2$h:$sign2$m:$sign2$s";
  } else {
    return "$sign1$y:$mon:$sign2$w:$d:$h:$m:$s";
  }
}

# This checks a delta to make sure it is valid.  If it is, it splits
# it and returns the elements with a sign on each.  The 2nd argument
# specifies the default sign.  Blank elements are set to 0.  If the
# third element is non-nil, exactly 7 elements must be included.
sub Delta_Split {
  print "DEBUG: Delta_Split\n"  if ($Curr{"Debug"} =~ /trace/);
  my($delta,$sign,$exact)=@_;
  my(@delta)=split(/:/,$delta);
  return ()  if ($exact  and $#delta != 6);
  my($i)=();
  $sign="+"  if (! defined $sign);
  for ($i=0; $i<=$#delta; $i++) {
    $delta[$i]="0"  if (! $delta[$i]);
    return ()  if ($delta[$i] !~ /^[+-]?\d+$/);
    $sign = ($delta[$i] =~ s/^([+-])// ? $1 : $sign);
    $delta[$i] = $sign.$delta[$i];
  }
  @delta;
}

# Reads up to 3 arguments.  $h may contain the time in any international
# format.  Any empty elements are set to 0.
sub Date_ParseTime {
  print "DEBUG: Date_ParseTime\n"  if ($Curr{"Debug"} =~ /trace/);
  my($h,$m,$s)=@_;
  my($t)=&CheckTime("one");

  if (defined $h  and  $h =~ /$t/) {
    $h=$1;
    $m=$2;
    $s=$3   if (defined $3);
  }
  $h="00"  if (! defined $h);
  $m="00"  if (! defined $m);
  $s="00"  if (! defined $s);

  ($h,$m,$s);
}

# Forms a date with the 6 elements passed in (all of which must be defined).
# No check as to validity is made.
sub Date_Join {
  print "DEBUG: Date_Join\n"  if ($Curr{"Debug"} =~ /trace/);
  my($y,$m,$d,$h,$mn,$s)=@_;
  my($ym,$md,$dh,$hmn,$mns)=();

  if      ($Cnf{"Internal"} == 0) {
    $ym=$md=$dh="";
    $hmn=$mns=":";

  } elsif ($Cnf{"Internal"} == 1) {
    $ym=$md=$dh=$hmn=$mns="";

  } elsif ($Cnf{"Internal"} == 2) {
    $ym=$md="-";
    $dh=" ";
    $hmn=$mns=":";

  } else {
    confess "ERROR: Invalid internal format in Date_Join.\n";
  }
  $m="0$m"    if (length($m)==1);
  $d="0$d"    if (length($d)==1);
  $h="0$h"    if (length($h)==1);
  $mn="0$mn"  if (length($mn)==1);
  $s="0$s"    if (length($s)==1);
  "$y$ym$m$md$d$dh$h$hmn$mn$mns$s";
}

# This checks a time.  If it is valid, it splits it and returns 3 elements.
# If "one" or "two" is passed in, a regexp with 1/2 or 2 digit hours is
# returned.
sub CheckTime {
  print "DEBUG: CheckTime\n"  if ($Curr{"Debug"} =~ /trace/);
  my($time)=@_;
  my($h)='(?:0?[0-9]|1[0-9]|2[0-3])';
  my($h2)='(?:0[0-9]|1[0-9]|2[0-3])';
  my($m)='[0-5][0-9]';
  my($s)=$m;
  my($hm)="(?:". $Lang{$Cnf{"Language"}}{"SepHM"} ."|:)";
  my($ms)="(?:". $Lang{$Cnf{"Language"}}{"SepMS"} ."|:)";
  my($ss)=$Lang{$Cnf{"Language"}}{"SepSS"};
  my($t)="^($h)$hm($m)(?:$ms($s)(?:$ss\\d+)?)?\$";
  if ($time eq "one") {
    return $t;
  } elsif ($time eq "two") {
    $t="^($h2)$hm($m)(?:$ms($s)(?:$ss\\d+)?)?\$";
    return $t;
  }

  if ($time =~ /$t/i) {
    ($h,$m,$s)=($1,$2,$3);
    $h="0$h" if (length($h)<2);
    $m="0$m" if (length($m)<2);
    $s="00"  if (! defined $s);
    return ($h,$m,$s);
  } else {
    return ();
  }
}

# This checks a recurrence.  If it is valid, it splits it and returns the
# elements.  Otherwise, it returns an empty list.
#    ($recur0,$recur1,$flags,$dateb,$date0,$date1)=&Recur_Split($recur);
sub Recur_Split {
  print "DEBUG: Recur_Split\n"  if ($Curr{"Debug"} =~ /trace/);
  my($recur)=@_;
  my(@ret,@tmp);

  my($R)  = '(\*?(?:[-,0-9]+[:\*]){6}[-,0-9]+)';
  my($F)  = '(?:\*([^*]*))';
  my($DB,$D0,$D1);
  $DB=$D0=$D1=$F;

  if ($recur =~ /^$R$F?$DB?$D0?$D1?$/) {
    @ret=($1,$2,$3,$4,$5);
    @tmp=split(/\*/,shift(@ret));
    return ()  if ($#tmp>1);
    return (@tmp,"",@ret)  if ($#tmp==0);
    return (@tmp,@ret);
  }
  return ();
}

# This checks a date.  If it is valid, it splits it and returns the elements.
# If no date is passed in, it returns a regular expression for the date.
sub Date_Split {
  print "DEBUG: Date_Split\n"  if ($Curr{"Debug"} =~ /trace/);
  my($date)=@_;
  my($ym,$md,$dh,$hmn,$mns)=();
  my($y)='(\d{4})';
  my($m)='(0[1-9]|1[0-2])';
  my($d)='(0[1-9]|[1-2][0-9]|3[0-1])';
  my($h)='([0-1][0-9]|2[0-3])';
  my($mn)='([0-5][0-9])';
  my($s)=$mn;

  if      ($Cnf{"Internal"} == 0) {
    $ym=$md=$dh="";
    $hmn=$mns=":";

  } elsif ($Cnf{"Internal"} == 1) {
    $ym=$md=$dh=$hmn=$mns="";

  } elsif ($Cnf{"Internal"} == 2) {
    $ym=$md="-";
    $dh=" ";
    $hmn=$mns=":";

  } else {
    confess "ERROR: Invalid internal format in Date_Split.\n";
  }

  my($t)="^$y$ym$m$md$d$dh$h$hmn$mn$mns$s\$";
  return $t  if ($date eq "");

  if ($date =~ /$t/) {
    ($y,$m,$d,$h,$mn,$s)=($1,$2,$3,$4,$5,$6);
    my(@d_in_m)=(0,31,28,31,30,31,30,31,31,30,31,30,31);
    $d_in_m[2]=29  if (&Date_LeapYear($y));
    return ()  if ($d>$d_in_m[$m]);
    return ($y,$m,$d,$h,$mn,$s);
  }
  return ();
}

# This returns the date easter occurs on for a given year as ($month,$day).
# This is from the Calendar FAQ.
sub Date_Easter {
  my($y)=@_;
  $y=&Date_FixYear($y)  if (length($y)==2);

  my($c) = $y/100;
  my($g) = $y % 19;
  my($k) = ($c-17)/25;
  my($i) = ($c - $c/4 - ($c-$k)/3 + 19*$g + 15) % 30;
  $i     = $i - ($i/28)*(1 - ($i/28)*(29/($i+1))*((21-$g)/11));
  my($j) = ($y + $y/4 + $i + 2 - $c + $c/4) % 7;
  my($l) = $i-$j;
  my($m) = 3 + ($l+40)/44;
  my($d) = $l + 28 - 31*($m/4);
  return ($m,$d);
}

# This takes a list of years, months, WeekOfMonth's, and optionally
# DayOfWeek's, and returns a list of dates.  Optionally, a list of dates
# can be passed in as the 1st argument (with the 2nd argument the null list)
# and the year/month of these will be used.
#
# If $FDn is non-zero, the first week of the month contains the first
# occurence of this day (1=Monday).  If $FIn is non-zero, the first week of
# the month contains the date (i.e. $FIn'th day of the month).
sub Date_Recur_WoM {
  my($y,$m,$w,$d,$FDn,$FIn)=@_;
  my(@y)=@$y;
  my(@m)=@$m;
  my(@w)=@$w;
  my(@d)=@$d;
  my($date0,$date1,@tmp,@date,$d0,$d1,@tmp2)=();

  if (@m) {
    @tmp=();
    foreach $y (@y) {
      return ()  if (length($y)==1 || length($y)==3 || ! &IsInt($y,0,9999));
      $y=&Date_FixYear($y)  if (length($y)==2);
      push(@tmp,$y);
    }
    @y=sort { $a<=>$b } (@tmp);

    return ()  if (! @m);
    foreach $m (@m) {
      return ()  if (! &IsInt($m,1,12));
    }
    @m=sort { $a<=>$b } (@m);

    @tmp=@tmp2=();
    foreach $y (@y) {
      foreach $m (@m) {
        push(@tmp,$y);
        push(@tmp2,$m);
      }
    }

    @y=@tmp;
    @m=@tmp2;

  } else {
    foreach $d0 (@y) {
      @tmp=&Date_Split($d0);
      return ()  if (! @tmp);
      push(@tmp2,$tmp[0]);
      push(@m,$tmp[1]);
    }
    @y=@tmp2;
  }

  return ()  if (! @w);
  foreach $w (@w) {
    return ()  if ($w==0  ||  ! &IsInt($w,-5,5));
  }

  if (@d) {
    foreach $d (@d) {
      return ()  if (! &IsInt($d,1,7));
    }
    @d=sort { $a<=>$b } (@d);
  }

  @date=();
  foreach $y (@y) {
    $m=shift(@m);

    # Find 1st day of this month and next month
    $date0=&Date_Join($y,$m,1,0,0,0);
    $date1=&DateCalc($date0,"+0:1:0:0:0:0:0");

    if (@d) {
      foreach $d (@d) {
        # Find 1st occurence of DOW (in both months)
        $d0=&Date_GetNext($date0,$d,1);
        $d1=&Date_GetNext($date1,$d,1);

        @tmp=();
        while (&Date_Cmp($d0,$d1)<0) {
          push(@tmp,$d0);
          $d0=&DateCalc($d0,"+0:0:1:0:0:0:0");
        }

        @tmp2=();
        foreach $w (@w) {
          if ($w>0) {
            push(@tmp2,$tmp[$w-1]);
          } else {
            push(@tmp2,$tmp[$#tmp+1+$w]);
          }
        }
        @tmp2=sort(@tmp2);
        push(@date,@tmp2);
      }

    } else {
      # Find 1st day of 1st week
      if ($FDn != 0) {
        $date0=&Date_GetNext($date0,$FDn,1);
      } else {
        $date0=&Date_Join($y,$m,$FIn,0,0,0);
      }
      $date0=&Date_GetPrev($date0,$Cnf{"FirstDay"},1);

      # Find 1st day of 1st week of next month
      if ($FDn != 0) {
        $date1=&Date_GetNext($date1,$FDn,1);
      } else {
        $date1=&DateCalc($date1,"+0:0:0:".($FIn-1).":0:0:0")  if ($FIn>1);
      }
      $date1=&Date_GetPrev($date1,$Cnf{"FirstDay"},1);

      @tmp=();
      while (&Date_Cmp($date0,$date1)<0) {
        push(@tmp,$date0);
        $date0=&DateCalc($date0,"+0:0:1:0:0:0:0");
      }

      @tmp2=();
      foreach $w (@w) {
        if ($w>0) {
          push(@tmp2,$tmp[$w-1]);
        } else {
          push(@tmp2,$tmp[$#tmp+1+$w]);
        }
      }
      @tmp2=sort(@tmp2);
      push(@date,@tmp2);
    }
  }

  @date;
}

# This returns a sorted list of dates formed by adding/subtracting
# $delta to $dateb in the range $date0<=$d<$dateb.  The first date int
# the list is actually the first date<$date0 and the last date in the
# list is the first date>=$date1 (because sometimes the set part will
# move the date back into the range).
sub Date_Recur {
  my($date0,$date1,$dateb,$delta)=@_;
  my(@ret,$d)=();

  while (&Date_Cmp($dateb,$date0)<0) {
    $dateb=&DateCalc_DateDelta($dateb,$delta);
  }
  while (&Date_Cmp($dateb,$date1)>=0) {
    $dateb=&DateCalc_DateDelta($dateb,"-$delta");
  }

  # Add the dates $date0..$dateb
  $d=$dateb;
  while (&Date_Cmp($d,$date0)>=0) {
    unshift(@ret,$d);
    $d=&DateCalc_DateDelta($d,"-$delta");
  }
  # Add the first date earler than the range
  unshift(@ret,$d);

  # Add the dates $dateb..$date1
  $d=&DateCalc_DateDelta($dateb,$delta);
  while (&Date_Cmp($d,$date1)<0) {
    push(@ret,$d);
    $d=&DateCalc_DateDelta($d,$delta);
  }
  # Add the first date later than the range
  push(@ret,$d);

  @ret;
}

# This sets the values in each date of a recurrence.
#
# $h,$m,$s can each be values or lists "1-2,4".  If any are equal to "-1",
# they are not set (and none of the larger elements are set).
sub Date_RecurSetTime {
  my($date0,$date1,$dates,$h,$m,$s)=@_;
  my(@dates)=@$dates;
  my(@h,@m,@s,$date,@tmp)=();

  $m="-1"  if ($s eq "-1");
  $h="-1"  if ($m eq "-1");

  if ($h ne "-1") {
    @h=&ReturnList($h);
    return ()  if ! (@h);
    @h=sort { $a<=>$b } (@h);

    @tmp=();
    foreach $date (@dates) {
      foreach $h (@h) {
        push(@tmp,&Date_SetDateField($date,"h",$h,1));
      }
    }
    @dates=@tmp;
  }

  if ($m ne "-1") {
    @m=&ReturnList($m);
    return ()  if ! (@m);
    @m=sort { $a<=>$b } (@m);

    @tmp=();
    foreach $date (@dates) {
      foreach $m (@m) {
        push(@tmp,&Date_SetDateField($date,"mn",$m,1));
      }
    }
    @dates=@tmp;
  }

  if ($s ne "-1") {
    @s=&ReturnList($s);
    return ()  if ! (@s);
    @s=sort { $a<=>$b } (@s);

    @tmp=();
    foreach $date (@dates) {
      foreach $s (@s) {
        push(@tmp,&Date_SetDateField($date,"s",$s,1));
      }
    }
    @dates=@tmp;
  }

  @tmp=();
  foreach $date (@dates) {
    push(@tmp,$date)  if (&Date_Cmp($date,$date0)>=0  &&
                          &Date_Cmp($date,$date1)<0  &&
                          &Date_Split($date));
  }

  @tmp;
}

sub DateCalc_DateDate {
  print "DEBUG: DateCalc_DateDate\n"  if ($Curr{"Debug"} =~ /trace/);
  my($D1,$D2,$mode)=@_;
  my(@d_in_m)=(0,31,28,31,30,31,30,31,31,30,31,30,31);
  $mode=0  if (! defined $mode);

  # Exact mode
  if ($mode==0) {
    my($y1,$m1,$d1,$h1,$mn1,$s1)=&Date_Split($D1);
    my($y2,$m2,$d2,$h2,$mn2,$s2)=&Date_Split($D2);
    my($i,@delta,$d,$delta,$y)=();

    # form the delta for hour/min/sec
    $delta[4]=$h2-$h1;
    $delta[5]=$mn2-$mn1;
    $delta[6]=$s2-$s1;

    # form the delta for yr/mon/day
    $delta[0]=$delta[1]=0;
    $d=0;
    if ($y2>$y1) {
      $d=&Date_DaysInYear($y1) - &Date_DayOfYear($m1,$d1,$y1);
      $d+=&Date_DayOfYear($m2,$d2,$y2);
      for ($y=$y1+1; $y<$y2; $y++) {
        $d+= &Date_DaysInYear($y);
      }
    } elsif ($y2<$y1) {
      $d=&Date_DaysInYear($y2) - &Date_DayOfYear($m2,$d2,$y2);
      $d+=&Date_DayOfYear($m1,$d1,$y1);
      for ($y=$y2+1; $y<$y1; $y++) {
        $d+= &Date_DaysInYear($y);
      }
      $d *= -1;
    } else {
      $d=&Date_DayOfYear($m2,$d2,$y2) - &Date_DayOfYear($m1,$d1,$y1);
    }
    $delta[2]=0;
    $delta[3]=$d;

    for ($i=0; $i<7; $i++) {
      $delta[$i]="+".$delta[$i]  if ($delta[$i]>=0);
    }

    $delta=join(":",@delta);
    $delta=&Delta_Normalize($delta,0);
    return $delta;
  }

  my($date1,$date2)=($D1,$D2);
  my($tmp,$sign,$err,@tmp)=();

  # make sure both are work days
  if ($mode==2 || $mode==3) {
    $date1=&Date_NextWorkDay($date1,0,1);
    $date2=&Date_NextWorkDay($date2,0,1);
  }

  # make sure date1 comes before date2
  if (&Date_Cmp($date1,$date2)>0) {
    $sign="-";
    $tmp=$date1;
    $date1=$date2;
    $date2=$tmp;
  } else {
    $sign="+";
  }
  if (&Date_Cmp($date1,$date2)==0) {
    return "+0:+0:+0:+0:+0:+0:+0"  if ($Cnf{"DeltaSigns"});
    return "+0:0:0:0:0:0:0";
  }

  my($y1,$m1,$d1,$h1,$mn1,$s1)=&Date_Split($date1);
  my($y2,$m2,$d2,$h2,$mn2,$s2)=&Date_Split($date2);
  my($dy,$dm,$dw,$dd,$dh,$dmn,$ds,$ddd)=(0,0,0,0,0,0,0,0);

  if ($mode != 3) {

    # Do years
    $dy=$y2-$y1;
    $dm=0;
    if ($dy>0) {
      $tmp=&DateCalc_DateDelta($date1,"+$dy:0:0:0:0:0:0",\$err,0);
      if (&Date_Cmp($tmp,$date2)>0) {
        $dy--;
        $tmp=$date1;
        $tmp=&DateCalc_DateDelta($date1,"+$dy:0:0:0:0:0:0",\$err,0)
          if ($dy>0);
        $dm=12;
      }
      $date1=$tmp;
    }

    # Do months
    $dm+=$m2-$m1;
    if ($dm>0) {
      $tmp=&DateCalc_DateDelta($date1,"+0:$dm:0:0:0:0:0",\$err,0);
      if (&Date_Cmp($tmp,$date2)>0) {
        $dm--;
        $tmp=$date1;
        $tmp=&DateCalc_DateDelta($date1,"+0:$dm:0:0:0:0:0",\$err,0)
          if ($dm>0);
      }
      $date1=$tmp;
    }

    # At this point, check to see that we're on a business day again so that
    # Aug 3 (Monday) -> Sep 3 (Sunday) -> Sep 4 (Monday)  = 1 month
    if ($mode==2) {
      if (! &Date_IsWorkDay($date1,0)) {
        $date1=&Date_NextWorkDay($date1,0,1);
      }
    }
  }

  # Do days
  if ($mode==2 || $mode==3) {
    $dd=0;
    while (1) {
      $tmp=&Date_NextWorkDay($date1,1,1);
      if (&Date_Cmp($tmp,$date2)<=0) {
        $dd++;
        $date1=$tmp;
      } else {
        last;
      }
    }

  } else {
    ($y1,$m1,$d1)=( &Date_Split($date1) )[0..2];
    $dd=0;
    # If we're jumping across months, set $d1 to the first of the next month
    # (or possibly the 0th of next month which is equivalent to the last day
    # of this month)
    if ($m1!=$m2) {
      $d_in_m[2]=29  if (&Date_LeapYear($y1));
      $dd=$d_in_m[$m1]-$d1+1;
      $d1=1;
      $tmp=&DateCalc_DateDelta($date1,"+0:0:0:$dd:0:0:0",\$err,0);
      if (&Date_Cmp($tmp,$date2)>0) {
        $dd--;
        $d1--;
        $tmp=&DateCalc_DateDelta($date1,"+0:0:0:$dd:0:0:0",\$err,0);
      }
      $date1=$tmp;
    }

    $ddd=0;
    if ($d1<$d2) {
      $ddd=$d2-$d1;
      $tmp=&DateCalc_DateDelta($date1,"+0:0:0:$ddd:0:0:0",\$err,0);
      if (&Date_Cmp($tmp,$date2)>0) {
        $ddd--;
        $tmp=&DateCalc_DateDelta($date1,"+0:0:0:$ddd:0:0:0",\$err,0);
      }
      $date1=$tmp;
    }
    $dd+=$ddd;
  }

  # in business mode, make sure h1 comes before h2 (if not find delta between
  # now and end of day and move to start of next business day)
  $d1=( &Date_Split($date1) )[2];
  $dh=$dmn=$ds=0;
  if ($mode==2 || $mode==3  and  $d1 != $d2) {
    $tmp=&Date_SetTime($date1,$Cnf{"WorkDayEnd"});
    $tmp=&DateCalc_DateDelta($tmp,"+0:0:0:0:0:1:0")
      if ($Cnf{"WorkDay24Hr"});
    $tmp=&DateCalc_DateDate($date1,$tmp,0);
    ($tmp,$tmp,$tmp,$tmp,$dh,$dmn,$ds)=&Delta_Split($tmp);
    $date1=&Date_NextWorkDay($date1,1,0);
    $date1=&Date_SetTime($date1,$Cnf{"WorkDayBeg"});
    $d1=( &Date_Split($date1) )[2];
    confess "ERROR: DateCalc DateDate Business.\n"  if ($d1 != $d2);
  }

  # Hours, minutes, seconds
  $tmp=&DateCalc_DateDate($date1,$date2,0);
  @tmp=&Delta_Split($tmp);
  $dh  += $tmp[4];
  $dmn += $tmp[5];
  $ds  += $tmp[6];

  $tmp="$sign$dy:$dm:0:$dd:$dh:$dmn:$ds";
  &Delta_Normalize($tmp,$mode);
}

sub DateCalc_DeltaDelta {
  print "DEBUG: DateCalc_DeltaDelta\n"  if ($Curr{"Debug"} =~ /trace/);
  my($D1,$D2,$mode)=@_;
  my(@delta1,@delta2,$i,$delta,@delta)=();
  $mode=0  if (! defined $mode);

  @delta1=&Delta_Split($D1);
  @delta2=&Delta_Split($D2);
  for ($i=0; $i<7; $i++) {
    $delta[$i]=$delta1[$i]+$delta2[$i];
    $delta[$i]="+".$delta[$i]  if ($delta[$i]>=0);
  }

  $delta=join(":",@delta);
  $delta=&Delta_Normalize($delta,$mode);
  return $delta;
}

sub DateCalc_DateDelta {
  print "DEBUG: DateCalc_DateDelta\n"  if ($Curr{"Debug"} =~ /trace/);
  my($D1,$D2,$errref,$mode)=@_;
  my($date)=();
  my(@d_in_m)=(0,31,28,31,30,31,30,31,31,30,31,30,31);
  my($h1,$m1,$h2,$m2,$len,$hh,$mm)=();
  $mode=0  if (! defined $mode);

  if ($mode==2 || $mode==3) {
    $h1=$Curr{"WDBh"};
    $m1=$Curr{"WDBm"};
    $h2=$Curr{"WDEh"};
    $m2=$Curr{"WDEm"};
    $hh=$h2-$h1;
    $mm=$m2-$m1;
    if ($mm<0) {
      $hh--;
      $mm+=60;
    }
  }

  # Date, delta
  my($y,$m,$d,$h,$mn,$s)=&Date_Split($D1);
  my($dy,$dm,$dw,$dd,$dh,$dmn,$ds)=&Delta_Split($D2);

  # do the month/year part
  $y+=$dy;
  &ModuloAddition(-12,$dm,\$m,\$y);   # -12 means 1-12 instead of 0-11
  $d_in_m[2]=29  if (&Date_LeapYear($y));

  # if we have gone past the last day of a month, move the date back to
  # the last day of the month
  if ($d>$d_in_m[$m]) {
    $d=$d_in_m[$m];
  }

  # do the week part
  if ($mode==0  ||  $mode==1) {
    $dd += $dw*7;
  } else {
    $date=&DateCalc_DateDelta(&Date_Join($y,$m,$d,$h,$mn,$s),
                              "+0:0:$dw:0:0:0:0",0);
    ($y,$m,$d,$h,$mn,$s)=&Date_Split($date);
  }

  # in business mode, set the day to a work day at this point so the h/mn/s
  # stuff will work out
  if ($mode==2 || $mode==3) {
    $d=$d_in_m[$m] if ($d>$d_in_m[$m]);
    $date=&Date_NextWorkDay(&Date_Join($y,$m,$d,$h,$mn,$s),0,1);
    ($y,$m,$d,$h,$mn,$s)=&Date_Split($date);
  }

  # seconds, minutes, hours
  &ModuloAddition(60,$ds,\$s,\$mn);
  if ($mode==2 || $mode==3) {
    while (1) {
      &ModuloAddition(60,$dmn,\$mn,\$h);
      $h+= $dh;

      if ($h>$h2  or  $h==$h2 && $mn>$m2) {
        $dh=$h-$h2;
        $dmn=$mn-$m2;
        $h=$h1;
        $mn=$m1;
        $dd++;

      } elsif ($h<$h1  or  $h==$h1 && $mn<$m1) {
        $dh=$h1-$h;
        $dmn=$m1-$mn;
        $h=$h2;
        $mn=$m2;
        $dd--;

      } elsif ($h==$h2  &&  $mn==$m2) {
        $dd++;
        $dh=-$hh;
        $dmn=-$mm;

      } else {
        last;
      }
    }

  } else {
    &ModuloAddition(60,$dmn,\$mn,\$h);
    &ModuloAddition(24,$dh,\$h,\$d);
  }

  # If we have just gone past the last day of the month, we need to make
  # up for this:
  if ($d>$d_in_m[$m]) {
    $dd+= $d-$d_in_m[$m];
    $d=$d_in_m[$m];
  }

  # days
  if ($mode==2 || $mode==3) {
    if ($dd>=0) {
      $date=&Date_NextWorkDay(&Date_Join($y,$m,$d,$h,$mn,$s),$dd,1);
    } else {
      $date=&Date_PrevWorkDay(&Date_Join($y,$m,$d,$h,$mn,$s),-$dd,1);
    }
    ($y,$m,$d,$h,$mn,$s)=&Date_Split($date);

  } else {
    $d_in_m[2]=29  if (&Date_LeapYear($y));
    $d=$d_in_m[$m]  if ($d>$d_in_m[$m]);
    $d += $dd;
    while ($d<1) {
      $m--;
      if ($m==0) {
        $m=12;
        $y--;
        if (&Date_LeapYear($y)) {
          $d_in_m[2]=29;
        } else {
          $d_in_m[2]=28;
        }
      }
      $d += $d_in_m[$m];
    }
    while ($d>$d_in_m[$m]) {
      $d -= $d_in_m[$m];
      $m++;
      if ($m==13) {
        $m=1;
        $y++;
        if (&Date_LeapYear($y)) {
          $d_in_m[2]=29;
        } else {
          $d_in_m[2]=28;
        }
      }
    }
  }

  if ($y<0 or $y>9999) {
    $$errref=3;
    return;
  }
  &Date_Join($y,$m,$d,$h,$mn,$s);
}

sub Date_UpdateHolidays {
  print "DEBUG: Date_UpdateHolidays\n"  if ($Curr{"Debug"} =~ /trace/);
  my($year)=@_;
  $Holiday{"year"}=$year;

  my($date,$delta,$err)=();
  my($key,@tmp,$tmp);

  foreach $key (keys %{ $Holiday{"desc"} }) {
    @tmp=&Recur_Split($key);
    if (@tmp) {
      $tmp=&ParseDateString("$year-01-01");
      ($date)=&ParseRecur($key,$tmp,$tmp,($year+1)."-01-01");
      next  if (! $date);

    } elsif ($key =~ /^(.*)([+-].*)$/) {
      # Date +/- Delta
      ($date,$delta)=($1,$2);
      $tmp=&ParseDateString("$date $year");
      if ($tmp) {
        $date=$tmp;
      } else {
        $date=&ParseDateString($date);
        next  if ($date !~ /^$year/);
      }
      $date=&DateCalc($date,$delta,\$err,0);

    } else {
      # Date
      $date=$key;
      $tmp=&ParseDateString("$date $year");
      if ($tmp) {
        $date=$tmp;
      } else {
        $date=&ParseDateString($date);
        next  if ($date !~ /^$year/);
      }
    }
    $Holiday{"dates"}{$year}{$date}=$Holiday{"desc"}{$key};
  }
}

# This sets a Date::Manip config variable.
sub Date_SetConfigVariable {
  print "DEBUG: Date_SetConfigVariable\n"  if ($Curr{"Debug"} =~ /trace/);
  my($var,$val)=@_;

  # These are most appropriate for command line options instead of in files.
  $Cnf{"PathSep"}=$val,          return  if ($var =~ /^PathSep$/i);
  $Cnf{"PersonalCnf"}=$val,      return  if ($var =~ /^PersonalCnf$/i);
  $Cnf{"PersonalCnfPath"}=$val,  return  if ($var =~ /^PersonalCnfPath$/i);
  &EraseHolidays(),              return  if ($var =~ /^EraseHolidays$/i);
  $Cnf{"IgnoreGlobalCnf"}=1,     return  if ($var =~ /^IgnoreGlobalCnf$/i);

  $Curr{"InitLang"}=1,
  $Cnf{"Language"}=$val,         return  if ($var =~ /^Language$/i);
  $Cnf{"DateFormat"}=$val,       return  if ($var =~ /^DateFormat$/i);
  $Cnf{"TZ"}=$val,               return  if ($var =~ /^TZ$/i);
  $Cnf{"ConvTZ"}=$val,           return  if ($var =~ /^ConvTZ$/i);
  $Cnf{"Internal"}=$val,         return  if ($var =~ /^Internal$/i);
  $Cnf{"FirstDay"}=$val,         return  if ($var =~ /^FirstDay$/i);
  $Cnf{"WorkWeekBeg"}=$val,      return  if ($var =~ /^WorkWeekBeg$/i);
  $Cnf{"WorkWeekEnd"}=$val,      return  if ($var =~ /^WorkWeekEnd$/i);
  $Cnf{"WorkDayBeg"}=$val,
  $Curr{"ResetWorkDay"}=1,       return  if ($var =~ /^WorkDayBeg$/i);
  $Cnf{"WorkDayEnd"}=$val,
  $Curr{"ResetWorkDay"}=1,       return  if ($var =~ /^WorkDayEnd$/i);
  $Cnf{"WorkDay24Hr"}=$val,
  $Curr{"ResetWorkDay"}=1,       return  if ($var =~ /^WorkDay24Hr$/i);
  $Cnf{"DeltaSigns"}=$val,       return  if ($var =~ /^DeltaSigns$/i);
  $Cnf{"Jan1Week1"}=$val,        return  if ($var =~ /^Jan1Week1$/i);
  $Cnf{"YYtoYYYY"}=$val,         return  if ($var =~ /^YYtoYYYY$/i);
  $Cnf{"UpdateCurrTZ"}=$val,     return  if ($var =~ /^UpdateCurrTZ$/i);
  $Cnf{"IntCharSet"}=$val,       return  if ($var =~ /^IntCharSet$/i);
  $Curr{"DebugVal"}=$val,        return  if ($var =~ /^Debug$/i);
  $Cnf{"TomorrowFirst"}=$val,    return  if ($var =~ /^TomorrowFirst$/i);
  $Cnf{"ForceDate"}=$val,        return  if ($var =~ /^ForceDate$/i);

  confess "ERROR: Unknown configuration variable $var in Date::Manip.\n";
}

sub EraseHolidays {
  print "DEBUG: EraseHolidays\n"  if ($Curr{"Debug"} =~ /trace/);

  $Cnf{"EraseHolidays"}=0;
  delete $Holiday{"list"};
  $Holiday{"list"}={};
  delete $Holiday{"desc"};
  $Holiday{"desc"}={};
}

# This reads an init file.
sub Date_InitFile {
  print "DEBUG: Date_InitFile\n"  if ($Curr{"Debug"} =~ /trace/);
  my($file)=@_;
  my($in)=new IO::File;
  local($_)=();
  my($section)="vars";
  my($var,$val,$recur,$name)=();

  $in->open($file)  ||  return;
  while(defined ($_=<$in>)) {
    chomp;
    s/^\s+//;
    s/\s+$//;
    next  if (! $_  or  /^\#/);

    if (/^\*holiday/i) {
      $section="holiday";
      &EraseHolidays()  if ($section =~ /holiday/i  &&  $Cnf{"EraseHolidays"});
      next;
    }

    if ($section =~ /var/i) {
      confess "ERROR: invalid Date::Manip config file line.\n  $_\n"
        if (! /(.*\S)\s*=\s*(.*)$/);
      ($var,$val)=($1,$2);
      &Date_SetConfigVariable($var,$val);

    } elsif ($section =~ /holiday/i) {
      confess "ERROR: invalid Date::Manip config file line.\n  $_\n"
        if (! /(.*\S)\s*=\s*(.*)$/);
      ($recur,$name)=($1,$2);
      $name=""  if (! defined $name);
      $Holiday{"desc"}{$recur}=$name;

    } else {
      # A section not currently used by Date::Manip (but may be
      # used by some extension to it).
      next;
    }
  }
  close($in);
}

# $flag=&Date_TimeCheck(\$h,\$mn,\$s,\$ampm);
#   Returns 1 if any of the fields are bad.  All fields are optional, and
#   all possible checks are done on the data.  If a field is not passed in,
#   it is set to default values.  If data is missing, appropriate defaults
#   are supplied.
sub Date_TimeCheck {
  print "DEBUG: Date_TimeCheck\n"  if ($Curr{"Debug"} =~ /trace/);
  my($h,$mn,$s,$ampm)=@_;
  my($tmp1,$tmp2,$tmp3)=();

  $$h=""     if (! defined $$h);
  $$mn=""    if (! defined $$mn);
  $$s=""     if (! defined $$s);
  $$ampm=""  if (! defined $$ampm);
  $$ampm=uc($$ampm)  if ($$ampm);

  # Check hour
  $tmp1=$Lang{$Cnf{"Language"}}{"AmPm"};
  $tmp2="";
  if ($$ampm =~ /^$tmp1$/i) {
    $tmp3=$Lang{$Cnf{"Language"}}{"AM"};
    $tmp2="AM"  if ($$ampm =~ /^$tmp3$/i);
    $tmp3=$Lang{$Cnf{"Language"}}{"PM"};
    $tmp2="PM"  if ($$ampm =~ /^$tmp3$/i);
  } elsif ($$ampm) {
    return 1;
  }
  if ($tmp2 eq "AM" || $tmp2 eq "PM") {
    $$h="0$$h"    if (length($$h)==1);
    return 1      if ($$h<1 || $$h>12);
    $$h="00"      if ($tmp2 eq "AM"  and  $$h==12);
    $$h += 12     if ($tmp2 eq "PM"  and  $$h!=12);
  } else {
    $$h="00"      if ($$h eq "");
    $$h="0$$h"    if (length($$h)==1);
    return 1      if (! &IsInt($$h,0,23));
    $tmp2="AM"    if ($$h<12);
    $tmp2="PM"    if ($$h>=12);
  }
  $$ampm=$Lang{$Cnf{"Language"}}{"AMstr"};
  $$ampm=$Lang{$Cnf{"Language"}}{"PMstr"}  if ($tmp2 eq "PM");

  # Check minutes
  $$mn="00"       if ($$mn eq "");
  $$mn="0$$mn"    if (length($$mn)==1);
  return 1        if (! &IsInt($$mn,0,59));

  # Check seconds
  $$s="00"        if ($$s eq "");
  $$s="0$$s"      if (length($$s)==1);
  return 1        if (! &IsInt($$s,0,59));

  return 0;
}

# $flag=&Date_DateCheck(\$y,\$m,\$d,\$h,\$mn,\$s,\$ampm,\$wk);
#   Returns 1 if any of the fields are bad.  All fields are optional, and
#   all possible checks are done on the data.  If a field is not passed in,
#   it is set to default values.  If data is missing, appropriate defaults
#   are supplied.
#
#   If the flag UpdateHolidays is set, the year is set to
#   CurrHolidayYear.
sub Date_DateCheck {
  print "DEBUG: Date_DateCheck\n"  if ($Curr{"Debug"} =~ /trace/);
  my($y,$m,$d,$h,$mn,$s,$ampm,$wk)=@_;
  my($tmp1,$tmp2,$tmp3)=();

  my(@d_in_m)=(0,31,28,31,30,31,30,31,31,30,31,30,31);
  my($curr_y)=$Curr{"Y"};
  my($curr_m)=$Curr{"M"};
  my($curr_d)=$Curr{"D"};
  $$m=1, $$d=1  if (defined $$y and ! defined $$m and ! defined $$d);
  $$y=""     if (! defined $$y);
  $$m=""     if (! defined $$m);
  $$d=""     if (! defined $$d);
  $$wk=""    if (! defined $$wk);
  $$d=$curr_d  if ($$y eq "" and $$m eq "" and $$d eq "");

  # Check year.
  $$y=$curr_y             if ($$y eq "");
  $$y=&Date_FixYear($$y)  if (length($$y)<4);
  return 1                if (! &IsInt($$y,0,9999));
  $d_in_m[2]=29           if (&Date_LeapYear($$y));

  # Check month
  $$m=$curr_m             if ($$m eq "");
  $$m=$Lang{$Cnf{"Language"}}{"MonthH"}{lc($$m)}
    if (exists $Lang{$Cnf{"Language"}}{"MonthH"}{lc($$m)});
  $$m="0$$m"              if (length($$m)==1);
  return 1                if (! &IsInt($$m,1,12));

  # Check day
  $$d="01"                if ($$d eq "");
  $$d="0$$d"              if (length($$d)==1);
  return 1                if (! &IsInt($$d,1,$d_in_m[$$m]));
  if ($$wk) {
    $tmp1=&Date_DayOfWeek($$m,$$d,$$y);
    $tmp2=$Lang{$Cnf{"Language"}}{"WeekH"}{lc($$wk)}
      if (exists $Lang{$Cnf{"Language"}}{"WeekH"}{lc($$wk)});
    return 1      if ($tmp1 != $tmp2);
  }

  return &Date_TimeCheck($h,$mn,$s,$ampm);
}

# Takes a year in 2 digit form and returns it in 4 digit form
sub Date_FixYear {
  print "DEBUG: Date_FixYear\n"  if ($Curr{"Debug"} =~ /trace/);
  my($y)=@_;
  my($curr_y)=$Curr{"Y"};
  $y=$curr_y  if (! defined $y  or  ! $y);
  return $y  if (length($y)==4);
  confess "ERROR: Invalid year ($y)\n"  if (length($y)!=2);
  my($y1,$y2)=();

  if (lc($Cnf{"YYtoYYYY"}) eq "c") {
    $y1=substring($y,0,2);
    $y="$y1$y";

  } elsif ($Cnf{"YYtoYYYY"} =~ /^c(\d{2})$/i) {
    $y1=$1;
    $y="$y1$y";

  } elsif ($Cnf{"YYtoYYYY"} =~ /^c(\d{2})(\d{2})$/i) {
    $y1="$1$2";
    $y ="$1$y";
    $y += 100  if ($y<$y1);

  } else {
    $y1=$curr_y-$Cnf{"YYtoYYYY"};
    $y2=$y1+99;
    $y="19$y";
    while ($y<$y1) {
      $y+=100;
    }
    while ($y>$y2) {
      $y-=100;
    }
  }
  $y;
}

# &Date_NthWeekOfYear($y,$n);
#   Returns a list of (YYYY,MM,DD) for the 1st day of the Nth week of the
#   year.
# &Date_NthWeekOfYear($y,$n,$dow,$flag);
#   Returns a list of (YYYY,MM,DD) for the Nth DoW of the year.  If flag
#   is nil, the first DoW of the year may actually be in the previous
#   year (since the 1st week may include days from the previous year).
#   If flag is non-nil, the 1st DoW of the year refers to the 1st one
#   actually in the year
sub Date_NthWeekOfYear {
  print "DEBUG: Date_NthWeekOfYear\n"  if ($Curr{"Debug"} =~ /trace/);
  my($y,$n,$dow,$flag)=@_;
  my($m,$d,$err,$tmp,$date,%dow)=();
  $y=$Curr{"Y"}  if (! defined $y  or  ! $y);
  $n=1       if (! defined $n  or  $n eq "");
  return ()  if ($n<0  ||  $n>53);
  if (defined $dow) {
    $dow=lc($dow);
    %dow=%{ $Lang{$Cnf{"Language"}}{"WeekH"} };
    $dow=$dow{$dow}  if (exists $dow{$dow});
    return ()  if ($dow<1 || $dow>7);
    $flag=""   if (! defined $flag);
  } else {
    $dow="";
    $flag="";
  }

  $y=&Date_FixYear($y)  if (length($y)<4);
  if ($Cnf{"Jan1Week1"}) {
    $date=&Date_Join($y,1,1,0,0,0);
  } else {
    $date=&Date_Join($y,1,4,0,0,0);
  }
  $date=&Date_GetPrev($date,$Cnf{"FirstDay"},1);
  $date=&Date_GetNext($date,$dow,1)  if ($dow ne "");

  if ($flag) {
    ($tmp)=&Date_Split($date);
    $n++  if ($tmp != $y);
  }

  if ($n>1) {
    $date=&DateCalc_DateDelta($date,"+0:0:". ($n-1) . ":0:0:0:0",\$err,0);
  } elsif ($n==0) {
    $date=&DateCalc_DateDelta($date,"-0:0:1:0:0:0:0",\$err,0);
  }
  ($y,$m,$d)=&Date_Split($date);
  ($y,$m,$d);
}

########################################################################
# LANGUAGE INITIALIZATION
########################################################################

# 8-bit international characters can be gotten by "\xXX".  I don't know
# how to get 16-bit characters.  I've got to read up on perllocale.
sub Char_8Bit {
  my($hash)=@_;

  #   grave `
  #     A`    00c0     a`    00e0
  #     E`    00c8     e`    00e8
  #     I`    00cc     i`    00ec
  #     O`    00d2     o`    00f2
  #     U`    00d9     u`    00f9
  #     W`    1e80     w`    1e81
  #     Y`    1ef2     y`    1ef3
  $$hash{"A`"} = "\xc0";   #   Å¿
  $$hash{"E`"} = "\xc8";   #   Å»
  $$hash{"I`"} = "\xcc";   #   ÅÃ
  $$hash{"O`"} = "\xd2";   #   Å“
  $$hash{"U`"} = "\xd9";   #   ÅŸ
  $$hash{"a`"} = "\xe0";   #   Å‡
  $$hash{"e`"} = "\xe8";   #   ÅË
  $$hash{"i`"} = "\xec";   #   ÅÏ
  $$hash{"o`"} = "\xf2";   #   ÅÚ
  $$hash{"u`"} = "\xf9";   #   Å˘

  #   acute '
  #     A'    00c1     a'    00e1
  #     C'    0106     c'    0107
  #     E'    00c9     e'    00e9
  #     I'    00cd     i'    00ed
  #     L'    0139     l'    013a
  #     N'    0143     n'    0144
  #     O'    00d3     o'    00f3
  #     R'    0154     r'    0155
  #     S'    015a     s'    015b
  #     U'    00da     u'    00fa
  #     W'    1e82     w'    1e83
  #     Y'    00dd     y'    00fd
  #     Z'    0179     z'    017a

  $$hash{"A'"} = "\xc1";   #   Å¡
  $$hash{"E'"} = "\xc9";   #   Å…
  $$hash{"I'"} = "\xcd";   #   ÅÕ
  $$hash{"O'"} = "\xd3";   #   Å”
  $$hash{"U'"} = "\xda";   #   Å⁄
  $$hash{"Y'"} = "\xdd";   #   Å›
  $$hash{"a'"} = "\xe1";   #   Å·
  $$hash{"e'"} = "\xe9";   #   ÅÈ
  $$hash{"i'"} = "\xed";   #   ÅÌ
  $$hash{"o'"} = "\xf3";   #   ÅÛ
  $$hash{"u'"} = "\xfa";   #   Å˙
  $$hash{"y'"} = "\xfd";   #   Å˝

  #   double acute "         "
  #     O"    0150     o"    0151
  #     U"    0170     u"    0171

  #   circumflex ^
  #     A^    00c2     a^    00e2
  #     C^    0108     c^    0109
  #     E^    00ca     e^    00ea
  #     G^    011c     g^    011d
  #     H^    0124     h^    0125
  #     I^    00ce     i^    00ee
  #     J^    0134     j^    0135
  #     O^    00d4     o^    00f4
  #     S^    015c     s^    015d
  #     U^    00db     u^    00fb
  #     W^    0174     w^    0175
  #     Y^    0176     y^    0177

  $$hash{"A^"} = "\xc2";   #   Å¬
  $$hash{"E^"} = "\xca";   #   Å 
  $$hash{"I^"} = "\xce";   #   ÅŒ
  $$hash{"O^"} = "\xd4";   #   Å‘
  $$hash{"U^"} = "\xdb";   #   Å€
  $$hash{"a^"} = "\xe2";   #   Å‚
  $$hash{"e^"} = "\xea";   #   ÅÍ
  $$hash{"i^"} = "\xee";   #   ÅÓ
  $$hash{"o^"} = "\xf4";   #   ÅÙ
  $$hash{"u^"} = "\xfb";   #   Å˚

  #   tilde ~
  #     A~    00c3    a~    00e3
  #     I~    0128    i~    0129
  #     N~    00d1    n~    00f1
  #     O~    00d5    o~    00f5
  #     U~    0168    u~    0169

  $$hash{"A~"} = "\xc3";   #   Å√
  $$hash{"N~"} = "\xd1";   #   Å—
  $$hash{"O~"} = "\xd5";   #   Å’
  $$hash{"a~"} = "\xe3";   #   Å„
  $$hash{"n~"} = "\xf1";   #   ÅÒ
  $$hash{"o~"} = "\xf5";   #   Åı

  #   macron -
  #     A-    0100    a-    0101
  #     E-    0112    e-    0113
  #     I-    012a    i-    012b
  #     O-    014c    o-    014d
  #     U-    016a    u-    016b

  #   breve ( [half circle up]
  #     A(    0102    a(    0103
  #     G(    011e    g(    011f
  #     U(    016c    u(    016d

  #   dot .
  #     C.    010a    c.    010b
  #     E.    0116    e.    0117
  #     G.    0120    g.    0121
  #     I.    0130
  #     Z.    017b    z.    017c

  #   diaeresis :  [side by side dots]
  #     A:    00c4    a:    00e4
  #     E:    00cb    e:    00eb
  #     I:    00cf    i:    00ef
  #     O:    00d6    o:    00f6
  #     U:    00dc    u:    00fc
  #     W:    1e84    w:    1e85
  #     Y:    0178    y:    00ff

  $$hash{"A:"} = "\xc4";   #   Åƒ
  $$hash{"E:"} = "\xcb";   #   ÅÀ
  $$hash{"I:"} = "\xcf";   #   Åœ
  $$hash{"O:"} = "\xd6";   #   Å÷
  $$hash{"U:"} = "\xdc";   #   Å‹
  $$hash{"a:"} = "\xe4";   #   Å‰
  $$hash{"e:"} = "\xeb";   #   ÅÎ
  $$hash{"i:"} = "\xef";   #   ÅÔ
  $$hash{"o:"} = "\xf6";   #   Åˆ
  $$hash{"u:"} = "\xfc";   #   Å¸
  $$hash{"y:"} = "\xff";   #   Å~

  #   ring o
  #     U0    016e    u0    016f

  #   cedilla ,  [squiggle down and left below the letter]
  #     ,C    00c7    ,c    00e7
  #     ,G    0122    ,g    0123
  #     ,K    0136    ,k    0137
  #     ,L    013b    ,l    013c
  #     ,N    0145    ,n    0146
  #     ,R    0156    ,r    0157
  #     ,S    015e    ,s    015f
  #     ,T    0162    ,t    0163

  $$hash{",C"} = "\xc7";   #   Å«
  $$hash{",c"} = "\xe7";   #   ÅÁ

  #   ogonek ;  [squiggle down and right below the letter]
  #     A;    0104    a;    0105
  #     E;    0118    e;    0119
  #     I;    012e    i;    012f
  #     U;    0172    u;    0173

  #   caron <  [little v on top]
  #     A<    01cd    a<    01ce
  #     C<    010c    c<    010d
  #     D<    010e    d<    010f
  #     E<    011a    e<    011b
  #     L<    013d    l<    013e
  #     N<    0147    n<    0148
  #     R<    0158    r<    0159
  #     S<    0160    s<    0161
  #     T<    0164    t<    0165
  #     Z<    017d    z<    017e


  # Other characters


  # First character is below, 2nd character is above
  $$hash{"||"} = "\xa6";   #   Å¶
  $$hash{" :"} = "\xa8";   #   Å®
  $$hash{"-a"} = "\xaa";   #   Å™
  #$$hash{" -"}= "\xaf";   #   ÅØ   (narrow bar)
  $$hash{" -"} = "\xad";   #   Å≠   (wide bar)
  $$hash{" o"} = "\xb0";   #   Å∞
  $$hash{"-+"} = "\xb1";   #   Å±
  $$hash{" 1"} = "\xb9";   #   Åπ
  $$hash{" 2"} = "\xb2";   #   Å≤
  $$hash{" 3"} = "\xb3";   #   Å≥
  $$hash{" '"} = "\xb4";   #   Å¥
  $$hash{"-o"} = "\xba";   #   Å∫
  $$hash{" ."} = "\xb7";   #   Å∑
  $$hash{", "} = "\xb8";   #   Å∏
  $$hash{"Ao"} = "\xc5";   #   Å≈
  $$hash{"ao"} = "\xe5";   #   ÅÂ
  $$hash{"ox"} = "\xf0";   #   Å

  # upside down characters

  $$hash{"ud!"} = "\xa1";  #   Å°
  $$hash{"ud?"} = "\xbf";  #   Åø

  # overlay characters

  $$hash{"X o"} = "\xa4";  #   Å§
  $$hash{"Y ="} = "\xa5";  #   Å•
  $$hash{"S o"} = "\xa7";  #   Åß
  $$hash{"O c"} = "\xa9";  #   Å©    Copyright
  $$hash{"O R"} = "\xae";  #   ÅÆ
  $$hash{"D -"} = "\xd0";  #   Å–
  $$hash{"O /"} = "\xd8";  #   Åÿ
  $$hash{"o /"} = "\xf8";  #   Å¯

  # special names

  $$hash{"1/4"} = "\xbc";  #   Åº
  $$hash{"1/2"} = "\xbd";  #   ÅΩ
  $$hash{"3/4"} = "\xbe";  #   Åæ
  $$hash{"<<"}  = "\xab";  #   Å´
  $$hash{">>"}  = "\xbb";  #   Åª
  $$hash{"cent"}= "\xa2";  #   Å¢
  $$hash{"lb"}  = "\xa3";  #   Å£
  $$hash{"mu"}  = "\xb5";  #   Åµ
  $$hash{"beta"}= "\xdf";  #   Åﬂ
  $$hash{"para"}= "\xb6";  #   Å∂
  $$hash{"-|"}  = "\xac";  #   Å¨
  $$hash{"AE"}  = "\xc6";  #   Å∆
  $$hash{"ae"}  = "\xe6";  #   ÅÊ
  $$hash{"x"}   = "\xd7";  #   Å◊
  $$hash{"P"}   = "\xde";  #   Åﬁ
  $$hash{"/"}   = "\xf7";  #   Å˜
  $$hash{"p"}   = "\xfe";  #   Å~
}

# $hashref = &Date_Init_LANGUAGE;
#   This returns a hash containing all of the initialization for a
#   specific language.  The hash elements are:
#
#   @ month_name      full month names          January February ...
#   @ month_abb       month abbreviations       Jan Feb ...
#   @ day_name        day names                 Monday Tuesday ...
#   @ day_abb         day abbreviations         Mon Tue ...
#   @ day_char        day character abbrevs     M T ...
#   @ am              AM notations
#   @ pm              PM notations
#
#   @ num_suff        number with suffix        1st 2nd ...
#   @ num_word        numbers spelled out       first second ...
#
#   $ now             words which mean now      now today ...
#   $ last            words which mean last     last final ...
#   $ each            words which mean each     each every ...
#   $ of              of (as in a member of)    in of ...
#                     ex.  4th day OF June
#   $ at              at 4:00                   at
#   $ on              on Sunday                 on
#   $ future          in the future             in
#   $ past            in the past               ago
#   $ next            next item                 next
#   $ prev            previous item             last previous
#   $ later           2 hours later
#
#   % offset          a hash of special dates   { tomorrow->0:0:0:1:0:0:0 }
#   % times           a hash of times           { noon->12:00:00 ... }
#
#   $ years           words for year            y yr year ...
#   $ months          words for month
#   $ weeks           words for week
#   $ days            words for day
#   $ hours           words for hour
#   $ minutes         words for minute
#   $ seconds         words for second
#   % replace
#       The replace element is quite important, but a bit tricky.  In
#       English (and probably other languages), one of the abbreviations
#       for the word month that would be nice is "m".  The problem is that
#       "m" matches the "m" in "minute" which causes the string to be
#       improperly matched in some cases.  Hence, the list of abbreviations
#       for month is given as:
#         "mon month months"
#       In order to allow you to enter "m", replacements can be done.
#       $replace is a list of pairs of words which are matched and replaced
#       AS ENTIRE WORDS.  Having $replace equal to "m"->"month" means that
#       the entire word "m" will be replaced with "month".  This allows the
#       desired abbreviation to be used.  Make sure that replace contains
#       an even number of words (i.e. all must be pairs).  Any time a
#       desired abbreviation matches the start of any other, it has to go
#       here.
#
#   $ exact           exact mode                exactly
#   $ approx          approximate mode          approximately
#   $ business        business mode             business
#
#   r sephm           hour/minute separator     (?::)
#   r sepms           minute/second separator   (?::)
#   r sepss           second/fraction separator (?:[.:])
#
#   Elements marked with an asterix (@) are returned as a set of lists.
#   Each list contains the strings for each element.  The first set is used
#   when the 7-bit ASCII (US) character set is wanted.  The 2nd set is used
#   when an international character set is available.  Both of the 1st two
#   sets should be complete (but the 2nd list can be left empty to force the
#   first set to be used always).  The 3rd set and later can be partial sets
#   if desired.
#
#   Elements marked with a dollar ($) are returned as a simple list of words.
#
#   Elements marked with a percent (%) are returned as a hash list.
#
#   Elements marked with (r) are regular expression elements which must not
#   create a back reference.
#
# ***NOTE*** Every hash element (unless otherwise noted) MUST be defined in
# every language.

sub Date_Init_English {
  print "DEBUG: Date_Init_English\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;

  $$d{"month_name"}=
    [["January","February","March","April","May","June",
      "July","August","September","October","November","December"]];

  $$d{"month_abb"}=
    [["Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"],
     [],
     ["","","","","","","","","Sept"]];

  $$d{"day_name"}=
    [["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]];
  $$d{"day_abb"}=
    [["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]];
  $$d{"day_char"}=
    [["M","T","W","Th","F","Sa","S"]];

  $$d{"num_suff"}=
    [["1st","2nd","3rd","4th","5th","6th","7th","8th","9th","10th",
      "11th","12th","13th","14th","15th","16th","17th","18th","19th","20th",
      "21st","22nd","23rd","24th","25th","26th","27th","28th","29th","30th",
      "31st"]];
  $$d{"num_word"}=
    [["first","second","third","fourth","fifth","sixth","seventh","eighth",
      "ninth","tenth","eleventh","twelfth","thirteenth","fourteenth",
      "fifteenth","sixteenth","seventeenth","eighteenth","nineteenth",
      "twentieth","twenty-first","twenty-second","twenty-third",
      "twenty-fourth","twenty-fifth","twenty-sixth","twenty-seventh",
      "twenty-eighth","twenty-ninth","thirtieth","thirty-first"]];

  $$d{"now"}     =["today","now"];
  $$d{"last"}    =["last","final"];
  $$d{"each"}    =["each","every"];
  $$d{"of"}      =["in","of"];
  $$d{"at"}      =["at"];
  $$d{"on"}      =["on"];
  $$d{"future"}  =["in"];
  $$d{"past"}    =["ago"];
  $$d{"next"}    =["next"];
  $$d{"prev"}    =["previous","last"];
  $$d{"later"}   =["later"];

  $$d{"exact"}   =["exactly"];
  $$d{"approx"}  =["approximately"];
  $$d{"business"}=["business"];

  $$d{"offset"}  =["yesterday","-0:0:0:1:0:0:0","tomorrow","+0:0:0:1:0:0:0"];
  $$d{"times"}   =["noon","12:00:00","midnight","00:00:00"];

  $$d{"years"}   =["y","yr","year","yrs","years"];
  $$d{"months"}  =["mon","month","months"];
  $$d{"weeks"}   =["w","wk","wks","week","weeks"];
  $$d{"days"}    =["d","day","days"];
  $$d{"hours"}   =["h","hr","hrs","hour","hours"];
  $$d{"minutes"} =["mn","min","minute","minutes"];
  $$d{"seconds"} =["s","sec","second","seconds"];
  $$d{"replace"} =["m","month"];

  $$d{"sephm"}   =':';
  $$d{"sepms"}   =':';
  $$d{"sepss"}   ='[.:]';

  $$d{"am"}      = ["AM","A.M."];
  $$d{"pm"}      = ["PM","P.M."];
}

sub Date_Init_Italian {
  print "DEBUG: Date_Init_Italian\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;

  $$d{"month_name"}=
    [[qw(Gennaio Febbraio Marzo Aprile Maggio Giugno
         Luglio Agosto Settembre Ottobre Novembre Dicembre)]];

  $$d{"month_abb"}=
    [[qw(Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic)]];

  $$d{"day_name"}=
    [[qw(Lunedi Martedi Mercoledi Giovedi Venerdi Sabato Domenica)],
     [qw(LunedÌ MartedÌ MercoledÌ GiovedÌ VenerdÌ)]];
  $$d{"day_abb"}=
    [[qw(Lun Mar Mer Gio Ven Sab Dom)]];
  $$d{"day_char"}=
    [[qw(L Ma Me G V S D)]];

  $$d{"num_suff"}=
    [[qw(1mo 2do 3zo 4to 5to 6to 7mo 8vo 9no 10mo 11mo 12mo 13mo 14mo 15mo
         16mo 17mo 18mo 19mo 20mo 21mo 22mo 23mo 24mo 25mo 26mo 27mo 28mo
         29mo 3mo 31mo)]];
  $$d{"num_word"}=
    [[qw(primo secondo terzo quarto quinto sesto settimo ottavo nono decimo
         undicesimo dodicesimo tredicesimo quattordicesimo quindicesimo
         sedicesimo diciassettesimo diciottesimo diciannovesimo ventesimo
         ventunesimo ventiduesimo ventitreesimo ventiquattresimo
         venticinquesimo ventiseiesimo ventisettesimo ventottesimo
         ventinovesimo trentesimo trentunesimo)]];

  $$d{"now"}     =[qw(adesso oggi)];
  $$d{"last"}    =[qw(ultimo)];
  $$d{"each"}    =[qw(ogni)];
  $$d{"of"}      =[qw(della del)];
  $$d{"at"}      =[qw(alle)];
  $$d{"on"}      =[qw(di)];
  $$d{"future"}  =[qw(fra)];
  $$d{"past"}    =[qw(fa)];
  $$d{"next"}    =[qw(prossimo)];
  $$d{"prev"}    =[qw(ultimo)];
  $$d{"later"}   =[qw(dopo)];

  $$d{"exact"}   =[qw(esattamente)];
  $$d{"approx"}  =[qw(circa)];
  $$d{"business"}=[qw(lavorativi lavorativo)];

  $$d{"offset"}  =[qw(ieri -0:0:0:1:0:0:0 domani +0:0:0:1:0:0:0)];
  $$d{"times"}   =[qw(mezzogiorno 12:00:00 mezzanotte 00:00:00)];

  $$d{"years"}   =[qw(anni anno a)];
  $$d{"months"}  =[qw(mesi mese mes)];
  $$d{"weeks"}   =[qw(settimane settimana sett)];
  $$d{"days"}    =[qw(giorni giorno g)];
  $$d{"hours"}   =[qw(ore ora h)];
  $$d{"minutes"} =[qw(minuti minuto min)];
  $$d{"seconds"} =[qw(secondi secondo sec)];
  $$d{"replace"} =[qw(s sec m mes)];

  $$d{"sephm"}   =':';
  $$d{"sepms"}   =':';
  $$d{"sepss"}   ='[.:]';

  $$d{"am"}      = [qw(AM)];
  $$d{"pm"}      = [qw(PM)];
}

sub Date_Init_French {
  print "DEBUG: Date_Init_French\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;
  my(%h)=();
  &Char_8Bit(\%h);
  my($e)=$h{"e'"};
  my($u)=$h{"u^"};
  my($a)=$h{"a'"};

  $$d{"month_name"}=
    [["janvier","fevrier","mars","avril","mai","juin",
      "juillet","aout","septembre","octobre","novembre","decembre"],
     ["janvier","f$e"."vrier","mars","avril","mai","juin",
      "juillet","ao$u"."t","septembre","octobre","novembre","d$e"."cembre"]];
  $$d{"month_abb"}=
    [["jan","fev","mar","avr","mai","juin",
      "juil","aout","sept","oct","nov","dec"],
     ["jan","f$e"."v","mar","avr","mai","juin",
      "juil","ao$u"."t","sept","oct","nov","d$e"."c"]];

  $$d{"day_name"}=
    [["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"]];
  $$d{"day_abb"}=
    [["lun","mar","mer","jeu","ven","sam","dim"]];
  $$d{"day_char"}=
    [["l","ma","me","j","v","s","d"]];

  $$d{"num_suff"}=
    [["1er","2e","3e","4e","5e","6e","7e","8e","9e","10e",
      "11e","12e","13e","14e","15e","16e","17e","18e","19e","20e",
      "21e","22e","23e","24e","25e","26e","27e","28e","29e","30e",
      "31e"]];
  $$d{"num_word"}=
    [["premier","deux","trois","quatre","cinq","six","sept","huit","neuf",
      "dix","onze","douze","treize","quatorze","quinze","seize","dix-sept",
      "dix-huit","dix-neuf","vingt","vingt et un","vingt-deux","vingt-trois",
      "vingt-quatre","vingt-cinq","vingt-six","vingt-sept","vingt-huit",
      "vingt-neuf","trente","trente et un"],
     ["1re"]];

  $$d{"now"}     =["aujourd'hui","maintenant"];
  $$d{"last"}    =["dernier"];
  $$d{"each"}    =["chaque","tous les","toutes les"];
  $$d{"of"}      =["en","de"];
  $$d{"at"}      =["a",$a."0"];
  $$d{"on"}      =["sur"];
  $$d{"future"}  =["en"];
  $$d{"past"}    =["il y a"];
  $$d{"next"}    =["suivant"];
  $$d{"prev"}    =["precedent","pr$e"."c$e"."dent"];
  $$d{"later"}   =["plus tard"];

  $$d{"exact"}   =["exactement"];
  $$d{"approx"}  =["approximativement"];
  $$d{"business"}=["professionel"];

  $$d{"offset"}  =["hier","-0:0:0:1:0:0:0","demain","+0:0:0:1:0:0:0"];
  $$d{"times"}   =["midi","12:00:00","minuit","00:00:00"];

  $$d{"years"}   =["an","annee","ans","annees","ann$e"."e","ann$e"."es"];
  $$d{"months"}  =["mois"];
  $$d{"weeks"}   =["sem","semaine"];
  $$d{"days"}    =["j","jour","jours"];
  $$d{"hours"}   =["h","heure","heures"];
  $$d{"minutes"} =["mn","min","minute","minutes"];
  $$d{"seconds"} =["s","sec","seconde","secondes"];
  $$d{"replace"} =["m","mois"];

  $$d{"sephm"}   ='[h:]';
  $$d{"sepms"}   =':';
  $$d{"sepss"}   ='[.:,]';

  $$d{"am"}      = ["du matin"];
  $$d{"pm"}      = ["du soir"];
}

sub Date_Init_Romanian {
  print "DEBUG: Date_Init_Romanian\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;

  $$d{"month_name"}=
    [["ianuarie","februarie","martie","aprilie","mai","iunie",
      "iulie","august","septembrie","octombrie","noiembrie","decembrie"]];
  $$d{"month_abb"}=
    [["ian","febr","mart","apr","mai","iun",
      "iul","aug","sept","oct","nov","dec"],
     ["","feb"]];

  $$d{"day_name"}=
    [["luni","marti","miercuri","joi","vineri","simbata","duminica"],
     ["luni","mar˛i","miercuri","joi","vineri","sÓmb„t„",
      "duminic„"]];
  $$d{"day_abb"}=
    [["lun","mar","mie","joi","vin","sim","dum"],
     ["lun","mar","mie","joi","vin","sÓm","dum"]];
  $$d{"day_char"}=
    [["L","Ma","Mi","J","V","S","D"]];

  $$d{"num_suff"}=
    [["prima","a doua","a 3-a","a 4-a","a 5-a","a 6-a","a 7-a","a 8-a",
      "a 9-a","a 10-a","a 11-a","a 12-a","a 13-a","a 14-a","a 15-a",
      "a 16-a","a 17-a","a 18-a","a 19-a","a 20-a","a 21-a","a 22-a",
      "a 23-a","a 24-a","a 25-a","a 26-a","a 27-a","a 28-a","a 29-a",
      "a 30-a","a 31-a"]];

  $$d{"num_word"}=
    [["prima","a doua","a treia","a patra","a cincea","a sasea","a saptea",
      "a opta","a noua","a zecea","a unsprezecea","a doisprezecea",
      "a treisprezecea","a patrusprezecea","a cincisprezecea","a saiprezecea",
      "a saptesprezecea","a optsprezecea","a nouasprezecea","a douazecea",
      "a douazecisiuna","a douazecisidoua","a douazecisitreia",
      "a douazecisipatra","a douazecisicincea","a douazecisisasea",
      "a douazecisisaptea","a douazecisiopta","a douazecisinoua","a treizecea",
      "a treizecisiuna"],
     ["prima","a doua","a treia","a patra","a cincea","a ∫asea",
      "a ∫aptea","a opta","a noua","a zecea","a unsprezecea",
      "a doisprezecea","a treisprezecea","a patrusprezecea","a cincisprezecea",
      "a ∫aiprezecea","a ∫aptesprezecea","a optsprezecea",
      "a nou„sprezecea","a dou„zecea","a dou„zeci∫iuna",
      "a dou„zeci∫idoua","a dou„zeci∫itreia",
      "a dou„zeci∫ipatra","a dou„zeci∫icincea",
      "a dou„zeci∫i∫asea","a dou„zeci∫i∫aptea",
      "a dou„zeci∫iopta","a dou„zeci∫inoua","a treizecea",
      "a treizeci∫iuna"],
     ["intii", "doi", "trei", "patru", "cinci", "sase", "sapte",
      "opt","noua","zece","unsprezece","doisprezece",
      "treisprezece","patrusprezece","cincisprezece","saiprezece",
      "saptesprezece","optsprezece","nouasprezece","douazeci",
      "douazecisiunu","douazecisidoi","douazecisitrei",
      "douazecisipatru","douazecisicinci","douazecisisase","douazecisisapte",
      "douazecisiopt","douazecisinoua","treizeci","treizecisiunu"],
     ["ÓntÓi", "doi", "trei", "patru", "cinci", "∫ase", "∫apte",
      "opt","nou„","zece","unsprezece","doisprezece",
      "treisprezece","patrusprezece","cincisprezece","∫aiprezece",
      "∫aptesprezece","optsprezece","nou„sprezece","dou„zeci",
      "dou„zeci∫iunu","dou„zeci∫idoi","dou„zeci∫itrei",
      "dou„zecisipatru","dou„zeci∫icinci","dou„zeci∫i∫ase",
      "dou„zeci∫i∫apte","dou„zeci∫iopt",
      "dou„zeci∫inou„","treizeci","treizeci∫iunu"]];

  $$d{"now"}     =["acum","azi","astazi","ast„zi"];
  $$d{"last"}    =["ultima"];
  $$d{"each"}    =["fiecare"];
  $$d{"of"}      =["din","in","n"];
  $$d{"at"}      =["la"];
  $$d{"on"}      =["on"];
  $$d{"future"}  =["in","Ón"];
  $$d{"past"}    =["in urma", "Ón urm„"];
  $$d{"next"}    =["urmatoarea","urm„toarea"];
  $$d{"prev"}    =["precedenta","ultima"];
  $$d{"later"}   =["mai tirziu", "mai tÓrziu"];

  $$d{"exact"}   =["exact"];
  $$d{"approx"}  =["aproximativ"];
  $$d{"business"}=["de lucru","lucratoare","lucr„toare"];

  $$d{"offset"}  =["ieri","-0:0:0:1:0:0:0",
                   "alaltaieri", "-0:0:0:2:0:0:0",
                   "alalt„ieri","-0:0:0:2:0:0:0",
                   "miine","+0:0:0:1:0:0:0",
                   "mÓine","+0:0:0:1:0:0:0",
                   "poimiine","+0:0:0:2:0:0:0",
                   "poimÓine","+0:0:0:2:0:0:0"];
  $$d{"times"}   =["amiaza","12:00:00",
                   "amiaz„","12:00:00",
                   "miezul noptii","00:00:00",
                   "miezul nop˛ii","00:00:00"];

  $$d{"years"}   =["ani","an","a"];
  $$d{"months"}  =["luni","luna","lun„","l"];
  $$d{"weeks"}   =["saptamini","s„pt„mÓni","saptamina",
                   "s„pt„mÓna","sapt","s„pt"];
  $$d{"days"}    =["zile","zi","z"];
  $$d{"hours"}   =["ore", "ora", "or„", "h"];
  $$d{"minutes"} =["minute","min","m"];
  $$d{"seconds"} =["secunde","sec",];
  $$d{"replace"} =["s","secunde"];

  $$d{"sephm"}   =':';
  $$d{"sepms"}   =':';
  $$d{"sepss"}   ='[.:,]';

  $$d{"am"}      = ["AM","A.M."];
  $$d{"pm"}      = ["PM","P.M."];
}

sub Date_Init_Swedish {
  print "DEBUG: Date_Init_Swedish\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;

  $$d{"month_name"}=
    [["Januari","Februari","Mars","April","Maj","Juni",
      "Juli","Augusti","September","Oktober","November","December"]];
  $$d{"month_abb"}=
    [["Jan","Feb","Mar","Apr","Maj","Jun",
      "Jul","Aug","Sep","Okt","Nov","Dec"]];

  $$d{"day_name"}=
    [["Mandag","Tisdag","Onsdag","Torsdag","Fredag","Lordag","Sondag"],
     ["MÂndag","Tisdag","Onsdag","Torsdag","Fredag","Lˆrdag",
      "Sˆndag"]];
  $$d{"day_abb"}=
    [["Man","Tis","Ons","Tor","Fre","Lor","Son"],
     ["MÂn","Tis","Ons","Tor","Fre","Lˆr","Sˆn"]];
  $$d{"day_char"}=
    [["M","Ti","O","To","F","L","S"]];

  $$d{"num_suff"}=
    [["1:a","2:a","3:e","4:e","5:e","6:e","7:e","8:e","9:e","10:e",
      "11:e","12:e","13:e","14:e","15:e","16:e","17:e","18:e","19:e","20:e",
      "21:a","22:a","23:e","24:e","25:e","26:e","27:e","28:e","29:e","30:e",
      "31:a"]];
  $$d{"num_word"}=
    [["forsta","andra","tredje","fjarde","femte","sjatte","sjunde",
      "attonde","nionde","tionde","elfte","tolfte","trettonde","fjortonde",
      "femtonde","sextonde","sjuttonde","artonde","nittonde","tjugonde",
      "tjugoforsta","tjugoandra","tjugotredje","tjugofjarde","tjugofemte",
      "tjugosjatte","tjugosjunde","tjugoattonde","tjugonionde",
      "trettionde","trettioforsta"],
     ["fˆrsta","andra","tredje","fj‰rde","femte","sj‰tte","sjunde",
      "Âttonde","nionde","tionde","elfte","tolfte","trettonde","fjortonde",
      "femtonde","sextonde","sjuttonde","artonde","nittonde","tjugonde",
      "tjugofˆrsta","tjugoandra","tjugotredje","tjugofj‰rde","tjugofemte",
      "tjugosj‰tte","tjugosjunde","tjugoÂttonde","tjugonionde",
      "trettionde","trettiofˆrsta"]];

  $$d{"now"}     =["idag","nu"];
  $$d{"last"}    =["forra","fˆrra","senaste"];
  $$d{"each"}    =["varje"];
  $$d{"of"}      =["om"];
  $$d{"at"}      =["kl","kl.","klockan"];
  $$d{"on"}      =["pa","pÂ"];
  $$d{"future"}  =["om"];
  $$d{"past"}    =["sedan"];
  $$d{"next"}    =["nasta","n‰sta"];
  $$d{"prev"}    =["forra","fˆrra"];
  $$d{"later"}   =["senare"];

  $$d{"exact"}   =["exakt"];
  $$d{"approx"}  =["ungefar","ungef‰r"];
  $$d{"business"}=["arbetsdag","arbetsdagar"];

  $$d{"offset"}  =["igÂr","-0:0:0:1:0:0:0","igar","-0:0:0:1:0:0:0",
                   "imorgon","+0:0:0:1:0:0:0"];
  $$d{"times"}   =["mitt pa dagen","12:00:00","mitt pÂ dagen","12:00:00",
                   "midnatt","00:00:00"];

  $$d{"years"}   =["ar","Âr"];
  $$d{"months"}  =["man","manad","manader","mÂn","mÂnad","mÂnader"];
  $$d{"weeks"}   =["v","vecka","veckor"];
  $$d{"days"}    =["d","dag","dagar"];
  $$d{"hours"}   =["t","tim","timme","timmar"];
  $$d{"minutes"} =["min","minut","minuter"];
  $$d{"seconds"} =["s","sek","sekund","sekunder"];
  $$d{"replace"} =["m","minut"];

  $$d{"sephm"}   ='[.:]';
  $$d{"sepms"}   =':';
  $$d{"sepss"}   ='[.:]';

  $$d{"am"}      = ["FM"];
  $$d{"pm"}      = ["EM"];
}

sub Date_Init_German {
  print "DEBUG: Date_Init_German\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;
  my(%h)=();
  &Char_8Bit(\%h);
  my($a)=$h{"a:"};
  my($u)=$h{"u:"};
  my($o)=$h{"o:"};
  my($b)=$h{"beta"};

  $$d{"month_name"}=
    [["Januar","Februar","Maerz","April","Mai","Juni",
      "Juli","August","September","Oktober","November","Dezember"],
    ["J$a"."nner","Februar","M$a"."rz","April","Mai","Juni",
      "Juli","August","September","Oktober","November","Dezember"]];
  $$d{"month_abb"}=
    [["Jan","Feb","Mar","Apr","Mai","Jun",
      "Jul","Aug","Sep","Okt","Nov","Dez"],
     ["J$a"."n","Feb","M$a"."r","Apr","Mai","Jun",
      "Jul","Aug","Sep","Okt","Nov","Dez"]];

  $$d{"day_name"}=
    [["Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag",
      "Sonntag"]];
  $$d{"day_abb"}=
    [["Mon","Die","Mit","Don","Fre","Sam","Son"]];
  $$d{"day_char"}=
    [["M","Di","Mi","Do","F","Sa","So"]];

  $$d{"num_suff"}=
    [["1.","2.","3.","4.","5.","6.","7.","8.","9.","10.",
      "11.","12.","13.","14.","15.","16.","17.","18.","19.","20.",
      "21.","22.","23.","24.","25.","26.","27.","28.","29.","30.",
      "31."]];
  $$d{"num_word"}=
    [
     ["erste","zweite","dritte","vierte","funfte","sechste","siebente",
      "achte","neunte","zehnte","elfte","zwolfte","dreizehnte","vierzehnte",
      "funfzehnte","sechzehnte","siebzehnte","achtzehnte","neunzehnte",
      "zwanzigste","einundzwanzigste","zweiundzwanzigste","dreiundzwanzigste",
      "vierundzwanzigste","funfundzwanzigste","sechundzwanzigste",
      "siebundzwanzigste","achtundzwanzigste","neunundzwanzigste",
      "dreibigste","einunddreibigste"],
     ["erste","zweite","dritte","vierte","f$u"."nfte","sechste","siebente",
      "achte","neunte","zehnte","elfte","zw$o"."lfte","dreizehnte",
      "vierzehnte","f$u"."nfzehnte","sechzehnte","siebzehnte","achtzehnte",
      "neunzehnte","zwanzigste","einundzwanzigste","zweiundzwanzigste",
      "dreiundzwanzigste","vierundzwanzigste","f$u"."nfundzwanzigste",
      "sechundzwanzigste","siebundzwanzigste","achtundzwanzigste",
      "neunundzwanzigste","drei$b"."igste","einunddrei$b"."igste"],
    ["erster"]];

  $$d{"now"}     =["heute","jetzt"];
  $$d{"last"}    =["letzte","letzten"];
  $$d{"each"}    =["jeden"];
  $$d{"of"}      =["der","im","des"];
  $$d{"at"}      =["um"];
  $$d{"on"}      =["am"];
  $$d{"future"}  =["in"];
  $$d{"past"}    =["vor"];
  $$d{"next"}    =["nachste","n$a"."chste","nachsten","n$a"."chsten"];
  $$d{"prev"}    =["vorherigen","vorherige","letzte","letzten"];
  $$d{"later"}   =["spater","sp$a"."ter"];

  $$d{"exact"}   =["genau"];
  $$d{"approx"}  =["ungefahr","ungef$a"."hr"];
  $$d{"business"}=["Arbeitstag"];

  $$d{"offset"}  =["gestern","-0:0:0:1:0:0:0","morgen","+0:0:0:1:0:0:0"];
  $$d{"times"}   =["mittag","12:00:00","mitternacht","00:00:00"];

  $$d{"years"}   =["j","Jahr","Jahre"];
  $$d{"months"}  =["Monat","Monate"];
  $$d{"weeks"}   =["w","Woche","Wochen"];
  $$d{"days"}    =["t","Tag","Tage"];
  $$d{"hours"}   =["h","std","Stunde","Stunden"];
  $$d{"minutes"} =["min","Minute","Minuten"];
  $$d{"seconds"} =["s","sek","Sekunde","Sekunden"];
  $$d{"replace"} =["m","Monat"];

  $$d{"sephm"}   =':';
  $$d{"sepms"}   ='[: ]';
  $$d{"sepss"}   ='[.:]';

  $$d{"am"}      = ["FM"];
  $$d{"pm"}      = ["EM"];
}

sub Date_Init_Dutch {
  print "DEBUG: Date_Init_Dutch\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;

  $$d{"month_name"}=
    [["januari","februari","maart","april","mei","juni","juli","augustus",
      "september","october","november","december"],
     ["","","","","","","","","","oktober"]];

  $$d{"month_abb"}=
    [["jan","feb","maa","apr","mei","jun","jul",
      "aug","sep","oct","nov","dec"],
     ["","","","","","","","","","okt"]];
  $$d{"day_name"}=
    [["maandag","dinsdag","woensdag","donderdag","vrijdag","zaterdag",
      "zondag"]];
  $$d{"day_abb"}=
    [["ma","di","wo","do","vr","zat","zon"]];
  $$d{"day_char"}=
    [["M","D","W","D","V","Za","Zo"]];

  $$d{"num_suff"}=
    [["1ste","2de","3de","4de","5de","6de","7de","8ste","9de","10de",
      "11de","12de","13de","14de","15de","16de","17de","18de","19de","20ste",
      "21ste","22ste","23ste","24ste","25ste","26ste","27ste","28ste","29ste",
      "30ste","31ste"]];
  $$d{"num_word"}=
    [["eerste","tweede","derde","vierde","vijfde","zesde","zevende","achtste",
      "negende","tiende","elfde","twaalfde",
      map {"${_}tiende";} qw (der veer vijf zes zeven acht negen),
      "twintigste",
      map {"${_}entwintigste";} qw (een twee drie vier vijf zes zeven acht
                                    negen),
      "dertigste","eenendertigste"],
     ["","","","","","","","","","","","","","","","","","","","",
      map {"${_}-en-twintigste";} qw (een twee drie vier vijf zes zeven acht
                                      negen),
      "dertigste","een-en-dertigste"],
     ["een","twee","drie","vier","vijf","zes","zeven","acht","negen","tien",
      "elf","twaalf",
      map {"${_}tien"} qw (der veer vijf zes zeven acht negen),
      "twintig",
      map {"${_}entwintig"} qw (een twee drie vier vijf zes zeven acht negen),
      "dertig","eenendertig"],
     ["","","","","","","","","","","","","","","","","","","","",
      map {"${_}-en-twintig"} qw (een twee drie vier vijf zes zeven acht
                                  negen),
      "dertig","een-en-dertig"]];

  $$d{"now"}     =["nu","nou","vandaag"];
  $$d{"last"}    =["laatste"];
  $$d{"each"}    =["elke","elk"];
  $$d{"of"}      =["in","van"];
  $$d{"at"}      =["om"];
  $$d{"on"}      =["op"];
  $$d{"future"}  =["over"];
  $$d{"past"}    =["geleden","vroeger","eerder"];
  $$d{"next"}    =["volgende","volgend"];
  $$d{"prev"}    =["voorgaande","voorgaand"];
  $$d{"later"}   =["later"];

  $$d{"exact"}   =["exact","precies","nauwkeurig"];
  $$d{"approx"}  =["ongeveer","ong",'ong\.',"circa","ca",'ca\.'];
  $$d{"business"}=["werk","zakelijke","zakelijk"];

  $$d{"offset"}  =["morgen","+0:0:0:1:0:0:0","overmorgen","+0:0:0:2:0:0:0",
                   "gisteren","-0:0:0:1:0:0:0","eergisteren","-0::00:2:0:0:0"];
  $$d{"times"}   =["noen","12:00:00","middernacht","00:00:00"];

  $$d{"years"}   =["jaar","jaren","ja","j"];
  $$d{"months"}  =["maand","maanden","mnd"];
  $$d{"weeks"}   =["week","weken","w"];
  $$d{"days"}    =["dag","dagen","d"];
  $$d{"hours"}   =["uur","uren","u","h"];
  $$d{"minutes"} =["minuut","minuten","min"];
  $$d{"seconds"} =["seconde","seconden","sec","s"];
  $$d{"replace"} =["m","minuten"];

  $$d{"sephm"}   ='[:.uh]';
  $$d{"sepms"}   ='[:.m]';
  $$d{"sepss"}   ='[.:]';

  $$d{"am"}      = ["am","a.m.","vm","v.m.","voormiddag","'s_ochtends",
                    "ochtend","'s_nachts","nacht"];
  $$d{"pm"}      = ["pm","p.m.","nm","n.m.","namiddag","'s_middags","middag",
                    "'s_avonds","avond"];
}

sub Date_Init_Polish {
  print "DEBUG: Date_Init_Polish\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;

  $$d{"month_name"}=
    [["stycznia","luty","marca","kwietnia","maja","czerwca",
      "lipca","sierpnia","wrzesnia","pazdziernika","listopada","grudnia"],
     ["stycznia","luty","marca","kwietnia","maja","czerwca","lipca",
      "sierpnia","wrzeúnia","paüdziernika","listopada","grudnia"]];
  $$d{"month_abb"}=
    [["sty.","lut.","mar.","kwi.","maj","cze.",
      "lip.","sie.","wrz.","paz.","lis.","gru."],
     ["sty.","lut.","mar.","kwi.","maj","cze.",
      "lip.","sie.","wrz.","paü.","lis.","gru."]];

  $$d{"day_name"}=
    [["poniedzialek","wtorek","sroda","czwartek","piatek","sobota",
      "niedziela"],
     ["poniedziaÅ≥ek","wtorek","úroda","czwartek","piÅπtek",
      "sobota","niedziela"]];
  $$d{"day_abb"}=
    [["po.","wt.","sr.","cz.","pi.","so.","ni."],
     ["po.","wt.","úr.","cz.","pi.","so.","ni."]];
  $$d{"day_char"}=
    [["p","w","e","c","p","s","n"],
     ["p","w","ú.","c","p","s","n"]];

  $$d{"num_suff"}=
    [["1.","2.","3.","4.","5.","6.","7.","8.","9.","10.",
      "11.","12.","13.","14.","15.","16.","17.","18.","19.","20.",
      "21.","22.","23.","24.","25.","26.","27.","28.","29.","30.",
      "31."]];
  $$d{"num_word"}=
    [["pierwszego","drugiego","trzeczego","czwartego","piatego","szostego",
      "siodmego","osmego","dziewiatego","dziesiatego",
      "jedenastego","dwunastego","trzynastego","czternastego","pietnastego",
      "szestnastego","siedemnastego","osiemnastego","dziewietnastego",
      "dwudziestego",
      "dwudziestego pierwszego","dwudziestego drugiego",
      "dwudziestego trzeczego","dwudziestego czwartego",
      "dwudziestego piatego","dwudziestego szostego",
      "dwudziestego siodmego","dwudziestego osmego",
      "dwudziestego dziewiatego","trzydziestego","trzydziestego pierwszego"],
     ["pierwszego","drugiego","trzeczego","czwartego","piÅπtego",
      "szÅÛstego","siÅÛdmego","ÅÛsmego","dziewiÅπtego",
      "dziesiÅπtego","jedenastego","dwunastego","trzynastego",
      "czternastego","piÅÍtnastego","szestnastego","siedemnastego",
      "osiemnastego","dziewietnastego","dwudziestego",
      "dwudziestego pierwszego","dwudziestego drugiego",
      "dwudziestego trzeczego","dwudziestego czwartego",
      "dwudziestego piÅπtego","dwudziestego szÅÛstego",
      "dwudziestego siÅÛdmego","dwudziestego ÅÛsmego",
      "dwudziestego dziewiÅπtego","trzydziestego",
      "trzydziestego pierwszego"]];

  $$d{"now"}     =["dzisaj","teraz"];
  $$d{"last"}    =["ostatni","ostatna"];
  $$d{"each"}    =["kazdy","kaÅødy", "kazdym","kaÅødym"];
  $$d{"of"}      =["w","z"];
  $$d{"at"}      =["o","u"];
  $$d{"on"}      =["na"];
  $$d{"future"}  =["za"];
  $$d{"past"}    =["temu"];
  $$d{"next"}    =["nastepny","nastÅÍpny","nastepnym","nastÅÍpnym",
                   "przyszly","przyszÅ≥y","przyszlym",
                   "przyszÅ≥ym"];
  $$d{"prev"}    =["zeszly","zeszÅ≥y","zeszlym","zeszÅ≥ym"];
  $$d{"later"}   =["later"];

  $$d{"exact"}   =["doklandnie","dokÅ≥andnie"];
  $$d{"approx"}  =["w przyblizeniu","w przybliÅøeniu","mniej wiecej",
                   "mniej wiÅÍcej","okolo","okoÅ≥o"];
  $$d{"business"}=["sluzbowy","sÅ≥uÅøbowy","sluzbowym",
                   "sÅ≥uÅøbowym"];

  $$d{"times"}   =["poÅ≥udnie","12:00:00",
                   "pÅÛÅ≥noc","00:00:00",
                   "poludnie","12:00:00","polnoc","00:00:00"];
  $$d{"offset"}  =["wczoraj","-0:0:1:0:0:0","jutro","+0:0:1:0:0:0"];

  $$d{"years"}   =["rok","lat","lata","latach"];
  $$d{"months"}  =["m.","miesiac","miesiÅπc","miesiecy",
                   "miesiÅÍcy","miesiacu","miesiÅπcu"];
  $$d{"weeks"}   =["ty.","tydzien","tydzieÅÒ","tygodniu"];
  $$d{"days"}    =["d.","dzien","dzieÅÒ","dni"];
  $$d{"hours"}   =["g.","godzina","godziny","godzinie"];
  $$d{"minutes"} =["mn.","min.","minut","minuty"];
  $$d{"seconds"} =["s.","sekund","sekundy"];
  $$d{"replace"} =["m.","miesiac"];

  $$d{"sephm"}   =':';
  $$d{"sepms"}   =':';
  $$d{"sepss"}   ='[.:]';

  $$d{"am"}      = ["AM","A.M."];
  $$d{"pm"}      = ["PM","P.M."];
}

sub Date_Init_Spanish {
  print "DEBUG: Date_Init_Spanish\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;

  $$d{"month_name"}=
    [["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto",
      "Septiembre","Octubre","Noviembre","Diciembre"]];

  $$d{"month_abb"}=
    [["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct",
      "Nov","Dic"]];

  $$d{"day_name"}=
    [["Lunes","Martes","Miercoles","Jueves","Viernes","Sabado","Domingo"]];
  $$d{"day_abb"}=
    [["Lun","Mar","Mie","Jue","Vie","Sab","Dom"]];
  $$d{"day_char"}=
    [["L","Ma","Mi","J","V","S","D"]];

  $$d{"num_suff"}=
    [["1o","2o","3o","4o","5o","6o","7o","8o","9o","10o",
      "11o","12o","13o","14o","15o","16o","17o","18o","19o","20o",
      "21o","22o","23o","24o","25o","26o","27o","28o","29o","30o","31o"],
     ["1a","2a","3a","4a","5a","6a","7a","8a","9a","10a",
      "11a","12a","13a","14a","15a","16a","17a","18a","19a","20a",
      "21a","22a","23a","24a","25a","26a","27a","28a","29a","30a","31a"]];
  $$d{"num_word"}=
    [["Primero","Segundo","Tercero","Cuarto","Quinto","Sexto","Septimo",
      "Octavo","Noveno","Decimo","Decimo Primero","Decimo Segundo",
      "Decimo Tercero","Decimo Cuarto","Decimo Quinto","Decimo Sexto",
      "Decimo Septimo","Decimo Octavo","Decimo Noveno","Vigesimo",
      "Vigesimo Primero","Vigesimo Segundo","Vigesimo Tercero",
      "Vigesimo Cuarto","Vigesimo Quinto","Vigesimo Sexto",
      "Vigesimo Septimo","Vigesimo Octavo","Vigesimo Noveno","Trigesimo",
      "Trigesimo Primero"],
     ["Primera","Segunda","Tercera","Cuarta","Quinta","Sexta","Septima",
      "Octava","Novena","Decima","Decimo Primera","Decimo Segunda",
      "Decimo Tercera","Decimo Cuarta","Decimo Quinta","Decimo Sexta",
      "Decimo Septima","Decimo Octava","Decimo Novena","Vigesima",
      "Vigesimo Primera","Vigesimo Segunda","Vigesimo Tercera",
      "Vigesimo Cuarta","Vigesimo Quinta","Vigesimo Sexta",
      "Vigesimo Septima","Vigesimo Octava","Vigesimo Novena","Trigesima",
      "Trigesimo Primera"]];




  $$d{"now"}     =["Hoy","Ahora"];
  $$d{"last"}    =["ultimo"];
  $$d{"each"}    =["cada"];
  $$d{"of"}      =["en","de"];
  $$d{"at"}      =["a"];
  $$d{"on"}      =["el"];
  $$d{"future"}  =["en"];
  $$d{"past"}    =["hace"];
  $$d{"next"}    =["siguiente"];
  $$d{"prev"}    =["anterior"];
  $$d{"later"}   =["later"];

  $$d{"exact"}   =["exactamente"];
  $$d{"approx"}  =["aproximadamente"];
  $$d{"business"}=["laborales"];

  $$d{"offset"}  =["ayer","-0:0:0:1:0:0:0","manana","+0:0:0:1:0:0:0"];
  $$d{"times"}   =["mediodia","12:00:00","medianoche","00:00:00"];

  $$d{"years"}   =["a","ano","ano","anos","anos"];
  $$d{"months"}  =["m","mes","mes","meses"];
  $$d{"weeks"}   =["sem","semana","semana","semanas"];
  $$d{"days"}    =["d","dia","dias"];
  $$d{"hours"}   =["hr","hrs","hora","horas"];
  $$d{"minutes"} =["min","min","minuto","minutos"];
  $$d{"seconds"} =["s","seg","segundo","segundos"];
  $$d{"replace"} =["m","mes"];

  $$d{"sephm"}   =':';
  $$d{"sepms"}   =':';
  $$d{"sepss"}   ='[.:]';

  $$d{"am"}      = ["AM","A.M."];
  $$d{"pm"}      = ["PM","P.M."];
}

sub Date_Init_Portuguese {
  print "DEBUG: Date_Init_Portuguese\n"  if ($Curr{"Debug"} =~ /trace/);
  my($d)=@_;

  $$d{"month_name"}=
    [["Janeiro","Fevereiro","Marco","Abril","Maio","Junho",
      "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"],
     ["Janeiro","Fevereiro","MarÁo","Abril","Maio","Junho",
      "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"]];

  $$d{"month_abb"}=
    [["Jan","Fev","Mar","Abr","Mai","Jun",
      "Jul","Ago","Set","Out","Nov","Dez"]];

  $$d{"day_name"}=
    [["Segunda","Terca","Quarta","Quinta","Sexta","Sabado","Domingo"],
     ["Segunda","TerÁa","Quarta","Quinta","Sexta","S·bado","Domingo"]];
  $$d{"day_abb"}=
    [["Seg","Ter","Qua","Qui","Sex","Sab","Dom"],
     ["Seg","Ter","Qua","Qui","Sex","S·b","Dom"]];
  $$d{"day_char"}=
    [["Sg","T","Qa","Qi","Sx","Sb","D"]];

  $$d{"num_suff"}=
    [["1∫","2∫","3∫","4∫","5∫","6∫","7∫","8∫",
      "9∫","10∫","11∫","12∫","13∫","14∫","15∫",
      "16∫","17∫","18∫","19∫","20∫","21∫","22∫",
      "23∫","24∫","25∫","26∫","27∫","28∫","29∫",
      "30∫","31∫"]];
  $$d{"num_word"}=
    [["primeiro","segundo","terceiro","quarto","quinto","sexto","setimo",
      "oitavo","nono","decimo","decimo primeiro","decimo segundo",
      "decimo terceiro","decimo quarto","decimo quinto","decimo sexto",
      "decimo setimo","decimo oitavo","decimo nono","vigesimo",
      "vigesimo primeiro","vigesimo segundo","vigesimo terceiro",
      "vigesimo quarto","vigesimo quinto","vigesimo sexto","vigesimo setimo",
      "vigesimo oitavo","vigesimo nono","trigesimo","trigesimo primeiro"],
     ["primeiro","segundo","terceiro","quarto","quinto","sexto","sÈtimo",
      "oitavo","nono","dÈcimo","dÈcimo primeiro","dÈcimo segundo",
      "dÈcimo terceiro","dÈcimo quarto","dÈcimo quinto",
      "dÈcimo sexto","dÈcimo sÈtimo","dÈcimo oitavo",
      "dÈcimo nono","vigÈsimo","vigÈsimo primeiro",
      "vigÈsimo segundo","vigÈsimo terceiro","vigÈsimo quarto",
      "vigÈsimo quinto","vigÈsimo sexto","vigÈsimo sÈtimo",
      "vigÈsimo oitavo","vigÈsimo nono","trigÈsimo",
      "trigÈsimo primeiro"]];

  $$d{"now"}     =["agora","hoje"];
  $$d{"last"}    =["˙ltimo","ultimo"];
  $$d{"each"}    =["cada"];
  $$d{"of"}      =["da","do"];
  $$d{"at"}      =["as","‡s"];
  $$d{"on"}      =["na","no"];
  $$d{"future"}  =["em"];
  $$d{"past"}    =["a","‡"];
  $$d{"next"}    =["proxima","proximo","prÛxima","prÛximo"];
  $$d{"prev"}    =["ultima","ultimo","˙ltima","˙ltimo"];
  $$d{"later"}   =["passadas","passados"];

  $$d{"exact"}   =["exactamente"];
  $$d{"approx"}  =["aproximadamente"];
  $$d{"business"}=["util","uteis"];

  $$d{"offset"}  =["ontem","-0:0:0:1:0:0:0",
                   "amanha","+0:0:0:1:0:0:0","amanh„","+0:0:0:1:0:0:0"];
  $$d{"times"}   =["meio-dia","12:00:00","meia-noite","00:00:00"];

  $$d{"years"}   =["anos","ano","ans","an","a"];
  $$d{"months"}  =["meses","mÍs","mes","m"];
  $$d{"weeks"}   =["semanas","semana","sem","sems","s"];
  $$d{"days"}    =["dias","dia","d"];
  $$d{"hours"}   =["horas","hora","hr","hrs"];
  $$d{"minutes"} =["minutos","minuto","min","mn"];
  $$d{"seconds"} =["segundos","segundo","seg","sg"];
  $$d{"replace"} =["m","mes","s","sems"];

  $$d{"sephm"}   =':';
  $$d{"sepms"}   =':';
  $$d{"sepss"}   ='[,]';

  $$d{"am"}      = ["AM","A.M."];
  $$d{"pm"}      = ["PM","P.M."];
}

########################################################################
# FROM MY PERSONAL LIBRARIES
########################################################################

no integer;

# &ModuloAddition($N,$add,\$val,\$rem);
#   This calculates $val=$val+$add and forces $val to be in a certain range.
#   This is useful for adding numbers for which only a certain range is
#   allowed (for example, minutes can be between 0 and 59 or months can be
#   between 1 and 12).  The absolute value of $N determines the range and
#   the sign of $N determines whether the range is 0 to N-1 (if N>0) or
#   1 to N (N<0).  The remainder (as modulo N) is added to $rem.
#   Example:
#     To add 2 hours together (with the excess returned in days) use:
#       &ModuloAddition(60,$s1,\$s,\$day);
sub ModuloAddition {
  my($N,$add,$val,$rem)=@_;
  return  if ($N==0);
  $$val+=$add;
  if ($N<0) {
    # 1 to N
    $N = -$N;
    if ($$val>$N) {
      $$rem+= int(($$val-1)/$N);
      $$val = ($$val-1)%$N +1;
    } elsif ($$val<1) {
      $$rem-= int(-$$val/$N)+1;
      $$val = $N-(-$$val % $N);
    }

  } else {
    # 0 to N-1
    if ($$val>($N-1)) {
      $$rem+= int($$val/$N);
      $$val = $$val%$N;
    } elsif ($$val<0) {
      $$rem-= int(-($$val+1)/$N)+1;
      $$val = ($N-1)-(-($$val+1)%$N);
    }
  }
}

# $Flag=&IsInt($String [,$low, $high]);
#    Returns 1 if $String is a valid integer, 0 otherwise.  If $low is
#    entered, $String must be >= $low.  If $high is entered, $String must
#    be <= $high.  It is valid to check only one of the bounds.
#
#    undef (rather than 0) is returned if there is an error in either $low
#    or $high or if $N is completely missing.
sub IsInt {
  my($N,$low,$high)=@_;
  return undef    if (! defined $N);
  return 0        if ($N !~ /^\s*([+-]?)\s*(\d+)\s*$/);
  $N="$1$2";
  if (defined $low  and  length($low)>0) {
    return undef  if (! &IsInt($low));
    return 0      if ($N<$low);
  }
  if (defined $high  and  length($high)>0) {
    return undef  if (! &IsInt($high));
    return 0  if ($N>$high);
  }
  return 1;
}
#&&

# $Pos=&SinLindex(\@List,$Str [,$offset [,$CaseInsensitive]]);
#    Searches for an exact string in a list.
#
#    This is similar to RinLindex except that it searches for elements
#    which are exactly equal to $Str (possibly case insensitive).
sub SinLindex {
  my($listref,$Str,$offset,$Insensitive)=@_;
  my($i,$len,$tmp)=();
  $len=$#$listref;
  return -2  if ($len<0 or ! $Str);
  return -1  if (&Index_First(\$offset,$len));
  $Str=uc($Str)  if ($Insensitive);
  for ($i=$offset; $i<=$len; $i++) {
    $tmp=$$listref[$i];
    $tmp=uc($tmp)  if ($Insensitive);
    return $i  if ($tmp eq $Str);
  }
  return -1;
}

sub Index_First {
  my($offsetref,$max)=@_;
  $$offsetref=0  if (! $$offsetref);
  if ($$offsetref < 0) {
    $$offsetref += $max + 1;
    $$offsetref=0  if ($$offsetref < 0);
  }
  return -1 if ($$offsetref > $max);
  return 0;
}

# $File=&CleanFile($file);
#   This cleans up a path to remove the following things:
#     double slash       /a//b  -> /a/b
#     trailing dot       /a/.   -> /a
#     leading dot        ./a    -> a
#     trailing slash     a/     -> a
sub CleanFile {
  my($file)=@_;
  $file =~ s/\s*$//;
  $file =~ s/^\s*//;
  $file =~ s|//+|/|g;  # multiple slash
  $file =~ s|/\.$|/|;  # trailing /. (leaves trailing slash)
  $file =~ s|^\./||    # leading ./
    if ($file ne "./");
  $file =~ s|/$||      # trailing slash
    if ($file ne "/");
  return $file;
}

# $File=&ExpandTilde($file);
#   This checks to see if a "~" appears as the first character in a path.
#   If it does, the "~" expansion is interpreted (if possible) and the full
#   path is returned.  If a "~" expansion is used but cannot be
#   interpreted, an empty string is returned.
#
#   This is Windows/Mac friendly.
#   This is efficient.
sub ExpandTilde {
  my($file)=shift;
  my($user,$home)=();
  # ~aaa/bbb=      ~  aaa      /bbb
  if ($file =~ s|^~([^/]*)||) {
    $user=$1;
    # Single user operating systems (Mac, MSWindows) don't have the getpwnam
    # and getpwuid routines defined.  Try to catch various different ways
    # of knowing we are on one of these systems:
    return ""  if ($OS eq "Windows"  or
                   $OS eq "Mac"  or
                   $OS eq "MPE");
    $user=""  if (! defined $user);

    if ($user) {
      $home= (getpwnam($user))[7];
    } else {
      $home= (getpwuid($<))[7];
    }
    return ""  if (! $home);
    $file="$home/$file";
  }
  $file;
}

# $File=&FullFilePath($file);
#   Returns the full path to $file (expanding "~" if necessary and turning
#   relative paths into full paths).  Returns an empty string if a "~"
#   expansion cannot be interpreted.  The path does not need to exist.
#   CleanFile is called.
#
#   I'd like to get rid of the call to cwd (which does `pwd`).
sub FullFilePath {
  my($file)=shift;
  $file=&ExpandTilde($file);
  return ""  if (! $file);
  my($cwd) = cwd;
  # $cwd = VMS::Filespec::unixpath($cwd) if (defined $^O and $^O eq 'VMS');
  $cwd = VMS::Filespec::unixpath($cwd) if ($OS eq "VMS");
  $file="$cwd/$file"  if ($file !~ m|^/|);   # $file = "a/b/c"
  return &CleanFile($file);
}

# $Flag=&CheckFilePath($file [,$mode]);
#   Checks to see if $file exists, to see what type it is, and whether
#   the script can access it.  If it exists and has the correct mode, 1
#   is returned.
#
#   $mode is a string which may contain any of the valid file test operator
#   characters except t, M, A, C.  The appropriate test is run for each
#   character.  For example, if $mode is "re" the -r and -e tests are both
#   run.
#
#   An empty string is returned if the file doesn't exist.  A 0 is returned
#   if the file exists but any test fails.
#
#   All characters in $mode which do not correspond to valid tests are
#   ignored.
sub CheckFilePath {
  my($file,$mode)=@_;
  my($test)=();
  $file=&FullFilePath($file);
  $mode = ""  if (! defined $mode);

  # Run tests
  return 0  if (! defined $file or ! $file);
  return 0  if ((                  ! -e $file) or
                ($mode =~ /r/  &&  ! -r $file) or
                ($mode =~ /w/  &&  ! -w $file) or
                ($mode =~ /x/  &&  ! -x $file) or
                ($mode =~ /R/  &&  ! -R $file) or
                ($mode =~ /W/  &&  ! -W $file) or
                ($mode =~ /X/  &&  ! -X $file) or
                ($mode =~ /o/  &&  ! -o $file) or
                ($mode =~ /O/  &&  ! -O $file) or
                ($mode =~ /z/  &&  ! -z $file) or
                ($mode =~ /s/  &&  ! -s $file) or
                ($mode =~ /f/  &&  ! -f $file) or
                ($mode =~ /d/  &&  ! -d $file) or
                ($mode =~ /l/  &&  ! -l $file) or
                ($mode =~ /s/  &&  ! -s $file) or
                ($mode =~ /p/  &&  ! -p $file) or
                ($mode =~ /b/  &&  ! -b $file) or
                ($mode =~ /c/  &&  ! -c $file) or
                ($mode =~ /u/  &&  ! -u $file) or
                ($mode =~ /g/  &&  ! -g $file) or
                ($mode =~ /k/  &&  ! -k $file) or
                ($mode =~ /T/  &&  ! -T $file) or
                ($mode =~ /B/  &&  ! -B $file));
  return 1;
}
#&&

# $Path=&FixPath($path [,$full] [,$mode] [,$error]);
#   Makes sure that every directory in $path (a colon separated list of
#   directories) appears as a full path or relative path.  All "~"
#   expansions are removed.  All trailing slashes are removed also.  If
#   $full is non-nil, relative paths are expanded to full paths as well.
#
#   If $mode is given, it may be either "e", "r", or "w".  In this case,
#   additional checking is done to each directory.  If $mode is "e", it
#   need ony exist to pass the check.  If $mode is "r", it must have have
#   read and execute permission.  If $mode is "w", it must have read,
#   write, and execute permission.
#
#   The value of $error determines what happens if the directory does not
#   pass the test.  If it is non-nil, if any directory does not pass the
#   test, the subroutine returns the empty string.  Otherwise, it is simply
#   removed from $path.
#
#   The corrected path is returned.
sub FixPath {
  my($path,$full,$mode,$err)=@_;
  local($_)="";
  my(@dir)=split(/$Cnf{"PathSep"}/,$path);
  $full=0  if (! defined $full);
  $mode="" if (! defined $mode);
  $err=0   if (! defined $err);
  $path="";
  if ($mode eq "e") {
    $mode="de";
  } elsif ($mode eq "r") {
    $mode="derx";
  } elsif ($mode eq "w") {
    $mode="derwx";
  }

  foreach (@dir) {

    # Expand path
    if ($full) {
      $_=&FullFilePath($_);
    } else {
      $_=&ExpandTilde($_);
    }
    if (! $_) {
      return ""  if ($err);
      next;
    }

    # Check mode
    if (! $mode  or  &CheckFilePath($_,$mode)) {
      $path .= $Cnf{"PathSep"} . $_;
    } else {
      return "" if ($err);
    }
  }
  $path =~ s/^$Cnf{"PathSep"}//;
  return $path;
}
#&&

# $File=&SearchPath($file,$path [,$mode] [,@suffixes]);
#   Searches through directories in $path for a file named $file.  The
#   full path is returned if one is found, or an empty string otherwise.
#   The file may exist with one of the @suffixes.  The mode is checked
#   similar to &CheckFilePath.
#
#   The first full path that matches the name and mode is returned.  If none
#   is found, an empty string is returned.
sub SearchPath {
  my($file,$path,$mode,@suff)=@_;
  my($f,$s,$d,@dir,$fs)=();
  $path=&FixPath($path,1,"r");
  @dir=split(/$Cnf{"PathSep"}/,$path);
  foreach $d (@dir) {
    $f="$d/$file";
    $f=~ s|//|/|g;
    return $f if (&CheckFilePath($f,$mode));
    foreach $s (@suff) {
      $fs="$f.$s";
      return $fs if (&CheckFilePath($fs,$mode));
    }
  }
  return "";
}

# @list=&ReturnList($str);
#    This takes a string which should be a comma separated list of integers
#    or ranges (5-7).  It returns a sorted list of all integers referred to
#    by the string, or () if there is an invalid element.
#
#    Negative integers are also handled.  "-2--1" is equivalent to "-2,-1".
sub ReturnList {
  my($str)=@_;
  my(@ret,@str,$from,$to,$tmp)=();
  @str=split(/,/,$str);
  foreach $str (@str) {
    if ($str =~ /^[-+]?\d+$/) {
      push(@ret,$str);
    } elsif ($str =~ /^([-+]?\d+)-([-+]?\d+)$/) {
      ($from,$to)=($1,$2);
      if ($from>$to) {
        $tmp=$from;
        $from=$to;
        $to=$tmp;
      }
      push(@ret,$from..$to);
    } else {
      return ();
    }
  }
  @ret;
}

1;
