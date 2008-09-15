package NOCpulse::Probe::DataSource::SQLServer;

use strict;

use Error ':try';
use DBI;
use POSIX 'dup';
use IO::Handle;

use NOCpulse::Probe::Error;

use base qw(NOCpulse::Probe::DataSource::AbstractDatabase);

use Class::MethodMaker
  get_set =>
  [qw(
      dbName
      password
      port
      serverName
      userName
      timeout
      _stderr_restored
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant SS_TABLE_NOT_FOUND => 208;

my %field_map = 
  (
   serverName => 'host',
   port       => 'port',
   userName   => 'username',
   password   => 'password',
   dbName     => 'database',
   timeout    => 'timeout_seconds',
  );


sub init {
    my ($self, %args) = @_;
    return $self->SUPER::init(\%field_map, %args);
}

sub connect {
    my $self = shift;

    $self->_create_temp_interfaces_file();

    $ENV{'SYBASE'} = $self->_interfaces_file_dir();

    my $username = $self->username;
    my $password = $self->password;
    my $host     = $self->host;
    my $port     = $self->port;
    my $database = $self->database;

    # NOTE: the port and database do not go in here. The port comes
    # from the interfaces file, which is created every time the probe
    # is run. The database is "used" so that we can trap specific errors,
    # which DBD::Sybase does not do.
    my $dbd = "Sybase:server=$host";

    try {
        # Certain errors spew to STDERR, so close and reopen it around the connect.
        $Log->log_method(4, "connect", "Redirecting stderr\n");
        $self->_kill_stderr();

        $Log->log_method(4, "connect", "to $host:$port as $username\n");

        $self->SUPER::connect($dbd, PrintError => 0, RaiseError => 0);

        $self->_restore_stderr();

        unless ($self->dbh) {
            $Log->log_method(2, "failed\n");
            my $msg = sprintf($self->_message_catalog->sqlserver('connect_failed'),
                              $host, $port, $username);
            throw NOCpulse::Probe::DbConnectError($msg);

        } elsif ($database) {
            # Connected, now try to get to the right database if one is specified.
            $Log->log_method(4, "connect", "OK, use $database\n");

            $self->dbh->do("use $database");

            if ($DBI::err) {
                $Log->log_method(2, "connect", "Use failed: $DBI::errstr\n");

                # The disconnect raises error 3903: "The ROLLBACK TRANSACTION request has
                # no corresponding BEGIN TRANSACTION" so get the "use" error now.
                my $dbi_code = $DBI::err;
                my $dbi_msg = $self->_clean_dbi_msg();

                $self->dbh->disconnect();

                my $msg;
                if ($dbi_code == 911) {
                    $msg = sprintf($self->_message_catalog->sqlserver('bad_db_name'), 
                                   $database);
                } else {
                    $msg = $dbi_msg;
                }
                throw NOCpulse::Probe::DbInstanceError($msg);
            }
        }
    } finally {
        alarm(0);
        $self->_restore_stderr();
    };
    
    # From here on, raise errors rather than forcing return code checks.
    $self->dbh->{RaiseError} = 1;

    return $self->dbh;
}

sub disconnect {
    my $self = shift;

    $self->SUPER::disconnect();
    $self->_remove_temp_interfaces_file();
}

sub execute {
    my ($self, $sql, $tables_used_arr, $fetch_one, @bind_vars) = @_;

    return $self->SUPER::execute($sql, SS_TABLE_NOT_FOUND,
                                 $tables_used_arr, $fetch_one, @bind_vars);
}

# Returns a sysperfinfo counter value.
sub perf_counter {
    my ($self, $object_name, $counter_name, $instance_name) = @_;

    my $row = $self->fetch_first(qq{
        select cntr_value
        from   master..sysperfinfo
        where  object_name = '$object_name'
        and    counter_name = '$counter_name'
        and    instance_name = '$instance_name'
    }, ['master..sysperfinfo']);
    return $row->{cntr_value};
}

# Returns the result from an sp_configure call.
sub sp_configure {
    my ($self, $name) = @_;
    my $row = $self->fetch_first("sp_configure '$name'");
    return $row->{run_value};
}

sub _kill_stderr {
    my $self = shift;
    open(SUPPRESS_SQLSERVER_STDERR, ">&STDERR")
      or throw NOCpulse::Probe::StderrRedirError("Cannot duplicate stderr: $!");
    open(STDERR, "/dev/null")
      or throw NOCpulse::Probe::StderrRedirError("Cannot redirect stderr to /dev/null: $!");
    $self->_stderr_restored(0);
}

sub _restore_stderr {
    my $self = shift;
    unless ($self->_stderr_restored) {
        open(STDERR, ">&SUPPRESS_SQLSERVER_STDERR\n")
          or throw NOCpulse::Probe::StderrRedirError("Cannot reopen stderr: $!");
        close(SUPPRESS_SQLSERVER_STDERR);
        $self->_stderr_restored(1);
    }
}

sub _interfaces_file_dir {
    my $self = shift;
    return "/tmp/interfaces$$";
}

sub _create_temp_interfaces_file {
    my $self = shift;

    my $dir = $self->_interfaces_file_dir();
    my $file = "$dir/interfaces";

    mkdir $dir, 0777;

    open(MYFILE, ">$file")
      or throw NOCpulse::Probe::InternalError("Cannot open file $file for writing: $?\n");
    my $info = "tds7.0 " . $self->host . " " . $self->port;
    print MYFILE $self->host, "\n";
    print MYFILE "  query tcp $info\n";
    print MYFILE "  master tcp $info\n";
    close(MYFILE)
      or throw NOCpulse::Probe::InternalError("Cannot close the interfaces file $file: $?\n");

    return $dir;
}

sub _remove_temp_interfaces_file {
    my $self = shift;

    my $dir = $self->_interfaces_file_dir();
    my $file = "$dir/interfaces";

    if (-e $dir) {
        unlink($file) || die "Cannot remove file $file: $?\n";
        rmdir($dir) || die "Cannot remove $dir: $?\n";
    }
}

1;

__END__
