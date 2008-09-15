package NOCpulse::Probe::DataSource::Oracle;

use strict;

use Error ':try';
use DBI;
use DBD::Oracle;

use NOCpulse::Probe::Error;

use base qw(NOCpulse::Probe::DataSource::AbstractDatabase);

use Class::MethodMaker
  get_set => 
  [qw(
      use_tnsnames
      ORACLE_HOME
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant ORA_TABLE_NOT_FOUND => 942;

my %field_map = 
  (
   ora_host     => 'host',
   ora_port     => 'port',
   ora_user     => 'username',
   ora_password => 'password',
   ora_sid      => 'database',
   timeout      => 'timeout_seconds',
   ORACLE_HOME  => 'ORACLE_HOME',
   use_tnsnames => 'use_tnsnames',
  );

sub init {
    my ($self, %args) = @_;
    return $self->SUPER::init(\%field_map, %args);
}

sub connect {
    my $self = shift;

    # DBD-Oracle warns if there's no ORACLE_HOME, so make sure it's there
    $ENV{ORACLE_HOME} = $self->ORACLE_HOME || '/home/oracle/OraHome1';
    my $host = $self->host;
    my $port = $self->port;
    my $sid  = $self->database;

    my $connect_to;
    
    if ($self->use_tnsnames) {
        $connect_to = $sid;
    } else {
        $connect_to = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)" .
                      "(HOST=$host)(PORT=$port))(CONNECT_DATA=(SID=$sid)))";
    }
    $connect_to
      or throw NOCpulse::Probe::InternalError("Connection information not provided\n");
    $Log->log(2, "connecting with $connect_to\n");

    try {
        $self->SUPER::connect("Oracle:$connect_to", RaiseError => 1);

    } catch NOCpulse::Probe::DbTimedOutError with {
        my $err = shift;
        throw $err;

    } catch NOCpulse::Probe::InternalError with {
        my $err = shift;
        throw $err;

    } otherwise {
        my $err = shift;
        my $msg;
        my $msgcat = $self->_message_catalog;

        my $dbi_msg = $self->_clean_dbi_msg();
        
        if ($DBI::err == 1017) {
            $msg = sprintf($msgcat->oracle('login_failed'), $sid, $self->username, $dbi_msg);
            throw NOCpulse::Probe::DbLoginError($msg);

        } elsif ($DBI::err == 12505) {
            $msg = sprintf($msgcat->oracle('bad_sid'), $sid, $dbi_msg);
            throw NOCpulse::Probe::DbInstanceError($msg);

        } elsif ($DBI::err == 12541) {
            $msg = sprintf($msgcat->oracle('connect_failed'), $sid, $host, $port, $dbi_msg);
            throw NOCpulse::Probe::DbPortError($msg);

        } elsif ($DBI::err == 12545) {
            $msg = sprintf($msgcat->oracle('connect_failed'), $sid, $host, $port, $dbi_msg);
            throw NOCpulse::Probe::DbHostError($msg);

        } elsif ($DBI::err) {
            throw NOCpulse::Probe::Error($dbi_msg);

        } else {
            throw NOCpulse::Probe::InternalError($err);
        }
    };

    return $self->dbh;
}

sub execute {
    my ($self, $sql, $tables_used_arr, $fetch_one, @bind_vars) = @_;

    return $self->SUPER::execute($sql, ORA_TABLE_NOT_FOUND,
                                 $tables_used_arr, $fetch_one, @bind_vars);
}

1;

__END__
