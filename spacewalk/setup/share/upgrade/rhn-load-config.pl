#!/usr/bin/perl

use strict;
use warnings;

use lib '/var/www/lib';

use English;

use Data::Dumper;
use Getopt::Long;
use Sys::Hostname;

use PXT::Utils;

use RHN::SatInstall;
use RHN::SatCluster;
use RHN::DB;
use RHN::DataSource::Simple;
use PXT::Config;
use PXT::Request;
use Spacewalk::Setup;

my %opts = ();
my @valid_opts = (
		  "force",
		  "disable-solaris",
		  "help",
		 );

my $usage = "usage: $0 [ --force ]"
  . " [ --disable-solaris ]"
  . " [ --help ]\n";

GetOptions(\%opts, @valid_opts);

if ($opts{help}) {
  die $usage;
}

my ($already_monitoring, $already_monitoring_scout, $already_osad);

my $mon_backend = PXT::Config->get('is_monitoring_backend') || '';
if ($mon_backend and $mon_backend !~ /@@/) {
  $already_monitoring = 1;
}

my $mon_scout = PXT::Config->get('is_monitoring_scout') || '';
if ($mon_scout and $mon_scout !~ /@@/) {
  $already_monitoring_scout = 1;
}

my $jabber_server = PXT::Config->get('osa-dispatcher', 'jabber_server') || '';
if ($jabber_server and $jabber_server !~ /@@/) {
  $already_osad = 1;
}

print "Generating RHN Satellite configuration dictionary\n";

Spacewalk::Setup::generate_satcon_dict();

print "Examining current configuration\n";

my %config_opts;

my @valid_keys = qw/db_name db_user db_password encrypted_passwords
  kickstart_mount_point mount_point serverDOTsatelliteDOTca_chain
  serverDOTsatelliteDOThttp_proxy
  serverDOTsatelliteDOThttp_proxy_username
  serverDOTsatelliteDOTrhn_parent session_secret_1 session_secret_2
  session_secret_3 session_secret_4 session_swap_secret_1
  session_swap_secret_2 session_swap_secret_3 session_swap_secret_4
  traceback_mail webDOTis_monitoring_backend webDOTis_monitoring_scout
  webDOTssl_available serverDOTsatelliteDOThttp_proxy_password/;

foreach my $key (@valid_keys) {
  $config_opts{$key} = check_current_config($key);
}

$config_opts{server_secret_key} = RHN::SatInstall->generate_secret;

load_jabber_configs(\%config_opts);

load_hibernate_configs(\%config_opts);

if ($opts{disable_solaris}) {
  $config_opts{webDOTenable_solaris_support} = 0;
}
else {
  $config_opts{webDOTenable_solaris_support} = 1;
}

if ($already_monitoring)  {
  $config_opts{monitoringDOTdbd} = 'Oracle';
  $config_opts{monitoringDOTorahome} = $ENV{ORACLE_HOME} || '/opt/oracle';
  $config_opts{monitoringDOTdbname} = $config_opts{'db_name'};
  $config_opts{monitoringDOTusername} = $config_opts{'db_user'};
  $config_opts{monitoringDOTpassword} = $config_opts{'db_password'};

  if ($already_monitoring_scout) {
    my $scout_shared_key = find_scout_key();

    $config_opts{monitoringDOTsmonDOTaddr} = '127.0.0.1';
    $config_opts{monitoringDOTsmonDOTfqdn} = 'localhost';
    $config_opts{monitoringDOTsmonDOTtestaddr} = '127.0.0.1';
    $config_opts{monitoringDOTsmonDOTtestfqdn} = 'localhost';
    $config_opts{monitoringDOTscout_shared_key} = $scout_shared_key;

    # if the satellite is already a monitoring scout, we need to update some ip address fields
    update_ip_addresses();
  }
}

my %nls_database_paramaters = RHN::SatInstall->get_nls_database_parameters();
$config_opts{serverDOTnls_lang} = 'english.' . $nls_database_paramaters{NLS_CHARACTERSET};
$config_opts{cobblerDOThost} = Sys::Hostname::hostname;
print "Writing configuration\n";
RHN::SatInstall->write_config(\%config_opts,
			      '/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');


Spacewalk::Setup::satcon_deploy();

print "Done\n";

exit 0;

sub update_ip_addresses {
  my $hostname = Sys::Hostname::hostname;
  my $ip_addr = RHN::Utils::find_ip_address($hostname);

  my $dbh = RHN::DB->connect();
  my $sth;

  # update recid 1 of the rhn_sat_cluster table,
  # which is always the cluster record for the scout on the satellite
  $sth = $dbh->prepare(<<EOQ);
UPDATE rhn_Sat_Cluster
   SET vip = :ip
 WHERE recid = 1
EOQ
  $sth->execute_h(ip => $ip_addr);

  # update recid 2 of the rhn_sat_node table,
  # which is always the node record for the scout on the satellite
  $sth = $dbh->prepare(<<EOQ);
UPDATE rhn_Sat_Node
   SET ip = :ip
 WHERE recid = 2
EOQ
  $sth->execute_h(ip => $ip_addr);

  $dbh->commit;
}

sub check_current_config {
  my $key = shift;

  $key =~ s/DOT/./g;

  my ($domain, $var);
  if ($key =~ /^(.*)\.(.*)$/) {
    $domain = $1;
    $var = $2;
  }
  else {
    $domain = 'web';
    $var = $key;
  }

  my $value = PXT::Config->get($domain, $var);
  if ($value =~ /^@@/) {
    return;
  }

  return $value;
}

#We have to do a mapping of the fake options to real options
sub load_jabber_configs {
  my $config_opts = shift;
  my %jabberOpts = (
           "jabberDOThostname" => "server.jabber_server",
           "osadispatcherDOTosa_ssl_cert" => "osa-dispatcher.osa_ssl_cert",
           "jabberDOTusername" => "osa-dispatcher.jabber_username",
           "jabberDOTpassword" => "osa-dispatcher.jabber_password"
	);
  while ( my ($key, $value) = each(%jabberOpts) ) {
	$config_opts->{$key} =  PXT::Config->get(split('\.', $value));
  }

}

sub find_scout_key {
  my $ds = new RHN::DataSource::Simple(-querybase => "scout_queries",
                                       -mode => 'scouts_for_org');
  my $data = $ds->execute_query(-org_id => 1);

  my ($sat_scout) = grep { not $_->{SERVER_ID} } @{$data};

  die "No satellite scout found!" unless $sat_scout;

  return $sat_scout->{SCOUT_SHARED_KEY};
}

sub load_hibernate_configs {
  my $config_opts = shift;

  open(TNSNAMES, '/etc/tnsnames.ora') or die "Could not open tnsnames.ora";

  my @lines = <TNSNAMES>;

  close(TNSNAMES);

  my $tnsnames = join('', @lines);

  $tnsnames =~ /^\s*(\S+).*HOST = ([^)\s]+).*PORT = (\d+)/s;

  my $sid = $1;
  my $host = $2;
  my $port = $3;

  $config_opts->{db_host} = $host;
  $config_opts->{db_port} = $port;
  $config_opts->{db_sid} = $sid;

  return;
}

sub split_dsn {
		  my $dsn = shift;

		    return split(/[\/@]/, $dsn);
}
