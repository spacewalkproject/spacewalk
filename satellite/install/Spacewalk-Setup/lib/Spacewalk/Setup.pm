package Spacewalk::Setup;
require Exporter;

use warnings;
use strict;

use Getopt::Long;
use Symbol qw(gensym);
use IPC::Open3;
use Pod::Usage;

=head1 NAME

Spacewalk::Setup

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

use constant SHARED_DIR => "/usr/share/spacewalk/setup";

use constant DEFAULT_ANSWER_FILE =>
  SHARED_DIR . '/defaults.conf';

use constant DEFAULT_RHN_CONF_LOCATION =>
  '/etc/rhn/rhn.conf';

use constant INSTALL_LOG_FILE =>
  '/var/log/rhn/rhn-installation.log';

use constant DB_INSTALL_LOG_FILE =>
  '/var/log/rhn/install_db.log';

use constant DB_POP_LOG_FILE =>
  '/var/log/rhn/populate_db.log';

use constant RHN_LOG_DIR =>
  '/var/log/rhn';

my $DEBUG;
$DEBUG = 0;

sub parse_options {
  my @valid_opts = (
		    "help",
		    "skip-system-version-test",
		    "skip-selinux-test",
		    "skip-fqdn-test",
		    "skip-python-test",
		    "skip-updates-install",
		    "skip-db-install",
		    "skip-db-diskspace-check",
		    "skip-db-population",
		    "skip-gpg-key-import",
		    "skip-ssl-cert-generation",
            "skip-services-check",
            "skip-logfile-init",
		    "clear-db",
		    "re-register",
		    "disconnected",
		    "answer-file=s",
		    "non-interactive",
		    "upgrade",
		    "run-updater:s",
		   );

  my $usage = loc("usage: %s %s\n",
		  $0,
		  "[ --help ] [ --answer-file=<filename> ] [ --non-interactive ] [ --skip-system-version-test ] [ --skip-selinux-test ] [ --skip-fqdn-test ] [ --skip-db-install ] [ --skip-db-diskspace-check ] [ --skip-db-population ] [ --skip-gpg-key-import ] [ --skip-ssl-cert-generation ] [ --skip-services-check ] [ --clear-db ] [ --re-register ] [ --disconnected ] [ --upgrade ] [ --run-updater[=no]]");

  # Terminate if any errors were encountered parsing the command line args:
  my %opts;
  if (not GetOptions(\%opts, @valid_opts)) {
    die("\n");
  }

  if ($opts{help}) {
    ( my $module = __PACKAGE__ ) =~ s!::!/!g;
    pod2usage(-exitstatus => 0, -verbose => 1, -message => $usage, -input => $INC{$module . '.pm'});
  }

  return %opts;
}

# This function is a simple wrapper around sprintf, which I'm using as
# a placeholder until or unless real I18N support is required.  Doing
# it this way should make it easier to identify which strings need
# localization, and help me avoid lazily catting strings together.
sub loc {
  my $string = shift;
  return sprintf($string, @_);
}

sub read_config {
  my $config_file = shift;
  my $options = shift;
  open(CONFIG, "< $config_file") or die "Could not open $config_file: $!";

  while (my $line = <CONFIG>) {
    if ($line =~ /^#/ or $line =~ /\[comment\]/ or $line =~ "^\n") {
      next;
    } else {
      chomp($line);
      (my $key, my $value) = split (/=/, $line);
      $key =~ s/^\s*//msg;
      $key =~ s/\s*$//msg;
      $value =~ s/^\s*//msg;
      $value =~ s/\s*$//msg;
      $options->{$key} = $value;
    }
  }
  return;
}

sub load_answer_file {
  my $options = shift;
  my $answers = shift;

  my $file = $options->{'answer-file'};

  $file ||= Spacewalk::Setup::DEFAULT_ANSWER_FILE;

  return unless -r $file;

  print Spacewalk::Setup::loc("* Loading answer file: %s.\n", $file);
  open FH, $file or die Spacewalk::Setup::loc("Could not open answer file: %s\n", $!);

  while (my $line = <FH>) {
    next if substr($line, 0, 1) eq '#';
    $line =~ /([\w-]*)\s*=\s*(.*)/;
    my ($key, $value) = ($1, $2);

    next unless $key;

    $answers->{$key} = $value;
  }

  close FH;

  return;
}

# Check if we're installing with an embedded database. Check for existence of
# an "EmbeddedDB" directory beneath the dir we're running from (i.e.
# installing from ISO)
sub is_embedded_db {
  return ( -d 'EmbeddedDB' ? 1 : 0 );
}

sub system_debug {
  my @args = @_;

  my $logfile = Spacewalk::Setup::INSTALL_LOG_FILE;

  if ($DEBUG) {
    print "Command: '" . join(' ', @args) . "'\n";
    return 0;
  }
  else {
    local $SIG{'ALRM'};
    if (@args == 1) {
      set_spinning_callback();
      my $ret = system("$args[0] 1>> $logfile 2>&1");
      alarm 0;
      return $ret;
    } else {
      local *LOGFILE;
      open(LOGFILE, ">>", $logfile) or do {
          print "Error writing log file '$logfile': $!\n";
          print STDERR "Error writing log file '$logfile': $!\n";
          return 1;
      };
      set_spinning_callback();
      my $pid = open3(gensym, ">&LOGFILE", ">&LOGFILE", @args);
      waitpid($pid, 0);
      close LOGFILE;
      alarm 0;
      return $?;
    }
  }
}

sub system_or_exit {
  my $command = shift;
  my $exit_code = shift;
  my $error = shift;
  my @args = @_;

  my $ret = Spacewalk::Setup::system_debug(@{$command});

  if ($ret) {
    my $exit_value = $? >> 8;

    print Spacewalk::Setup::loc($error . "  Exit value: %d.\n", (@args, $exit_value));
    print "Please examine /var/log/rhn/rhn-installation.log for more information.\n";

    exit $exit_code;
  }

  return 1;
}

sub upgrade_stop_services {
  my $opts = shift;
  if ($opts->{'upgrade'} && not $opts->{'skip-services-check'}) {
    print "* Upgrade flag passed.  Stopping necessary services.\n";
    if (-e "/etc/rc.d/init.d/rhn-satellite") {
      Spacewalk::Setup::system_or_exit(['/sbin/service', 'rhn-satellite', 'stop'], 16,
                      'Could not stop the rhn-satellite service.');
    } else {
      # shutdown pre 3.6 services proerly
      Spacewalk::Setup::system_or_exit(['/sbin/service', 'httpd', 'stop'], 25,
                      'Could not stop the http service.');
      Spacewalk::Setup::system_or_exit(['/sbin/service', 'taskomatic', 'stop'], 27,
                      'Could not stop the taskomatic service.');
      if (Spacewalk::Setup::is_embedded_db()) {
        Spacewalk::Setup::system_or_exit(['/sbin/service', 'rhn-database', 'stop'], 31,
                        'Could not stop the rhn-database service.');
      }
    }
  }
  return 1;
}

my $spinning_callback_count;
sub spinning_callback {
	my $spinning_callback_chars = '/-\|';
	my $old = select STDOUT;
	$| = 1;
	print STDOUT substr($spinning_callback_chars, ($spinning_callback_count++ % 4), 1), "\r";
	select $old;
	alarm 1;
}

sub set_spinning_callback {
	if (not -t STDOUT) {
		return;
	}
	$spinning_callback_count = 0;
	$SIG{'ALRM'} = \&spinning_callback;
	alarm 1;
}

sub init_log_files {
  my @args = @_;

  if (not -e RHN_LOG_DIR) {
    mkdir RHN_LOG_DIR;
  }

  log_rotate(Spacewalk::Setup::INSTALL_LOG_FILE);
  log_rotate(Spacewalk::Setup::DB_INSTALL_LOG_FILE);
  log_rotate(Spacewalk::Setup::DB_POP_LOG_FILE);

  open(FH, ">", Spacewalk::Setup::INSTALL_LOG_FILE)
    or die "Could not open '" . Spacewalk::Setup::INSTALL_LOG_FILE .
        "': $!";

  my $log_header = "RHN Satellite installation log.\nCommand: "
    . $0 . " " . join(" ", @args) . "\n\n";

  print FH $log_header;

  close(FH);

  return;
}

sub log_rotate {
  my $file = shift;

  my $counter = 1;
  if (-e $file) {
    while (-e $file . '.' . $counter) {
      $counter++;
    }

    rename $file, $file . '.' . $counter;
  }

  return;
}







=head1 NAME

Spacewalk::Setup

=head1 DESCRIPTION

Spacewalk::Setup is a module which provides the guts of the
spacewalk-setup program. In will run the necessary steps to configure
the Spacewalk server.

=head1 OPTIONS

=over 8

=item B<--help>

Print this help message.

=item B<--answer-file=<filename>>

Indicates the location of an answer file to be use for answering
questions asked during the installation process.
See answers.txt for an example.

=item B<--non-interactive>

For use only with --answer-file.  If the --answer-file doesn't provide
a required response, exit instead of prompting the user.

=item B<--re-register>

Register the system with RHN, even if it is already registered.

=item B<--disconnected>

Install the satellite in disconnected mode.

=item B<--clear-db>

Clear any pre-existing database schema before installing.
This will destroy any data in the Satellite database and re-create
empty Satellite schema.

=item B<--skip-system-version-test>

Do not test the Red Hat Enterprise Linux version before installing.

=item B<--skip-selinux-test>

Do not check if SELinux is Permissive or Disabled.
RHN Satellite is not currently supported on selinux 'Enforcing'
enabled systems.
See http://kbase.redhat.com/faq/FAQ_49_6086.shtm for more information.

=item B<--skip-fqdn-test>

Do not verify that the system has a valid hostname.  RHN Satellite
requires that the hostname be properly set during installation.
Using this option may result in a Satellite server that is not fully
functional.

=item B<--skip-db-install>

Do not install the embedded database.  This option may be useful if you
are re-installing the satellite, and do not want to clear the database.

=item B<--skip-db-diskspace-check>

Do not check to make sure there is enough free disk space to install
the embedded database.

=item B<--skip-db-population>

Do not populate the database schema.

=item B<--skip-gpg-key-import>

Do not import Red Hat's GPG key.

=item B<--skip-ssl-cert-generation>

Do not generate the SSL certificates for the Satellite.

=item B<--upgrade>

Only runs necessary steps for a Satellite upgrade.

=item B<--skip-services-check>

Proceed with upgrade if services are already stopped.

=item B<--run-updater>

Do not ask and install needed packages from RHN, provided the system is
registered.

=item B<--run-updater=no>

Stop when there are needed packages missing, do not ask.

=back

=head1 SEE ALSO

See documentation at L<https://fedorahosted.org/spacewalk/> for more
details and the Spacewalk server, its configuration and use..

=head1 AUTHOR

Devan Goodwin, C<< <dgoodwin at redhat.com> >>

=head1 BUGS

Please report any bugs using or feature requests using
L<https://bugzilla.redhat.com/enter_bug.cgi?product=Spacewalk>.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Devan Goodwin, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Spacewalk::Setup
