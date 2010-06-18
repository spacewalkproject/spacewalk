#!/usr/bin/perl

use strict;
use warnings;

use lib '/var/www/lib';

use English;

use Data::Dumper;
use Sys::Hostname;
use Getopt::Long;

use PXT::Utils;
use PXT::Config;
use RHN::SatInstall;
use RHN::SatCluster;
use RHN::DB;
use RHN::DataSource::Simple;
use Spacewalk::Setup;

use RHN::Utils;

my %opts = ();
my @valid_opts = (
		  "enable-scout",
		  "admin-email:s",
		  "mail-mx:s",
		  "mail-domain:s",
		  "hostname:s",
		  "help",
		 );

my $usage = "usage: $0 [ --enable-scout ] [ --admin-email=<email_address> ] [ --mail-mx=<mail_mx> ]"
  . " [ --mail-domain=<mail_domain> ] [ --hostname=<override_hostname> ]"
  . " [ --help ]\n";

GetOptions(\%opts, @valid_opts);

if ($opts{help}) {
  die $usage;
}

my $db_connect = RHN::SatInstall->test_db_connection();

die "Could not connect to the database"
  unless $db_connect;

my $scout_shared_key = find_scout_key();
my $hostname = Sys::Hostname::hostname;

unless ($scout_shared_key) {
  # create the key if it doesn't already exist
  my $ip_addr = RHN::Utils::find_ip_address($hostname);
  my $org_id = RHN::SatInstall->get_satellite_org_id();
  my $sc = new RHN::SatCluster(customer_id => $org_id,
			       description => 'RHN Monitoring Satellite',
			       last_update_user => 'installer',
			       vip => $ip_addr,
			      );

  eval {
    $sc->create_new();
  };
  if ($@) {
    my $E = $@;

    warn "error creating scout shared key.  Error: $E";
  }
  else {
    $scout_shared_key = RHN::SatCluster->fetch_key($sc->recid);
  }
}


my %config_opts;

$config_opts{webDOTis_monitoring_backend} = '1';
$config_opts{webDOTis_monitoring_scout} = $opts{"enable-scout"} ? '1' : '0';

$config_opts{monitoringDOTdbd} = 'Oracle';
$config_opts{monitoringDOTorahome} = $ENV{ORACLE_HOME} || '/opt/oracle';
$config_opts{monitoringDOTdbname} = PXT::Config->get('db_name');
$config_opts{monitoringDOTusername} = PXT::Config->get('db_user');
$config_opts{monitoringDOTpassword} = PXT::Config->get('db_password');

$config_opts{monitoringDOTsmonDOTaddr} = '127.0.0.1';
$config_opts{monitoringDOTsmonDOTfqdn} = 'localhost';
$config_opts{monitoringDOTsmonDOTtestaddr} = '127.0.0.1';
$config_opts{monitoringDOTsmonDOTtestfqdn} = 'localhost';

$config_opts{monitoringDOTscout_shared_key} = $scout_shared_key;

RHN::SatInstall->write_config(\%config_opts,
			      '/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');

print "Deploying config\n";

Spacewalk::Setup::satcon_deploy();

my %mon_config =
  (
   RHN_ADMIN_EMAIL => $opts{'admin-email'} || PXT::Config->get('traceback_mail'),
   MAIL_MX => $opts{'mail-mx'} || 'localhost',
   MDOM => $opts{'mail-domain'} || $opts{'hostname'} || $hostname,
   RHN_DB_NAME => $config_opts{monitoringDOTdbname},
   RHN_DB_USERNAME => $config_opts{monitoringDOTusername},
   RHN_DB_PASSWD => $config_opts{monitoringDOTpassword},
   RHN_DB_TABLE_OWNER => $config_opts{monitoringDOTusername},
   RHN_SAT_HOSTNAME => $opts{'hostname'} || $hostname,
   XPROTO => 'https',
   RHN_SAT_WEB_PORT => 443
);

RHN::SatInstall->update_monitoring_config(\%mon_config);

print "Restarting satellite services\n";
system("/usr/sbin/rhn-satellite", "restart");

exit 0;

sub split_dsn {
  my $dsn = shift;

  return split(/[\/@]/, $dsn);
}

sub find_scout_key {
  my $ds = new RHN::DataSource::Simple(-querybase => "scout_queries",
                                       -mode => 'scouts_for_org');
  my $data = $ds->execute_query(-org_id => 1);

  my ($sat_scout) = grep { not $_->{SERVER_ID} } @{$data};

  return unless $sat_scout;

  return $sat_scout->{SCOUT_SHARED_KEY};
}

1;
