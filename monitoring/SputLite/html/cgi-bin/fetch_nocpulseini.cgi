#!/usr/bin/perl

use strict;
use CGI;
use NOCpulse::NOCpulseini;
use NOCpulse::NPRecords;
use lib qw(/etc/rc.d/np.d);
use PhysCluster;

my $q = CGI->new;

$NOCpulse::Object::config = NOCpulse::Config->new('/etc/rc.d/np.d/SysV.ini');
my $cluster = PhysCluster->newInitialized();
my $localConfig = $cluster->get_LocalConfig;
my $config = (values(%$localConfig))[0];
my $dbd = $config->get_dbd;
my $dbname = $config->get_dbname;
my $orahome = $config->get_orahome;
my $username = $config->get_username;
my $password = $config->get_password;

my $ini = NOCpulse::NOCpulseini->new();

$ini->connect($dbd,$dbname,$username,$password,$orahome);

$ini->fetch_nocpulseini('EXTERNAL');

print $q->header("text/plain"),
	$ini->dump();

