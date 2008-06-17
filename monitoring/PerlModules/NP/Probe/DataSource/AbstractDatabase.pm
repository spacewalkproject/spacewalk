package NOCpulse::Probe::DataSource::AbstractDatabase;


use strict;

use Error ':try';
use DBI;

use NOCpulse::Probe::Error;

use base qw(NOCpulse::Probe::DataSource::AbstractDataSource);

use Class::MethodMaker
  get_set =>
  [qw(
      host
      port
      username
      password
      database
      timeout_seconds
      dbh
      sth
     )],
  new_with_init => 'new',
  ;

use Exporter;
use vars qw (@ISA @EXPORT_OK %EXPORT_TAGS);
use base qw(Exporter);
@EXPORT_OK = qw(constants FETCH_ARRAYREF FETCH_SINGLE FETCH_ROWCOUNT);
%EXPORT_TAGS = (constants => [qw(FETCH_ARRAYREF FETCH_SINGLE FETCH_ROWCOUNT)]);

use constant FETCH_ARRAYREF => 0;
use constant FETCH_SINGLE   => 1;
use constant FETCH_ROWCOUNT => 2;


my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

# Uses the field map to convert incoming parameters to the
# canonical field names.
sub init {
    my ($self, $field_map_hashref, %args) = @_;

    my %connect_args;
    foreach my $field (keys %$field_map_hashref) {
        $connect_args{$field_map_hashref->{$field}} = $args{$field};
    }
    return $self->SUPER::init(%connect_args);
}

sub connect {
    my ($self, $dbd, %attrs) = @_;

    my $username = $self->username;
    my $password = $self->password;
    my $host     = $self->host;
    my $port     = $self->port;
    my $database = $self->database;

    $port     or throw NOCpulse::Probe::InternalError("No port specified");
    $username or throw NOCpulse::Probe::InternalError("No username specified");
    $password or throw NOCpulse::Probe::InternalError("No password specified");

    exists $attrs{AutoCommit} or $attrs{AutoCommit} = 0;
    exists $attrs{RaiseError} or $attrs{RaiseError} = 1;
    exists $attrs{PrintError} or $attrs{PrintError} = 0;
    exists $attrs{ChopBlanks} or $attrs{ChopBlanks} = 1;

    $Log->log(2, "to $dbd\n");

    local $SIG{'ALRM'} = sub { 
        $self->timed_out(1);
        my $msg = sprintf($self->_message_catalog->database('connect_timed_out'),
                          $database, $host, $port, $self->timeout_seconds);
        throw NOCpulse::Probe::DbTimedOutError($msg);
    };
    alarm($self->timeout_seconds);

    try {
        $self->dbh(DBI->connect("dbi:$dbd", $username, $password, \%attrs));
        alarm(0);

        if ($self->dbh) {
            $Log->log_method(2, "connect", "OK\n");
        } else {
            $Log->log_method(2, "connect", "failed (no handle returned)\n");
        }
    } otherwise {
        alarm(0);
        my $err = shift;
        $Log->log_method(2, "connect", "failed: $err\n");
        throw $err;
    };
    return $self->dbh;
}

sub disconnect {
    my $self = shift;

    if ($self->connected()) {
        $self->dbh->rollback();
        $self->dbh->disconnect();
    }
}

sub connected {
    my $self = shift;

    return $self->dbh && $self->dbh->{Active};
}

sub commit {
    my $self = shift;

    return $self->dbh && $self->dbh->commit();
}

sub rollback {
    my $self = shift;

    return $self->dbh && $self->dbh->rollback();
}

sub fetch {
    my ($self, $sql, $tables_used_arr, @bind_vars) = @_;
    return $self->execute($sql, $tables_used_arr, 0, @bind_vars);
}

sub fetch_first {
    my ($self, $sql, $tables_used_arr, @bind_vars) = @_;
    return $self->execute($sql, $tables_used_arr, 1, @bind_vars);
}

sub execute {
    my ($self, $sql, $table_not_found_code, $tables_used_arr, $fetch_mode, @bind_vars) = @_;

    $self->connected()
      or throw NOCpulse::Probe::InternalError($self->_message_catalog->database('not_connected'));

    $Log->log(2, "$sql\n");
    if (scalar(@bind_vars)) {
        $Log->log(2, "bind vars: '", join("', '", @bind_vars), "'\n");
    }

    local $SIG{'ALRM'} = sub { 
        $self->timed_out(1);
        my $msg = sprintf($self->_message_catalog->database('select_timed_out'),
                          $self->timeout_seconds);
        throw NOCpulse::Probe::DbTimedOutError($msg);
    };
    alarm($self->timeout_seconds);

    my $sth;

    $Log->log(2, "prepare and execute\n");

    try {
        $sth = $self->dbh->prepare($sql);
	$self->sth($sth);
        $sth->execute(@bind_vars);
        alarm(0);

    } catch NOCpulse::Probe::DbTimedOutError with {
        alarm(0);
        $Log->log(2, "timed out\n");
        my $err = shift;
        throw $err;

    } otherwise {
        alarm(0);
        my $err = shift;

        my $query = $sql;
        @bind_vars and $query .= ' with ' . join(', ', @bind_vars);

        $Log->log(2, "failed: $err, $query\n");

        if ($DBI::err == $table_not_found_code) {
            my $msg = $self->_format_table_error($tables_used_arr, $query);
            throw NOCpulse::Probe::DbTableNotFoundError($msg);
        } elsif ($DBI::err) {
            my $msg = sprintf($self->_message_catalog->database('select_failed'),
                              $DBI::err, $query, $self->_clean_dbi_msg());
            throw NOCpulse::Probe::InternalError($msg);
        } else {
            throw NOCpulse::Probe::InternalError($err);
        }
    };
    alarm(0);

    my $arrayref = [];

    if ($sth->{NUM_OF_FIELDS}) {
        # Passing an empty hashref returns results as hashrefs instead of arrays.
        $arrayref = $sth->fetchall_arrayref({ });
        $Log->log(2, "fetched ", scalar(@$arrayref), " rows\n");
    } else {
        $Log->log(2, "fetched no rows\n");
    }

    $sth->finish();

    $self->results($arrayref);

    if ($fetch_mode == 0) {
        return $arrayref;
    } elsif ($fetch_mode == 1) {
        return scalar(@$arrayref) > 0 ? $arrayref->[0] : undef;
    } elsif ($fetch_mode == 2) {
        return $sth->rows();
    }
}

# If the tables used in this query are specified, returns a formatted
# message reporting that they should be selectable. Otherwise returns
# query and DBI error message.
sub _format_table_error {
    my ($self, $tables_used_arr, $query) = @_;
    $tables_used_arr = [$tables_used_arr] unless (ref($tables_used_arr));

    my $msg;

    if ($tables_used_arr) {
        my $tables_str;
        my $num_used = scalar @$tables_used_arr;
        if ($num_used > 1) {
            $tables_str = join(', ', @$tables_used_arr[0 .. $num_used-2]);
            if ($num_used > 2) {
                $tables_str .= ',';
            }
            $tables_str .= ' and ' . @$tables_used_arr[-1];
        } else {
            $tables_str = $tables_used_arr->[0];
        }                    
        $msg = sprintf($self->_message_catalog->database('may_need_grant'),
                       $self->username, $tables_str);
    } else {
        $msg = "$query\n" . $self->_clean_dbi_msg();
    }
    return $msg;
}

sub _clean_dbi_msg {
    my $self = shift;
    my $dbi_msg = $DBI::errstr;
    $dbi_msg =~ s/ \(DBD ERROR: .*$//;
    return $dbi_msg;
}

1;

__END__
