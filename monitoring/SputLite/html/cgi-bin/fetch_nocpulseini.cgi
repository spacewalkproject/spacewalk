#!/usr/bin/perl

use strict;
use CGI;
use NOCpulse::NOCpulseini;
use NOCpulse::NPRecords;
use lib qw(/etc/rc.d/np.d);
use PhysCluster;

my $q = CGI->new;
my $key = $q->param('scoutsharedkey');
my $sat_record = SatNodeRecord->LoadOneFromSqlWithBind("SELECT sat_cluster_id FROM rhn_sat_node WHERE scout_shared_key = ?", [$key]);
if (not $sat_record) {
	print $q->header(-status => "403 Forbidden"), 'Your are not allowed to access this file.';
}

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

