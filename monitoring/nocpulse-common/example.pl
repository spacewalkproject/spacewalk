#!/usr/bin/perl

use NOCpulse::Config;

my $cfg = new NOCpulse::Config;


# Example:  Oracle parameters for the config database
my $dbd     = $cfg->get('cf_db', 'dbd');
my $dbname  = $cfg->get('cf_db', 'name');
my $dbuname = $cfg->get('cf_db', 'username');
my $dbpass  = $cfg->get('cf_db', 'password');

print "DBI->connect('DBI:$dbd:$dbname', $dbuname, $dbpass)\n";


# Example:  TelAlert directories
$ENV{'TELALERTBIN'} = $cfg->get('telalert', 'bin');
$ENV{'TELALERTCFG'} = $cfg->get('telalert', 'cfg');
$ENV{'TELALERTDIR'} = $cfg->get('telalert', 'dir');
$ENV{'TELALERTTMP'} = $cfg->get('telalert', 'tmp');

system("$ENV{TELALERTBIN}/telalert -status");
