#!/usr/bin/perl

use strict;
use NOCpulse::RPM;

my $rpm=new NOCpulse::RPM;

my ($results,$retval,$cmd)=$rpm->exec('--help');
print "results are\n$results\n\n";
print "return value is\n$retval\n\n";
print "command executed was\n$cmd\n\n";

