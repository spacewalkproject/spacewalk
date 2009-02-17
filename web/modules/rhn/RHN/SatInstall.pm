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

sub generate_satcon_dict {
  my $class = shift;
  my %params = validate(@_, { conf_file => { default => DEFAULT_SATCON_DICT },
			      tree => { default => DEFAULT_RHN_SATCON_TREE },
			    });

  my $ret = system("/usr/bin/sudo", "/usr/bin/satcon-build-dictionary.pl",
		   "--tree=" . $params{tree},
		   "--target=" . $params{conf_file});

  if ($ret) {
    throw 'There was a problem building the satcon dictionary.  '
      . 'See the webserver error log for details.';
  }

  return;
}

sub satcon_deploy {
  my $class = shift;
  my %params = validate(@_, { conf_file => { default => DEFAULT_SATCON_DICT },
			      tree => { default => DEFAULT_RHN_SATCON_TREE },
			      dest => { default => '/etc' },
			    });

  my @opts = ("--source=" . $params{tree}, "--dest=" . $params{dest},
	      "--conf=" . $params{conf_file});

  my $ret = system("/usr/bin/sudo", "/usr/bin/satcon-deploy-tree.pl", @opts);

  if ($ret) {
    throw 'There was a problem deploying the satellite configuration.  '
      . 'See the webserver error log for details.';
  }

  return;
}

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

sub config_up2date {
  my $class = shift;
  my %params = validate(@_, { http_proxy => 0,
			      http_proxy_username => 0,
			      http_proxy_password => 0,
			    });

  my $up2date_opts = { enableProxy => ($params{http_proxy} ? '1' : '0'),
		       httpProxy => $params{http_proxy},
		       enableProxyAuth => ($params{http_proxy_username} ? '1' : '0'),
		       proxyUser => $params{http_proxy_username},
		       proxyPassword => $params{http_proxy_password},
		     };

  $class->write_config($up2date_opts, '/etc/sysconfig/rhn/up2date');

  # swallow the exception - the only good reason for this to fail if
  # the previous command succeeded is that we are running an up2date
  # client that doesn't have seperate configs for rhn_regsiter.
  eval {
    $class->write_config($up2date_opts, '/etc/sysconfig/rhn/rhn_register');
  };

  return;
}

sub is_embedded_db {
  my $class = shift;

  return $class->is_rpm_installed('oracle-server-admin');
}

sub db_population_in_progress {
  my $class = shift;

  return (-e '/var/lock/subsys/rhn-satellite-db-population' ? 1 : 0);
}

sub build_proxy_url {
  my ($url, $user, $pass) = @_;

  return unless $url;

  $url =~ m|^((https?)://)?(.*)|;
  my $proto = $2 || 'http';
  my $rest = $3;

  throw "Could not parse url '$url'\n"
    unless $rest;

  my $ret;

  if ($user) {
    $ret = sprintf('%s://%s:%s@%s', $proto, $user, $pass, $rest);
  }
  else {
    $ret = sprintf('%s//%s', $proto, $rest);
  }

  return $ret;
}

sub build_rhn_url {
  my ($host, $ssl) = @_;

  my $proto = $ssl ? 'https' : 'http';

  return sprintf('%s://%s/XMLRPC', $proto, $host);
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

sub check_valid_ssl_cert_password {
  my $class = shift;
  my $password = shift;

  my $ret;

  if ($password =~ /([\t\r\n\f\013&+%\'\`\\\"=\#)])/) {
    $ret = $1;
  }

  return $ret;
}

sub sat_sync {
  my $class = shift;
  my %params = validate(@_, { ca_cert_file => 1,
			      dsn => 1,
			      step => 1,
			    });

  my %args = ('--step' => $params{step},
	      '--db' => $params{dsn},
	      '--ca-cert' => $params{ca_cert_file},
	     );

  my $ret = system('/usr/bin/sudo', '/usr/bin/satellite-sync',
		   %args);

  if ($ret) {
    throw 'There was a problem running satellite-sync.  '
      . 'See the webserver error log for details.';
  }

  return $ret;
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

  my @command = ('/usr/bin/sudo', '/usr/bin/rhn-ssl-tool', @opts);

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

  my @command = ('/usr/bin/sudo', '/usr/bin/rhn-ssl-tool',  @opts, '-q');

  my $ret = system(@command);

  return $ret;
}

my $valid_bootstrap_params = {
			      hostname => 1,
			      "ssl-cert" => 1,
			      "http-proxy" => 0,
			      "http-proxy-username" => 0,
			      "http-proxy-password" => 0,
			      "no-ssl" => 0,
			      "no-gpg" => 0,
			      "allow-config-actions" => 0,
			      "allow-remote-commands" => 0,
			      overrides => 1,
			      script => 1,
			     };

sub generate_bootstrap_scripts {
  my $class = shift;
  my %params = validate(@_, $valid_bootstrap_params);

  my @opts;

  foreach my $key (keys %{$valid_bootstrap_params}) {
    if (grep { $key eq $_ } qw/no-ssl no-gpg allow-config-actions allow-remote-commands/) {

      push @opts, "--$key" if ($params{$key});
      next;
    }

    if (not $params{$key}) {
      next;
    }

    push @opts, sprintf('--%s=%s', $key, $params{$key});
  }

  my $ret = system('/usr/bin/sudo', '/usr/bin/rhn-bootstrap', @opts);

  my %retcodes = (
		  10 => 'A script with that name already exists',
		  11 => 'Invalid script name',
		  12 => 'Invalid arguments',
		  13 => 'Could not parse httpd proxy URL',
		  14 => 'Cannot find pub tree',
		  15 => 'The hostname was not valid',
		  16 => 'Could not find the CA certificate',
		  17 => 'Could not find GPG key',
		 );

  if ($ret) {
    my $exit_value = $? >> 8;
    throw "(bootstrap_script_creation_failed) $retcodes{$exit_value}" if exists $retcodes{$exit_value};

    throw "There was a problem generating the bootstrap scripts: $exit_value";
  }

  return;
}

sub write_satellite_cert {
  my $class = shift;
  my %params = validate(@_, {contents => 1});

  my $contents = $params{contents} || '';
  my $filename = "/tmp/satcert_${PID}";

  open(FH, ">$filename") or die "Could not open $filename for writing: $OS_ERROR";

  print FH $contents;

  close(FH);

  return $filename;
}

sub get_db_population_log_stats {
  my $class = shift;
  my $file = shift || DEFAULT_DB_POP_LOG_FILE;

  my $ret = {};
  if (not (-r $file)) {
    $ret->{$_} = '' foreach (qw/file_size/);
    return $ret;
  }

  my @stats = stat $file;

  $ret->{file_size} = $stats[7];
  $ret->{percent_complete} = int(100 * $ret->{file_size} / DB_POP_LOG_SIZE);

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

  exec('/usr/bin/sudo', '/sbin/service', $params{service}, 'restart')
    or throw "(exec_error) Could not exec 'service $params{service} restart': $!";

  # exec does not return
}

my @valid_sysv_steps = qw/Monitoring MonitoringScout/;

sub setup_monitoring_sysv_step {
  my $class = shift;
  my $step = shift;
  my $command = shift || 'install';

  throw "No step name given" unless $step;
  throw "Invalid step: '$step'"
    unless (grep { $step eq $_ } @valid_sysv_steps);

  my $ret = system('/usr/bin/sudo', '/etc/rc.d/np.d/step', $step, $command);

  if ($ret) {
    throw "There was a problem starting the monitoring backend.  "
      . 'See the webserver error log for details.';
  }

  return;
}

sub get_db_population_errors {
  my $class = shift;
  my %params = validate(@_, {log_file => 0});

  my $log_file = $params{log_file} || DEFAULT_DB_POP_LOG_FILE;


  open(ERRORS, qq(grep -P "^ORA|Errors for" $log_file |))
    or die "Could not grep $log_file: $OS_ERROR";

  my @errors = <ERRORS>;

  close(ERRORS);

  return @errors;
}

sub store_ssl_cert {
  my $class = shift;
  my %params = validate(@_, { ssl_dir => 1,
			      ca_cert => { default => DEFAULT_CA_CERT_NAME },
			    });


  my $cert_path = File::Spec->catfile($params{ssl_dir}, $params{ca_cert});
  my @opts = ("--ca-cert=${cert_path}");

  my $ret = system('/usr/bin/sudo', '/usr/bin/rhn-ssl-dbstore', @opts);

  my %retcodes = (
		  10 => 'CA certificate not found',
		  11 => 'DB initialization failure',
		  12 => 'No Organization ID',
		  13 => 'Could not insert the certificate',
		 );

  if ($ret) {
    my $exit_code = $? >> 8;

    throw "(satinstall:ssl_cert_import_failed) $retcodes{$exit_code}" if exists $retcodes{$exit_code};

    throw "There was a problem validating the satellite certificate: $exit_code";
  }

  return;
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

1;
