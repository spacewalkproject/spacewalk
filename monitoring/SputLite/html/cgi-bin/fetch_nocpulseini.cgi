#!/usr/bin/perl

use strict;
use CGI;
use NOCpulse::NOCpulseini;
use NOCpulse::NPRecords;
use NOCpulse::Config ();
use lib qw(/etc/rc.d/np.d);
use PhysCluster;

my $q = CGI->new;

$NOCpulse::Object::config = NOCpulse::Config->new('/etc/rc.d/np.d/SysV.ini');

my $ini = NOCpulse::NOCpulseini->new();

$ini->connect();

$ini->fetch_nocpulseini('EXTERNAL');

print $q->header("text/plain"),
	$ini->dump();

