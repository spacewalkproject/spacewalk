#!/usr/bin/perl
use strict;
use Test qw(plan);
use TestSwitches;

#
# Driver for plugin framework tests. Output of a successful run has
# the single line "1..1".
#
BEGIN { Test::plan tests => 1 }

# Only show problems from tests, not successes.
sub filter {
   return if my $pid = open(STDOUT, "|-");
   die "Can't fork: $!" unless defined $pid;
   $| = 1;
   while (<STDIN>) {
      print if $_ !~ /^ok [0-9]*/;
   }
   exit;
}

filter();

TestSwitches->run;

exit;
