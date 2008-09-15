######################################
package NOCpulse::TelAlert;
######################################

use vars qw($VERSION);
$VERSION = (split(/\s+/,
     q$Id: TelAlert.pm,v 1.56 2002-06-17 22:43:30 kjacqmin Exp $,
     4))[2];

use strict;
use Data::Dumper; # for debugging
use DBI;
use DBD::Oracle;
use FreezeThaw qw(freeze thaw);
use IO::File;
use Sys::Hostname;
use GDBM_File;
use NOCpulse::Debug;
use NOCpulse::Config;

# Globals
my $cfg      = new NOCpulse::Config;
my $DBD      = $cfg->get('cf_db', 'dbd');
my $DBNAME  = $cfg->get('cf_db', 'name');
my $DBUNAME = $cfg->get('cf_db', 'notification_username');
my $DBPASS  = $cfg->get('cf_db', 'notification_password');
$ENV{'TELALERTBIN'}     = $cfg->get('telalert', 'bin');
my $TELALERTBIN = $ENV{'TELALERTBIN'};
$ENV{'TELALERTCFG'}     = $cfg->get('telalert', 'cfg');
$ENV{'TELALERTDIR'}     = $cfg->get('telalert', 'dir');
$ENV{'TELALERTTMP'}     = $cfg->get('telalert', 'tmp');
$ENV{'TELALERTHOME'}   = $cfg->get('telalert', 'home');
$ENV{'ORACLE_HOME'}     = $cfg->get('oracle', 'ora_home');

my $DEFAULTDATEFORMAT  = 'MM-DD-YYYY HH24:MI:SS';

my $TELALERTCONFIGFILE = "telalert.ini";

# backups for db down state
my $CONTACT_FORMAT_FILE     = $ENV{'TELALERTCFG'} . "/NOCpulse/config/generated/contact_to_format.gdbm";
my $FORMAT_FILE             = $ENV{'TELALERTCFG'} . "/NOCpulse/config/generated/message_formats.gdbm";
my $REDIRECT_FILE           = $ENV{'TELALERTCFG'} . "/NOCpulse/config/generated/redirects.gdbm";
my $CUSTOMER_REDIRECT_FILE  = $ENV{'TELALERTCFG'} . "/NOCpulse/config/generated/customer_redirects.gdbm";
my $TELALERTS_FILE          = $ENV{'TELALERTCFG'} . "/NOCpulse/config/generated/telalerts.gdbm";

# Table cache for load_table
my %TABLE;

###############################################
# Misc. Methods
###############################################


#----------------------------------------------
sub new   {

  my ($class) = @_;
  my $self  = {};
  bless $self, $class;

  # Default values
  $self->dateformat($DEFAULTDATEFORMAT);
  $self->ticketcount(0);
  $self->tablecache(1);
  $self->timeout(90);

  return $self;
}


# Accessor methods
sub connected    { shift->_elem('connected',    @_); }
sub dateformat  { shift->_elem('dateformat',  @_); }
sub dbh          { shift->_elem('dbh',          @_); }
sub ip          { shift->_elem('ip',          @_); }
sub serverid    { shift->_elem('serverid',    @_); }
sub tablecache  { shift->_elem('tablecache',  @_); }
sub ticketcount { shift->_elem('ticketcount', @_); }
sub timeout     { shift->_elem('timeout',     @_); }


sub nextticket {
  my $self = shift;

  my $ticketcount = $self->ticketcount();
  $self->ticketcount($ticketcount + 1);

  return $ticketcount;
}


# Stolen from LWP::MemberMixin
sub _elem
{
  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}


#----------------------------------------------
sub connect   {

  # Usage:
  # my $telalert = new NOCpulse::TelAlert;
  # $telalert->connect ( 'PrintError'=>0, 'RaiseError'=>0, 'AutoCommit'=>0 );

  my ($self, %paramHash) = @_;

  my $PrintError = $paramHash{PrintError} || 0;
  my $RaiseError = $paramHash{RaiseError} || 0;
  my $AutoCommit = $paramHash{AutoCommit} || 0;


  # Open a connection to the DB
  my $dbh = DBI->connect("DBI:$DBD:$DBNAME", $DBUNAME, $DBPASS, { RaiseError => $RaiseError, AutoCommit => $AutoCommit });

  if ($dbh) {
    # Remember dbh
    $self->dbh($dbh);
    $self->connected(1);
  }
  else { $@ = $DBI::errstr ;  return undef }

  return $self;

}

#----------------------------------------------
sub disconnect  {

  my ($self) = @_;
  my $status = 1;

  # Close the connection to the DB
  if($self->connected()) {
    $self->dbh->disconnect;
  }
  $self->connected(0);

}

#----------------------------------------------
sub commit  {

  my ($self) = @_;

  # Commit changes to the database
  if($self->connected()) {
    $self->dbh->commit || return (1,$self->dbh->errstr);
  } else {
   return (1,"database not connected")
  }
  return (0)
}

#----------------------------------------------
sub rollback  {

  my ($self) = @_;

  # Roll back changes to the database
  if($self->connected()) {
    $self->dbh->rollback;
  }

}

#----------------------------------------------
sub dbexecute {

  my ($self, $sql_statement, @bindvars) = @_;

  my $errcode=0;
  my $errstring="SUCCESS";
  my $dataref = [];

#  print STDERR ("Executing: $sql_statement with: @bindvars\n");

  # Make sure we have an open DB handle
  $self->connect() unless ($self->connected());
  unless ($self->connected()) {
    $errcode=1;
    $errstring=$@ . ".  Not connected to database."; 
    return ($dataref,$errcode,$errstring,$sql_statement,@bindvars);
  }

  # Prepare the statement handle
  my $statement_handle;
  $statement_handle = $self->dbh->prepare($sql_statement);
  if (!$statement_handle) { 
    $errcode=1;
    $errstring = $DBI::errstr; 
    $@=$errstring;
    $errstring .= ".  Unable to prepare statement handle.";
    print STDERR "$sql_statement\n$errstring\n"; 
    return ($dataref,$errcode,$errstring,$sql_statement,@bindvars);
  }

  # Execute the query
  my $rc;
  $rc = $statement_handle->execute(@bindvars);
  if (!$rc) {
    $errcode=1;
    $errstring = $DBI::errstr; 
    $@=$errstring;
    $errstring .= ".  Unable to execute the query.";
    print STDERR "$sql_statement\n$errstring\n"; 
    return ($dataref,$errcode,$errstring,$sql_statement,@bindvars);
  }

  # Fetch the data, if any

  if ($statement_handle->{NUM_OF_FIELDS}) {
    $dataref = $statement_handle->fetchall_arrayref;
    if ($statement_handle->err) {
      $dataref= [];
      $errcode=1;
      $errstring = $DBI::errstr; 
      $@=$errstring;
      $errstring .= ".  Unable to fetch the data.";
      print STDERR "$sql_statement\n$errstring\n"; 
      return ($dataref,$errcode,$errstring,$sql_statement,@bindvars);
    }
  }

  # Close the statement handle
  if (!$errcode) {
    $statement_handle->finish;
    if ($DBI::err) {
      $errcode=1;
      $errstring = $DBI::errstr; 
      $@=$errstring;
      $errstring .= ".  Unable to close the statement handle.";
      print STDERR "$sql_statement\n$errstring\n"; 
      return ($dataref,$errcode,$errstring,$sql_statement,@bindvars);
    }
  }

  return ($dataref,$errcode,$errstring,$sql_statement,@bindvars);
}

#----------------------------------------------
sub dbexec {
  my ($self,@rest)=@_;
  my @array=$self->dbexecute(@rest);
  return wantarray ? @array : shift(@array);
}

#----------------------------------------------
sub taexec {

  my ($self, @params) = @_;

  # Prepare command for shell
  my $cmd = "$TELALERTBIN/telalert @params";

  # Don't let it take too long!
  my $tomsg   = "Timed out!\n";
  my $results;
  my $exitstatus;
  my $attempts = 1;

  #Repeat once if telalert doesn't respond

  while ($attempts > 0 && $attempts < 3) {
    eval {
      $SIG{'ALRM'} = sub {die $tomsg};
      alarm($self->timeout);

      # Execute command and capture STDOUT & STDERR
      $results .= `$cmd 2>&1`;

      alarm(0);
    };

    if ($@ eq $tomsg) {

      $results .= "Error: Timed out\n";
      $exitstatus = 4;
      $attempts = 0;

    } elsif ($@) {

      $results .= "Error: $@\n";
      $exitstatus = 4;
      $attempts = 0;
 

    } else {
      # Interpret the exit status
      $exitstatus = $? >> 8;

      if ($exitstatus && $results =~ /Can\'t read from host/) {
        $attempts++;
      } else {
        $attempts = 0; 
      }
    }
  }	

  # Return results
  return($results, $exitstatus, $cmd);
}

#----------------------------------------------
sub clearticket {

  my ($self, $ticket_id) = @_;
  $ticket_id =~ s/'/'"'"'/g;

  my($results) = $self->taexec("-clear -ticket '$ticket_id'");

  return $results;
}

#----------------------------------------------
sub clear {

  my ($self, $ticket_id) = @_;
  $ticket_id =~ s/'/'"'"'/g;

  my($results) = $self->taexec("-clear '$ticket_id'");

  return $results;
}

#----------------------------------------------
sub ack {

  my ($self, $ticket_id) = @_;
  $ticket_id =~ s/'/'"'"'/g;

  my($results) = $self->taexec("-ack '$ticket_id'");

  return $results;
}

#----------------------------------------------
sub nak {

  my ($self, $ticket_id) = @_;
  $ticket_id =~ s/'/'"'"'/g;

  my($results) = $self->taexec("-nak '$ticket_id'");

  return $results;
}

#----------------------------------------------
sub writetrail {

  my ($self, $message) = @_;
  $message =~ s/'/'"'"'/g;

  my($results) = $self->taexec("-writetrail '$message'");

  return $results;
}


#----------------------------------------------
sub listsection {

  my ($self, $section, $withvalue) = @_;
  $withvalue = "-value" if ($withvalue);
  $section =~ s/'/'"'"'/g;

  my($results) = $self->taexec("-list '$section' $withvalue");

  return $results;
}

#----------------------------------------------
sub stop {

  my ($self) = shift;

  my($results) = $self->taexec("-stop");

  return $results;
}

#----------------------------------------------
sub start {

  my ($self, $init) = @_;
  $init = "-init" if $init;

  my($results) = $self->taexec("-start $init");

  return $results;
}

#----------------------------------------------
sub show {

  my ($self, $option) = @_;
  $option = '-'.$option if ($option && $option !~ /^-.*/);

  my($results) = $self->taexec("-show $option");

  return $results;
}

#----------------------------------------------
sub activateport {

  my ($self, $portname) = @_;

  my($results) = $self->taexec("-activate -port $portname");

  return $results;
}

#----------------------------------------------
sub deactivateport {

  my ($self, $portname) = @_;

  my($results) = $self->taexec("-deactivate -port $portname");

  return $results;
}

#----------------------------------------------
sub getMyIP {

  my ($self) = @_;
  my $ip='';

  # Return cached IP if it exists
  if (defined($self->ip())) {

    return($self->ip());

  } else {

    # Determine my IP address by hook or by crook

    # First attempt is to parse the TelAlert list license command
    my $results = $self->listsection('license', 1);
    my @results = split (/\n/, $results);
    $ip      = (grep { /^HostIPAddress=/ } @results)[0];
    $ip      = (split (/HostIPAddress=/, $ip, 2) )[1];
    $ip      =~ s/\n//g;


    unless (defined($ip)) {

  # Second attempt is to parse the TelAlert config file
  my @configFile = $self->getTAConfig;

  # Extract the Tetalert Host IP Address
  my @ip = grep { /^HostIPAddress=/ } @configFile;
  $ip     = (split (/HostIPAddress=/, $ip[0], 2) )[1];
  $ip     =~ s/\n//g;

    }




    unless (defined($ip)) {

  # Third attempt is to use ifconfig command
  my @ip    = ();
  my $cmd    = "/sbin/ifconfig eth0";   # Tested only on Linux
  $results = `$cmd 2>&1`;
  @results = split (/\n/, $results);
  @ip     = grep { /inet addr:/ } @results;
  $ip     = $ip[0];
  $ip     =~ s/^\s+//;
  $ip     =~ s/\s+/ /g;
  $ip     = (split (/inet addr:/, $ip, 2) )[1];
  $ip     = (split (/ /, $ip) )[0];
  $ip     =~ s/\n//g;

    }


    unless (defined($ip)) {

  # Fourth and final attempt, use Perl's system library routines
  my $hostname = hostname();
  my $packedIP = gethostbyname $hostname;
  $ip       = join ".", unpack("C4", $packedIP);


    }

    $self->ip($ip) if (defined($ip));
    return $ip;

  }

} # End of getMyIP

#----------------------------------------------
sub getTAConfig {
  return &readfile("$ENV{'TELALERTCFG'}/$TELALERTCONFIGFILE") if (wantarray);
  return join '', &readfile("$ENV{'TELALERTCFG'}/$TELALERTCONFIGFILE");
}

sub readfile {
  my $file = shift;
  my @configfile;

  my $fh = new IO::File;
  $fh->open ("< $file") or die "Couldn't open $file: $!\n";

  while (<$fh>) {
    if (/^\s*\$include/) {
      my ($op, $file) = split(' ', $_);
      push (@configfile, "# Including file '$file'\n");
      push (@configfile, &readfile("$ENV{'TELALERTCFG'}/$file") );

    }
    else { push (@configfile, $_) }
  }

  $fh->close;

  return @configfile;
}

#----------------------------------------------
sub DESTROY {
  my $self = shift;
  $self->disconnect();
}

#----------------------------------------------
sub newticketid
{

  # $server_recid is the recid of the TelAlert server in the "telalerts" DB table

  my ($self) = @_;
  $self->serverid($self->getTelAlertServerID()) unless (defined($self->serverid())); my $server_recid = $self->serverid();
  my $ticketcount = $self->nextticket();
  my $ticket = sprintf ( "%02d_%010d_%06d_%03d", $server_recid, time(), $$,
               $ticketcount );

  return $ticket;

} # End of newticketid

#----------------------------------------------


###############################################
# TelAlert/SQL Methods
###############################################

sub dbIsOkay {
  my $self = shift;

  $self->dbexec('select * from dual');
  return !$@ 
}

#----------------------------------------------
sub activeAlertExists {

    my ($self, $ticket_id) = @_;

    # Are there any alerts matching this ticket_id?
    my $sql_statement = sprintf<<EOSQL;  
SELECT  count(*)
FROM    current_alerts
WHERE   current_alerts.ticket_id = ?
  AND   current_alerts.date_completed is NULL
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $ticket_id);


  #-- Return the count of matching active alerts
  return $rows_ref->[0]->[0];


} # End of activeAlertExists

#----------------------------------------------
sub getActiveAlerts {

  my ($self) = @_;


  # Fetch all alerts from the DB
  my $dateformat = $self->dateformat();

  my $sql_statement = sprintf<<EOSQL;
SELECT     
       alerts.recid,
       alerts.ticket_id,
       alerts.destination_name,
       alerts.escalation_level,
       TO_CHAR (alerts.date_submitted, '$dateformat') AS datesubmitted,
       oowner.telalert_name AS origip,
       cowner.telalert_name AS curgip,
       TO_CHAR (alerts.last_server_change, '$dateformat'),
       TO_CHAR (alerts.date_completed, '$dateformat'),
       SUBSTR (alerts.message, 0, 15),
       cowner.recid,
       alerts.customer_id,
       customer.description
FROM     
       telalerts      oowner,
       telalerts      cowner,
       current_alerts alerts,
       customer
WHERE   
       alerts.current_server  = cowner.recid
  AND  alerts.original_server = oowner.recid
  AND  alerts.customer_id     = customer.recid
  AND  alerts.date_completed  is NULL
ORDER BY
       curgip ASC, datesubmitted ASC, alerts.ticket_id
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement);
  my @alerts   = @$rows_ref;

  return @alerts;

} # End of getActiveAlerts

#----------------------------------------------
sub getAlertValues {

  #--- Fetch the values for this alert from DB

  my ($self, $alert_recid) = @_;


  my $dateformat = $self->dateformat();
  my $sql_statement = sprintf<<EOSQL;
SELECT     recid,
       TO_CHAR (alerts.date_submitted,     '$dateformat'),
       TO_CHAR (alerts.last_server_change, '$dateformat'),
       TO_CHAR (alerts.date_completed,     '$dateformat'),
       oowner.telalert_name as origip,
       cowner.telalert_name as curgip,
       alerts.tel_args,
       alerts.message,
       alerts.ticket_id,
       alerts.destination_name,
       alerts.escalation_level,
       alerts.host_probe_id,
       alerts.host_state,
       alerts.service_probe_id,
       alerts.service_state,
       alerts.customer_id,
       alerts.netsaint_id,
       alerts.probe_type
       customer.description
FROM     
       telalerts      oowner,
       telalerts      cowner,
       current_alerts alerts,
       customer
WHERE   
       alerts.recid           = ?
  AND  alerts.current_server  = cowner.recid
  AND  alerts.original_server = oowner.recid
  AND  alerts.customer_id     = customer.recid
EOSQL


  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $alert_recid);

  if (scalar(@$rows_ref)) {

    my @columns = qw(
  recid       date_submitted     last_server_change  date_completed
  original_server   current_server     tel_args        message
  ticket_id     destination_name  escalation_level    host_probe_id
  host_state     service_probe_id  service_state    customer_id
  netsaint_id     probe_type       customer_description);

    my %values;
    @values{@columns} = @{$rows_ref->[0]};

    return \%values;

  } else {

    return undef;
  
  }


} # End of getAlertValues



#----------------------------------------------
sub getLastAlertByType {

  #--- Fetch the values for this alert from DB

  my ($self, $type, $id) = @_;

  my $dateformat = $self->dateformat();

  my $column = ($type eq 'HostProbe' ? 'host_probe_id' : 'service_probe_id');

  my $sql_statement = sprintf<<EOSQL;
SELECT *
FROM (
  SELECT   alerts.recid,
       TO_CHAR (alerts.date_submitted,   '$dateformat'),
       TO_CHAR (alerts.last_server_change, '$dateformat'),
       TO_CHAR (alerts.date_completed,   '$dateformat'),
       oowner.telalert_name as origip,
       cowner.telalert_name as curgip,
       alerts.tel_args,
       alerts.message,
       alerts.ticket_id,
       alerts.destination_name,
       alerts.escalation_level,
       alerts.host_probe_id,
       alerts.host_state,
       alerts.service_probe_id,
       alerts.service_state,
       alerts.customer_id,
       alerts.netsaint_id,
       alerts.probe_type,
       customer.description
  FROM     
       telalerts      oowner,
       telalerts      cowner,
       current_alerts alerts,
       customer
  WHERE     
       alerts.current_server  = cowner.recid
  AND  alerts.original_server = oowner.recid
  AND  alerts.customer_id     = customer.recid
  AND  alerts.probe_type      = ?
  AND  alerts.$column         = ?
  ORDER BY   
       date_submitted DESC )
WHERE rownum = 1
EOSQL


  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $type, $id);

  if (scalar(@$rows_ref)) {

    my @columns = qw(
  recid       date_submitted     last_server_change  date_completed
  original_server   current_server     tel_args        message
  ticket_id     destination_name  escalation_level    host_probe_id
  host_state     service_probe_id  service_state    customer_id
  netsaint_id     probe_type       customer_description);

    my %values;
    @values{@columns} = @{$rows_ref->[0]};

    return \%values;

  } else {

    return undef;
  
  }

} # End of getLastAlertByType



#----------------------------------------------
sub getDestsByCustomer {

  # Get a list of all TelAlert destinations in the DB.
  # Returns a hash keyed on destination name.

  my ($self, $custid) = @_;

  my $sql_statement = "
      SELECT 
        contact_methods.recid || ':' || contact_methods.method_name ref,
        contact_methods.method_name || '(i)' name 
      FROM   contact_methods, contact
      WHERE  contact_methods.contact_id = contact.recid
      AND    contact.customer_id = $custid

      UNION

      SELECT 
        contact_groups.recid || ':' || contact_groups.contact_group_name ref,
        contact_groups.contact_group_name || '(g)' name
      FROM   contact_groups
      WHERE  contact_groups.customer_id = $custid

      ORDER BY name";

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement);

  # Build a hash
  my %dests;
  map($dests{$_->[0]} = $_->[1], @$rows_ref);

  return \%dests;
          
} # End of getDestsByCustomer

#----------------------------------------------
sub getContactsByCustomer {

  # Returns a hash of row value hashes keyed on recid.

  my ($self, $custid) = @_;

  my $sql_statement = "
    SELECT recid, contact_last_name || ', ' || contact_first_name name
    FROM contact
    WHERE customer_id = ?";

   # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement, $custid);

  # Build a hash
  my %contacts;
  map($contacts{$_->[0]} = $_->[1], @$rows_ref);

  return \%contacts;

} # End of getContactsByCustomer


#----------------------------------------------
sub getContactMethodsByCustomer {

  # Get a list of all TelAlert contact method destinations in the DB.
  # Returns a hash of row value hashes keyed on recid.

  my ($self, $custid) = @_;

  my $sql_statement = "
      SELECT contact_methods.recid, contact_methods.method_name
      FROM   contact_methods, contact
      WHERE  contact_methods.contact_id = contact.recid
      AND    contact.customer_id = ?";

   # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement, $custid);

  # Build a hash
  my %methods;
  map($methods{$_->[0]} = $_->[1], @$rows_ref);

  return \%methods;

} # End of getContactMethodsByCustomer


#----------------------------------------------
sub getContactMethodNameById {

  # Get the hostname for a particular host

  my ($self, $id) = @_;

  my $sql_statement = sprintf<<EOSQL;
     SELECT method_name
     FROM    contact_methods
     WHERE  recid = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $id);

  # Return the hostname
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  }
} #end getContactMethodNameById

#----------------------------------------------
sub getContactGroupsByCustomer {

  # Get a list of all TelAlert group destinations in the DB.
  # Returns a hash of row value hashes keyed on recid

  my ($self, $custid) = @_;

  my $sql_statement = "
      SELECT recid, contact_group_name  
      FROM   contact_groups
      WHERE  customer_id = ?";

   # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement,$custid);

  # Build a hash
  my %groups;
  map($groups{$_->[0]} = $_->[1], @$rows_ref);

  return \%groups;
          
} # End of getContactGroupsByCustomer

#----------------------------------------------
sub getContactGroupNameById {

  # Get the hostname for a particular host

  my ($self, $id) = @_;

  my $sql_statement = sprintf<<EOSQL;
     SELECT contact_group_name
     FROM    contact_groups
     WHERE  recid = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $id);

  # Return the hostname
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  } 
}  #end getContaceGroupNameById

#----------------------------------------------
sub getHostnameByHostid {

  # Get the hostname for a particular host

  my ($self, $hostid) = @_;

  my $sql_statement = sprintf<<EOSQL;
     SELECT host_name
     FROM    probes
     WHERE  recid = ?
     AND    probe_type = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $hostid, 'HostProbe');

  # Return the hostname
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  }
} # End of getHostnameByHostid
#----------------------------------------------
sub getHostsByCustomer {

  # Get a list of all TelAlert destinations in the DB.
  # Returns a hash keyed on destination name.

  my ($self, $custid) = @_;

  my $sql_statement = sprintf<<EOSQL;
     SELECT 
            host.recid, 
            host.host_name
     FROM    
            probes host, 
            sat_cluster
     WHERE  
            host.probe_type         = ?
       AND  host.netsaint_id        = sat_cluster.recid
       AND  sat_cluster.customer_id = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, 'HostProbe', $custid);

  # Build a hash
  my %hosts;
  map($hosts{$_->[0]} = $_->[1], @$rows_ref);

  return \%hosts;

} # End of getHostsByCustomer



#----------------------------------------------
sub getPagerTypes {

  # Fetch pager type list from DB
  my ($self) = @_;


  my $sql_statement = sprintf<<EOSQL;
SELECT Recid, Pager_Type_Name FROM pager_types
EOSQL


  # Get the data
  my $rows_ref = $self->dbexec($sql_statement);

  # Build a hash
  my %pagertypes;
  map($pagertypes{$_->[0]} = $_->[1], @$rows_ref);

  return \%pagertypes;

} # End of sun getPagerTypes

#----------------------------------------------

sub getProbeTypeById {

  # Get the probe type for a particular probe

  my ($self, $id) = @_;

  my $sql_statement = sprintf<<EOSQL;
     SELECT probe_type
     FROM    probes
     WHERE  recid = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $id);

  # Return the probe type
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  } 
}  #end getProbeTypeId


#----------------------------------------------
sub getProbeTypes {

  # Fetch probe type list from DB
  my ($self) = @_;


  my $sql_statement = sprintf<<EOSQL;
SELECT probe_type, type_description FROM probe_types
EOSQL


  # Get the data
  my $rows_ref = $self->dbexec($sql_statement);

  # Build a hash
  my %probetypes;
  map($probetypes{$_->[0]} = $_->[1], @$rows_ref);

  return \%probetypes;

} # End of sun getProbeTypes

#----------------------------------------------
sub getRedirectTypes {

  my $self=shift;

  my $sql_statement = "
    SELECT  name, name || ' - ' || description as descr
    FROM   redirect_types";

  my $rows_ref = $self->dbexec($sql_statement);

  my %types;
  map($types{$_->[0]} = $_->[1], @$rows_ref);

  return \%types;
}
#----------------------------------------------
sub getNextRedirectId {

  my ($self) = @_;

  my $sql_statement = sprintf<<EOSQL;
SELECT REDIRECTS_RECID_SEQ.NEXTVAL
FROM dual
EOSQL

  # Fetch the data
  my $rows_ref     = $self->dbexec($sql_statement);

  if (scalar(@$rows_ref)) {

    my $id = $rows_ref->[0]->[0];
    return($id);

  } else {

    return undef;  # $@ contains DB error

  }

} # End of getNextRedirectId

#----------------------------------------------
sub addRedirect {
  my ($self, @args)= @_;

  my $sql_statement = "
  INSERT INTO redirects
    (recid, customer_id, contact_id, redirect_type, description, reason, 
      expiration,
      last_update_user, last_update_date, start_date)
  
  VALUES 
    (? , ?, ?, ?, ?, ?, 
      TO_DATE(?,'yyyy-mm-dd hh24:mi:ss'),
      ?, SYSDATE, TO_DATE(?,'yyyy-mm-dd hh24:mi:ss'))";

  $self->dbexec($sql_statement, @args);

}
#----------------------------------------------
sub updateRedirect {
  my ($self, $recid, $customer_id, $contact_id, $redirect_type, 
      $description, $reason, $expiration, $last_update_user, $start_date) = @_;

  my $sql_statement = "
  UPDATE redirects
  SET
    customer_id       = $customer_id, 
    contact_id        = $contact_id, 
    redirect_type     = \'$redirect_type\', 
    description       = \'$description\', 
    reason            = \'$reason\', 
    expiration        = TO_DATE(\'$expiration\', 'yyyy-mm-dd hh24:mi:ss'),
    last_update_user  = \'$last_update_user\', 
    last_update_date  = SYSDATE,
    start_date        = TO_DATE(\'$start_date\', 'yyyy-mm-dd hh24:mi:ss')
  WHERE 
    recid = $recid";

  $self->dbexec($sql_statement);

}

#----------------------------------------------
sub getNextRedirectCriteriaId {

  my ($self) = @_;

  my $sql_statement = sprintf<<EOSQL;
SELECT REDIRECT_CRITERIA_RECID_SEQ.NEXTVAL
FROM dual
EOSQL

  # Fetch the data
  my $rows_ref     = $self->dbexec($sql_statement);

  if (scalar(@$rows_ref)) {

    my $id = $rows_ref->[0]->[0];
    return($id);

  } else {

    return undef;  # $@ contains DB error

  }

} # End of getNextRedirectId

#----------------------------------------------
sub addRedirectCriteria {
  my ($self, @args)= @_;
  my $recid = $self->getNextRedirectCriteriaId;

  my $sql_statement = "
  INSERT INTO redirect_criteria
  (recid, redirect_id, match_param, match_value, inverted)
  
  VALUES 
    (?, ?, ?, ?, ?)";

  $self->dbexec($sql_statement, $recid, @args);

}

#----------------------------------------------
sub addRedirectGroup {
  my ($self, @args)= @_;

  my $sql_statement = "
  INSERT INTO redirect_group_targets
  (redirect_id, contact_group_id)
  
  VALUES 
    (?, ?)";

  $self->dbexec($sql_statement, @args);

}
 
#----------------------------------------------
sub addRedirectMethod {
  my ($self, @args)= @_;

  my $sql_statement = "
  INSERT INTO redirect_method_targets
  (redirect_id, contact_method_id)
  
  VALUES 
    (?, ?)";

  $self->dbexec($sql_statement, @args);

}

#----------------------------------------------
sub addRedirectEmail {
  my ($self, @args)= @_;

  my $sql_statement = "
  INSERT INTO redirect_email_targets
  (redirect_id, email_address)
  
  VALUES 
    (?, ?)";

  $self->dbexec($sql_statement, @args);

}


#----------------------------------------------
sub deleteRedirectData {
  my ($self, $redir_id)= @_;

  my $archive_begin_statement = " 
  INSERT INTO archive_master
  (customer_id, activity_code, table_name, key_col_1)
  VALUES (?,?,?,?)";

  my $archive_end_statement = "
  DELETE FROM archive_master
  WHERE customer_id  = ?
  AND  activity_code = ?
  AND  table_name    = ?
  AND  key_col_1     = ?";

  my $sql_statement;
  
  $sql_statement = "
  DELETE FROM redirect_email_targets
  WHERE redirect_id = ?";
  
  $self->dbexec($archive_begin_statement, 1, 'DEL', 'redirect_email_targets', 'redirect_id');
  $self->dbexec($sql_statement, $redir_id);
  $self->dbexec($archive_end_statement,   1, 'DEL', 'redirect_email_targets', 'redirect_id');

  $sql_statement = "
  DELETE FROM redirect_method_targets
  WHERE redirect_id = ?";
  
  $self->dbexec($archive_begin_statement, 1, 'DEL', 'redirect_method_targets', 'redirect_id');
  $self->dbexec($sql_statement, $redir_id);
  $self->dbexec($archive_end_statement,   1, 'DEL', 'redirect_method_targets', 'redirect_id');

  $sql_statement = "
  DELETE FROM redirect_group_targets
  WHERE redirect_id = ?";
  
  $self->dbexec($archive_begin_statement, 1, 'DEL', 'redirect_group_targets', 'redirect_id');
  $self->dbexec($sql_statement, $redir_id);
  $self->dbexec($archive_end_statement,   1, 'DEL', 'redirect_group_targets', 'redirect_id');

  $sql_statement = "
  DELETE FROM redirect_criteria
  WHERE redirect_id = ?";
  
  $self->dbexec($archive_begin_statement, 1, 'DEL', 'redirect_criteria', 'redirect_id');
  $self->dbexec($sql_statement, $redir_id);
  $self->dbexec($archive_end_statement,   1, 'DEL', 'redirect_criteria', 'redirect_id');
}

#----------------------------------------------
sub deleteRedirect {
  my ($self, $redir_id)= @_;

  my $sql_statement = "
    DELETE FROM redirects
    WHERE recid = ?";

  $self->dbexec($sql_statement, $redir_id);
}

#----------------------------------------------
sub getRedirectById {     

#Fetch all the redirect with the specified recid

  my ($self, $recid) = @_;

  my $sql_statement = "
   SELECT redirects.recid,
          redirects.redirect_type,
          redirects.expiration,
          redirects.contact_id,
          redirects.reason,
          redirects.description,
          customer.recid,
          customer.description,
          TO_CHAR (redirects.expiration, 'yyyy-mm-dd hh24:mi:ss'),
          redirects.start_date,
          TO_CHAR (redirects.start_date, 'yyyy-mm-dd hh24:mi:ss')

    FROM  redirects,
          customer
    WHERE redirects.recid = ?
      AND redirects.customer_id = customer.recid
    ";

#Fetch the data
  my $rows_ref = $self->dbexec($sql_statement, $recid);

  if ( scalar(@$rows_ref) ) {

    my %row;
    my @columns = qw( recid redirect_type expiration contact_id reason description cust_id cust_name formatted_expiration start_date formatted_start_date);

    my $row_ref=$rows_ref->[0];

    @row{@columns} = @$row_ref;
    return \%row;

  } else {

    return {};

  }

} # End of getRedirectById

#----------------------------------------------

sub getContactMethodsByRedirectId {

  my $self = shift;
  my $redirid = shift;

  my $sql_statement = "
  SELECT contact_method_id
  FROM   redirect_method_targets
  WHERE  redirect_id = ?
  ";

# Fetch the data
my $rows_ref = $self->dbexec($sql_statement, $redirid);

my @methods   = map($_->[0], @$rows_ref);

return \@methods;


}

#----------------------------------------------

sub getContactGroupsByRedirectId {

  my $self = shift;
  my $redirid = shift;

  my $sql_statement = "
  SELECT contact_group_id
  FROM   redirect_group_targets
  WHERE  redirect_id = ?
  ";

# Fetch the data
my $rows_ref = $self->dbexec($sql_statement, $redirid);

my @groups   = map($_->[0], @$rows_ref);

return \@groups;


}

#----------------------------------------------

sub getRedirectMatchTypes {

  my $self = shift;

  my $sql_statement = "
  SELECT name
  FROM   redirect_match_types
  ";

# Fetch the data
my $rows_ref = $self->dbexec($sql_statement);

my @types   = map($_->[0], @$rows_ref);

return \@types;


}

#----------------------------------------------
sub getRedirectDetailsById {
#Fetch the detailed criteria for the specified redirect

  my ($self, $redir_id) = @_;

  if ($self->dbIsOkay) {

    my $sql_statement = "
      SELECT    match_param,
                match_value,
                inverted
      FROM      redirect_criteria
      WHERE     redirect_criteria.redirect_id = ?
      ORDER BY  match_param";

    #Fetch the data
    my $rows_ref = $self->dbexec($sql_statement,  $redir_id);

    my ($row_ref, $row_id);
    my %table;

    if ( scalar(@$rows_ref) ) {

      my @columns = qw( match_param match_value inverted );


      my $row_id = 0;
      foreach $row_ref (@$rows_ref) {

        my %row;
        $row_id++;
        @row{@columns} = @$row_ref;
        $table{$row_id} = \%row;

      }

      return \%table;

    } else {

      return {};

    }
  } else {

    # We can't reach the database -- use the local store

    my %hash;
    dbmopen(%hash,$REDIRECT_FILE,undef) || print STDERR "Unable to open $REDIRECT_FILE: $! ";
    my $r=$hash{$redir_id};
    dbmclose(%hash) || print STDERR "Unable to close $REDIRECT_FILE: $! ";

    if ($r) {
      my ($rec)=thaw($r);
      return $rec->{'criteria'}
    } else {
      return undef
    }
  }

} # End of getRedirectDetailsById

#----------------------------------------------
sub getCurrentRedirectsByCustomer {     

#Fetch all non-expired redirects for this company from DB

  my ($self, $customer_id) = @_;

  if ($self->dbIsOkay()) {
    my $sql_statement = "
      SELECT recid,
            redirect_type,
            expiration,
            contact_id,
            reason,
            description,
            start_date
      FROM  redirects
      WHERE redirects.customer_id = ?
      AND   expiration           >= sysdate
      AND   start_date           <= sysdate";

    #Fetch the data
    my $rows_ref = $self->dbexec($sql_statement,  $customer_id);

    if ( scalar(@$rows_ref) ) {

      my (%table, $row_ref);
      my @columns = qw( recid redirect_type expiration contact_id reason description start_date);

      foreach $row_ref (@$rows_ref) {

        my %row;
        @row{@columns} = @$row_ref;
        $table{$row{'recid'}} = \%row;

      }

      return \%table;

    } else {
        return {};
    }
  } else {

    # We can't reach the database -- use the local store

    my %hash;
    dbmopen(%hash,$CUSTOMER_REDIRECT_FILE,undef) || print STDERR "Unable to open $CUSTOMER_REDIRECT_FILE: $! ";
    my $r=$hash{$customer_id};
    dbmclose(%hash) || print STDERR "Unable to close $CUSTOMER_REDIRECT_FILE: $! ";

    if (!$r) {
      return {}
    }

    my @redirects=thaw($r);

    my %hash2;
    dbmopen(%hash2,$REDIRECT_FILE,undef) || print STDERR "Unable to open $REDIRECT_FILE: $! ";
    my %rethash = map { 
      my $r=$hash2{$_};
      my ($rec)=thaw($r);
      $_ => $rec;
    } @redirects;

    return \%rethash;

  }

} # End of getCurrentRedirectsByCustomer
#----------------------------------------------
sub getRedirectsByCustomer {     

#Fetch all redirects for this company from DB

  my ($self, $customer_id) = @_;

  my $sql_statement = "
   SELECT recid,
          redirect_type,
          expiration,
          contact_id,
          reason,
          description,
          TO_CHAR (expiration, 'yyyy-mm-dd hh24:mi:ss'),
          expiration - SYSDATE,
          start_date,
          TO_CHAR (start_date, 'yyyy-mm-dd hh24:mi:ss'),
          SYSDATE - start_date
    FROM  redirects
    WHERE redirects.customer_id = ?";

#Fetch the data
  my $rows_ref = $self->dbexec($sql_statement,  $customer_id);

  if ( scalar(@$rows_ref) ) {

    my (%table, $row_ref);
    my @columns = qw( recid redirect_type expiration contact_id reason description formatted_expiration expired_days start_date formatted_start_date active_days);

    foreach $row_ref (@$rows_ref) {

      my %row;
      @row{@columns} = @$row_ref;
      $table{$row{'recid'}} = \%row;

    }

    return \%table;

  } else {

    return {};

  }

} # End of getRedirectsByCustomer


#----------------------------------------------
sub getRedirectDests {

  # Fetch all destinations for this redirect

  my ($self, $redirect_id) = @_;

  if ($self->dbIsOkay) {
    my $sql_statement = "
      SELECT contact.customer_id || '_' || contact_methods.recid || '_' ||  contact_methods.method_name
      FROM  
       redirect_method_targets, 
        contact_methods, 
        contact
      WHERE   redirect_method_targets.redirect_id       = $redirect_id
        AND   redirect_method_targets.contact_method_id = contact_methods.recid
        AND   contact_methods.contact_id                = contact.recid

      UNION 
    
      SELECT contact_groups.customer_id || '_' || contact_groups.recid || '_' || contact_groups.contact_group_name
      FROM   
        redirect_group_targets, 
        contact_groups
      WHERE   redirect_group_targets.redirect_id      = $redirect_id
      AND     redirect_group_targets.contact_group_id = contact_groups.recid"; 

    # Fetch the data
    my $rows_ref = $self->dbexec($sql_statement);

    my @dests   = map($_->[0], @$rows_ref);

    return @dests;
  } else {
    # We can't reach the database -- use the local store

    my @dests;
    my %hash;
    dbmopen(%hash,$REDIRECT_FILE,undef) || print STDERR "Unable to open $REDIRECT_FILE: $! ";
    my $r=$hash{$redirect_id};
    dbmclose(%hash) || print STDERR "Unable to close $REDIRECT_FILE: $! ";

    if ($r) {
      my ($rec)=thaw($r);
      my $g=$rec->{'groups'};
      foreach (keys(%$g)) {
        my $str=$rec->{'customer_id'};
        $str .= "_" . $_;
        $str .= "_" . $g->{$_};
        push(@dests, $str);
      }
      my $m=$rec->{'methods'};
      foreach (keys(%$m)) {
        my $str=$rec->{'customer_id'};
        $str .= "_" . $_;
        $str .= "_" . $m->{$_};
        push(@dests, $str);
      }

      return @dests;
    }
  }


} # End of getRedirectDests

#----------------------------------------------
sub getRedirectEmails {

  # Fetch all ad-hoc email destinations for this redirect

  my ($self, $redirect_id) = @_;

  if ($self->dbIsOkay) {
    my $sql_statement = "
      SELECT email_address
      FROM   redirect_email_targets
      WHERE   redirect_id = $redirect_id";

    # Fetch the data
    my $rows_ref = $self->dbexec($sql_statement);

    my @dests   = map($_->[0], @$rows_ref);

    return @dests;
  } else {

    # We can't reach the database -- use the local store

    my %hash;
    dbmopen(%hash,$REDIRECT_FILE,undef) || print STDERR "Unable to open $REDIRECT_FILE: $! ";
    my $r=$hash{$redirect_id};
    dbmclose(%hash) || print STDERR "Unable to close $REDIRECT_FILE: $! ";

    if ($r) {
      my ($rec)=thaw($r);
      $rec=$rec->{'emails'};
      return @$rec if $rec;
    }
  }
  return ();

} # End of getRedirectEmails

#----------------------------------------------
sub getFormatForContactMethodId {
  my ($self, $recid) = @_;
  
  if ($self->dbIsOkay) {

    my $sql_statement = "
    SELECT n.recid, n.customer_id, n.description, n.subject_format, 
      n.body_format, n.max_subject_length, n.max_body_length
    FROM notification_formats n, contact_methods m
    WHERE m.notification_format_id = n.recid 
    AND   m.recid = ?";

    # Fetch the data
    my $rows_ref = $self->dbexec($sql_statement, $recid);

    if ( scalar(@$rows_ref) ) {

      my @columns = qw(recid customer_id description subject_format body_format max_subject_length max_body_length);
      my %values;
      @values{@columns} = @{$rows_ref->[0]};
      return \%values;

    } 
  }

  return $self->getFormatFromDBM("i$recid");
}

#----------------------------------------------
sub getFormatForContactGroupId {
  my ($self, $recid) = @_;

  if ($self->dbIsOkay) {

    my $sql_statement = "
    SELECT n.recid, n.customer_id, n.description, n.subject_format, 
      n.body_format, n.max_subject_length, n.max_body_length
    FROM notification_formats n, contact_groups g
    WHERE g.notification_format_id = n.recid 
    AND   g.recid = ?";

    # Fetch the data
    my $rows_ref = $self->dbexec($sql_statement, $recid);

    if ( scalar(@$rows_ref) ) {

      my @columns = qw(recid customer_id description subject_format body_format max_subject_length max_body_length);
      my %values;
      @values{@columns} = @{$rows_ref->[0]};
      return \%values;

    }
  }

    return $self->getFormatFromDBM("g$recid");
}

#----------------------------------------------
sub getFormatFromDBM {
  my ($self, $recid) = @_;

  # Value not found with the database -- try the dbm
  # Get the format id

  my %hash;
  dbmopen(%hash,$CONTACT_FORMAT_FILE,undef) || warn "Unable to open $CONTACT_FORMAT_FILE: $! ";
  my $id = $hash{$recid};

  return undef unless $id;
  dbmclose(%hash)|| warn "Unable to close $CONTACT_FORMAT_FILE: $! ";

  # Get the format itself

  my %hash2;
  dbmopen(%hash2,$FORMAT_FILE,undef) || warn "Unable to open $FORMAT_FILE: $! ";
  my $value = $hash2{$id};


  return undef unless $value;
  dbmclose(%hash2) || warn "Unable to close $FORMAT_FILE: $! ";

  # Parse the format and return it as a hash

  my ($fmt) = thaw($value);
  return $fmt
}

#----------------------------------------------
sub getSatellites {

  # Fetch all TelAlert servers listed in DB
  my ($self) = @_;

  #--- For now, the scope in terms of company, not contact
  my $sql_statement = sprintf<<EOSQL;
SELECT   
     recid,
     description
FROM
     sat_cluster
EOSQL


  # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement);

  # Build a hash
  my %satellites;
  map($satellites{$_->[0]} = $_->[1], @$rows_ref);

  return \%satellites;

} # End of getSatellites


#----------------------------------------------
sub getSatellitesByCustomer {

  # Fetch all TelAlert servers listed in DB
  my ($self, $custid) = @_;

  #--- For now, the scope in terms of company, not contact
  my $sql_statement = sprintf<<EOSQL;
SELECT   
     recid,
     description
FROM
     sat_cluster
WHERE
     customer_id = ?
EOSQL


  # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement, $custid);

  # Build a hash
  my %satellites;
  map($satellites{$_->[0]} = $_->[1], @$rows_ref);

  return \%satellites;

} # End of getSatellitesByCustomer





#----------------------------------------------
sub getScoutsByCustomer {

  # Fetch all TelAlert servers listed in DB
  my ($self, $custid) = @_;

  #--- For now, the scope in terms of company, not contact
  my $sql_statement = sprintf<<EOSQL;
SELECT
        recid,
        description
FROM    
        sat_cluster sc,
        ll_netsaint ll
WHERE    
        customer_id    = ?
AND     ll.netsaint_id = sc.recid
EOSQL


  # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement, $custid);

  # Build a hash
  my %scouts;
  map($scouts{$_->[0]} = $_->[1], @$rows_ref);

  return \%scouts;

} # End of getScoutsByCustomer




#----------------------------------------------
sub getUrlsByCustomer {

  # Fetch all TelAlert servers listed in DB
  my ($self, $custid) = @_;

  #--- For now, the scope in terms of company, not contact

  my $sql_statement = sprintf<<EOSQL;
  SELECT s.url_probe_id, s.description, s.url
  FROM url_probe_role r, url_probe_step s
  WHERE r.url_probe_id = s.url_probe_id
  AND r.customer_id = ? 
EOSQL


  # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement, $custid);

  # Return the results
  return $rows_ref;

} # End of getUrlsByCustomer



#----------------------------------------------
sub getServers {

  # Fetch all TelAlert servers listed in DB
  my ($self) = @_;

  #--- For now, the scope in terms of company, not contact
  my $sql_statement = sprintf<<EOSQL;
SELECT   recid, telalert_name
FROM   telalerts
ORDER BY telalert_name
EOSQL


  # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement);

  # Build a hash
  my %servers;
  map($servers{$_->[0]} = $_->[1], @$rows_ref);

  return \%servers;

} # End of getServers


#----------------------------------------------
sub getServerNames {

  # Fetch all TelAlert servers listed in DB
  my ($self) = @_;

  #--- For now, the scope in terms of company, not contact
  my $sql_statement = sprintf<<EOSQL;
SELECT   telalert_name
FROM   telalerts
ORDER BY telalert_name
EOSQL


  # Fetch the data
  my $rows_ref = $self->dbexec($sql_statement);

  # Build array
  my @servers;
  map(push(@servers, $_->[0]), @$rows_ref);

  return @servers;

}

#----------------------------------------------
sub getTelAlertServerIDByName {

  my ($self,$name) = @_;

  if ($self->dbIsOkay) {
    my $sql_statement = "
      SELECT recid
      FROM   telalerts
      WHERE  telalert_name = ?";

    # Fetch the data
    my $rows_ref     = $self->dbexec($sql_statement, $name);

    if (scalar(@$rows_ref)) {

      my $serverid = $rows_ref->[0]->[0];
      return $serverid;  # $@ contains DB error

    } else {
      return undef
    }
  } else {
    # We can't reach the database -- use the local store

    my %hash;
    dbmopen(%hash,$TELALERTS_FILE,undef) || print STDERR "Unable to open $TELALERTS_FILE: $! "; 
    my $r=$hash{$name};
    
    dbmclose(%hash) || print STDERR "Unable to close $TELALERTS_FILE: $! ";

    return $r
  }

} # End of getTelAlertServerIDByName



#----------------------------------------------
sub getTelAlertServerID {

   my ($self) = @_;

   #Return cached ID if it exists
   if (defined($self->serverid())) {

      return($self->serverid());

   } else {

      # Determine the TelAlert server's IP address
      my $ip = $self->getMyIP;

      # Get the recid for this server's ip address
      my $serverid = $self->getTelAlertServerIDByName($ip);
      $self->serverid($serverid);
      return($serverid);
   }
} # End of getTelAlertServerID



#----------------------------------------------
sub getCustomers {

  my ($self) = @_;

  # Get all customer recids
  my $sql_statement = sprintf<<EOSQL;
SELECT recid,description
FROM   customer
ORDER BY recid
EOSQL

  # Fetch the data
  my $rows_ref   = $self->dbexec($sql_statement);

  # Build a hash
  my %names;
  map($names{$_->[0]} = $_->[1], @$rows_ref);

  return \%names;


} # End of getCustomers



#----------------------------------------------
sub getServiceProbes {

  my ($self) = @_;

  # Get all customer recids
  my $sql_statement = sprintf<<EOSQL;
SELECT recid,description
FROM   customer
ORDER BY recid
EOSQL

  # Fetch the data
  my $rows_ref   = $self->dbexec($sql_statement);

  # Build a hash
  my %names;
  map($names{$_->[0]} = $_->[1], @$rows_ref);

  return \%names;


} # End of getServiceProbes



#----------------------------------------------
sub getServiceProbesByHost {

  my($self, $hostid) = @_;

  # Get all customer recids
  my $sql_statement = sprintf<<EOSQL;
SELECT svc.recid,svc.description
FROM   probes host, probes svc
WHERE  svc.parent_probes_id = host.recid
AND    host.recid = ?
EOSQL

  # Fetch the data
  my $rows_ref   = $self->dbexec($sql_statement, $hostid);

  # Build a hash
  my %names;
  map($names{$_->[0]} = $_->[1], @$rows_ref);

  return \%names;


} # End of getServiceProbesByHost



#----------------------------------------------
sub getDescByServiceid {

  # Get the service description for a particular service probe

  my ($self, $svcid) = @_;

  my $sql_statement = sprintf<<EOSQL;
     SELECT description
     FROM    probes
     WHERE  recid = ?
     AND    probe_type = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $svcid, 'ServiceProbe');

  # Return the hostname
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  }


} # End of getDescByServiceid



#----------------------------------------------
sub getDescByCustomerid {

  # Get the description for a particular customer

  my ($self, $svcid) = @_;

  my $sql_statement = sprintf<<EOSQL;
     SELECT description
     FROM    customer
     WHERE  recid = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $svcid);

  # Return the hostname
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  }


} # End of getDescByCustomerid



#----------------------------------------------
sub getDescBySatelliteid {

  # Get the description for a particular satellite

  my ($self, $svcid) = @_;

  my $sql_statement = sprintf<<EOSQL;
     SELECT description
     FROM    sat_cluster
     WHERE  recid = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $svcid);

  # Return the hostname
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  }


} # End of getDescBySatelliteid


#----------------------------------------------
sub getContactEmailForDestination {

  # Get the email belonging to the destination's contact

  my ($self, $dest_name, $cust_id) = @_;

  my $sql_statement = sprintf<<EOSQL;
           SELECT contact.email_address
           FROM contact_methods, contact
           WHERE contact.recid = contact_methods.contact_id
           AND contact_methods.method_name = ?
           AND contact.customer_id = ?
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $dest_name, $cust_id);

  # Return the email address
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  }


} # End of getContactEmailForDestination

#----------------------------------------------
sub getTicketCaseNumWithDescription {

  # Get the email belonging to the destination's contact

  my ($self, $desc) = @_;

  my $sql_statement = sprintf<<EOSQL;
           SELECT MAX(case_num)
           FROM hd_problem
           WHERE short_desc = ?
     AND trunc(date_mod) + 1 >= trunc(sysdate)
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement, $desc);

  # Return the case number
  if (scalar(@$rows_ref)) {
    return $rows_ref->[0]->[0];
  } else {
    return undef;
  }

    
} # End of getTicketCaseNumWithDescription


#----------------------------------------------

sub updateTicketProblemWithCaseNum {

  my ($self, $casenum, $problem) = @_;
  my $p='';

  my $sql_statement = sprintf<<EOSQL;
           SELECT problem
           FROM hd_problem
           WHERE case_num = '$casenum'
EOSQL

  # Get the data
  my $rows_ref = $self->dbexec($sql_statement);

  # Return the case number
  if (scalar(@$rows_ref)) {
    $p=$rows_ref->[0]->[0];
  };  

  $p .= "$problem\n";
  $p =~ s/'/''/g;
  $p =~ s/'''/''/g;

  $sql_statement = "
    UPDATE innovate.hd_problem
    SET
      problem = '$p [' || TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS AM') || ']\n',
      status = 'Pending'
    WHERE 
      case_num = '$casenum'";

  $self->dbexec($sql_statement);

  $self->commit();

  return length($@);

}

#----------------------------------------------
sub putStates {
 
  # Save details of a new alert into the DB
  my ($self, @args) = @_;
  my @fields = qw(tel_args message ticket_id destination_name
          host_probe_id host_state service_probe_id service_state
      customer_id netsaint_id probe_type event_timestamp);
  my ($next_recid, %args);

  @args{@fields} = @args;

  # Get a good recid for the CURRENT_ALERTS table
  my $sql_statement = "
    SELECT CURRENT_ALERTS_RECID_SEQ.NEXTVAL
    FROM dual";
  my $rows_ref  = $self->dbexec($sql_statement);
  $next_recid = $rows_ref->[0]->[0];

  # Construct the other fields
  my $serverid = $self->getTelAlertServerID();
  
  # Populate the current_alerts table
  $sql_statement = "
    INSERT INTO current_alerts
      (recid, date_submitted, last_server_change, date_completed,
      original_server, current_server, tel_args, message, ticket_id,
      destination_name, escalation_level, host_probe_id, host_state,
      service_probe_id, service_state, customer_id, netsaint_id,
      probe_type, last_update_date, event_timestamp)
    VALUES (?,
     sysdate,
     sysdate,
   NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
     sysdate, TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS')
     )";

  my @array=($sql_statement,
      $next_recid,
      $serverid, $serverid, $args{'tel_args'}, $args{'message'},
      $args{'ticket_id'}, $args{'destination_name'}, 0,
      $args{'host_probe_id'}, $args{'host_state'},
      $args{'service_probe_id'}, $args{'service_state'},
      $args{'customer_id'}, $args{'netsaint_id'},
      $args{'probe_type'}, $args{'event_timestamp'});
 
  $self->dbexec(@array);
 
  $self->commit();

} # End of putStates

#----------------------------------------------
sub clearAlert {

  # Set a complete date on an alert in the database
  my ($self, $ticketid) = @_;


  # Update the current_alerts table
  my $sql_statement = "
    UPDATE current_alerts
    SET date_completed=sysdate,
    last_update_date=sysdate
    WHERE ticket_id  = ?
  ";

  my ($dataref,$errcode,$errstring,$sql,@bindvars)=
     $self->dbexec($sql_statement, $ticketid);
  return ($dataref,$errcode,$errstring,$sql,@bindvars) if $errcode;

  my ($commit_code,$commit_err)=$self->commit();
  return ($dataref,$commit_code,$commit_err,$sql,@bindvars) if $commit_code;

  return ($dataref,$errcode,$errstring,$sql,@bindvars);

} # End of clearAlert



#----------------------------------------------
sub desc {
  my($self, $tablename) = @_;

  my $sql = "SELECT   LOWER(t.column_name),t.data_type,
                      t.data_precision,t.nullable
             FROM     all_tab_columns t, all_synonyms s
             WHERE    UPPER(t.table_name) = UPPER(?)
             AND      t.table_name = s.table_name
       AND      t.owner = s.table_owner
         AND      s.owner = 'PUBLIC'
             ORDER BY t.column_id";

#  my $sql = "SELECT   LOWER(t.column_name),t.data_type,
#                      t.data_precision,t.nullable
#             FROM     all_tab_columns t
#             WHERE    UPPER(t.table_name) = UPPER(?)
#             ORDER BY t.column_id";

#  my $output = $self->dbexec($sql, $tablename);
  my $output = $self->dbexec($sql, $tablename);

  return $output;
}





#----------------------------------------------
sub getTable {
  # Load an entire DB table into a Perl data structure
  my($self, $tablename, $keyfield, $notunique) = @_;

  # Return table from cache if it exists there
  if ($self->tablecache) {
  return $TABLE{"$tablename.$keyfield"} if ($TABLE{"$tablename.$keyfield"});
  }


  # Get table description
  my $tabledesc = $self->desc($tablename);

  # Apply any formats
  my (@fspecs, @fields);
  my $row;
  foreach $row (@$tabledesc) {
  my($colname, $type, $size, $nullable) = @$row;
  push(@fields, $colname);
  if ($type eq 'DATE') {
    push(@fspecs, sprintf("TO_CHAR(%s, '%s')", $colname, $self->dateformat));
  } else {
    push(@fspecs, $colname);
  }
  }

  my $fields = join(",", @fspecs);

  # Now load the table into a hash
  my $sql = "SELECT $fields FROM $tablename";

  my $output = $self->dbexec($sql);

  my $record;
  my %table;
  foreach $record (@$output) {
  my %field;
  @field{@fields} = @$record;
  if ($notunique) {
    push(@{$table{$field{$keyfield}}}, \%field);
  } else {
    $table{$field{$keyfield}} = \%field;
  }
  }


  $TABLE{"$tablename.$keyfield"} = \%table if ($self->tablecache);
  return \%table;

}  # End of getTable

#----------------------------------------------

sub getCursorForStatement {
   my ($self, $sql_statement) = @_;

   # Make sure we have an open DB handle
   $self->connect() unless ($self->connected());
   return undef unless ($self->connected());

   # Prepare the statement handle
   my $statement_handle = $self->dbh->prepare($sql_statement);
   if (!$statement_handle) {print STDERR "$sql_statement\n"; $@ = $DBI::errstr ;  return undef }

   # Execute the query
   my $rc = $statement_handle->execute();
   if (!$rc) {$@ = $DBI::errstr ;  return undef }

   return $statement_handle;

}
#----------------------------------------------

sub getTableCursor {
   my ($self, $tableName) = @_;
   my $sql_statement="select * from $tableName";

   return $self->getCursorForStatement($sql_statement);
}


#----------------------------------------------
sub clearTableCache {

  my($self, $tablename, $keyfield) = @_;

  if (defined($tablename) && defined($keyfield)) {

  # Clear out the specified cache entry
  delete($TABLE{"$tablename.$keyfield"});

  } elsif (defined($tablename)) {

  # Clear out all cache entries for this table
  my $key;
  foreach $key (keys %TABLE) {
    if ($key =~ /^$tablename\./) {
    delete($TABLE{$key});
    }
  }

  } else {

  # Clear the table cache
  %TABLE = ();

  }
}

sub bumpEscalation {
  my ($self, $ticket_id) = @_;

  my $sql = "SELECT ESCALATION_LEVEL " .
    "FROM CURRENT_ALERTS " .
    "WHERE TICKET_ID = ?";

  my ($rows_ref,$errcode,$errstring,$sql_statement,@bindvars) = 
    $self->dbexec($sql, $ticket_id);
  if ($errcode) {
    return($rows_ref,$errcode,$errstring,$sql_statement,@bindvars);
  }

  my %escalate_to = ('NULL' => '1', 'NOT NULL' => 'ESCALATION_LEVEL + 1');
  foreach my $row (@$rows_ref) {
    my $isnull = (defined($row->[0]) ? 'NOT NULL' : 'NULL');

    $sql = "UPDATE CURRENT_ALERTS " .
      "SET ESCALATION_LEVEL = $escalate_to{$isnull}, " .
      "last_update_date = sysdate" .
      "WHERE TICKET_ID = ? " .
      "AND ESCALATION_LEVEL IS $isnull";

    my ($rows_ref,$errcode,$errstring,$sql_statement,@bindvars) = 
      $self->dbexec($sql, $ticket_id);
    if ($errcode) {
      return($rows_ref,$errcode,$errstring,$sql_statement,@bindvars);
    }
  }

  $self->commit();
  return($rows_ref,$errcode,$errstring,$sql_statement,@bindvars);
}

sub send_as_snmp_trap {
  my ($self,$output,@bindvars)= @_; 

#  $sender_cluster_id, $dest_ip, $dest_port, $date_generated, 
#  $command_name, $notif_type, $op_center, $os_name, $message, $probe_id, 
#  $host_ip, $severity, $command_id, $probe_class, $host_name) = @bindvars;  

  my $sql="
    INSERT INTO SNMP_ALERT 
    ( RECID, 
      SENDER_CLUSTER_ID, DEST_IP, DEST_PORT, DATE_GENERATED, DATE_SUBMITTED, 
      COMMAND_NAME, NOTIF_TYPE, OP_CENTER, NOTIF_URL, OS_NAME, MESSAGE, PROBE_ID, 
      HOST_IP, SEVERITY, COMMAND_ID, PROBE_CLASS, HOST_NAME, SUPPORT_CENTER ) 
    SELECT SNMP_ALERT_RECID_SEQ.NEXTVAL,
      ?, ?, ?, TO_DATE(?,'DY MON  DD HH24:MI:SS YYYY'), SYSDATE, 
      ?, ?, ?, ?, ?, ?, ?, 
      ?, ?, ?, ?, ?, NULL from DUAL";

  my @array=$self->dbexecute($sql,@bindvars); 

  $self->commit();
  return @array;
}
 
1;
