package Spacewalk::Setup;
require Exporter;

use warnings;
use strict;

use English;

use Exporter 'import';
use vars '@EXPORT_OK';
@EXPORT_OK = qw(loc system_debug system_or_exit);

use Getopt::Long qw(GetOptions);
use Symbol qw(gensym);
use IPC::Open3 qw(open3);
use Pod::Usage qw(pod2usage);
use POSIX ":sys_wait_h";
use Fcntl qw(F_GETFD F_SETFD FD_CLOEXEC);

use Params::Validate qw(validate);
Params::Validate::validation_options(strip_leading => "-");

=head1 NAME

Spacewalk::Setup, spacewalk-setup

=head1 VERSION

Version 1.1

=cut

our $VERSION = '1.1';

use constant SATELLITE_SYSCONFIG  => "/etc/sysconfig/rhn-satellite";

use constant SHARED_DIR => "/usr/share/spacewalk/setup";

use constant POSTGRESQL_SCHEMA_FILE => File::Spec->catfile("/etc", "sysconfig", 
    'rhn', 'postgres', 'main.sql');

use constant DEFAULT_ANSWER_FILE_GLOB =>
  SHARED_DIR . '/defaults.d/*.conf';

use constant DEFAULT_RHN_CONF_LOCATION =>
  '/etc/rhn/rhn.conf';

use constant DEFAULT_RHN_ETC_DIR =>
  '/etc/sysconfig/rhn';

use constant DEFAULT_SATCON_DICT =>
  '/etc/sysconfig/rhn-satellite-prep/satellite-local-rules.conf';

use constant DEFAULT_RHN_SATCON_TREE =>
  '/etc/sysconfig/rhn-satellite-prep/etc';

use constant DEFAULT_BACKUP_DIR =>
   '/etc/sysconfig/rhn/backup-' . `date +%F-%R`;

use constant INSTALL_LOG_FILE =>
  '/var/log/rhn/rhn-installation.log';

use constant DB_INSTALL_LOG_FILE =>
  '/var/log/rhn/install_db.log';

use constant DB_POP_LOG_FILE =>
  '/var/log/rhn/populate_db.log';

use constant DB_POP_LOG_SIZE => 2500000;

use constant RHN_LOG_DIR =>
  '/var/log/rhn';

use constant DB_UPGRADE_LOG_FILE =>
  '/var/log/rhn/upgrade_db.log';

use constant DB_UPGRADE_LOG_SIZE => 20000000;

use constant DB_INSTALL_LOG_SIZE => 11416;



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
                    "skip-ssl-vhost-setup",
            "skip-services-check",
            "skip-logfile-init",
		    "clear-db",
		    "re-register",
		    "disconnected",
		    "answer-file=s",
		    "non-interactive",
		    "upgrade",
		    "run-updater:s",
            "run-cobbler",
            "enable-tftp:s",
		   );

  my $usage = loc("usage: %s %s\n",
		  $0,
		  "[ --help ] [ --answer-file=<filename> ] [ --non-interactive ] [ --skip-system-version-test ] [ --skip-selinux-test ] [ --skip-fqdn-test ] [ --skip-db-install ] [ --skip-db-diskspace-check ] [ --skip-db-population ] [ --skip-gpg-key-import ] [ --skip-ssl-cert-generation ] [--skip-ssl-vhost-setup] [ --skip-services-check ] [ --clear-db ] [ --re-register ] [ --disconnected ] [ --upgrade ] [ --run-updater=<yes|no>] [--run-cobbler] [ --enable-tftp=<yes|no>]" );

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

  my @files = glob(DEFAULT_ANSWER_FILE_GLOB);
  push @files, $options->{'answer-file'} if $options->{'answer-file'};

  for my $file (@files) {

    next unless -r $file;

    if ($options->{'answer-file'} and $file eq $options->{'answer-file'}) {
      print loc("* Loading answer file: %s.\n", $file);
    }
    open FH, $file or die loc("Could not open answer file: %s\n", $!);

    while (my $line = <FH>) {
      next if substr($line, 0, 1) eq '#';
      $line =~ /([\w\.-]*)\s*=\s*(.*)/;
      my ($key, $value) = ($1, $2);

      next unless $key;

      $answers->{$key} = $value;
    }

    close FH;
  }
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

  my $logfile = INSTALL_LOG_FILE;

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
      my $orig_stdout = select LOGFILE;
      $| = 1;
      select $orig_stdout;
      local *PROCESS_OUT;
      set_spinning_callback();
      my $pid = open3(gensym, \*PROCESS_OUT, \*PROCESS_OUT, @args);
      my ($vecin, $vecout) = ('', '');
      vec($vecin, fileno(PROCESS_OUT), 1) = 1;
      my $ret;
      # Some programs that daemonize themselves do not close their stdout,
      # so doing just while (<PROCESS_OUT>) would block forever. That's why
      # we try to select'n'sysread, to have a chance to see if the child
      # is ready to be reaped, even if we did not get eof.
      while (1) {
        if (select($vecout=$vecin, undef, undef, 10) > 0) {
          my $buffer;
          if (sysread(PROCESS_OUT, $buffer, 4096) > 0) {
            print LOGFILE $buffer;
            redo;
          }
        }
        my $pidout = waitpid($pid, WNOHANG);
        if ($pidout < 0) {
          print LOGFILE "We've lost the child [@args] pid [$pid]\n";
          $ret = -1;
          last;
        }
        if ($pidout) {
          $ret = $?;
          last;
        }
      }
      close PROCESS_OUT;
      close LOGFILE;
      alarm 0;
      return $ret;
    }
  }
}

sub system_or_exit {
  my $command = shift;
  my $exit_code = shift;
  my $error = shift;
  my @args = @_;

  my $ret = system_debug(@{$command});

  if ($ret) {
    my $exit_value = $? >> 8;

    print loc($error . "  Exit value: %d.\n", (@args, $exit_value));
    print "Please examine @{[ INSTALL_LOG_FILE ]} for more information.\n";

    exit $exit_code;
  }

  return 1;
}

sub upgrade_stop_services {
  my $opts = shift;
  if ($opts->{'upgrade'} && not $opts->{'skip-services-check'}) {
    print "* Upgrade flag passed.  Stopping necessary services.\n";
    if (-e "/usr/sbin/spacewalk-service") {
      system_or_exit(['/usr/sbin/spacewalk-service', 'stop'], 16,
                      'Could not stop the rhn-satellite service.');
    } elsif (-e "/usr/sbin/rhn-satellite") {
      system_or_exit(['/usr/sbin/rhn-satellite', 'stop'], 16,
                      'Could not stop the rhn-satellite service.');
    } elsif (-e "/etc/init.d/rhn-satellite") {
      system_or_exit(['/etc/init.d/rhn-satellite', 'stop'], 16,
                      'Could not stop the rhn-satellite service.')
    } else {
      # shutdown pre 3.6 services proerly
      system_or_exit(['/sbin/service', 'httpd', 'stop'], 25,
                      'Could not stop the http service.');
      system_or_exit(['/sbin/service', 'taskomatic', 'stop'], 27,
                      'Could not stop the taskomatic service.');
      if (is_embedded_db()) {
        system_or_exit(['/sbin/service', 'rhn-database', 'stop'], 31,
                        'Could not stop the rhn-database service.');
      }
    }
  }
  return 1;
}

my $spinning_callback_count;
my @spinning_pattern = (
    '~~\0/~~~~~~',
    '~~-0-~~~~~^',
    '~~/0\~~~~^~',
    '~~-0-~~~^~~',
    '~~\0/~~^~~~',
    '~~-0-~^~~~~',
    q|~~`o'^~~~~~|,
    '~~o<^=><~~~',
    '~~~^~~~~~~~',
    '~~^~~~~~~~~',
    '~^~~~~~~~~~',
    '^~~~~~~~~~~',
);

my $spinning_pattern_maxlength = 0;
for (@spinning_pattern) {
	if (length > $spinning_pattern_maxlength) {
		$spinning_pattern_maxlength = length;
	}
}
sub spinning_callback {
	my $old = select STDOUT;
	$| = 1;
	my $index = ($spinning_callback_count++ % scalar(@spinning_pattern));
	print STDOUT $spinning_pattern[$index],
		(' ' x ($spinning_pattern_maxlength - length($spinning_pattern[$index]))),
		"\r";
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
  my $product_name = shift;
  my @args = @_;

  if (not -e RHN_LOG_DIR) {
    mkdir RHN_LOG_DIR;
  }

  log_rotate(INSTALL_LOG_FILE);
  if (have_selinux()) {
    local *X; open X, '> ' . INSTALL_LOG_FILE and close X;
    system('/sbin/restorecon', INSTALL_LOG_FILE);
  }
  log_rotate(DB_INSTALL_LOG_FILE);
  log_rotate(DB_POP_LOG_FILE);

  open(FH, ">", INSTALL_LOG_FILE)
    or die "Could not open '" . INSTALL_LOG_FILE .
        "': $!";

  my $log_header = "Installation log of $product_name\nCommand: "
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

sub check_users_exist {
    my @required_users = @_;

    my $missing_a_user;

    foreach my $user (@required_users) {
        if (not getpwnam($user)) {
            print loc("The user '%s' should exist.\n", $user);
            $missing_a_user = 1;
        }

    }

    if ($missing_a_user) {
        exit 7;
    }
}

sub check_groups_exist {
    my @required_groups = @_;

    my $missing_a_group;

    foreach my $group (@required_groups) {
        if (not getgrnam($group)) {
            print loc("The group '%s' should exist.\n", $group);
            $missing_a_group = 1;
        }
    }

    if ($missing_a_group) {
        exit 8;
    }
}

sub clear_db {
    my $answers = shift;

    my $dbh = get_dbh($answers);

    print loc("** Database: Shutting down spacewalk services that may be using DB.\n");

    system_debug('/usr/sbin/spacewalk-service --exclude=oracle* --exclude=postgresql stop');

    print loc("** Database: Services stopped.  Clearing DB.\n");

    my $select_sth = $dbh->prepare(<<EOQ);
  SELECT 'drop ' || UO.object_type ||' '|| UO.object_name AS DROP_STMT
    FROM user_objects UO
   WHERE UO.object_type NOT IN ('TABLE', 'INDEX', 'TRIGGER', 'LOB')
UNION
  SELECT 'drop ' || UO.object_type ||' '|| UO.object_name
         || ' cascade constraints' AS DROP_STMT
    FROM user_objects UO
   WHERE UO.object_type = 'TABLE'
     AND UO.object_name NOT LIKE '%$%'
EOQ

    $select_sth->execute();

    while (my ($drop_stmt) = $select_sth->fetchrow()) {
        my $drop_sth = $dbh->prepare($drop_stmt);
        $drop_sth->execute();
    }

    if ($DEBUG) {
        $dbh->rollback();
    }
    else {
        $dbh->commit();
    }

    $dbh->disconnect();

    return;
}

# TODO: Still duplicated in install.pl, didn't move out to module as nicely
# as other routines on account of usage of $opts:
sub ask {
    my %params = validate(@_, {
            noninteractive => 1,
            question => 1,
            test => 0,
            answer => 1,
            password => 0,
            default => 0,
        });

    if (${$params{answer}} and not $params{default}) {
        $params{default} = ${$params{answer}};
    }

    while (not defined ${$params{answer}} or
        not answered($params{test}, ${$params{answer}})) {
        if ($params{noninteractive}) {
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

sub get_nls_database_parameters {
    my $answers = shift;
    my $dbh = get_dbh($answers);

    my $sth = $dbh->prepare(<<EOQ);
SELECT NDP.parameter, NDP.value
  FROM nls_database_parameters NDP
EOQ

    $sth->execute();
    my %nls_database_parameters;

    while (my ($param, $value) = $sth->fetchrow()) {
        $nls_database_parameters{$param} = $value;
    }

    $sth->finish();
    $dbh->disconnect();

    return %nls_database_parameters;
}


my $progress_callback_length;
sub print_progress {
	my %params = validate(@_, { init_message => 1,
		log_file_name => 1,
		log_file_size => 1,
		err_message => 1,
		err_code => 1,
		system_opts => 1,
	});

	local *LOGFILE;
	open(LOGFILE, ">>", $params{log_file_name}) or do {
		print "Error writing log file '$params{log_file_name}': $!\n";
		print STDERR "Error writing log file '$params{log_file_name}': $!\n";
		exit $params{err_code};
	};

	local $SIG{'ALRM'};
	my $orig_stdout = select LOGFILE;
	$| = 1;
	select $orig_stdout;
	print loc($params{init_message});
	local *PROCESS_OUT;
	set_progress_callback($params{log_file_size});
	my $pid = open3(gensym, \*PROCESS_OUT, \*PROCESS_OUT, @{$params{system_opts}});
	while (<PROCESS_OUT>) {
		print LOGFILE $_;
		$progress_callback_length += length;
	}
	waitpid($pid, 0);
	my $ret = $?;
	close LOGFILE;
	alarm 0;
	print "\n";

	if ($ret) {
		print loc($params{err_message});
		exit $params{err_code};
	}
}

my $progress_hashes_done;
sub progress_callback {
	my $target_length = shift;
	my $target_hashes = 0;
	if ($target_length) {
		$target_hashes = int(60 * $progress_callback_length / $target_length);
	}
	if ($target_hashes > $progress_hashes_done) {
		my $old = select STDOUT;
		$| = 1;
		select $old;
		print STDOUT "#" x ($target_hashes - $progress_hashes_done);
		$progress_hashes_done = $target_hashes;
	}
	alarm 1;
}

sub set_progress_callback {
	if (not -t STDOUT) {
		return;
	}
	$progress_callback_length = 0;
	$progress_hashes_done = 0;
	my $target_length = shift;
	$SIG{'ALRM'} = sub { progress_callback($target_length) };
	alarm 1;
}

sub oracle_get_database_answers {
    my $opts = shift;
    my $answers = shift;

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "DB User",
        -test => qr/\S+/,
        -answer => \$answers->{'db-user'});

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "DB Password",
        -test => qr/\S+/,
        -answer => \$answers->{'db-password'},
        -password => 1);

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "DB SID",
        -test => qr/\S+/,
        -answer => \$answers->{'db-sid'});

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "DB hostname",
        -test => qr/\S+/,
        -answer => \$answers->{'db-host'});

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "DB port",
        -test => qr/\d+/,
        -default => 1521,
        -answer => \$answers->{'db-port'});

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "DB protocol",
        -test => qr/\S+/,
        -default => 'TCP',
        -answer => \$answers->{'db-protocol'});

    return;
}

sub postgresql_get_database_answers {
    my $opts = shift;
    my $answers = shift;

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "Hostname (leave empty for local)",
        -test => sub { 1 },
        -answer => \$answers->{'db-host'});

    if ($answers->{'db-host'} ne '') {
        ask(
            -noninteractive => $opts->{"non-interactive"},
            -question => "Port",
            -test => qr/\d+/,
            -default => 5432,
            -answer => \$answers->{'db-port'});
    } else {
            $answers->{'db-port'} = '';
    }

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "Database",
        -test => qr/\S+/,
        -answer => \$answers->{'db-name'});

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "Username",
        -test => qr/\S+/,
        -answer => \$answers->{'db-user'});

    ask(
        -noninteractive => $opts->{"non-interactive"},
        -question => "Password",
        -test => qr/\S+/,
        -answer => \$answers->{'db-password'},
        -password => 1);

    return;
}


############################
# PostgreSQL Specific Code #
############################

# Parent PostgreSQL setup function:
sub postgresql_setup_db {
    my $opts = shift;
    my $answers = shift;

    print Spacewalk::Setup::loc("** Database: Setting up database connection for PostgreSQL backend.\n");
    my $connected;

    while (not $connected) {
        postgresql_get_database_answers($opts, $answers);

        my $dbh;

        eval {
            $dbh = get_dbh($answers);
            $dbh->disconnect();
        };
        if ($@) {
            print Spacewalk::Setup::loc("Could not connect to the database.  Your connection information may be incorrect.  Error: %s\n", $@);

            delete @{$answers}{qw/db-host db-port db-name db-user db-password/};
        }
        else {
            $connected = 1;
        }
    }

    postgresql_populate_db($opts, $answers);

    return 1;
}

sub postgresql_populate_db {
    my $opts = shift;
    my $answers = shift;

    print Spacewalk::Setup::loc("** Database: Populating database.\n");

    if ($opts->{"skip-db-population"} || $opts->{"upgrade"}) {
        print Spacewalk::Setup::loc("** Database: Skipping database population.\n");
        return 1;
    }

    #my $tablespace_name = oracle_get_default_tablespace_name($answers);
    #oracle_populate_tablespace_name($tablespace_name);

    if ($opts->{"clear-db"}) {
        print Spacewalk::Setup::loc("** Database: --clear-db option used.  Clearing database.\n");
        postgresql_clear_db($answers);
    }

    if (postgresql_test_db_schema($answers)) {
        ask(
            -noninteractive => $opts->{"non-interactive"},
            -question => "The Database has schema.  Would you like to clear the database",
            -test => qr/(Y|N)/i,
            -answer => \$answers->{'clear-db'},
            -default => 'Y',
        );

        if ($answers->{"clear-db"} =~ /Y/i) {
            print Spacewalk::Setup::loc("** Database: Clearing database.\n");
            postgresql_clear_db($answers);
            print Spacewalk::Setup::loc("** Database: Re-populating database.\n");
        }
        else {
            print Spacewalk::Setup::loc("** Database: The database already has schema.  Skipping database population.\n");
            return 1;
        }
    }

    my $sat_schema_deploy = POSTGRESQL_SCHEMA_FILE;
    my $logfile = DB_POP_LOG_FILE;

    my @opts = ('/usr/bin/rhn-populate-database.pl',
        sprintf('--user=%s', @{$answers}{'db-user'}),
        sprintf('--password=%s', @{$answers}{'db-password'}),
        sprintf('--database=%s', @{$answers}{'db-name'}),
        sprintf('--host=%s', @{$answers}{'db-host'}),
        sprintf('--port=%s', @{$answers}{'db-port'}),
        sprintf("--schema-deploy-file=$sat_schema_deploy"),
        sprintf('--nofork'),
        sprintf('--postgresql'),
    );

    print_progress(-init_message => "*** Progress: #",
        -log_file_name => Spacewalk::Setup::DB_POP_LOG_FILE,
        -log_file_size => Spacewalk::Setup::DB_POP_LOG_SIZE,
        -err_message => "Could not populate database.\n",
        -err_code => 23,
        -system_opts => [@opts]);

    return 1;
}

# Check if the database appears to already have schema loaded:
sub postgresql_test_db_schema {
    my $answers = shift;
    my $dbh = get_dbh($answers);

    # Assumption, if web_customer table exists then schema exists:
    my $sth = $dbh->prepare("SELECT tablename from pg_tables where schemaname='public' and tablename='web_customer'");

    $sth->execute;
    my ($row) = $sth->fetchrow;
    $sth->finish;
    $dbh->disconnect();
    return $row ? 1 : 0;
}

# Clear the PostgreSQL schema by deleting the 'public' schema with cascade, 
# then re-creating it. Also delete all the other known schemas that
# Spacewalk might have created.

my $POSTGRESQL_CLEAR_SCHEMA = <<EOS;
	drop schema rpm cascade ;
	drop schema rhn_exception cascade ;
	drop schema rhn_quota cascade ;
	drop schema rhn_config cascade ;
	drop schema rhn_server cascade ;
	drop schema rhn_entitlements cascade ;
	drop schema rhn_bel cascade ;
	drop schema rhn_cache cascade ;
	drop schema rhn_channel cascade ;
	drop schema rhn_config_channel cascade ;
	drop schema rhn_org cascade ;
	drop schema rhn_package cascade ;
	drop schema rhn_user cascade ;
	drop schema public cascade ;
	create schema public authorization postgres ;
EOS
sub postgresql_clear_db {
	my $answers = shift;

	my $dbh = get_dbh($answers);
	local $dbh->{RaiseError} = 0;
	local $dbh->{PrintError} = 1;
	local $dbh->{AutoCommit} = 1;
	for my $c (split /\n/, $POSTGRESQL_CLEAR_SCHEMA) {
		$dbh->do($c);
	}
	$dbh->disconnect;
	return 1;
}





########################
# Oracle Specific Code #
########################

# Parent Oracle setup function:
sub oracle_setup_db {
    my $opts = shift;
    my $answers = shift;

    print loc("* Setting up Oracle environment.\n");

    oracle_check_for_users_and_groups();

    print loc("* Setting up database.\n");
    oracle_setup_embedded_db($opts, $answers);
    oracle_setup_db_connection($opts, $answers);
    oracle_test_db_settings($opts, $answers);
    oracle_populate_db($opts, $answers);
}

sub oracle_upgrade_start_db {
    my $opts = shift;
    if (is_embedded_db()) {
        if ($opts->{'upgrade'}) {
            system_or_exit(['/sbin/service', 'oracle', 'start'], 19,
                'Could not start the oracle database service.');
        }
    }

    return;
}

sub oracle_check_for_users_and_groups {
    if (is_embedded_db()) {
        my @required_users = qw/oracle/;
        my @required_groups = qw/oracle dba/;

        check_users_exist(@required_users);
        check_groups_exist(@required_groups);
    }
}

sub need_oracle_9i_10g_upgrade {
	my $orahome = qx{dbhome embedded};
	chomp($orahome);
	my $spfile = $orahome. "/dbs/spfilerhnsat.ora";
	return (not -r $spfile);
}

sub oracle_setup_embedded_db {
    my $opts = shift;
    my $answers = shift;

    if (not is_embedded_db()) {
        return 0;
    } else {
        $answers->{'db-user'} = 'rhnsat' if not defined $answers->{'db-user'};
        $answers->{'db-password'} = 'rhnsat' if not defined $answers->{'db-password'};
        $answers->{'db-sid'} = 'rhnsat' if not defined $answers->{'db-sid'};
        $answers->{'db-host'} = 'localhost';
        $answers->{'db-port'} = 1521;
        $answers->{'db-protocol'} = 'TCP';
    }

    # create DB_SERVICE entry in /etc/sysconfig/rhn-satellite
    if (! -e SATELLITE_SYSCONFIG) {
            open(S, '>>', SATELLITE_SYSCONFIG)
                or die loc("Could not open '%s' file: %s\n", SATELLITE_SYSCONFIG, $!);
            close(S);
    }


    if ($opts->{'upgrade'}) {
		my $upgrade_script = "upgrade-db-10g.sh";
		need_oracle_9i_10g_upgrade() and $upgrade_script = "upgrade-db.sh";

        printf loc(<<EOQ, DB_UPGRADE_LOG_FILE);
** Database: Upgrading the database server to latest Oracle 10g:
** Database: This is a long process that is logged in:
** Database: %s
EOQ
        print_progress(-init_message => "*** Progress: #",
                   -log_file_name => DB_UPGRADE_LOG_FILE,
                   -log_file_size => DB_UPGRADE_LOG_SIZE,
                   -err_message => "Could not upgrade database.\n",
                   -err_code => 15,
                   -system_opts => ['/sbin/runuser', 'oracle', '-c',
                                    SHARED_DIR . '/oracle/' . $upgrade_script .
                                    " --db $answers->{'db-sid'}" .
                                    " --user $answers->{'db-user'}"]);

        system_or_exit(['service', 'oracle', 'restart'], 41,
                       'Could not restart oracle service');

        return 0;
    }

    if ($opts->{"skip-db-install"} || $opts->{"upgrade"}) {
        print loc("** Database: Embedded database installation SKIPPED.\n");

        return 0;
    }

    if (-d "/rhnsat/data") {
        my $shared_dir = SHARED_DIR;
        print loc(<<EOQ);
The embedded database appears to be already installed. Either rerun
this script with the --skip-db-install option, or use the
'$shared_dir/oracle/remove-db.sh' script to remove the embedded database and try
again.
EOQ

        exit 13;
    }

    if (not $opts->{"skip-db-diskspace-check"}) {
        system_or_exit(['python', SHARED_DIR .
            '/embedded_diskspace_check.py'], 14,
            'There is not enough space available for the embedded database.');
    }
    else {
        print loc("** Database: Embedded database diskspace check SKIPPED!\n");
    }

    printf loc(<<EOQ, DB_INSTALL_LOG_FILE);
** Database: Installing the database:
** Database: This is a long process that is logged in:
** Database:   %s
EOQ

    if (have_selinux()) {
      local *X; open X, '> ' . DB_INSTALL_LOG_FILE and close X;
      system('/sbin/restorecon', DB_INSTALL_LOG_FILE);
    }
    print_progress(-init_message => "*** Progress: #",
        -log_file_name => DB_INSTALL_LOG_FILE,
		-log_file_size => DB_INSTALL_LOG_SIZE,
		-err_message => "Could not install database.\n",
		-err_code => 15,
		-system_opts => [ SHARED_DIR . "/oracle/install-db.sh", "--db", $answers->{'db-sid'},
                        "--user", $answers->{'db-user'}, "--password", $answers->{'db-password'}]);

    print loc("** Database: Installation complete.\n");

    sleep(5); # We need to sleep because sometimes the database doesn't
            # come back up fast enough.

    return 1;
}

sub oracle_setup_db_connection {
    my $opts = shift;
    my $answers = shift;

    print loc("** Database: Setting up database connection for Oracle backend.\n");
    my $connected;

    while (not $connected) {
        oracle_get_database_answers($opts, $answers);

        my $address = join(",", @{$answers}{qw/db-protocol db-host db-port/});

        system_or_exit([ "/usr/bin/rhn-config-tnsnames.pl",
            "--target=/etc/tnsnames.ora",
            "--sid=" . $answers->{'db-sid'},
            "--address=$address" ],
            18,
            "Could not update tnsnames.ora");

        my $dbh;

        eval {
            $dbh = get_dbh($answers);
            $dbh->disconnect();
        };
        if ($@) {
            print loc("Could not connect to the database.  Your connection information may be incorrect.  Error: %s\n", $@);
            if (is_embedded_db() or $opts->{"non-interactive"}) {
                exit 19;
            }

            delete @{$answers}{qw/db-protocol db-host db-port db-user db-sid db-password/};
        }
        else {
            $connected = 1;
        }
    }

    return 1;
}

sub oracle_check_db_version {
    my $answers = shift;

    my $dbh = get_dbh($answers);

    my ($v, $c);

    my $query = <<EOQ;
BEGIN
  dbms_utility.db_version(:v, :c);
END;
EOQ

    my $sth = $dbh->prepare($query);
    $sth->bind_param_inout(':v', \$v, 4096);
    $sth->bind_param_inout(':c', \$c, 4096);

    $sth->execute();
    $sth->finish();
    $dbh->disconnect();

    my $version = join('', (split(/\./, $v))[0 .. 2]);
    my @allowed_db_versions = qw/1120 1110 1020 920/;

    unless (grep { $version == $_ } @allowed_db_versions) {
        print loc("Invalid db version: (%s, %s)\n", $v, $c);
        exit 20;
    }

    return 1;
}

sub oracle_test_db_settings {
  my $opts = shift;
  my $answers = shift;

  print loc("** Database: Testing database connection.\n");

  oracle_check_db_version($answers);
  oracle_check_db_privs($answers);
  oracle_check_db_tablespace_settings($answers);
  oracle_check_db_charsets($answers);

  return 1;
}

sub oracle_check_db_privs {
    my $answers = shift;

    my $dbh = get_dbh($answers);

    my $sth = $dbh->prepare(<<EOQ);
SELECT DISTINCT privilege
  FROM (
          SELECT USP.privilege
            FROM user_sys_privs USP
        UNION
          SELECT RSP.privilege
            FROM role_sys_privs RSP,
                 user_role_privs URP
           WHERE RSP.role = URP.granted_role
        UNION
          SELECT RSP.privilege
            FROM role_sys_privs RSP,
                 role_role_privs RRP,
                 user_role_privs URP1,
                 user_role_privs URP2
           WHERE URP1.granted_role = RRP.role
             AND RRP.role = URP2.granted_role
             AND URP2.granted_role = RSP.role
       )
 WHERE privilege = ?
EOQ

    my @required_privs =
    ('ALTER SESSION',
        'CREATE SEQUENCE',
        'CREATE SYNONYM',
        'CREATE TABLE',
        'CREATE VIEW',
        'CREATE PROCEDURE',
        'CREATE TRIGGER',
        'CREATE TYPE',
        'CREATE SESSION',
    );

    my @errs;

    foreach my $priv (@required_privs) {
        $sth->execute($priv);
        my ($got_priv) = $sth->fetchrow();

        unless ($got_priv) {
            push @errs, loc("User '%s' does not have the '%s' privilege.", $answers->{'db-user'}, $priv);
        }
    }

    if (@errs) {
        print loc("Tablespace errors:\n  %s\n", join("\n  ", @errs));
        exit 21;
    }

    $sth->finish();
    $dbh->disconnect();

    return 0;
}

# returns 0 if the tablespace settings are good, dies with error(s) otherwise
sub oracle_check_db_tablespace_settings {
    my $answers = shift;

    my $tablespace_name = oracle_get_default_tablespace_name($answers);

    my $dbh = get_dbh($answers);

    my $sth = $dbh->prepare(<<EOQ);
SELECT UT.status, UT.contents, UT.logging
  FROM user_tablespaces UT
 WHERE UT.tablespace_name = ?
EOQ

    $sth->execute($tablespace_name);
    my $row = $sth->fetchrow_hashref;
    $sth->finish;
    $dbh->disconnect();

    unless (ref $row eq 'HASH' and (%{$row})) {
        print loc("Tablespace '%s' does not appear to exist.\n", $tablespace_name);
    }

    my %expectations = (STATUS => 'ONLINE',
        CONTENTS => 'PERMANENT',
        LOGGING => 'LOGGING',
    );
    my @errs = ();

    foreach my $column (keys %expectations) {
        if ($row->{$column} ne $expectations{$column}) {
            push @errs, loc("tablespace %s has %s set to %s where %s is expected",
                $tablespace_name, $column, $row->{$column}, $expectations{$column});
        }
    }

    if (@errs) {
        print loc("Tablespace errors: %s\n", join(';', @errs));
        exit 21;
    }

    return 1;
}

sub oracle_check_db_charsets {
    my $answers = shift;

    my %nls_database_parameters = get_nls_database_parameters($answers);

    my @ALLOWED_CHARSETS = qw/UTF8 AL32UTF8/;

    unless (exists $nls_database_parameters{NLS_CHARACTERSET} and
        grep { $nls_database_parameters{NLS_CHARACTERSET} eq $_ } @ALLOWED_CHARSETS) {
        print loc("Database is using an invalid (non-UTF8) character set: (NLS_CHARACTERSET = %s)\n", $nls_database_parameters{NLS_CHARACTERSET});
        exit 21;
    }

    return 0;
}

sub oracle_populate_db {
    my $opts = shift;
    my $answers = shift;

    print loc("** Database: Populating database.\n");

    if ($opts->{"skip-db-population"} || $opts->{"upgrade"}) {
        print loc("** Database: Skipping database population.\n");
        return 1;
    }

    my $tablespace_name = oracle_get_default_tablespace_name($answers);

    oracle_populate_tablespace_name($tablespace_name);

    if ($opts->{"clear-db"}) {
        print loc("** Database: --clear-db option used.  Clearing database.\n");
        clear_db($answers);
    }

    if (oracle_test_db_schema($answers)) {
        ask(
            -noninteractive => $opts->{"non-interactive"},
            -question => "The Database has schema.  Would you like to clear the database",
            -test => qr/(Y|N)/i,
            -answer => \$answers->{'clear-db'},
            -default => 'Y',
        );

        if ($answers->{"clear-db"} =~ /Y/i) {
            print loc("** Database: Clearing database.\n");

            clear_db($answers);

            print loc("** Database: Re-populating database.\n");
        }
        else {
            print loc("** Database: The database already has schema.  Skipping database population.\n");

            return 1;
        }
    }

    my $sat_schema_deploy =
        File::Spec->catfile(DEFAULT_RHN_ETC_DIR, 'oracle', 'deploy.sql');
    my $logfile = DB_POP_LOG_FILE;

#    my @opts = ('/usr/bin/rhn-populate-database.pl',
#        sprintf('--dsn=%s/%s@%s', @{$answers}{qw/db-user db-password db-sid/}),
#        "--schema-deploy-file=$sat_schema_deploy",
#        '--nofork',
#    );
    my @opts = ('/usr/bin/rhn-populate-database.pl',
        sprintf('--user=%s', @{$answers}{'db-user'}),
        sprintf('--password=%s', @{$answers}{'db-password'}),
        sprintf('--database=%s', @{$answers}{'db-sid'}),
        sprintf('--host=%s', @{$answers}{'db-host'}),
        sprintf("--schema-deploy-file=$sat_schema_deploy"),
        sprintf('--nofork'),
    );


    if (have_selinux()) {
      local *X; open X, '> ' . DB_POP_LOG_FILE and close X;
      system('/sbin/restorecon', DB_POP_LOG_FILE);
    }
    print_progress(-init_message => "*** Progress: #",
        -log_file_name => DB_POP_LOG_FILE,
        -log_file_size => DB_POP_LOG_SIZE,
        -err_message => "Could not populate database.\n",
        -err_code => 23,
        -system_opts => [@opts]);

    return 1;
}

sub oracle_populate_tablespace_name {
  my $tablespace_name = shift;

  my $sat_schema = File::Spec->catfile(DEFAULT_RHN_ETC_DIR, 'oracle', 'main.sql');
  my $sat_schema_deploy =
    File::Spec->catfile(DEFAULT_RHN_ETC_DIR, 'oracle', 'deploy.sql');

  system_or_exit([ "/usr/bin/rhn-config-schema.pl",
		   "--source=" . $sat_schema,
		   "--target=" . $sat_schema_deploy,
		   "--tablespace-name=${tablespace_name}" ],
		 22,
		 'There was a problem populating the universe.deploy.sql file.',
		);

  return 1;
}


sub oracle_test_db_schema {
  my $answers = shift;

  my $dbh = get_dbh($answers);

  my $sth = $dbh->prepare(<<'EOQ');
SELECT 1
  FROM user_objects
 WHERE object_name <> 'PLAN_TABLE'
   and object_type <> 'LOB'
   and object_name not like 'BIN$%'
   and rownum = 1
EOQ

  $sth->execute;
  my ($row) = $sth->fetchrow;
  $sth->finish;

  $dbh->disconnect();

  return $row ? 1 : 0;
}

sub get_dbh {
        my $answers = shift;

        my $dbh_attributes = {
                RaiseError => 1,
                PrintError => 0,
                Taint => 0,
                AutoCommit => 0,
        };

        my $backend = $answers->{'db-backend'};
        if ($backend eq 'oracle') {
                my $dbh = DBI->connect("dbi:Oracle:$answers->{'db-sid'}",
                        $answers->{'db-user'},
                        $answers->{'db-password'},
                        $dbh_attributes);

                # Bugzilla 466747: On s390x, stty: standard input: Bad file descriptor
                # For some reason DBI mistakenly sets FD_CLOEXEC on a stdin file descriptor
                # here. This made it impossible for us to succesfully call `stty -echo`
                # later in the code. Following two lines work around the problem.

                my $flags = fcntl(STDIN, F_GETFD, 0);
                fcntl(STDIN, F_SETFD, $flags & ~FD_CLOEXEC);

                return $dbh;
        }

        if ($backend eq 'postgresql') {
		my $dsn = "dbi:Pg:dbname=$answers->{'db-name'}";
		if ($answers->{'db-host'} ne '') {
			$dsn .= ";host=$answers->{'db-host'}";
			if ($answers->{'db-port'} ne '') {
				$dsn .= ";port=$answers->{'db-port'}";
			}
		}
                my $dbh = DBI->connect($dsn,
                        $answers->{'db-user'},
                        $answers->{'db-password'},
                        $dbh_attributes);

                return $dbh;
        }

        die "Unknown db-backend [$backend]\n";
}

# Find the default tablespace name for the given (oracle) user.
sub oracle_get_default_tablespace_name {
  my $answers = shift;

  my $dbh = get_dbh($answers);

  my $sth = $dbh->prepare(<<EOQ);
SELECT UU.default_tablespace
  FROM user_users UU
 WHERE UU.username = upper(?)
EOQ

  $sth->execute($answers->{'db-user'});

  my ($ts) = $sth->fetchrow();
  $sth->finish;
  $dbh->disconnect();

  if (not $ts) {
    print loc("No tablespace found for user '%s'\n", $answers->{'db-user'});
    exit 20;
  }

  return $ts;
}

# Function to check that we have SELinux, in the sense that we are on
# system with modular SELinux (> RHEL 4), and the module spacewalk is loaded.
my $have_selinux;
sub have_selinux {
	return $have_selinux if defined $have_selinux;
	if (system(q!/usr/sbin/selinuxenabled && /usr/sbin/semodule -l 2> /dev/null | grep '^spacewalk\b' 2>&1 > /dev/null!)) {
		$have_selinux = 0;
	} else {
		$have_selinux = 1;
	}
	return $have_selinux;
}

sub generate_satcon_dict {
	my %params = validate(@_, { conf_file => { default => DEFAULT_SATCON_DICT },
		tree => { default => DEFAULT_RHN_SATCON_TREE },});

	system_or_exit([ "/usr/bin/satcon-build-dictionary.pl",
		"--tree=" . $params{tree},
		"--target=" . $params{conf_file} ],
		28,
		'There was a problem building the satcon dictionary.');

	return 1;
}

sub satcon_deploy {
	my %params = validate(@_, { conf_file => { default => DEFAULT_SATCON_DICT },
				tree => { default => DEFAULT_RHN_SATCON_TREE },
				dest => { default => '/etc' },
				backup => { default => DEFAULT_BACKUP_DIR },
				});

	$params{backup} =~ s/\s+$//;
	my @opts = ("--source=" . $params{tree}, "--dest=" . $params{dest},
		"--conf=" . $params{conf_file}, "--backupdir=" . $params{backup});

	system_or_exit([ "/usr/bin/satcon-deploy-tree.pl", @opts ],	30,
		'There was a problem deploying the satellite configuration.');

	return 1;
}

sub generate_server_pem {
	my %params = validate(@_, { ssl_dir => 1, system => 1, out_file => 0 });

	my @opts;
	push @opts, '--ssl-dir=' . File::Spec->catfile($params{ssl_dir}, $params{system});

	if ($params{out_file}) {
		push @opts, '--out-file=' . $params{out_file};
	}
	my $opts = join(' ', @opts);

	my $content;
	open(FH, "/usr/bin/rhn-generate-pem.pl $opts |")
		or die "Could not generate server.pem file: $OS_ERROR";

	my @content = <FH>;
	close(FH);

	if (not $params{out_file}) {
		$content = join('', @content);
	}

	return $content;
}

sub backup_file {
    my $dir = shift;
    my $file = shift;
    my $backup_suffix = shift || '-swsave';

    system("cp", "--backup=numbered", "$dir/$file", "$dir/$file$backup_suffix");

    if ( $? >> 8 ) {
        die loc("An error ocurred while attempting to back up your original $file\n");
    } else {
        print loc("** $dir/$file has been backed up to $file$backup_suffix\n");
    }
}


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

On RHEL 5 and Fedoras, SELinux should be in Permissive or Enforcing
mode for the installation and setup to proceed properly. If you are
certain that you are not in Disabled mode or you want to install in
Disabled anyway, re-run the installer with the flag
--skip-selinux-test.

On RHEL 4, SELinux is not supported, so it must be Disabled or
Permissive, not Enforcing. If you are certain that you are not in
Enforcing mode or you know what you're doing, re-run the installer
with the flag --skip-selinux-test.

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

=item B<--skip-ssl-vhost-setup>

Do not configure the default SSL virtual host for Spacewalk.

Note that if you choose to have Spacewalk setup skip this step,
it's up to you to ensure that the following are included
in the virtual host definition:

RewriteEngine on
RewriteOptions inherit
SSLProxyEngine on

=item B<--upgrade>

Only runs necessary steps for a Satellite upgrade.

=item B<--skip-services-check>

Proceed with upgrade if services are already stopped.

=item B<--run-updater=<yes|no>>

Set to 'yes' to automatically install needed packages from RHN, provided the system is registered. Set to 'no' to terminate the installer if any needed packages are missing.

=item B<--run-cobbler>

Only runs the necessary steps to setup cobbler

=item B<--enable-tftp=<yes|no>>

Set to 'yes' to automatically enable tftp and xinetd services needed for Cobbler PXE provisioning functionality. Set to 'no' if you do not want the installer to enable these services.

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

Copyright (c) 2008--2010 Red Hat, Inc.

This software is licensed to you under the GNU General Public License,
version 2 (GPLv2). There is NO WARRANTY for this software, express or
implied, including the implied warranties of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
along with this software; if not, see
http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

Red Hat trademarks are not licensed under GPLv2. No permission is
granted to use or replicate Red Hat trademarks that are incorporated
in this software or its documentation.

=cut

1; # End of Spacewalk::Setup
