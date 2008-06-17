#!/usr/bin/perl
## This program is written as a Remote Program with Data check.  It counts
## number of instance of a given string in a log file, averaging per minute
## over a specified time period.

## Please see the following url for details on how to write your own check.
## https://command.nocpulse.com/help/userguides/user_guide_v2/Output/InfrastructureManagement.html#475254.

use strict;
use Getopt::Long;
use Date::Parse;
  
# Command Center remote program with data check required exit values.
  my $OK_EXIT = 0;
  my $WARNING_EXIT  = 1;
  my $CRITICAL_EXIT = 2;
  my $UNKNOWN_EXIT  = 3;
  my $exit_value=$OK_EXIT;
  
# Program options from the command line
  my $debug = '';    # default value for debug is off
  my $expr;          # regular expression of which to count occurences
  my $mins  = 15;    # how many minutes worth of log file to process
  my $lines = 10000; # how many lines of log file to tail to find
                     # appropriate amounts of data to process
  my $warn;          
  my $crit;
  my $help;
  
# Get the command line options
  GetOptions ('help'           => \$help,
              'debug|verbose'  => \$debug, 
              'expr|regexp=s'  => \$expr,
              'mins|minutes=i' => \$mins,
              'lines=i'        => \$lines,
              'warning=i'      => \$warn,
              'critical=i'     => \$crit
             );

  my ($filename)=@ARGV;

# Check to make sure the user provided enough of the options required
# to run the program.  If not print out the help section.
  unless (!$help && $expr && $filename && $warn && $crit ) {
    &help();
    exit($UNKNOWN_EXIT)
  }
  
# Process the specified log file, counting the number of occurences of
# the requested regular expression for the requested time frame in minutes

  my $count;
  open(LOG,"tail -$lines $filename |");
  my $now=time();
  while (<LOG>) {
    next unless /$expr/;
    /^(....-..-..\s..:..:..)/;
    my $datestr=$1;
    next unless $datestr;
    my $time=str2time($datestr);
    print "$time $now ", $now-$time,"\n" if $debug;
    if ($time >= ($now - $mins * 60)) {
      $count++;
    }
  }
  close(LOG);

# Compute the average per minute
  my $avg=$count / $mins;
  print "$avg\n" if $debug;  

# Print out the data in xml format required by a Command Center Remote Program
# with Data

  print "<perldata>\n<hash>\n";
  print '<item key="data">';
  print $avg;
  print "</item>\n</hash>\n</perldata>";

# Check for threshold violations and set the appropriate program exit status

  if ($avg >= $crit) {
    $exit_value=$CRITICAL_EXIT;
  } elsif ($avg >= $warn) {
    $exit_value=$WARNING_EXIT;
  }
  exit $exit_value;


sub help {
  print "$0 [--help]  | ( [--debug] --expr=\"regexp\" [--lines=n] [--mins=n] --warn=n --crit=n \"path/filename\" ) \n";
  print "-h, --help:                 display this help message\n";
  print "-d, --debug, -v, --verbose: turn on debug messages\n";
  print "-e, --expr, -r, --regexp:   regular expression to count occurences of\n";
  print "-l, --lines:                number of lines to tail from the log file to search\n";
  print "-m, --minutes:              number of minutes of the end of the log file to parse\n";
  print "-w, --warn, --warning:      number of occurences/minute as to cause a Command Center warning state change\n";
  print "-c, --crit, --critical:     number of occurences/minute as to cause a Command Center critical state change\n";
  print "path/filename:              the full path and filename of the log file to parse\n";
}
