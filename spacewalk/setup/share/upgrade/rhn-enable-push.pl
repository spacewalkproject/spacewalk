#!/usr/bin/perl

use strict;
use warnings;

use lib '/var/www/lib';

use English;

use Data::Dumper;
use Getopt::Long;
use Sys::Hostname;

use PXT::Utils;
use PXT::Request;
use RHN::SatInstall;
use RHN::DB;
use Spacewalk::Setup;

my %opts = ();
my @valid_opts = (
		  "hostname:s",
		  "ssl-dir:s",
		  "pub-ssl-cert:s",
		  "force",
		  "help",
		 );

my $usage = "usage: $0 [ --hostname=<override_hostname> ] [ --ssl-dir=<ssl_build_directory> ]"
  . " [ --pub-ssl-cert=<public_ssl_certificate> ] [ --force ]"
  . " [ --help ]\n";

GetOptions(\%opts, @valid_opts);

if ($opts{help}) {
  die $usage;
}

unless ($opts{force}) {
  my $jabber_server = PXT::Config->get('osa-dispatcher', 'jabber_server') || '';

 if ($jabber_server and $jabber_server !~ /@@/) {
    die "Push is already enabled - do not run this script more than once.  Use --force to override.\n";
  }
}

my $db_connect = RHN::SatInstall->test_db_connection();

die "Could not connect to the database"
  unless $db_connect;

my @hostname_parts = split(/\./, $opts{hostname} || Sys::Hostname::hostname);
my $system_name;

if (scalar @hostname_parts > 2) {
  $system_name = join('.', splice(@hostname_parts, 0, -2));
}
else {
  $system_name = join('.', @hostname_parts);
}


# nuke the jabberd generated authentication database
if (-e '/var/lib/jabberd/authreg.db') {
    unlink ('/var/lib/jabberd/authreg.db');
}

if (-e '/var/lib/jabberd/sm.db') {
    unlink ('/var/lib/jabberd/sm.db');
}

Spacewalk::Setup::generate_server_pem(-ssl_dir => $opts{"ssl-dir"} || '/root/ssl-build',
				     -system => $system_name,
				     -out_file => '/etc/jabberd/server.pem');

my %config_opts;

$config_opts{jabberDOThostname} = $opts{hostname} || Sys::Hostname::hostname();
$config_opts{jabberDOTusername} = 'rhn-dispatcher-sat';
$config_opts{jabberDOTpassword} = 'rhn-dispatcher-' . PXT::Utils->random_password(6);
$config_opts{osadispatcherDOTosa_ssl_cert} = $opts{'pub-ssl-cert'} || '/var/www/html/pub/RHN-ORG-TRUSTED-SSL-CERT';

RHN::SatInstall->write_config(\%config_opts,
			      '/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf');

print "Deploying config\n";

Spacewalk::Setup::satcon_deploy();

print "Restarting satellite services\n";
system("/usr/sbin/rhn-satellite", "restart");

print "Done\n";

exit 0;
