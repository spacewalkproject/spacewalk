#!/usr/bin/perl

use strict;
use warnings;

use lib '/var/www/lib';

use Data::Dumper;
use Sys::Hostname;

use Getopt::Long;

use PXT::Utils;

use RHN::SatInstall;
use RHN::SatCluster;

use RHN::DB;

use English;

my %opts = (
	    username => '',
	    password => '',
	    server => '',
	    http_proxy => '',
	    http_proxy_username => '',
	    http_proxy_password => '',
	    email => '',
	    db => '',
	    db_server => '',
	    rhn_cert => '',
	    ssl_password => '',
	    ssl_country_code => 'US',
	    ssl_province_name => 'North Carolina',
	    ssl_locality_name => 'Raleigh',
	    ssl_org_name => 'Red Hat',
	    ssl_org_unit => '',
	    ssl_common_name => '',
	    mount_point => '/var/satellite',
	    ca_cert => '/usr/share/rhn/RHNS-CA-CERT',
	    mail_mx => '',
	    mdom => '',
	    mac_address => '',
	    ignore_db_version => 0,
	    disconnected_install => 0,
	    empty_db => 0,
	    monitoring_backend => 0,
	    monitoring_scout => 0,
	    help => 0,
	    );

my $usage = "usage: $0 --file=<source_file> --version=<version> --top=<cvs_top>"
  . "[ --help ]\n";

GetOptions(\%opts,
	   "username:s",
           "password:s",
	   "server:s",
	   "http-proxy:s",
	   "http-proxy-username:s",
	   "http-proxy-password:s",
	   "email=s",
	   "db:s",
	   "db-server:s",
	   "rhn-cert=s",
	   "ssl-password=s",
	   "ssl-country-code=s",
	   "ssl-province-name=s",
	   "ssl-locality-name=s",
	   "ssl-org-name=s",
	   "ssl-org-unit=s",
	   "ssl-common-name:s",
	   "mount-point:s",
	   "ca-cert:s",
	   "mail-mx:s",
	   "mdom:s",
	   "mac-address:s",
	   "ignore-db-version",
	   "disconnected-install",
	   "empty-db",
	   "monitoring-backend",
	   "monitoring-scout",
	   "help",
	   "cli"
	  );

if ($opts{help}) {
  die $usage;
}

unless ($opts{disconnected_install}) {
  die "The --username option is required for connected installs"
    unless $opts{username};
  die "The --password option is required for connected installs"
    unless $opts{password};
}

die "Could not read rhn cert: " . $opts{"rhn-cert"}
  unless (-r $opts{"rhn-cert"});

if (my $invalid_char = RHN::SatInstall->check_valid_ssl_cert_password($opts{"ssl-password"})) {
  die "Invalid character '$invalid_char' in ssl cert password.";
}

# Write this early.
RHN::SatInstall->write_config( {'traceback_mail' => $opts{email}} );

PXT::Config->set(debug_disable_database => 0);
RHN::SatInstall->write_config( {debug_disable_database => 0} );

my $dsn;
my ($db_user, $db_pass, $db_sid) = qw/rhnsat rhnsat rhnsat/;
my $db_address = { protocol => 'TCP', host => 'localhost', port => 1521 };

if (RHN::SatInstall->is_embedded_db) {
  die "Do not specify --db for embedded db"
    if $opts{db};

  die "Do not specify --db-server for embedded db"
    if $opts{"db-server"};

  $db_address->{protocol} = 'TCP';

  $dsn = make_dsn($db_user, $db_pass, $db_sid);
}
else {
  if ($opts{db} =~ /^(.*)\/(.*)@(.*)$/) {
    $db_user = $1;
    $db_pass = $2;
    $db_sid = $3;
  }
  else {
    die "Could not parse dsn: '$opts{db}'";
  }

  die "No server specified for db"
    unless $opts{"db-server"};

  $dsn = $opts{db};
  $db_address->{host} = $opts{"db-server"};
}

RHN::SatInstall->write_tnsnames($db_sid => [ ($db_address) ]);
set_default_db($dsn);
my $db_connect = RHN::SatInstall->test_db_connection();

die "Could not connect to $dsn"
  unless $db_connect;

RHN::SatInstall->check_db_version();
RHN::SatInstall->check_db_tablespace_settings($db_user);
RHN::SatInstall->check_db_charsets();

my $db_schema = RHN::SatInstall->test_db_schema();

# Do not fork b/c we need to wait until it db population is complete.
my %db_opts = (-nofork => 1);

if ($db_schema and $opts{"empty-db"}) {
  $db_opts{-clear_db} = 1;
  $db_schema = 0;
}

@{%db_opts}{qw/-user -password -sid/} = ($db_user, $db_pass, $db_sid);

unless ($db_schema) {
# Either it wasn't there, or we decided to clear and repopulate
  print "Populating db\n";

  RHN::SatInstall->populate_database(%db_opts);
}

my $version = RHN::SatInstall->schema_version;

unless ($version) {
  die "Could not retrieve version info from DB.";
}

print "Schema version: $version\n";

my %config_opts;

$config_opts{traceback_mail} = $opts{mail};
$config_opts{mount_point} = $opts{"mount-point"} || '/var/satellite';
$config_opts{kickstart_mount_point} = $config_opts{"mount-point"};
$config_opts{serverDOTsatelliteDOTrhn_parent}
  = $opts{server} || 'satellite.rhn.redhat.com';

$config_opts{serverDOTsatelliteDOThttp_proxy}
  = $opts{"http-proxy"} || '';
$config_opts{"serverDOTsatelliteDOThttp_proxy_username"}
  = $opts{"http-proxy-username"} || '';
$config_opts{serverDOTsatelliteDOThttp_proxy_password}
  = $opts{"http-proxy-password"} || '';

$config_opts{webDOTis_monitoring_backend}
  = $opts{"monitoring-backend"} || '0';
$config_opts{webDOTis_monitoring_scout}
  = $opts{"monitoring-scout"} || '0';

$config_opts{monitoringDOTdbd}
  = $opts{"monitoring-dbd"} || 'Oracle';
$config_opts{monitoringDOTdbname}
  = $db_sid;
$config_opts{monitoringDOTorahome}
  = $ENV{ORACLE_HOME};
$config_opts{monitoringDOTusername}
  = $db_user;
$config_opts{monitoringDOTpassword}
  = $db_pass;

$config_opts{monitoringDOTsmonDOTaddr}
  = '127.0.0.1';
$config_opts{monitoringDOTsmonDOTfqdn}
  = 'localhost';
$config_opts{monitoringDOTsmonDOTtestaddr}
  = '127.0.0.1';
$config_opts{monitoringDOTsmonDOTtestfqdn}
  = 'localhost';

$config_opts{encrypted_passwords} = 1;
$config_opts{ssl_available} = 1;
$config_opts{default_db} = $dsn;
$config_opts{db_user} = $db_user;
$config_opts{db_password} = $db_pass;
$config_opts{db_sid} = $db_sid;
$config_opts{db_host} = $db_address->{host};
$config_opts{db_port} = $db_address->{port};

$config_opts{traceback_mail} = PXT::Config->get('traceback_mail');
$config_opts{jabberDOThostname} = Sys::Hostname::hostname();
$config_opts{jabberDOTusername} = 'rhn-dispatcher-sat';
$config_opts{jabberDOTpassword} = 'rhn-dispatcher-' . PXT::Utils->random_password(6);

foreach my $opt_name (qw/session_swap_secret session_secret/) {
  foreach my $i (1 .. 4) {
    $config_opts{"${opt_name}_${i}"} = RHN::SatInstall->generate_secret;
  }
}

$config_opts{server_secret_key} = RHN::SatInstall->generate_secret;

$config_opts{serverDOTsatelliteDOTca_chain} =
  $opts{"ca-cert"} || '/usr/share/rhn/RHNS-CA-CERT';

# Bugzilla: 159721 - set character set in NLS_LANG based upon
# nls_database_paramaters from DB.
my %nls_database_paramaters = RHN::SatInstall->get_nls_database_parameters();
$config_opts{serverDOTnls_lang} = 'english.' . $nls_database_paramaters{NLS_CHARACTERSET};

RHN::SatInstall->write_config( { 'server.satellite.rhn_parent' => $opts{server} || 'satellite.rhn.redhat.com' },
			       '/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf' );

print "Generating satcon_dict\n";

RHN::SatInstall->generate_satcon_dict();

print "Writing config\n";

RHN::SatInstall->write_config(\%config_opts,
			      '/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');

print "Deploying config\n";

RHN::SatInstall->satcon_deploy();

unless ($opts{"disconnected-install"}) {
  RHN::SatInstall->config_up2date(-http_proxy => $config_opts{serverDOTsatelliteDOThttp_proxy},
				  -http_proxy_username => $config_opts{serverDOTsatelliteDOThttp_proxy_username},
				  -http_proxy_password => $config_opts{serverDOTsatelliteDOThttp_proxy_password},
				 );

  # Configure the server URLs 'manually' here since the web installer doesn't provide that option.
  my $up2date_opts = { noSSLServerURL => 'http://' . $config_opts{serverDOTsatelliteDOTrhn_parent} . '/XMLRPC',
		       serverURL => 'https://' . $config_opts{serverDOTsatelliteDOTrhn_parent} . '/XMLRPC' };

  RHN::SatInstall->write_config($up2date_opts, '/etc/sysconfig/rhn/up2date');
  if (-e '/etc/sysconfig/rhn/rhn_register') {
    RHN::SatInstall->write_config($up2date_opts, '/etc/sysconfig/rhn/rhn_register');
  }

  my %rhn_reg;

  $rhn_reg{-username} = $opts{username};
  $rhn_reg{-password} = $opts{password};

  @rhn_reg{qw/-http_proxy -proxy_user -proxy_pass/} =
    @config_opts{("serverDOTsatelliteDOThttp_proxy",
		  "serverDOTsatelliteDOThttp_proxy_username",
		  "serverDOTsatelliteDOThttp_proxy_password")};

  RHN::SatInstall->register_system(%rhn_reg);
}

print "Writing Satellite cert\n";
open(CERT, $opts{"rhn-cert"})
  or die "Could not read '" . $opts{"rhn-cert"} . "': $OS_ERROR";

my $cert_contents = do { local $/; <CERT> };
my $cert_file = RHN::SatInstall->write_satellite_cert(-contents => $cert_contents);

print "Validating Satellite cert\n";

RHN::SatInstall->satellite_activate(-filename => $cert_file,
				    -sanity_only => 1);

my %activate_opts;

if ($opts{"disconnected-install"}) {
  $activate_opts{"-disconnected"} = 1;
}

RHN::SatInstall->satellite_activate(-filename => $cert_file,
				    %activate_opts);

print "Syncing channel families\n";

RHN::SatInstall->sat_sync(-ca_cert_file =>
			  $config_opts{"serverDOTsatelliteDOTca_chain"},
			  -dsn => $dsn,
			  -step => 'channel-families');

print "Generating CA cert\n";

my @hostname_parts = split(/\./, Sys::Hostname::hostname);
my $system_name;

if (scalar @hostname_parts > 2) {
  $system_name = join('.', splice(@hostname_parts, 0, -2));
}
else {
  $system_name = join('.', @hostname_parts);
}

my %ssl_cert_opts =
  (
   dir => '/root/ssl-build',
   password => $opts{"ssl-password"},
   'set-country' => $opts{"ssl-country-code"},
   'set-state' => $opts{"ssl-province-name"},
   'set-city' => $opts{"ssl-locality-name"},
   'set-org' => $opts{"ssl-org-name"},
   'set-org-unit' => $opts{"ssl-org-unit"},
   'set-common-name' => $opts{"ssl-common-name"},
   'server-rpm' => 'rhn-org-httpd-ssl-key-pair-' . $system_name,
   'cert-expiration' => 32,
  );

my $invalid_char =
  RHN::SatInstall->check_valid_ssl_cert_password($ssl_cert_opts{password});

if ($invalid_char) {
  die "Invalid character '$invalid_char' in cert password.";
}

RHN::SatInstall->generate_ca_cert(%ssl_cert_opts);

print "Deploying CA cert\n";

RHN::SatInstall->deploy_ca_cert("-source-dir" => $ssl_cert_opts{dir},
				"-target-dir" => '/var/www/html/pub');

print "Generating Server cert\n";

delete $ssl_cert_opts{'server-rpm'};
delete $ssl_cert_opts{'set-common-name'};

$ssl_cert_opts{'set-email'} = $opts{email};
$ssl_cert_opts{'set-hostname'} = Sys::Hostname::hostname;
$ssl_cert_opts{'cert-expiration'} = 5;

RHN::SatInstall->generate_server_cert(%ssl_cert_opts);

print "Installing Server cert\n";

RHN::SatInstall->install_server_cert(-dir => $ssl_cert_opts{dir},
				     -system => $system_name);

RHN::SatInstall->generate_server_pem(-ssl_dir => $ssl_cert_opts{dir},
				     -system => $system_name,
				     -out_file => '/etc/jabberd/server.pem');

RHN::SatInstall->store_ssl_cert(-ssl_dir => $ssl_cert_opts{dir});

if ($opts{"monitoring-backend"}) {
  print "Setting up Monitoring backend\n";

  RHN::SatInstall->setup_monitoring_sysv_step('Monitoring');

  my $org_id = RHN::SatInstall->get_satellite_org_id();
  my $sc = new RHN::SatCluster(customer_id => $org_id,
			       description => 'RHN Monitoring Satellite',
			       last_update_user => 'installer',
			      );
  $sc->create_new();

  my $scout_shared_key = RHN::SatCluster->fetch_key($sc->recid);
  RHN::SatInstall->write_config({ monitoringDOTscout_shared_key => $scout_shared_key },
				'/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');
}

if ($opts{"monitoring-scout"}) {
  print "Setting up Monitoring scout\n";

  RHN::SatInstall->setup_monitoring_sysv_step('MonitoringScout');
}

print "Disabling Satellite install web UI\n";

my $final_config = {satellite_install => 0,
		    webDOTssl_available => 1,
		    osadispatcherDOTosa_ssl_cert => '/var/www/html/pub/RHN-ORG-TRUSTED-SSL-CERT',
		   };

RHN::SatInstall->write_config($final_config);
RHN::SatInstall->write_config($final_config,
			      '/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');

RHN::SatInstall->satcon_deploy(-tree => '/etc/sysconfig/rhn-satellite-prep/etc/rhn',
			       -dest => '/etc/rhn');

print "Restarting satellite services\n";
RHN::SatInstall->restart_satellite(-delay => 1);

print "Done\n";

exit 0;

sub set_default_db {
  my $dsn = shift;

  my %options = ('default_db' => $dsn);
  RHN::SatInstall->write_config(\%options);

  RHN::DB->set_default_handle($dsn);

  return;
}

sub make_dsn {
  my ($db_user, $db_pass, $db_sid) = @_;

  return sprintf('%s/%s@%s', $db_user, $db_pass, $db_sid);
}
