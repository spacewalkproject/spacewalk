package Spacewalk::Setup;
require Exporter;

use warnings;
use strict;

use English;

use Exporter 'import';
use vars '@EXPORT_OK';
@EXPORT_OK = qw(loc system_debug system_or_exit postgresql_clear_db);

use Getopt::Long qw(GetOptions);
use Symbol qw(gensym);
use IPC::Open3 qw(open3);
use Pod::Usage qw(pod2usage);
use POSIX ":sys_wait_h";
use Fcntl qw(F_GETFD F_SETFD FD_CLOEXEC);
use Socket;
use Net::LibIDN ();

use Params::Validate qw(validate);
Params::Validate::validation_options(strip_leading => "-");

=head1 NAME

Spacewalk::Setup, spacewalk-setup

=head1 VERSION

Version 1.1

=cut

our $VERSION = '1.1';

use constant SHARED_DIR => "/usr/share/spacewalk/setup";

use constant POSTGRESQL_SCHEMA_FILE => File::Spec->catfile("/etc", "sysconfig", 
    'rhn', 'postgres', 'main.sql');

use constant POSTGRESQL_DEPLOY_FILE => File::Spec->catfile("/etc", "sysconfig",
    'rhn', 'postgres', 'deploy.sql');

use constant DEFAULT_ANSWER_FILE_GLOB =>
  SHARED_DIR . '/defaults.d/*.conf';

use constant DEFAULT_RHN_CONF_LOCATION =>
  '/etc/rhn/rhn.conf';

use constant DEFAULT_UP2DATE_LOCATION =>
  '/etc/sysconfig/rhn/up2date';

use constant DEFAULT_RHN_ETC_DIR =>
  '/etc/sysconfig/rhn';

use constant DEFAULT_SATCON_DICT =>
  '/var/lib/rhn/rhn-satellite-prep/satellite-local-rules.conf';

use constant DEFAULT_RHN_SATCON_TREE =>
  '/var/lib/rhn/rhn-satellite-prep/etc';

use constant DEFAULT_BACKUP_DIR =>
   '/etc/sysconfig/rhn/backup-' . `date +%F-%R`;

use constant INSTALL_LOG_FILE =>
  '/var/log/rhn/rhn_installation.log';

use constant DB_INSTALL_LOG_FILE =>
  '/var/log/rhn/install_db.log';

use constant DB_POP_LOG_FILE =>
  '/var/log/rhn/populate_db.log';

use constant PG_POP_LOG_SIZE => 156503;
use constant ORA_POP_LOG_SIZE => 132243;

use constant RHN_LOG_DIR =>
  '/var/log/rhn';

use constant DB_UPGRADE_LOG_FILE =>
  '/var/log/rhn/upgrade_db.log';

use constant DB_UPGRADE_LOG_SIZE => 22000000;

use constant DB_INSTALL_LOG_SIZE => 11416;

use constant DB_MIGRATION_LOG_FILE =>
  '/var/log/rhn/rhn_db_migration.log';

use constant ORACLE_RHNCONF_BACKUP =>
  '/tmp/oracle-rhn.conf';

use constant EMBEDDED_DB_ANSWERS =>
  '/usr/share/spacewalk/setup/defaults.d/embedded-postgresql.conf';


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
            "external-oracle",
            "external-postgresql",
            "db-only",
            "rhn-http-proxy:s",
            "rhn-http-proxy-username:s",
            "rhn-http-proxy-password:s",
            "managed-db",
		   );

  my $usage = loc("usage: %s %s\n",
		  $0,
		  "[ --help ] [ --answer-file=<filename> ] [ --non-interactive ] [ --skip-system-version-test ] [ --skip-selinux-test ] [ --skip-fqdn-test ] [ --skip-db-install ] [ --skip-db-diskspace-check ] [ --skip-db-population ] [ --skip-gpg-key-import ] [ --skip-ssl-cert-generation ] [--skip-ssl-vhost-setup] [ --skip-services-check ] [ --clear-db ] [ --re-register ] [ --disconnected ] [ --upgrade ] [ --run-updater=<yes|no>] [--run-cobbler] [ --enable-tftp=<yes|no>] [ --external-oracle | --external-postgresql ]" );

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
  local * CONFIG;
  open(CONFIG, '<', $config_file) or die "Could not open $config_file: $!";

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
  my (@skip) = @{(shift)};

  my @files = ();
  foreach my $afile (glob(DEFAULT_ANSWER_FILE_GLOB)) {
      push @files, $afile if not grep $afile, @skip;
  }
  push @files, $options->{'answer-file'} if $options->{'answer-file'};

  for my $file (@files) {

    next unless (-r $file or $file eq $options->{'answer-file'});

    if ($options->{'answer-file'} and $file eq $options->{'answer-file'}) {
      print loc("* Loading answer file: %s.\n", $file);
    }
    local * FH;
    open FH, '<', $file or die loc("Could not open answer file: %s\n", $!);

    while (my $line = <FH>) {
      next if substr($line, 0, 1) eq '#';
      $line =~ /([\w\.-]*)\s*=\s*(.*)/;
      my ($key, $value) = ($1, $2);

      next unless $key;

      $answers->{$key} = $value;
    }

    close FH;
  }
  if ($answers->{'db-host'}) {
    $answers->{'db-host'} = Net::LibIDN::idn_to_ascii($answers->{'db-host'}, "utf8");
  }
  return;
}

# Check if we're installing with an embedded database.
sub is_embedded_db {
  my $opts = shift;
  return not (defined($opts->{'external-oracle'})
           or defined($opts->{'external-postgresql'})
           or defined($opts->{'managed-db'}));
}

sub contains_embedded_oracle {
  foreach my $rpm ('oracle-server-i386', 'oracle-server-x86_64', 'oracle-server-s390x') {
    system("rpm -q $rpm >& /dev/null");
    if ($? >> 8 == 0) {
      return 1;
    }
  }

  return 0;
}

# Return 1 in case setup should also *migrate* from oracle -> postgresql
sub is_db_migration {
	my $opts = shift;

	# We cannot migrate in non-upgrade mode
	return 0 if (not defined $opts->{'upgrade'});
	# We're not migrating, if we're using external oracle db
	return 0 if (defined $opts->{'external-oracle'});

	my %config = ();

	if (-f ORACLE_RHNCONF_BACKUP) {
		read_config(ORACLE_RHNCONF_BACKUP, \%config);
	} else {
		read_config(DEFAULT_RHN_CONF_LOCATION, \%config);
	}

	# Satellite 5.3 and older used default_db -> we know we are on Oracle
	# -> we know we want to migrate to PostgreSQL (no --external-oracle specified)
	return 1 if (exists $config{'default_db'});

	# Satellite 5.4 and beyond used db_backend
	return 1 if (exists $config{'db_backend'} and $config{'db_backend'} eq 'oracle');

	return 0;
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
      die "Single parameter system_debug [@args] not supported.\n";
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
      if (is_embedded_db($opts)) {
        system_or_exit(['/sbin/service', 'rhn-database', 'stop'], 31,
                        'Could not stop the rhn-database service.');
      }
    }
  }
  return 1;
}

my $spinning_callback_count;
my @spinning_pattern = split /\n/, <<EOF;
.               
 .              
  o             
   @            
   (O)          
    (*)         
   ((%%))       
    (( # ))     
   ( ( # ) )    
 (  (  #  )  )  
    (  !  )     
       :        
       .        
       _        
      . .       
    .     .     
                
EOF

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
    local *X; open X, '>', INSTALL_LOG_FILE and close X;
    system('/sbin/restorecon', INSTALL_LOG_FILE);
  }
  log_rotate(DB_INSTALL_LOG_FILE);
  log_rotate(DB_POP_LOG_FILE);

  local * FH;
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

    # The --exclude=oracle is needed for embedded database Satellites.
    system_debug('/usr/sbin/spacewalk-service', '--exclude=oracle', 'stop');

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

	$| = 1;
	my $orig_stdout = select LOGFILE;
	$| = 1;
	select $orig_stdout;
	print loc($params{init_message});
	local *PROCESS_OUT;
	my $progress_hashes_done = 0;
	my $progress_callback_length = 0;
	my $pid = open3(gensym, \*PROCESS_OUT, \*PROCESS_OUT, @{$params{system_opts}});
	while (<PROCESS_OUT>) {
		print LOGFILE $_;
		$progress_callback_length += length;
		if (-t STDOUT and $params{log_file_size}) {
			my $target_hashes = int(60 * $progress_callback_length / $params{log_file_size});
			if ($target_hashes > $progress_hashes_done) {
				print "#" x ($target_hashes - $progress_hashes_done);
				$progress_hashes_done = $target_hashes;
			}
		}
	}
	close PROCESS_OUT;
	waitpid($pid, 0);
	my $ret = $?;
	close LOGFILE;
	print "\n";

	if ($ret) {
		print loc($params{err_message});
		exit $params{err_code};
	}
}

# Format connect data to connect string.
sub _oracle_make_dsn_string {
	my $data = shift;
	if (not (defined $data->{'db-host'} and defined $data->{'db-name'})) {
		return;
	}
	my $dsn = "//$data->{'db-host'}";
	if (defined $data->{'db-port'}) {
		$dsn .= ':' . $data->{'db-port'};
	}
	$dsn .= "/$data->{'db-name'}";
	return $dsn;
}

# We attempt to connect to the database using the current db-* values.
# Returns 0 if could not even connect, 1 if could connect but
# login/password was wrong, and 2 if the connect was fully successful.
sub _oracle_check_connect_info {
	my $data = shift;
	eval {
		my $dbh = get_dbh($data);
		$dbh->disconnect();
	};
	if (not $@) {
		# We were able to connect to the database. Good.
		return 2;
	}
	if (not defined DBI->err()) {	# maybe we failed to load the DBD?
		die $@;
	}
	if (DBI->err() == 1017 or DBI->err() == 1005) {
		# We at least knew the connect string, so we
		# were able to communicate with the database.
		return 1;
	}
	return 0;
}

# Called from oracle_get_database_answers, here we focus on
# at least reaching some instance, not worrying about username
# and password for now.
sub oracle_get_connect_answers {
	my $opts = shift;
	my $answers = shift;

	my $ret;

	my %data;
	$data{'db-backend'} = 'oracle';
	$data{'db-user'} = $answers->{'db-user'};
	$data{'db-password'} = $answers->{'db-password'};

REDO_CONNECT:
	# If the answers hold data that make it possible
	# to create DSN, try it without asking first.
	$data{'db-name'} = _oracle_make_dsn_string($answers);
	if (defined $data{'db-name'}) {
		# Try the direct //host:port/name format.
		if ($ret  = _oracle_check_connect_info(\%data)) {
			# It worked, we shall set it in place of name.
			$answers->{'db-name'} = $data{'db-name'};
			return $ret;
		}
	}

	if (defined $answers->{'db-name'}) {
		# Try just the db-name directly, ignore db-host.
		# This would work if tnsnames.ora already existed.
		if ($ret = _oracle_check_connect_info($answers)) {
			return $ret;
		}
	}

	ask(
		-noninteractive => $opts->{"non-interactive"},
		-question => "Database service name (SID)",
		-test => qr/\S+/,
		-answer => \$answers->{'db-name'}
	);

	# Try the db-name as full connect (ignore host).
	if ($ret = _oracle_check_connect_info($answers)) {
		return $ret;
	}

	$data{'db-name'} = _oracle_make_dsn_string($answers);
	if (not defined $data{'db-name'}) {
		$data{'db-name'} = $answers->{'db-name'};
		$data{'db-host'} = 'localhost';
		$data{'db-name'} = _oracle_make_dsn_string(\%data);
	}
	if (defined $data{'db-name'}) {
		# Try db-name as SID for host (//host:port/name).
		if ($ret  = _oracle_check_connect_info(\%data)) {
			# It worked, we shall set it in place of name.
			$answers->{'db-name'} = $data{'db-name'};
			return $ret;
		}
	}

	ask(
		-noninteractive => $opts->{"non-interactive"},
		-question => "Database hostname",
		-test => qr/\S+/,
		-default => 'localhost',
		-answer => \$answers->{'db-host'});

    $answers->{'db-host'} = Net::LibIDN::idn_to_ascii($answers->{'db-host'}, "utf8");
	$data{'db-name'} = _oracle_make_dsn_string($answers);
	if (defined $data{'db-name'}) {
		# Try db-name as SID for host (//host:port/name).
		if ($ret  = _oracle_check_connect_info(\%data)) {
			# It worked, we shall set it in place of name.
			$answers->{'db-name'} = $data{'db-name'};
			return $ret;
		}
	}

	ask(
		-noninteractive => $opts->{"non-interactive"},
		-question => "Database (listener) port",
		-test => qr/\d+/,
		-default => '1521',
		-answer => \$answers->{'db-port'});

	$data{'db-name'} = _oracle_make_dsn_string($answers);
	if (defined $data{'db-name'}) {
		# Try db-name as SID for host (//host:port/name).
		if ($ret  = _oracle_check_connect_info(\%data)) {
			# It worked, we shall set it in place of name.
			$answers->{'db-name'} = $data{'db-name'};
			return $ret;
		}
	}

	print loc("*** Database connection error: " . DBI->errstr() . "\n") if ($@ and DBI->err());
	if (is_embedded_db($opts) or $opts->{"non-interactive"}) {
		exit 19;
	}

	delete @{$answers}{qw/db-host db-port db-name/};
	goto REDO_CONNECT;
}

sub oracle_get_database_answers {
	my $opts = shift;
	my $answers = shift;

	while (1) {
		my $ret = oracle_get_connect_answers($opts, $answers);
		if ($ret > 1) {
			# Connect info was good, and even username and password were OK.
			return;
		}

		while (1) {
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

			$ret = _oracle_check_connect_info($answers);
			if ($ret > 1) {
				return;
			}
			print loc("*** Database connection error: " . DBI->errstr() . "\n") if ($@ and DBI->err());
			if (is_embedded_db($opts) or $opts->{"non-interactive"}) {
				exit 19;
			}

			if (not $ret) {
				# We won't try username/password, need to go
				# back to connect check loop.
				last;
			}
			delete @{$answers}{qw/db-user db-password/};
		}
		delete @{$answers}{qw/db-host db-port db-name/};
	}
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
        $answers->{'db-host'} = Net::LibIDN::idn_to_ascii($answers->{'db-host'}, "utf8");
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

    if (is_embedded_db($opts)) {
      postgresql_start();
    } else {
      system('sed',
             '-i',
             '-e',
             's/^\\(SERVICES=.*postgresql.*\$\\)/# \\1/g',
             '/etc/rhn/service-list');
    }
    postgresql_setup_embedded_db($opts, $answers);

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

    write_rhn_conf($answers, 'db-backend', 'db-host', 'db-port', 'db-name', 'db-user', 'db-password');
    postgresql_populate_db($opts, $answers);

    if (is_db_migration($opts)) {
        print loc("* Database: Starting Oracle to PostgreSQL database migration.\n");
        migrate_ora2pg($opts, $answers);
    }

    return 1;
}

sub postgresql_start {
    system('service postgresql status >&/dev/null');
    system('service postgresql start >&/dev/null') if ($? >> 8);
    return ($? >> 8);
}

sub postgresql_setup_embedded_db {
    my $opts = shift;
    my $answers = shift;

    if (not is_embedded_db($opts)) {
        return 0;
    }

    if ($opts->{"skip-db-install"} or $opts->{"upgrade"} and not is_db_migration($opts)) {
        print loc("** Database: Embedded database installation SKIPPED.\n");
        return 0;
    }

    if (not -x '/usr/bin/spacewalk-setup-postgresql') {
        print loc(<<EOQ);
The spacewalk-setup-postgresql does not seem to be available.
You might want to use --external-oracle or --external-postgresql command line option.
EOQ
        exit 24;
    }

    if (-d "/var/lib/pgsql/data/base" and
        ! system(qq{/usr/bin/spacewalk-setup-postgresql check --db $answers->{'db-name'}})) {
        my $shared_dir = SHARED_DIR;
        print loc(<<EOQ);
The embedded database appears to be already installed. Either rerun
this script with the --skip-db-install option, or use the
'/usr/bin/spacewalk-setup-postgresql remove --db $answers->{'db-name'} --user $answers->{'db-user'}'
script to remove the embedded database and try again.
EOQ

        exit 13;
    }

    if (not $opts->{"skip-db-diskspace-check"}) {
        system_or_exit(['python', SHARED_DIR .
            '/embedded_diskspace_check.py', '/var/lib/pgsql/data', '12288'], 14,
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
      local *X; open X, '>', DB_INSTALL_LOG_FILE and close X;
      system('/sbin/restorecon', DB_INSTALL_LOG_FILE);
    }
    print_progress(-init_message => "*** Progress: #",
        -log_file_name => DB_INSTALL_LOG_FILE,
		-log_file_size => DB_INSTALL_LOG_SIZE,
		-err_message => "Could not install database.\n",
		-err_code => 15,
		-system_opts => [ "/usr/bin/spacewalk-setup-postgresql",
                                  "create",
                                  "--db", $answers->{'db-name'},
                                  "--user", $answers->{'db-user'},
                                  "--password", $answers->{'db-password'}]);

    print loc("** Database: Installation complete.\n");

    return 1;
}

sub postgresql_populate_db {
    my $opts = shift;
    my $answers = shift;

    print Spacewalk::Setup::loc("** Database: Populating database.\n");

    if ($opts->{"skip-db-population"} or ($opts->{'upgrade'} and not is_db_migration($opts))) {
        print Spacewalk::Setup::loc("** Database: Skipping database population.\n");
        return 1;
    }

    if ($opts->{"clear-db"}) {
        print Spacewalk::Setup::loc("** Database: --clear-db option used.  Clearing database.\n");
        my $dbh = get_dbh($answers);
        postgresql_clear_db($dbh);
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
            my $dbh = get_dbh($answers);
            postgresql_clear_db($dbh);
            print Spacewalk::Setup::loc("** Database: Re-populating database.\n");
        }
        else {
            print Spacewalk::Setup::loc("** Database: The database already has schema.  Skipping database population.\n");
            return 1;
        }
    }

    my $sat_schema = POSTGRESQL_SCHEMA_FILE;
    my $sat_schema_deploy = POSTGRESQL_DEPLOY_FILE;

    system_or_exit([ "/usr/bin/rhn-config-schema.pl",
                   "--source=" . $sat_schema,
                   "--target=" . $sat_schema_deploy,
                   "--tablespace-name=None" ],
                   22,
                   'There was a problem populating the deploy.sql file.',
                   );

    my $logfile = DB_POP_LOG_FILE;

    my @opts = ('spacewalk-sql', '--select-mode-direct', $sat_schema_deploy);

    print_progress(-init_message => "*** Progress: #",
        -log_file_name => Spacewalk::Setup::DB_POP_LOG_FILE,
        -log_file_size => Spacewalk::Setup::PG_POP_LOG_SIZE,
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
	drop schema if exists rpm cascade ;
	drop schema if exists rhn_exception cascade ;
	drop schema if exists rhn_config cascade ;
	drop schema if exists rhn_server cascade ;
	drop schema if exists rhn_entitlements cascade ;
	drop schema if exists rhn_bel cascade ;
	drop schema if exists rhn_cache cascade ;
	drop schema if exists rhn_channel cascade ;
	drop schema if exists rhn_config_channel cascade ;
	drop schema if exists rhn_org cascade ;
	drop schema if exists rhn_user cascade ;
	drop schema if exists logging cascade ;
	drop schema if exists public cascade ;
	create schema public authorization postgres ;
EOS
sub postgresql_clear_db {
	my $dbh = shift;
        my $do_shutdown = (defined($_[0]) ? shift : 1);

        if ($do_shutdown) {
            print loc("** Database: Shutting down spacewalk services that may be using DB.\n");

            # The --exclude=postgresql is needed for embedded database Satellites.
            system_debug('/usr/sbin/spacewalk-service', '--exclude=postgresql', 'stop');
            print loc("** Database: Services stopped.  Clearing DB.\n");
        }

	local $dbh->{RaiseError} = 0;
	local $dbh->{PrintError} = 1;
	local $dbh->{PrintWarn} = 0;
	local $dbh->{AutoCommit} = 1;
	for my $c (split /\n/, $POSTGRESQL_CLEAR_SCHEMA) {
		$dbh->do($c);
	}
	$dbh->disconnect;
	return 1;
}

sub embedded_oracle_start {
  if (-x "/etc/init.d/oracle") {
      system("service oracle start >&/dev/null");
  } else {
      system("runuser", "oracle", "-l", "-c", "lsnrctl start >&/dev/null");
      system("runuser", "oracle", "-l", "-c", "echo startup|ORACLE_SID=rhnsat sqlplus '/ as sysdba' >&/dev/null");
  }
}

sub embedded_oracle_stop {
  if (-x "/etc/init.d/oracle") {
      system("service oracle stop >& /dev/null");
  } else {
      system("runuser", "oracle", "-l", "-c", "lsnrctl stop >&/dev/null");
      system("runuser", "oracle", "-l", "-c",
        "echo shutdown immediate|ORACLE_SID=rhnsat sqlplus '/ as sysdba' >&/dev/null");
  }
}

sub migrate_ora2pg {
  my $opts = shift;
  my $answers = shift;

  # FIXME: Test sufficient disk space for migration

  if (contains_embedded_oracle()) {
    print loc("** Database: Starting embedded Oracle database.\n");
    embedded_oracle_start();
  }

  my $oracle_creds = {
    'db-backend' => 'oracle',
    'db-host' => 'localhost',
    'db-name' => $answers->{'embedded-oracle-name'} || '//localhost:1521/rhnsat.world',
    'db-user' => $answers->{'embedded-oracle-user'} || 'rhnsat',
    'db-password' => $answers->{'embedded-oracle-password'} || 'rhnsat',
    'db-port' => 1521,
  };

  if (-f Spacewalk::Setup::ORACLE_RHNCONF_BACKUP) {
    my %oldOptions = ();
    read_config(Spacewalk::Setup::ORACLE_RHNCONF_BACKUP, \%oldOptions);

    for my $option ('db_backend', 'db_name', 'db_user', 'db_password', 'db_host', 'db_port') {
      (my $db_option = $option) =~ s!_!-!;
      $oracle_creds->{$db_option} = $oldOptions{$option} if (exists $oldOptions{$option});
    }
  }

  print loc("** Database: Trying to connect to Oracle database: ");
  if (_oracle_check_connect_info($oracle_creds) != 2) {
    print loc("failed.\n*** Please make sure you are using correct Oracle database login credentials.\n");
    exit 1;
  } else {
    print loc("succeded.\n");
  }

  print loc("** Database: Migrating data.\n");
  print loc("*** Database: Migration process logged at: " . DB_MIGRATION_LOG_FILE . "\n");
  log_rotate(DB_MIGRATION_LOG_FILE);
  system_or_exit(["/bin/bash", "-c",
	"(set -o pipefail; /usr/bin/spacewalk-dump-schema" .
	" --db=" . $oracle_creds->{'db-name'} .
	" --user=" . $oracle_creds->{'db-user'} .
	" --password=" . $oracle_creds->{'db-password'} . " | spacewalk-sql" .
	" --verbose" .
	" --select-mode-direct" .
	" - ) > " . DB_MIGRATION_LOG_FILE . ' 2>&1'],
	1,
	"*** Data migration failed.");

  print loc("** Database: Data migration successfully completed.\n");

  if (contains_embedded_oracle()) {
    print loc("** Database: Stoping embedded Oracle database.\n");
    embedded_oracle_stop();
  }

  unlink(Spacewalk::Setup::ORACLE_RHNCONF_BACKUP);
}



########################
# Oracle Specific Code #
########################

# Parent Oracle setup function:
sub oracle_setup_db {
    my $opts = shift;
    my $answers = shift;

    print loc("* Setting up Oracle environment.\n");

    oracle_check_for_users_and_groups($opts);

    print loc("* Setting up database.\n");
    oracle_setup_db_connection($opts, $answers);
    oracle_test_db_settings($opts, $answers);
    write_rhn_conf($answers, 'db-backend', 'db-name', 'db-user', 'db-password');
    oracle_populate_db($opts, $answers);
}


sub oracle_check_for_users_and_groups {
    my $opts = shift;
    if (is_embedded_db($opts)) {
        my @required_users = qw/oracle/;
        my @required_groups = qw/oracle dba/;

        check_users_exist(@required_users);
        check_groups_exist(@required_groups);
    }
}

sub oracle_setup_db_connection {
    my $opts = shift;
    my $answers = shift;

    print loc("** Database: Setting up database connection for Oracle backend.\n");
    my $connected;

    while (not $connected) {
        oracle_get_database_answers($opts, $answers);

        my $dbh;

        eval {
            oracle_check_db_version($answers);
        };
        if ($@) {
            print loc("Could not connect to the database.  Your connection information may be incorrect.  Error: %s\n", $@);
            if (is_embedded_db($opts) or $opts->{"non-interactive"}) {
                exit 19;
            }

            delete @{$answers}{qw/db-host db-port db-user db-name db-password/};
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

    my $version = join('.', (split(/\./, $v))[0 .. 2]);
    my @allowed_db_versions = qw/11.2.0 11.1.0 10.2.0/;

    unless (grep { $version eq $_ } @allowed_db_versions) {
        die "Version [$version] is not supported (does not match "
                . join(', ', @allowed_db_versions) . ").\n";
    }

    return 1;
}

sub oracle_test_db_settings {
  my $opts = shift;
  my $answers = shift;

  print loc("** Database: Testing database connection.\n");

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

    my @opts = ('spacewalk-sql', '--select-mode-direct', $sat_schema_deploy);

    if (have_selinux()) {
      local *X; open X, '>', DB_POP_LOG_FILE and close X;
      system('/sbin/restorecon', DB_POP_LOG_FILE);
    }
    print_progress(-init_message => "*** Progress: #",
        -log_file_name => DB_POP_LOG_FILE,
        -log_file_size => ORA_POP_LOG_SIZE,
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
                my $dbh = DBI->connect("dbi:Oracle:$answers->{'db-name'}",
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
	local * FH;
	open(FH, '-|', "/usr/bin/rhn-generate-pem.pl $opts")
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

sub update_monitoring_scout {
	# This routine fixes monitoring problem described in bug #511052
	# Earlier Satellites (3.7) set rhn_sat_node.ip and rhn_sat_cluster.vip
	# to '127.0.0.1' during installation / monitoring activation. These
	# values need to be set to ip address of satellite for
	# MonitoringAccessHandler.pm to operate properly.

	my $opts = shift;
	my $answers = shift;

	return unless ($opts->{'upgrade'});

	my $host = gethostbyname($answers->{'hostname'});
	my $ip_addr = inet_ntoa($host);

	my $dbh = get_dbh($answers);

	# If IP address for satellite / spacewalk scout was set to 127.0.0.1, it needs to be updated
	my $sql1 = q{
		update rhn_sat_node
			set ip = ?,
			last_update_user = 'upgrade',
			last_update_date = current_timestamp
		where ip = '127.0.0.1' and
			recid = 2};

	my $sql2 = q{
		update rhn_sat_cluster
			set vip = ?,
			last_update_user = 'upgrade',
			last_update_date = current_timestamp
		where vip = '127.0.0.1' and
			recid = 1};

	# If IP address for satellite / spacewalk scout was not set, it needs to be updated
	my $sql3 = q{
		update rhn_sat_node
			set ip = ?,
			last_update_user = 'upgrade',
			last_update_date = current_timestamp
		where ip is null and
			recid = 2};

	my $sql4 = q{
		update rhn_sat_cluster
			set vip = ?,
			last_update_user = 'upgrade',
			last_update_date = current_timestamp
		where vip is null and
			recid = 1};

	$dbh->do($sql1, {}, ($ip_addr));
	$dbh->do($sql2, {}, ($ip_addr));
	$dbh->do($sql3, {}, ($ip_addr));
	$dbh->do($sql4, {}, ($ip_addr));

	$dbh->commit;
	$dbh->disconnect;
}

sub update_monitoring_ack_enqueuer {
	my $opts = shift;
	my $answers = shift;

	return unless ($opts->{'upgrade'});

	my $l = '/etc/smrsh/ack_enqueuer.pl';
	my $t = '/usr/bin/ack_enqueuer.pl';

	# '/opt/notification/scripts/ack_enqueuer.pl' was the old location
	# '/usr/bin/ack_enqueuer.pl' is the new location
	if (-l $l && readlink($l) eq '/opt/notification/scripts/ack_enqueuer.pl') {
		unlink($l);
		symlink($t, $l);
	}
}

# Write subset of $answers to /etc/rhn/rhn.conf.
sub write_rhn_conf {
	my $answers = shift;

	my $rhnconf = DEFAULT_RHN_CONF_LOCATION;
	local *RHNCONF;
	open RHNCONF, '>', $rhnconf or die "Error writing [$rhnconf]: $!\n";
	for my $n (@_) {
		if (defined $answers->{$n}) {
			my $name = $n;
			$name =~ s!-!_!g;
			print RHNCONF "$name = $answers->{$n}\n";
		}
	}
	close RHNCONF;
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

For the installation and setup to proceed properly, SELinux should
be in Permissive or Enforcing mode. If you are certain that
you are not in Disabled mode or you want to install in
Disabled anyway, re-run the installer with the flag --skip-selinux-test.

=item B<--skip-fqdn-test>

Do not verify that the system has a valid hostname.  Red Hat Satellite
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

=item B<--external-oracle>

Assume the Red Hat Satellite installation uses an external Oracle database (Red Hat Satellite only).

=item B<--external-postgresql>

Assume the Red Hat Satellite installation uses an external PostgreSQL database (Red Hat Satellite only).

=item B<--managed-db>

Setup PostgreSQL database for multi-server installation (database and Spacewalk / Red Hat Satellite on different machines).

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

Copyright (c) 2008--2014 Red Hat, Inc.

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
