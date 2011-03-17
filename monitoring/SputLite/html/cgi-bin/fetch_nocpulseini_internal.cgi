#!/usr/bin/perl

use strict;
use NOCpulse::NOCpulseini;
use lib qw(/etc/rc.d/np.d);
use PhysCluster;

$NOCpulse::Object::config = NOCpulse::Config->new('/etc/rc.d/np.d/SysV.ini');

my $ini = NOCpulse::NOCpulseini->new();

$ini->connect();

$ini->fetch_nocpulseini('INTERNAL');

print "Content-type: text\n\n";
print $ini->dump();

