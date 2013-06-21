#!/usr/bin/perl

use strict;
use warnings;
use English;

use Pod::Usage;
use Sys::Hostname;

use constant DEFAULT_UP2DATE_CONF_LOCATION =>
  '/etc/sysconfig/rhn/up2date';

use constant SPACEWALK_SETUP_SCRIPT => '/usr/bin/spacewalk-setup';

# Run everything from the proper directory
BEGIN {
	my $program = $PROGRAM_NAME;

	my @parts = split(m|/|, $program);
	my $dir = join('/', @parts[0 .. $#parts - 1]);

	if ($dir) {
	  chdir $dir;
	}
}

# Store the command line args for eventual call to spacewalk-setup. These
# seem to be stripped as soon as we do the validation.
my @ARGV_ORIG = @ARGV;

# Load some Perl libraries directly from the ISO:
use lib 'install/lib';
use Params::Validate;
use Spacewalk::Setup qw(loc system_debug system_or_exit);

Params::Validate::validation_options(strip_leading => "-");
print loc("* Starting the Spacewalk installer.\n");

my $DEBUG;
$DEBUG = 0;

Spacewalk::Setup::init_log_files(get_product_name(), @ARGV);

my %opts = Spacewalk::Setup::parse_options();

my %up2dateOptions = ();
my %rhnOptions = ();
my @additionalOptions = ();
# read existing confgiuration
Spacewalk::Setup::read_config(DEFAULT_UP2DATE_CONF_LOCATION, \%up2dateOptions);

if (-e Spacewalk::Setup::DEFAULT_RHN_CONF_LOCATION) {
    Spacewalk::Setup::read_config(Spacewalk::Setup::DEFAULT_RHN_CONF_LOCATION, \%rhnOptions);
}

my %answers = ();
my @skip = ();
push @skip, Spacewalk::Setup::EMBEDDED_DB_ANSWERS if (defined $opts{'managed-db'});
Spacewalk::Setup::load_answer_file(\%opts, \%answers, \@skip);

$answers{hostname} ||= Sys::Hostname::hostname;

my %version_info = get_version_info();

print loc("* Performing pre-install checks.\n");
do_precondition_checks(\%opts, \%answers);

print loc("* Pre-install checks complete.  Beginning installation.\n");

print loc("* RHN Registration.\n");
rhn_register(\%opts, \%answers, \%up2dateOptions, \%rhnOptions, \@additionalOptions);

Spacewalk::Setup::upgrade_stop_services(\%opts);
remove_obsoleted_packages(\%opts);
remove_jabberd_configs(\%opts);
remove_rhn_cache_and_kickstarts(\%opts);
remove_nocpulse_ini(\%opts);
backup_oracle_rhnconf(\%opts);

my $run_updater;
if (defined $opts{'run-updater'}) {
  if ($opts{'run-updater'} eq ''
    or $opts{'run-updater'} =~ /^\s*y(es)?\s*$/i) {
    $run_updater = 1;
  } else {
    $run_updater = 0;
  }
} elsif (defined $answers{'run-updater'}) {
  if ($answers{'run-updater'} =~ /^\s*y(es)?\s*$/i) {
    $run_updater = 1;
  } else {
    $run_updater = 0;
  }
}

my (%rpm_qa, $needed_rpms);

@rpm_qa{ map { chomp ; $_; } `rpm -qa --qf '%{name}\n'` } = ();
print loc("* Checking for uninstalled prerequisites.\n");
$needed_rpms = check_required_rpms(\%opts, \%answers, $run_updater, \%rpm_qa);
$needed_rpms = {} if not defined $needed_rpms;

print loc("* Installing RHN packages.\n");
import_gpg_key();
install_rhn_packages(\%opts);


my %satellite_rpms = map { m!^.+/(.+)-.+-.+$! and ( $1 => 1 ); }
    glob("Satellite/*.rpm Oracle/*.rpm EmbeddedDB/*.rpm PostgreSQL/*.rpm");
my %current_rpm_qa =
    map { ( $_ => 1 ) }
    grep { not exists $rpm_qa{$_} and not exists $satellite_rpms{$_} }
    map { chomp ; $_; } `rpm -qa --qf '%{name}\n'`;
my @extra_rpms = grep { $_ ne 'gpg-pubkey' } grep { not exists $needed_rpms->{$_} } sort keys %current_rpm_qa;
if (@extra_rpms) {
    print loc("Warning: more packages were installed by yum than expected:\n");
    print map "\t$_\n", @extra_rpms;
}
my @not_installed_rpms = grep { not exists $current_rpm_qa{$_} } sort keys %$needed_rpms;
if (@not_installed_rpms) {
    print loc("Warning: yum did not install the following packages:\n");
    print map "\t$_\n", @not_installed_rpms;
}

# Call spacewalk-setup:
print loc("* Now running spacewalk-setup.\n");
exec(SPACEWALK_SETUP_SCRIPT, @ARGV_ORIG, '--skip-logfile-init', @additionalOptions) or die;






sub get_version_info {
  my $vre = `rpm -q --queryformat '%{version} %{release} %{epoch}' --whatprovides redhat-release`;
  my ($version, $release, $epoch) = split /\s/, $vre;

  my %version_info = (
		      version => $version,
		      release => $release,
		      epoch => $epoch,
		     );

  return %version_info;
}

sub do_precondition_checks {
  my $opts = shift;
  my $answers = shift;

  if (umask() & ~022) {
    print "The installer needs umask not to exceed 0022.\n";
    exit 56;
  }

  if (not $opts->{"skip-system-version-test"}
      and not correct_system_version(%version_info)) {
    print loc(<<EOQ);
This version of Red Hat Satellite runs only on:
   Red Hat Enterprise Linux 5 Server
   Red Hat Enterprise Linux 6 Server

Installation interrupted.
EOQ

    exit 2;
  }

  if (not $opts->{"skip-selinux-test"}) {
      if (getenforce() eq 'Disabled') {		# we should use SELinux
        print loc(<<EOH);
Red Hat recommends SELinux be configured in either Permissive or Enforcing
mode for your Red Hat Satellite installation.  Run /usr/sbin/getenforce to see your
current mode.  If you wish to run in Disabled mode, re-run the installer with
the flag --skip-selinux-test.  When you install while SELinux is disabled and
want to enable SELinux later, run /usr/sbin/spacewalk-selinux-enable once
you've enabled SELinux, to run the post-installation steps which would
otherwise be run by the installer.
EOH
        exit 3;
      }
  }

  if (not $opts->{"skip-fqdn-test"}
      and not hostname_is_fqdn($answers)) {
    exit 4;
  }

  if (not $opts->{"skip-python-test"}
      and not python_path()) {
    print loc(<<EOH);
ERROR: Could not find Python executable in your path or /usr/bin/python.
EOH
    exit 5;
  }

  if ($opts->{"upgrade"}) {
    my $ret = system_debug('rpm', '-q', 'rhns') && system_debug('rpm', '-q', 'spacewalk-schema');

    if ($ret) {
      print loc(<<EOH);
ERROR: Upgrade flag passed, but could not determine if a satellite is installed.
EOH
    exit 21;
    }

    $ret = system_debug('rpm', '-q', 'rhn-upgrade');

    if ($ret) {
      print loc(<<EOH);
ERROR: Upgrade flag passed, but could not find the rhn-upgrade package.
Please download the latest rhn-upgrade package from the Satellite channel on RHN.
EOH
      exit 23;
    }
  }

  return 1;
}

sub correct_system_version {
  my %version_info = @_;

  return 1 if grep { $version_info{version} eq $_ } qw/5Server 6Server/;
}

sub getenforce {
	my $getenforce = `/usr/sbin/getenforce`;
	chomp $getenforce;
	return $getenforce;
}

sub hostname_is_fqdn {
  my $answers = shift;

  if ((my @parts = split/\./, $answers->{hostname}) < 3) {
    print loc(<<EOH, $answers->{hostname}, "--skip-fqdn-test");
%s doesn't have 3 fields (111.222.333). Can't be FQDN.
Use %s to bypass this error.
Exiting...
EOH
    return 0;
  }

  if ($answers->{hostname} =~ /localhost/) {
    print loc(<<EOH, $answers->{hostname}, "localhost", "--skip-fqdn-test");
Hostname appears to be '%s'.  "%s" of any sort is not a
FQDN. Or just a poor machine name.
Use %s to bypass this error.
Exiting...
EOH
    return 0;
  }

  if ($answers->{hostname} =~ /127\.0\.0\.1/) {
    print loc(<<EOH, $answers->{hostname}, "--skip-fqdn-test");
%s is not a FQDN.
Use %s to bypass this error.
Exiting...
EOH
    return 0;
  }

  return 1;
}

sub python_path {
  my $path = `which python 2>/dev/null`;
  chomp $path;

  $path ||= '/usr/bin/python';

  return $path;
}

sub system_is_registered {
  my $ret = system_debug('/usr/sbin/rhn_check', '--');

  return ($ret ? 0 : 1);
}

sub rhn_register {
  my $opts = shift;
  my $answers = shift;
  my $up2dateopts = shift;
  my $rhnOptions = shift;
  my $proxyOptionsRef = shift;
  my $proxyAccept;

  if ($opts->{disconnected}) {
    print loc("** Registration: Disconnected mode.  Not registering with RHN.\n");
    return 0;
  }

  if (system_is_registered()) {
    if ($opts->{"re-register"}) {
      print loc("** Registration: System is already registered with RHN, but --re-register option used.  Re-registering.\n");
    }
    else {
      print loc("** Registration: System is already registered with RHN.  Not re-registering.\n");
      return 0;
    }
  }

  ask(-question => "RHN Username",
      -test => qr/\S+/,
      -answer => \$answers->{'rhn-username'});

  ask(-question => "RHN Password",
      -test => qr/\S+/,
      -answer => \$answers->{'rhn-password'},
      -password => 1);

  if ($up2dateopts->{'httpProxy'}) {
    $up2dateopts->{'proxyUser'} ||= '';
    $up2dateopts->{'proxyPassword'} ||= '';
    ask(-question => "The following proxy information was found in use by up2date:
Proxy Hostname: $up2dateopts->{'httpProxy'}
Proxy Username: $up2dateopts->{'proxyUser'}
Proxy Password: Not displayed - see /etc/sysconfig/rhn/up2date:proxyPassword

Import values to be used by Satellite [y/n]",
        -test => qr/\S+/,
        -answer => \$proxyAccept);
  } else {
    $proxyAccept = 'n';
  }
  if ($proxyAccept eq 'y') {
    $answers->{'rhn-http-proxy'} = $up2dateopts->{'httpProxy'};
    $answers->{'rhn-http-proxy-username'} = $up2dateopts->{'proxyUser'};
    $answers->{'rhn-http-proxy-password'} = $up2dateopts->{'proxyPassword'};
  } else {

    ask(-question => "HTTP Proxy Hostname",
	-test => sub { my $text = shift; return (empty($text) or valid_proxy($text)) },
	-answer => \$answers->{'rhn-http-proxy'});

    if ($answers->{'rhn-http-proxy'}) {
      $answers->{'rhn-http-proxy'} =~ /^([^:\/]*)(:\d+)?/;

      my ($host, $port) = ($1, $2);

      ask(-question => "HTTP Proxy Port",
	  -test => qr/\d+/,
	  -default => '8080',
	  -answer => \$port);

      $answers->{'rhn-http-proxy'} = $host . ':' . $port;

      ask(-question => "HTTP Proxy Username",
	  -answer => \$answers->{'rhn-http-proxy-username'},
	  -test => sub { 1 },
	  -default => '');

      if ($answers->{'rhn-http-proxy-username'}) {
        ask(-question => "HTTP Proxy Password",
	    -answer => \$answers->{'rhn-http-proxy-password'},
	    -test => sub { 1 },
	    -password => 1,
	    -default => '');
      }
    }
  }

  push @$proxyOptionsRef, map { "--$_=" . $answers{$_} } grep { defined $answers{$_} } grep /^rhn-http-proxy/, keys %answers;

  my $sys_hostname = $answers->{hostname};

  ask(-question => "RHN Profile Name",
      -answer => \$answers->{'rhn-profile-name'},
      -default => $sys_hostname,
      -test => qr/\S+/,
     );

  register_system(-rhn_username => $answers->{'rhn-username'},
		  -rhn_password => $answers->{'rhn-password'},
		  -rhn_http_proxy => $answers->{'rhn-http-proxy'},
		  -rhn_http_proxy_username => $answers->{'rhn-http-proxy-username'},
		  -rhn_http_proxy_password => $answers->{'rhn-http-proxy-password'},
		  -rhn_profile_name => $answers->{'rhn-profile-name'},
		  -rhn_server_name => $answers->{'rhn-server-name'},
		 );

  return 1;
}

sub register_system {
  my %params = validate(@_, { rhn_username => 1,
			      rhn_password => 1,
			      rhn_http_proxy => 0,
			      rhn_http_proxy_username => 0,
			      rhn_http_proxy_password => 0,
			      rhn_profile_name => 0,
			      rhn_server_name => 0});

  my @args;

  @args = ('--username', $params{rhn_username},
	   '--password', $params{rhn_password});

  if ($params{http_proxy}) {
    push @args, ('--proxy', $params{rhn_http_proxy});
  }

  if ($params{proxy_user}) {
    push @args, ('--proxyUser', $params{rhn_http_proxy_username});
  }

  if ($params{proxy_pass}) {
    push @args, ('--proxyPassword', $params{rhn_http_proxy_password});
  }

  if ($params{rhn_profile_name}) {
    push @args, ('--profilename', $params{rhn_profile_name});
  }

  if ($params{rhn_server_name}) {
    push @args, ('--serverUrl', "https://" . $params{rhn_server_name} . "/XMLRPC");
  }


  push @args, '--force';

  my $ret = system_debug('/usr/sbin/rhnreg_ks', @args);

  my %retcodes = (
		  1 => 'Fatal error registering with RHN.  Check your proxy settings and parent server and try again.  Also ensure that the specified user exists and that the user has an available Satellite software entitlement.',
		  -1 => 'Could not register with RHN.  Check your username and password and try again.',
		 );

  if ($ret) {
    my $exit_value = $CHILD_ERROR >> 8;

    if (exists $retcodes{$exit_value}) {
      print loc("Satellite registration failed: %s\n", $retcodes{$exit_value});
    }
    else {
      print loc("There was a problem registering the satellite.  Exit code: %d\n", $exit_value);
    }

    exit 17;
  }

  return;
}

sub valid_fqdn {
  my $text = shift || '';

  my @parts = split(/\./, $text);
  my @non_empty_parts = grep { $_ } @parts;

  unless (scalar @parts >= 3 and scalar @parts == scalar @non_empty_parts) {
    print loc("Invalid hostname: '%s' does not appear to be a valid hostname.\n", $text);
    return 0;
  }

  if ($text =~ /([^a-zA-z0-9\.-])/) {
    print loc("Invalid hostname: '%s' contains at least one character that is not allowed in a hostname: '$1'\n", $text);
    return 0;
  }

  return 1;
}

sub valid_proxy {
  my $text = shift;

  my $hostname;

  if ($text =~ /^([^:\/]*)(:\d+)?/) {
    $hostname = $1; # Check the hostname seperately
  }
  else {
    print loc("'%s' does not appear to be a valid proxy name.\n", $text);
  }

  return valid_fqdn($hostname);
}

sub empty {
  my $text = shift;

  return ($text ? 0 : 1);
}

sub remove_obsoleted_packages {
  my $opts = shift;
  if ($opts->{'upgrade'}) {
    print "* Purging conflicting packages.\n";
    my @pkgs = ('rhn-apache', 'rhn-modpython', 'rhn-modssl', 'rhn-modperl',
                'perl-libapreq', 'bouncycastle-jdk1.4',
                'quartz-oracle', 'jaf', 'jta',
                'python-sgmlop', 'geronimo-specs-compat', 'spacewalk-backend-upload-server');

    # Remove xml-commons on RHEL-5 only
    if (`rpm -q --qf='%{VERSION}' redhat-release 2>/dev/null` =~ /^5.+$/) {
        push @pkgs, 'xml-commons';
        push @pkgs, 'rhn-java-sat';
        push @pkgs, 'spacewalk-slf4j-1.6.1-4.el5sat';
    }

    if (Spacewalk::Setup::is_db_migration()) {
        push @pkgs, 'spacewalk-oracle', 'perl-NOCpulse-Probe-Oracle', 'NOCpulsePlugins-Oracle';
        push @pkgs, 'oracle-instantclient-sqlplus';
        push @pkgs, 'oracle-instantclient-sqlplus-selinux';
    }

    for my $pkg (@pkgs) {
      if (system_debug('rpm', '-q', $pkg) == 0) {
        system_debug('rpm', '-ev', '--nodeps', $pkg);
      }
    }
  }
  return 1;
}

# We need to remove jabberd configs before the package installation so that
# they can be replaced by configs from latest jabberd build. These will later
# be properly configured by spacewalk-setup-jabberd.
sub remove_jabberd_configs {
  my $opts = shift;

  return unless ($opts->{'upgrade'});
  # Don't remove the config files if we're on latest version already
  return if (`rpm -qp --qf='%{VERSION}-%{RELEASE}' Satellite/jabberd-2*.rpm` eq
             `rpm -q --qf='%{VERSION}-%{RELEASE}' jabberd`);

  foreach my $cf ('c2s', 's2s', 'sm', 'router', 'router-users') {
    my $cf_path = "/etc/jabberd/$cf.xml";
    if (-f $cf_path) {
      system("mv -f $cf_path $cf_path.old");
    }
  }
}

sub remove_rhn_cache_and_kickstarts {
  my $opts = shift;

  return unless ($opts->{'upgrade'});

  my $schema_version;

  foreach my $schema ('satellite-schema', 'rhn-satellite-schema') {
    system("rpm -q --qf='%{VERSION}' $schema >/dev/nul 2>&1");
    if ($? >> 8 == 0) {
      $schema_version = `rpm -q --qf='%{VERSION}' $schema 2>/dev/null`;
    }
  }

  if ($schema_version and $schema_version =~ /^5\.[01234]\./) {
     system('rm -rf /var/cache/rhn/* > /dev/null 2>&1');

     if (-d '/var/lib/rhn/kickstarts/wizard') {
         system('rm -f /var/lib/rhn/kickstarts/wizard/* > /dev/null 2>&1');
     }
  }
}

sub remove_nocpulse_ini {
  my $opts = shift;

  return unless ($opts->{'upgrade'});

  if (-f "/etc/NOCpulse.ini") {
    system("rm -f /etc/NOCpulse.ini > /dev/null 2>&1");
  }
}

sub backup_oracle_rhnconf {
  my $opts = shift;
  my $schema_version;

  return if ((not $opts->{'upgrade'}) or -f Spacewalk::Setup::ORACLE_RHNCONF_BACKUP);

  foreach my $schema ('satellite-schema', 'rhn-satellite-schema') {
    system("rpm -q --qf='%{VERSION}' $schema >/dev/nul 2>&1");
    if ($? >> 8 == 0) {
      $schema_version = `rpm -q --qf='%{VERSION}' $schema 2>/dev/null`;
    }
  }

  if ($schema_version and $schema_version =~ /^5\.[2345]\./ and
      -f Spacewalk::Setup::DEFAULT_RHN_CONF_LOCATION) {
    system("cp", "-f", Spacewalk::Setup::DEFAULT_RHN_CONF_LOCATION, Spacewalk::Setup::ORACLE_RHNCONF_BACKUP);
  }
}

sub ask {
  my %params = validate(@_, { question => 1,
			      test => 0,
			      answer => 1,
			      password => 0,
			      default => 0,
			    });

  if (${$params{answer}} and not $params{default}) {
    $params{default} = ${$params{answer}};
  }

  while (not defined ${$params{answer}} or
	 not answered($params{test}, ${$params{answer}})
        ) {
    if ($opts{"non-interactive"}) {
      if (defined ${$params{answer}}) {
	die "The answer '" . ${$params{answer}} . "' provided for '" . $params{question} . "' is invalid.\n";
      }
      else {
	die "No answer provided for '" . $params{question} . "'\n";
      }
    }

    my $default_string = "";
    if ($params{default}) {
      if ($params{password}) {
	$default_string = " [******]";
      }
      else {
	$default_string = " [" . $params{default} . "]";
      }
    }

    print loc("%s%s? ",
	      $params{question},
	      $default_string);

    if ($params{password}) {
      my $stty_orig_val = `stty -g`;
      system('stty', '-echo');
      ${$params{answer}} = <STDIN>;
      system("stty $stty_orig_val");
      print "\n";
    }
    else {
      ${$params{answer}} = <STDIN>;
    }

    chomp ${$params{answer}};

    ${$params{answer}} ||= $params{default} || '';
  }

  ${$params{answer}} ||= $params{default} || '';

  return;
}

sub answered {
  my $test = shift;
  my $answer = shift;

  my $testsub;
  if (ref $test eq 'CODE') {
    $testsub = $test;
  }
  else {
    $testsub = sub {
      my $param = shift;
      if ($param =~ $test) {
	return 1
      }
      else {
	print loc("'%s' is not a valid response\n", $param);
	return 0
      }
    };
  }

  return $testsub->($answer);
}

# The file updates/rhelrpms contains list of package names
# that Satellite rpms need.

sub get_required_rpms {
  my $opts = shift;
  my %needed_rpms;
  my $NEEDRPMS_FILE = 'updates/rhelrpms';
  my @NEEDRPMS_FILES = ($NEEDRPMS_FILE);
  if (Spacewalk::Setup::is_embedded_db($opts)) {
      if (-d 'PostgreSQL') {
	  push @NEEDRPMS_FILES, "$NEEDRPMS_FILE.postgresql";
      } elsif (-d 'EmbeddedDB') {
          push @NEEDRPMS_FILES, "$NEEDRPMS_FILE.oracle";
      }
  } else {	# this is external database, meaning Oracle
      push @NEEDRPMS_FILES, "$NEEDRPMS_FILE.external-oracle";
  }
  for my $f (@NEEDRPMS_FILES) {
    open FH, $f
      or die loc("Error reading list of needed rpms from %s: %s", $f, $!);
    while (<FH>) {
      next if /^\s*#/;
      chomp;
      $needed_rpms{$_} = 1 if /./;
    }
    close FH;
  }
  return \%needed_rpms;
}

sub check_required_rpms {
  my $opts = shift;
  my $answers = shift;
  my $run_updater = shift;
  my $rpm_qa = shift;

  my $needed_rpms = get_required_rpms($opts);
  for (keys %$needed_rpms) {
    if (exists $rpm_qa->{$_}) {
      delete $needed_rpms->{$_};
    }
  }

  if (keys %$needed_rpms) {
    if (defined $run_updater and $run_updater) {
      print loc(<<'EOF');
There are some packages from Red Hat Enterprise Linux that are not part
of the @base group that Satellite will require to be installed on this
system. The installer will try resolve the dependencies automatically.
EOF
      return $needed_rpms;
    }
    my $package_list = join "\n\t", sort keys %$needed_rpms;
    if (not defined $run_updater and yum_is_available()) {
      print loc(<<'EOF');
There are some packages from Red Hat Enterprise Linux that are not part
of the @base group that Satellite will require to be installed on this
system. The installer will try resolve the dependencies automatically.
However, you may want to install these prerequisites manually.
EOF

      my $run_updater_answer;
      ask(-question => loc('Do you want the installer to resolve dependencies [y/N]'),
          -answer => \$run_updater_answer,
          -test => qr/^/,
         );
      if (not $run_updater_answer =~ /^\s*y(es)?\s*$/i) {
        print loc(<<'EOF', $package_list);
Very well, the installer will not resolve the dependencies. Please install

	%s

and rerun the installer. Thank you.
EOF
        exit 2;
      }
      return $needed_rpms;
    }

    print loc(<<'EOF', $package_list);
The following packages from Red Hat Enterprise Linux that are not part
of the @base group have to be installed on this system for the installer
and the Satellite to operate correctly:

	%s

EOF
    if (not(defined $run_updater and not $run_updater) and not yum_is_available()) {
      print loc(<<'EOF');
The installer will not try to install the packages as this system appears
not to be registered with RHN.
EOF
    }

    print loc(<<'EOF');
Please install the packages listed above and rerun the Satellite installer.
EOF
      exit 5;
  }
  return;
}


sub print_yum_commands {
  my $needed_rpms = shift;
  if (keys %$needed_rpms) {
    print "\tyum install ", (join " ", sort keys %$needed_rpms), "\n";
  }
}

my $yum_available;
sub yum_is_available {
  return $yum_available if defined $yum_available;
  print loc("** Checking if yum is available ...\n");
  if (grep /^No Repositories Available/, `LC_ALL=C yum list base 2>&1`) {
    $yum_available = 0;
  } else {
    $yum_available = 1;
  }
  return $yum_available;
}

sub import_gpg_key {
   my $gpg_key_file = '/etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release';
   if (-f $gpg_key_file) {
     my $file_content = `gpg $gpg_key_file 2> /dev/null`;
     my ($fingerprint) = ($file_content =~  m!/(\S+)!);
     if (defined $fingerprint and system "rpm -q gpg-pubkey-\L$fingerprint > /dev/null") {
       system "rpm --import $gpg_key_file";
     }
   }
}

sub install_rhn_packages {
  my $opts = shift;
  my @rpms = glob("Satellite/*.rpm");

  if (Spacewalk::Setup::is_embedded_db($opts)) {
      push(@rpms, glob("EmbeddedDB/*.rpm"), glob("PostgreSQL/*.rpm"));
  }
  if (not(-d 'PostgreSQL' and Spacewalk::Setup::is_embedded_db($opts))) {
      push(@rpms, glob("Oracle/*.rpm"));
  }
  system_or_exit(['yum', 'localinstall', '-y', @rpms],
		 26,
		 'Could not install RHN packages.  Most likely your system is not configured with the @Base package group.  See the Red Hat Satellite Server Installation Guide for more information about Software Requirements.');
  return 1;
}

sub get_product_name {
  my $composeinfo_file = ".composeinfo";
  my $productName = "Red Hat Satellite", my $treeName;
  my $productVersion;
  my $productSection, my $treeSection;

  open(CINFO, $composeinfo_file) || return $productName;

  foreach my $line (<CINFO>) {
    chomp $line;

    if ($line =~ /^\[(.+)\]$/) {
      $productSection = ($1 eq "product");
      $treeSection = ($1 eq "tree");
    }

    if ($productSection) {

      if ($line =~ /^name\s*=\s*(.+)$/) {
        $productName = $1;
      }
      if ($line =~ /^version\s*=\s*(.+)$/) {
        $productVersion = $1;
      }

    }

    if ($treeSection) {

      if ($line =~ /^name\s*=\s*(.+)$/) {
        $treeName = $1;
      }
    }
  }
  close(CINFO);

  if (defined $productVersion) { $productName .= " $productVersion"; }
  if (defined $treeName) { $productName .= "\n($treeName)"; }
  
  return "$productName";
}


