package Spacewalk::Setup;
require Exporter;

use warnings;
use strict;

use Exporter 'import';
use vars '@EXPORT_OK';
@EXPORT_OK = qw(loc system_debug system_or_exit);

use Getopt::Long;
use Symbol qw(gensym);
use IPC::Open3;
use Pod::Usage;
use POSIX ":sys_wait_h";
use Fcntl qw(F_GETFD F_SETFD FD_CLOEXEC);

use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

=head1 NAME

Spacewalk::Setup

=head1 VERSION

Version 0.2

=cut

our $VERSION = '0.2';

use constant SATELLITE_SYSCONFIG  => "/etc/sysconfig/rhn-satellite";

use constant SHARED_DIR => "/usr/share/spacewalk";

use constant POSTGRESQL_SCHEMA_FILE => File::Spec->catfile(SHARED_DIR, 
    'schema', 'postgresql', 'main.sql');

use constant DEFAULT_ANSWER_FILE_GLOB =>
  SHARED_DIR . '/setup/defaults.d/*.conf';

use constant DEFAULT_RHN_CONF_LOCATION =>
  '/etc/rhn/rhn.conf';

use constant DEFAULT_RHN_ETC_DIR =>
  '/etc/sysconfig/rhn';

use constant INSTALL_LOG_FILE =>
  '/var/log/rhn/rhn-installation.log';

use constant DB_INSTALL_LOG_FILE =>
  '/var/log/rhn/install_db.log';

use constant DB_POP_LOG_FILE =>
  '/var/log/rhn/populate_db.log';

use constant DB_POP_LOG_SIZE => 180000;

use constant RHN_LOG_DIR =>
  '/var/log/rhn';

use constant DB_UPGRADE_LOG_FILE =>
  '/var/log/rhn/upgrade_db.log';

use constant DB_UPGRADE_LOG_SIZE => 20000000;

use constant DB_INSTALL_LOG_SIZE => 15000;



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
            "run-cobbler"
		   );

  my $usage = loc("usage: %s %s\n",
		  $0,
		  "[ --help ] [ --answer-file=<filename> ] [ --non-interactive ] [ --skip-system-version-test ] [ --skip-selinux-test ] [ --skip-fqdn-test ] [ --skip-db-install ] [ --skip-db-diskspace-check ] [ --skip-db-population ] [ --skip-gpg-key-import ] [ --skip-ssl-cert-generation ] [--skip-ssl-vhost-setup] [ --skip-services-check ] [ --clear-db ] [ --re-register ] [ --disconnected ] [ --upgrade ] [ --run-updater[=no]] [--run-cobbler]");

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

  my @files = glob(Spacewalk::Setup::DEFAULT_ANSWER_FILE_GLOB);
  push @files, $options->{'answer-file'} if $options->{'answer-file'};

  for my $file (@files) {

    next unless -r $file;

    if ($options->{'answer-file'} and $file eq $options->{'answer-file'}) {
      print Spacewalk::Setup::loc("* Loading answer file: %s.\n", $file);
    }
    open FH, $file or die Spacewalk::Setup::loc("Could not open answer file: %s\n", $!);

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
    if (-e "/usr/sbin/rhn-satellite") {
      Spacewalk::Setup::system_or_exit(['/usr/sbin/rhn-satellite', 'stop'], 16,
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
	my $spinning_callback_chars = '.oO0Oo._';
	my $old = select STDOUT;
	$| = 1;
	print STDOUT substr($spinning_callback_chars, ($spinning_callback_count++ % 8), 1), "\r";
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

  log_rotate(Spacewalk::Setup::INSTALL_LOG_FILE);
  local *X; open X, '> ' . Spacewalk::Setup::INSTALL_LOG_FILE and close X;
  system('/sbin/restorecon', Spacewalk::Setup::INSTALL_LOG_FILE);
  log_rotate(Spacewalk::Setup::DB_INSTALL_LOG_FILE);
  log_rotate(Spacewalk::Setup::DB_POP_LOG_FILE);

  open(FH, ">", Spacewalk::Setup::INSTALL_LOG_FILE)
    or die "Could not open '" . Spacewalk::Setup::INSTALL_LOG_FILE .
        "': $!";

  my $log_header = "$product_name installation log.\nCommand: "
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
    my @required_users = shift;

    my $missing_a_user;

    foreach my $user (@required_users) {
        if (not getpwnam($user)) {
            print Spacewalk::Setup::loc("The user '%s' should exist.\n", $user);
            $missing_a_user = 1;
        }

    }

    if ($missing_a_user) {
        exit 7;
    }
}

sub check_groups_exist {
    my @required_groups = shift;

    my $missing_a_group;

    foreach my $group (@required_groups) {
        if (not getgrnam($group)) {
            print Spacewalk::Setup::loc("The group '%s' should exist.\n", $group);
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

    print Spacewalk::Setup::loc("** Database: Shutting down services that may be using DB: [tomcat5, taskomatic, httpd, jabberd, osa-dispatcher, tsdb_local_queue].\n");

    Spacewalk::Setup::system_debug('/sbin/service tomcat5 stop');
    Spacewalk::Setup::system_debug('/sbin/service taskomatic stop');
    Spacewalk::Setup::system_debug('/sbin/service httpd stop');
    Spacewalk::Setup::system_debug('/sbin/service jabberd stop');
    Spacewalk::Setup::system_debug('/sbin/service osa-dispatcher stop');
    Spacewalk::Setup::system_debug('/sbin/service tsdb_local_queue stop');

    print Spacewalk::Setup::loc("** Database: Services stopped.  Clearing DB.\n");

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

        print Spacewalk::Setup::loc("%s%s? ",
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
                print Spacewalk::Setup::loc("'%s' is not a valid response\n", $param);
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

sub print_progress {
    my %params = validate(@_, { init_message => 1,
            log_file_name => 1,
            log_file_size => 1,
            err_message => 1,
            err_code => 1,
            system_opts => 1,
        });

    my $pid = fork();

    # parent process draws hashmarks, child process does the heavy lifting.
    if ($pid) { # parent
        my $childpid;

        my $hashcounter = 0;
        print Spacewalk::Setup::loc($params{init_message});

        do {
            sleep 1;
            print_progress_hashmark_if_needed(\$hashcounter,
                $params{log_file_name},
                $params{log_file_size});
            $childpid = waitpid($pid, WNOHANG);
        } until $childpid > 0;

        my $err = $?;
        if ($err) {
            my $exit_value = $? >> 8;

            print Spacewalk::Setup::loc($params{err_message});
            exit $exit_value;
        }

        print "\n";
    }
    else { # child
        my $ret = system(@{$params{system_opts}});

        if ($ret) {
            exit $params{err_code};
        }

        exit 0;
    }
}

sub print_progress_hashmark_if_needed {
    my $hashcounter_ref = shift;
    my $file = shift;
    my $max_size = shift;

    if (not -r $file) {
        return;
    }

    my @stats = stat $file;

    my $current_size = $stats[7];
    my $target_hashes = int(60 * $current_size / $max_size);

    $| = 1;

    # draw hashmarks until we reach the maximum size.
    while ($$hashcounter_ref < $target_hashes) {
        print "#";
        $$hashcounter_ref++;
    }

    $| = 0;

    return;
}

sub get_database_answers {
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


############################
# PostgreSQL Specific Code #
############################

# Parent PostgreSQL setup function:
sub postgresql_setup_db {
    my $opts = shift;
    my $answers = shift;

    print Spacewalk::Setup::loc("** Database: Setting up database connection.\n");
    my $connected;

    while (not $connected) {
        get_database_answers($opts, $answers);

        my $dbh;

        eval {
            $dbh = get_dbh($answers);
            $dbh->disconnect();
        };
        if ($@) {
            print Spacewalk::Setup::loc("Could not connect to the database.  Your connection information may be incorrect.  Error: %s\n", $@);

            delete @{$answers}{qw/db-protocol db-host db-port db-user db-sid db-password/};
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
            print Spacewalk::Setup::loc("**Database: The database already has schema.  Skipping database population.");
            return 1;
        }
    }

    my $sat_schema_deploy = POSTGRESQL_SCHEMA_FILE;
    my $logfile = DB_POP_LOG_FILE;

    my @opts = ('/usr/bin/rhn-populate-database.pl',
        sprintf('--user=%s', @{$answers}{'db-user'}),
        sprintf('--password=%s', @{$answers}{'db-password'}),
        sprintf('--database=%s', @{$answers}{'db-sid'}),
        sprintf('--host=%s', @{$answers}{'db-host'}),
        sprintf("--schema-deploy-file=$sat_schema_deploy"),
        sprintf("--log=$logfile"),
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
# then re-creating it.
sub postgresql_clear_db {
    my $answers = shift;
    my $dbh = get_dbh($answers);

    # Silence "NOTICE:" lines:
    open STDERR, "| grep -v '^NOTICE:  '"
        or die "Cannot pipe STDERR to grep\n";

    my $sth = $dbh->prepare("DROP SCHEMA public CASCADE");
    $sth->execute;

    close STDERR;

    $sth = $dbh->prepare("CREATE SCHEMA public");
    $sth->execute;
    $sth->finish;

    $sth = $dbh->commit();

    $dbh->disconnect();
    return 1;
}



########################
# Oracle Specific Code #
########################

# Parent Oracle setup function:
sub oracle_setup_db {
    my $opts = shift;
    my $answers = shift;

    oracle_upgrade_setup_oratab($opts);
    oracle_upgrade_start_db($opts);

    print Spacewalk::Setup::loc("* Setting up Oracle environment.\n");

    oracle_check_for_users_and_groups();

    print Spacewalk::Setup::loc("* Setting up database.\n");
    oracle_setup_embedded_db($opts, $answers);
    oracle_setup_db_connection($opts, $answers);
    oracle_test_db_settings($opts, $answers);
    oracle_populate_db($opts, $answers);
}

sub oracle_upgrade_setup_oratab {
    my $opts = shift;

    # 5.2 to 5.3 and beyond upgrades: edit rhnsat entry in /etc/oratab
    if ($opts->{'upgrade'} and Spacewalk::Setup::is_embedded_db()) {
        print Spacewalk::Setup::loc("** Database: setting up /etc/oratab\n");
        if (not -f "/etc/oratab") {
            die Spacewalk::Setup::loc("File /etc/oratab does not exist.\n");
        }
        system('sed -i "s/^rhnsat:\(.\+\):N$/rhnsat:\1:Y/g" /etc/oratab');
    }
}

sub oracle_upgrade_start_db {
    my $opts = shift;
    if (Spacewalk::Setup::is_embedded_db()) {
        if ($opts->{'upgrade'}) {
            Spacewalk::Setup::system_or_exit(['/sbin/service', 'oracle', 'start'], 19,
                'Could not start the oracle database service.');
        }
    }

    return;
}

sub oracle_check_for_users_and_groups {
    if (Spacewalk::Setup::is_embedded_db()) {
        my @required_users = qw/oracle/;
        my @required_groups = qw/oracle dba/;

        Spacewalk::Setup::check_users_exist(@required_users);
        Spacewalk::Setup::check_groups_exist(@required_groups);
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

    if (not Spacewalk::Setup::is_embedded_db()) {
        return 0;
    }

    # create DB_SERVICE entry in /etc/sysconfig/rhn-satellite
    if (! -e Spacewalk::Setup::SATELLITE_SYSCONFIG) {
            open(S, '>>', Spacewalk::Setup::SATELLITE_SYSCONFIG)
                or die Spacewalk::Setup::loc("Could not open '%s' file: %s\n", Spacewalk::Setup::SATELLITE_SYSCONFIG, $!);
            close(S);
    }


    if ($opts->{'upgrade'} and need_oracle_9i_10g_upgrade()) {
        printf loc(<<EOQ, Spacewalk::Setup::DB_UPGRADE_LOG_FILE);
** Database: Upgrading the database server to Oracle 10g:
** Database: This is a long process that is logged in:
** Database: %s
EOQ
        print_progress(-init_message => "*** Progress: #",
                   -log_file_name => Spacewalk::Setup::DB_UPGRADE_LOG_FILE,
                   -log_file_size => Spacewalk::Setup::DB_UPGRADE_LOG_SIZE,
                   -err_message => "Could not upgrade database.\n",
                   -err_code => 15,
                   -system_opts => ['/sbin/runuser', 'oracle', '-c',
                                    '/bin/bash ' . Spacewalk::Setup::SHARED_DIR . '/setup/upgrage-db.sh 1>> ' .  Spacewalk::Setup::DB_UPGRADE_LOG_FILE . ' 2>&1']);

        return 0;
    }

    if ($opts->{"skip-db-install"} || $opts->{"upgrade"}) {
        print Spacewalk::Setup::loc("** Database: Embedded database installation SKIPPED.\n");

        return 0;
    }

    if (-d "/rhnsat/data") {
        my $shared_dir = Spacewalk::Setup::SHARED_DIR . "/setup";
        print Spacewalk::Setup::loc(<<EOQ);
The embedded database appears to be already installed. Either rerun
this script with the --skip-db-install option, or use the
'$shared_dir/oracle/remove-db.sh' script to remove the embedded database and try
again.
EOQ

        exit 13;
    }

    if (not $opts->{"skip-db-diskspace-check"}) {
        Spacewalk::Setup::system_or_exit(['python', Spacewalk::Setup::SHARED_DIR .
            '/setup/embedded_diskspace_check.py'], 14,
            'There is not enough space available for the embedded database.');
    }
    else {
        print Spacewalk::Setup::loc("** Database: Embedded database diskspace check SKIPPED!\n");
    }
    print Spacewalk::Setup::loc(<<EOQ);
** Database: Installing the embedded database (not the schema).
** Database: Shutting down the database first.
EOQ

    Spacewalk::Setup::system_debug('/sbin/service oracle stop');

    printf Spacewalk::Setup::loc(<<EOQ, Spacewalk::Setup::DB_INSTALL_LOG_FILE);
** Database: Installing the database:
** Database: This is a long process that is logged in:
** Database:   %s
EOQ

    print_progress(-init_message => "*** Progress: #",
        -log_file_name => Spacewalk::Setup::DB_INSTALL_LOG_FILE,
		-log_file_size => Spacewalk::Setup::DB_INSTALL_LOG_SIZE,
		-err_message => "Could not install database.\n",
		-err_code => 15,
		-system_opts => [ "/bin/bash " . Spacewalk::Setup::SHARED_DIR . "/setup/oracle/install-db.sh 1>> " . Spacewalk::Setup::DB_INSTALL_LOG_FILE . " 2>&1" ]);

    print Spacewalk::Setup::loc("** Database: Installation complete.\n");

    sleep(5); # We need to sleep because sometimes the database doesn't
            # come back up fast enough.

    return 1;
}

sub oracle_setup_db_connection {
    my $opts = shift;
    my $answers = shift;

    print Spacewalk::Setup::loc("** Database: Setting up database connection.\n");
    my $connected;

    while (not $connected) {
        if (Spacewalk::Setup::is_embedded_db()) {
            $answers->{'db-user'} = 'rhnsat';
            $answers->{'db-password'} = 'rhnsat';
            $answers->{'db-sid'} = 'rhnsat';
            $answers->{'db-host'} = 'localhost';
            $answers->{'db-port'} = 1521;
            $answers->{'db-protocol'} = 'TCP';
        }
        else {
            get_database_answers($opts, $answers);
        }

        my $address = join(",", @{$answers}{qw/db-protocol db-host db-port/});

        Spacewalk::Setup::system_or_exit([ "/usr/bin/rhn-config-tnsnames.pl",
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
            print Spacewalk::Setup::loc("Could not connect to the database.  Your connection information may be incorrect.  Error: %s\n", $@);
            if (Spacewalk::Setup::is_embedded_db() or $opts->{"non-interactive"}) {
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
    my @allowed_db_versions = qw/1110 1020 920/;

    unless (grep { $version == $_ } @allowed_db_versions) {
        print Spacewalk::Setup::loc("Invalid db version: (%s, %s)\n", $v, $c);
        exit 20;
    }

    return 1;
}

sub oracle_test_db_settings {
  my $opts = shift;
  my $answers = shift;

  print Spacewalk::Setup::loc("** Database: Testing database connection.\n");

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
            push @errs, Spacewalk::Setup::loc("User '%s' does not have the '%s' privilege.", $answers->{'db-user'}, $priv);
        }
    }

    if (@errs) {
        print Spacewalk::Setup::loc("Tablespace errors:\n  %s\n", join("\n  ", @errs));
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
        print Spacewalk::Setup::loc("Tablespace '%s' does not appear to exist.\n", $tablespace_name);
    }

    my %expectations = (STATUS => 'ONLINE',
        CONTENTS => 'PERMANENT',
        LOGGING => 'LOGGING',
    );
    my @errs = ();

    foreach my $column (keys %expectations) {
        if ($row->{$column} ne $expectations{$column}) {
            push @errs, Spacewalk::Setup::loc("tablespace %s has %s set to %s where %s is expected",
                $tablespace_name, $column, $row->{$column}, $expectations{$column});
        }
    }

    if (@errs) {
        print Spacewalk::Setup::loc("Tablespace errors: %s\n", join(';', @errs));
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
        print Spacewalk::Setup::loc("Database is using an invalid (non-UTF8) character set: (NLS_CHARACTERSET = %s)\n", $nls_database_parameters{NLS_CHARACTERSET});
        exit 21;
    }

    return 0;
}

sub oracle_populate_db {
    my $opts = shift;
    my $answers = shift;

    print Spacewalk::Setup::loc("** Database: Populating database.\n");

    if ($opts->{"skip-db-population"} || $opts->{"upgrade"}) {
        print Spacewalk::Setup::loc("** Database: Skipping database population.\n");
        return 1;
    }

    my $tablespace_name = oracle_get_default_tablespace_name($answers);

    oracle_populate_tablespace_name($tablespace_name);

    if ($opts->{"clear-db"}) {
        print Spacewalk::Setup::loc("** Database: --clear-db option used.  Clearing database.\n");
        Spacewalk::Setup::clear_db($answers);
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
            print Spacewalk::Setup::loc("** Database: Clearing database.\n");

            Spacewalk::Setup::clear_db($answers);

            print Spacewalk::Setup::loc("** Database: Re-populating database.\n");
        }
        else {
            print Spacewalk::Setup::loc("**Database: The database already has schema.  Skipping database population.");

            return 1;
        }
    }

    my $sat_schema_deploy =
    File::Spec->catfile(DEFAULT_RHN_ETC_DIR, 'universe.deploy.sql');

    my @opts = ('/usr/bin/rhn-populate-database.pl',
        sprintf('--dsn=%s/%s@%s', @{$answers}{qw/db-user db-password db-sid/}),
        "--schema-deploy-file=$sat_schema_deploy",
        '--log=' . Spacewalk::Setup::DB_POP_LOG_FILE,
        '--nofork',
    );

    print_progress(-init_message => "*** Progress: #",
        -log_file_name => Spacewalk::Setup::DB_POP_LOG_FILE,
        -log_file_size => Spacewalk::Setup::DB_POP_LOG_SIZE,
        -err_message => "Could not populate database.\n",
        -err_code => 23,
        -system_opts => [@opts]);

    return 1;
}

sub oracle_populate_tablespace_name {
  my $tablespace_name = shift;

  my $sat_schema = File::Spec->catfile(Spacewalk::Setup::DEFAULT_RHN_ETC_DIR, 'universe.satellite.sql');
  my $sat_schema_deploy =
    File::Spec->catfile(Spacewalk::Setup::DEFAULT_RHN_ETC_DIR, 'universe.deploy.sql');

  Spacewalk::Setup::system_or_exit([ "/usr/bin/rhn-config-schema.pl",
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

  my ($database, $username, $password, $sid, $host, $port) = @{$answers}{qw/db-backend db-user db-password db-sid db-host db-port/};

  my $dbh;
  if ($database eq "oracle") {
      $dbh = DBI->connect("dbi:Oracle:$sid", $username, $password,
          {
              RaiseError => 1,
              PrintError => 0,
              Taint => 0,
              AutoCommit => 0,
          }
      );
  }
  elsif ($database eq "postgresql") {
      $dbh = DBI->connect("DBI:Pg:dbname=$sid;host=$host;port=$port", $username, $password,
          {
              RaiseError => 1,
              PrintError => 0,
              Taint => 0,
              AutoCommit => 0,
          }
      );
  }

  # Bugzilla 466747: On s390x, stty: standard input: Bad file descriptor
  # For some reason DBI mistakenly sets FD_CLOEXEC on a stdin file descriptor
  # here. This made it impossible for us to succesfully call `stty -echo`
  # later in the code. Following two lines work around the problem.

  my $flags = fcntl(STDIN, F_GETFD, 0);
  fcntl(STDIN, F_SETFD, $flags & ~FD_CLOEXEC);

  return $dbh;
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
    print Spacewalk::Setup::loc("No tablespace found for user '%s'\n", $answers->{'db-user'});
    exit 20;
  }

  return $ts;
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

Copyright (c) 2008 Red Hat, Inc.

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
