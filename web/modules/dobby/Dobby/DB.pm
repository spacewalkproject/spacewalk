#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

use strict;
package Dobby::DB;
use RHN::DB;
use PXT::Config;
use Dobby::Log;

use IO::Select ();
use IPC::Open2 ();

use Carp qw/carp croak/;

use File::Spec::Functions;
use IO::Handle;

sub new {
  my $class = shift;

  my $self = bless { }, $class;

  return $self;
}

sub config {
  my $self = shift;

  return $self->{config} if $self->{config};

  $self->{config} = new PXT::Config("dobby");
  return $self->{config};
}

sub DESTROY {
  my $self = shift;

  $self->{sysdbh}->disconnect if $self->{sysdbh};
  $self->{dbh}->disconnect if $self->{dbh};
}

sub sid {
  my $self = shift;

  # maybe make this smarter someday
  return $self->config->get('sid');
}

sub database_started {
  my $self = shift;

  my $dbh = eval { $self->sysdba_connect };
  return $dbh ? 1 : 0;
}

sub data_dir {
  my $self = shift;

  return sprintf($self->config->get("data_dir_format"), $self->sid);
}

sub archive_log_dir {
  my $self = shift;

  return sprintf($self->config->get("archive_dir_format"), $self->sid);
}

sub oracle_homedir_relative {
  my $self = shift;
  my $path = shift;

  my @pwent = getpwuid($>);

  return File::Spec->catfile($pwent[7], $path);
}

sub sp_file {
  my $self = shift;

  return $self->oracle_homedir_relative("config/10.2.0/spfilerhnsat.ora");
}

sub lk_file {
  my $self = shift;

  return $self->oracle_homedir_relative("config/10.2.0/lkRHNSAT");
}

sub tablespaces {
  my $self = shift;
  my $ts = shift;

  my $dbh = $self->sysdba_connect;
  my $sth = $dbh->prepare(<<EOS);
select tablespace_name NAME, contents TYPE from dba_tablespaces
EOS
  $sth->execute;

  return $sth->fullfetch_hashref;
}

sub tablespace_datafiles {
  my $self = shift;
  my $ts = shift;

  my $dbh = $self->sysdba_connect;

  my $sth = $dbh->prepare(<<EOS);
select file_name FILENAME, status STATUS, bytes BYTES,
       'DATAFILE' filetype
  from dba_data_files
  where tablespace_name = :ts
union
select file_name FILENAME, status STATUS, bytes BYTES,
       'TEMPFILE' filetype
  from dba_temp_files
  where tablespace_name = :ts
order by filename
EOS
  $sth->execute_h(ts => $ts);
  return $sth->fullfetch_hashref;
}

sub tablespace_extend {
  my $self = shift;
  my $ts = shift;
  my $ft = shift;
  my $fn = shift;
  my $sz = shift;

  my $dbh = $self->sysdba_connect;
  $dbh->do("ALTER TABLESPACE $ts ADD $ft '$fn' SIZE $sz REUSE");
}

sub report_database_stats {
  my $self = shift;

  my $stats = {
        stale => 0,
        empty => 0,
  };
  my $dbh = $self->connect;

  my $sth = $dbh->prepare(<<RSTATS);
declare
  objs dbms_stats.objecttab;
begin
  dbms_stats.gather_schema_stats(NULL, options=>'LIST STALE', objlist=>objs);
  :stale := objs.count();
  dbms_stats.gather_schema_stats(NULL, options=>'LIST EMPTY', objlist=>objs);
  :empty := objs.count();
end;
RSTATS
  $sth->bind_param_inout(':stale', \$stats->{stale}, 16);
  $sth->bind_param_inout(':empty', \$stats->{empty}, 16);
  $sth->execute();
  
  return $stats;
}

sub gather_database_stats {
  my $self = shift;
  my $pct  = shift;

  my $dbh = $self->connect;
  $dbh->do("begin dbms_stats.gather_schema_stats(NULL, ESTIMATE_PERCENT=> $pct, DEGREE=>DBMS_STATS.DEFAULT_DEGREE, CASCADE=>TRUE); end;");
}

sub segadv_runtask {
  my $self = shift;

  my $dbh = $self->connect;

  my $query = <<EOQ;
DECLARE
  taskname VARCHAR2(100) := 'SAT-SEGADV-' || to_char(sysdate, 'YYYYMMDDHH24MISS');
  tbsname VARCHAR2(30);
  task_id NUMBER;
  oid NUMBER;
BEGIN
  select default_tablespace into tbsname from user_users;
  DBMS_ADVISOR.CREATE_TASK('Segment Advisor', task_id, taskname, NULL, NULL);
  DBMS_ADVISOR.CREATE_OBJECT(taskname, 'TABLESPACE', tbsname, ' ', ' ', NULL, oid);
  DBMS_ADVISOR.SET_TASK_PARAMETER(taskname, 'RECOMMEND_ALL', 'TRUE');
  DBMS_ADVISOR.RESET_TASK(taskname);
  DBMS_ADVISOR.EXECUTE_TASK(taskname);
END;
EOQ

  my $sth = $dbh->do($query);
}

sub shrink_segment {
  my $self = shift;
  my $seg  = shift;

  my $query;

  if ($seg->{SEGMENT_TYPE} eq 'TABLE') {
    $query = sprintf("alter table %s.%s shrink space",
                     @$seg{qw/SEGMENT_OWNER SEGMENT_NAME/});
  } elsif ($seg->{SEGMENT_TYPE} eq 'INDEX') {
    $query = sprintf("alter index %s.%s shrink space",
                     @$seg{qw/SEGMENT_OWNER SEGMENT_NAME/});
  } else {
    printf "ERROR: do not know how to shrink %s %s.%s\n",
            @$seg{qw/SEGMENT_TYPE SEGMENT_OWNER SEGMENT_NAME/};
    return -1;
  }
  my $dbh = $self->connect;
  $dbh->do($query);
}

sub listener_startup {
  my $self = shift;

  # ugly, but not much we really can do anyway; if it fails, it fails.
  # Unpleasant, though.
  my $lsnrctl = catfile($self->config->get("oracle_home"), 'bin', 'lsnrctl');
  system("$lsnrctl start &> /dev/null");
}

sub listener_shutdown {
  my $self = shift;

  # ditto comment above
  my $lsnrctl = catfile($self->config->get("oracle_home"), 'bin', 'lsnrctl');
  system("$lsnrctl stop &> /dev/null");
}

sub database_startup {
  my $self = shift;
  my $mode = shift;

  $self->assert_local;
  if ($mode) {
    $mode = uc $mode;
  }
  else {
    $mode = '';
  }

  $self->sqlplus_nolog("STARTUP $mode");
}

sub database_shutdown {
  my $self = shift;
  my $mode = shift;

  $self->assert_local;
  if ($mode) {
    $mode = uc $mode;
  }
  else {
    $mode = '';
  }

  $self->sqlplus_nolog("SHUTDOWN $mode");
}

sub sqlplus_nolog {
  my $self = shift;
  my @commands = @_;

  $self->assert_local;

  Dobby::Log->log("Connecting via sqlplus as sysdba...");

  $ENV{ORACLE_SID} = $self->config->get("sid");
  $ENV{ORACLE_HOME} = $self->config->get("oracle_home");

  my $sqlplus = catfile($self->config->get("oracle_home"), 'bin', 'sqlplus');
  my($chld_out, $chld_in);
  my $pid = IPC::Open2::open2($chld_out, $chld_in, $sqlplus, '-S', '/nolog');
  my $rs = IO::Select->new($chld_out);
  my $ws = IO::Select->new($chld_in);
  my $es = IO::Select->new($chld_out, $chld_in);
  while ($rs->handles and $ws->handles
         and my ($rds, $wrs, $errs) = IO::Select->select($rs, $ws, $es)) {
    if (defined $errs and @$errs) {
      for my $e (@$errs) {
        $es->remove($e);
        $e->close;
      }
    }
    elsif (defined $rds and @$rds) {
      my $buffer = '';
      sysread $rds->[0], $buffer, 1024;
      if (length($buffer) == 0) {
        $rs->remove($rds->[0]);
      } else {
        Dobby::Log->log("    read: $buffer");
      }
    }
    elsif (defined $wrs and @$wrs) {
      if (@commands) {
        my $command = shift @commands;
        Dobby::Log->log("    sent: $command");
        $wrs->[0]->print("CONNECT / AS SYSDBA\n");
        $wrs->[0]->print("$command\n");
      } else {
        $wrs->[0]->print("EXIT\n");
        $ws->remove($wrs->[0]);
        $wrs->[0]->close;
      }
    }
  }

  Dobby::Log->log("Completed sqlplus conversation");
}

sub connect {
  my $self = shift;

  return $self->{dbh} if $self->{dbh};

  my %params = (RaiseError => 1,
		PrintError => 0,
		AutoCommit => 0);

  $ENV{ORACLE_SID} = $self->config->get("sid");
  $ENV{ORACLE_HOME} = $self->config->get("oracle_home");
  my $dbi_str = "dbi:Oracle:";
  $dbi_str .= $self->config->get("remote_dsn") if $self->config->get("remote_dsn");

  my $dbh = RHN::DB->direct_connect($dbi_str,
				    $self->config->get("normal_username"),
				    $self->config->get("normal_password"),
				    \%params);

  $self->{dbh} = $dbh;
  return $dbh;
}

sub instance_state {
  my $self = shift;
  # ORA-01033 -- startup/shutdown in progress (mounted but not open)
  # ORA-01089 -- immediate startup/shutdown in progress (shutdown in progress)
  # ORA-01034 -- oracle not available

  my $dbh = eval { $self->sysdba_connect };
  $dbh->disconnect if $dbh;
  delete $self->{sysdbh};
  my $err = RHN::DB->err;

  if (not $err) {
    return "OPEN";
  }

  my %states = (1033 => "MOUNTED",
		1089 => "STOPPING",
		1034 => "OFFLINE");

  croak "Unknown error code $err " . RHN::DB->errstr if not exists $states{$err};

  return $states{$err};
}

sub sysdba_connect {
  my $self = shift;

  return $self->{sysdbh} if $self->{sysdbh};

  $ENV{ORACLE_SID} = $self->config->get("sid");
  $ENV{ORACLE_HOME} = $self->config->get("oracle_home");

  my %params = (RaiseError => 1,
		PrintError => 0,
		AutoCommit => 0,
		ora_session_mode => 2);  # ora_session_mode: OCI_SYSDBA

  my $dbi_str = "dbi:Oracle:";
  if ($self->config->get("remote_dsn")) {
    $dbi_str .= $self->config->get("remote_dsn");
    delete $params{ora_session_mode};
  }

  # this is a terrible workaround for a bug in DBI.  When doing
  # ora_session_mode commits with DBI 1.37 and DBD-Oracle 1.14, there
  # is a place in the connect call that drh->errstr is undefined.  DBI
  # then concats this string with a general error string.  Result is a
  # bizarre spurious warning.  To get around it, we muffle it with a
  # locally defined __WARN__ "signal" handler.  Truly terrible, but necessary.

  local $SIG{__WARN__} = sub {
    my $str = shift;
    if ($str =~ /Use of uninitialized value in concatenation/) {
      # nop -- hide this error
    }
    else {
      warn "X: $str";
    }
  };

  my $dbh = RHN::DB->direct_connect($dbi_str,
				    $self->config->get("sysdba_username"),
				    $self->config->get("sysdba_password"),
				    \%params);

  $self->{sysdbh} = $dbh;
  return $dbh;
}

sub assert_local {
  my $self = shift;

  croak"attempt to perform local-only operation on remote dobby db"
    if $self->config->get("remote_dsn");
}

1;
