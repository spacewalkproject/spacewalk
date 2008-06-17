#!/usr/bin/perl

use strict;
use NOCpulse::CVS;

my $rpm=new NOCpulse::CVS;

my ($results,$retval,$cmd)=$rpm->exec('--help-options');
print "results are\n$results\n\n";
print "return value is\n$retval\n\n";
print "command executed was\n$cmd\n\n";

