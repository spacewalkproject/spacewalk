#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

package RHN::SatInstall;

use strict;

use File::Spec;
use Data::Dumper;
use Frontier::Client;
use Digest::MD5 qw/md5_hex/;

use English;
use POSIX qw/dup2 setsid O_WRONLY O_CREAT/;
use ModPerl::Util qw/exit/;
use DateTime;
use IPC::Open3;

use RHN::DB;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

use PXT::Utils;
use RHN::Exception qw/throw/;

use RHN::DB::SatInstall;

use RHN::SatelliteCert;

our @ISA = qw/RHN::DB::SatInstall/;

use constant DEFAULT_RHN_SATCON_TREE =>
  '/etc/sysconfig/rhn-satellite-prep/etc';

use constant DEFAULT_SATCON_DICT =>
  '/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf';

use constant DEFAULT_RHN_CERT_LOCATION =>
  '/etc/sysconfig/rhn/rhn-entitlement-cert.xml';

use constant DEFAULT_RHN_CONF_LOCATION =>
  '/etc/rhn/rhn.conf';

use constant DEFAULT_RHN_ETC_DIR =>
  '/etc/sysconfig/rhn';

use constant DEFAULT_DB_POP_LOG_FILE =>
  '/var/log/rhn/populate_db.log';

use constant DEFAULT_CA_CERT_NAME =>
  'RHN-ORG-TRUSTED-SSL-CERT';

use constant DB_POP_LOG_SIZE => 154000;

# Some utility functions to do the configuration steps needed for the
# satellite install.

sub write_config {
  my $class = shift;
  my $options = shift;
  my $target = shift || DEFAULT_RHN_CONF_LOCATION;

  my @opt_strings = map { "--option=${_}=" . $options->{$_} } keys %{$options};

  my $ret = system("/usr/bin/sudo", "/usr/bin/rhn-config-satellite.pl",
		   "--target=$target", @opt_strings);

  if ($ret) {
    throw 'There was a problem updating your configuration.  '
      . 'See the webserver error log for details.';
  }

  return;
}

sub is_embedded_db {
  my $class = shift;

  return $class->is_rpm_installed('oracle-server-admin');
}

sub generate_secret {
  return md5_hex(PXT::Utils->random_bits(4096));
}

sub local_sat_cert_checks {
  my $filename = shift;
  my $check_monitoring = shift;

  open(CERT, $filename) or throw "(satellite_activation_failed) File upload error: $OS_ERROR";
  my @data = <CERT>;
  close(CERT);

  my $cert_str = join('', @data);
  my ($signature, $cert);

  eval {
    ($signature, $cert) = RHN::SatelliteCert->parse_cert($cert_str);
  };
  if ($@) {
    throw "(parse_error) Error parsing satellite cert: $@";
  }

  my $sat_version = PXT::Config->get('version');
  my $cert_version = $cert->get_field('satellite-version');

  #The cert version should be less specific than the sat version.
  my $match_length = length($cert_version);
  $sat_version = substr($sat_version, 0, $match_length);
  unless ($sat_version eq $cert_version) {
    throw "(satellite_activation_failed) The version of the supplied cert ($cert_version)"
      . " did not match the version of this satellite ($sat_version)";
  }

  my $mon_slots = $cert->get_field('monitoring-slots');

  if ($check_monitoring and not $mon_slots) {
    throw "(no_monitoring_entitlements) You have provided a certificate that does not contain monitoring entitlements.";
  }

  return;
}

my %ca_cert_opts = (
   dir => 1,
   password => 1,
   'set-country' => 1,
   'set-state' => 1,
   'set-city' => 1,
   'set-org' => 1,
   'set-org-unit' => 1,
   'set-common-name' => 0,
   'cert-expiration' => 1, # In years
);

my @unquoted_cert_opts = qw/cert-expiration set-country dir set-hostname/;

sub generate_ca_cert {
  my $class = shift;
  my %params = validate(@_, {
   %ca_cert_opts,
   'server-rpm' => 1,
			    });

  $params{'cert-expiration'} *= 365;

  my @opts = "--gen-ca";

  foreach my $name (keys %params) {
    next unless ($params{$name}
		 and exists $ca_cert_opts{$name});

    push @opts, qq(--$name=$params{$name});
  }

  my @command = ('/usr/bin/rhn-sudo-ssl-tool', @opts);

  my $ret = system(@command);

  return $ret;
}

my %server_cert_opts = (
   dir => 1,
   password => 1,
   'set-country' => 1,
   'set-state' => 1,
   'set-city' => 1,
   'set-org' => 1,
   'set-org-unit' => 1,
   'cert-expiration' => 1,
   'set-email' => 1,
   'set-hostname' => 1,
);

sub generate_server_cert {
  my $class = shift;
  my %params = validate(@_, {
   %server_cert_opts,
			    });

  $params{'cert-expiration'} *= 365;

  my @opts = "--gen-server";

  foreach my $name (keys %params) {
    next unless ($params{$name}
		 and exists $server_cert_opts{$name});

    push @opts, qq(--$name=$params{$name});
  }

  my @command = ('/usr/bin/rhn-sudo-ssl-tool',  @opts, '-q');

  my $pid = open3(undef, ">&STDERR", ">&STDERR", @command);
  waitpid( $pid, 0 );
  my $ret = $?;

  return $ret;
}

sub restart_satellite {
  my $class = shift;
  my %params = validate(@_, { delay => 1,
			      service => { default => 'rhn-satellite' },
			    });

  RHN::DB->prepare_for_fork();
  # we fork here.  the original process returns and sends content to
  # the client so the page renders.  the child will quickly terminate...
  return if fork;

  # sleep to let the parent process cleanup
  sleep $params{delay};
  # when apache restarts, it sends a kill to its entire process group.
  # for us, though, that would include the restart script.  oops.
  POSIX::setsid();

  exec('/usr/bin/sudo', '/usr/sbin/rhn-satellite', 'restart')
    or throw "(exec_error) Could not exec '/usr/sbin/rhn-satellite restart': $!";

  # exec does not return
}

sub is_rpm_installed {
  my $class = shift;
  my $rpmname = shift;

  throw "(satinstall:missing_param) No rpm name param" unless $rpmname;

  # If the return code from rpm -q <rpmname> is nonzero, then the RPM was not found.
  my $ret = system('rpm', '-q', $rpmname);

  if ($ret) {
    return 0;
  }

  return 1;
}

sub default_cert_expiration {
  my $dt = DateTime->now;
  my $dt2 = new DateTime (year => 2038, month => 1, day => 18);
  my $diff = $dt2 - $dt;

  return $diff->years - 1;
}

sub enable_notification_cron {
  my $class = shift;

  my $ret = system('/usr/bin/sudo', 'ln', '-s', '/opt/notification/cron/notification',
		   '/etc/cron.d/notification');

  return;
}

sub disable_notification_cron {
  my $class = shift;

  my $ret = system('/usr/bin/sudo', 'rm', '/etc/cron.d/notification');

  return;
}

1;
