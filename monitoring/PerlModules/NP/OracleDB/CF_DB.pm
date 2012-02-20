######################################
package NOCpulse::CF_DB;
######################################

use vars qw($VERSION @ISA);
$VERSION = (split(/\s+/,
           q$Id: CF_DB.pm,v 1.33 2005-02-14 17:31:59 kja Exp $,
           4))[2];

use strict;
use NOCpulse::OracleDB;

@ISA = qw(NOCpulse::OracleDB);


###############################################
# Generic Class Methods
###############################################

sub username{ 
  my $self=shift;
  my $result = $self->_elem('username',     @_); 
  unless (@_) {
    # in case no one set the username
    return $self->dbuname() unless $result
  }
  return $result
}

##############
sub setDebug {
##############
  &NOCpulse::OracleDB::setDebug(@_);
}

####################
sub setDebugParams {
####################
  &NOCpulse::OracleDB::setDebugParams(@_);
}



###############################################
# CF_DB-specific Generic Methods
###############################################

#########
sub new {
#########
  my ($class) = shift;
  my $conf    = shift;
  my $self    = new NOCpulse::OracleDB($conf);
  bless $self, $class;

  # Set database parameters from config values
  $self->dbd(      $self->cfg->get('cf_db', 'dbd')      );
  $self->dbname(   $self->cfg->get('cf_db', 'name')     );
  $self->dbuname(  $self->cfg->get('cf_db', 'username') );
  $self->dbpasswd( $self->cfg->get('cf_db', 'password') );

  return $self;
}





###############################################
# CF_DB-specific SQL Base Methods
###############################################

#################
sub CQ_Commands {
#################

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = "RHN_COMMAND_QUEUE_COMMANDS";
  my $idseq  = "rhn_command_q_comm_recid_seq.NEXTVAL";
  my $keycol = 'RECID';
  my @cols   = qw(RECID            DESCRIPTION
                  NOTES            COMMAND_LINE
                  PERMANENT        RESTARTABLE 
                  EFFECTIVE_USER   EFFECTIVE_GROUP
                  LAST_UPDATE_USER LAST_UPDATE_DATE);
  my $idnum;

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    my $rv = $self->dbexec("SELECT $idseq FROM dual");
    $idnum = $rv->[0]->[0];
    unshift(@$whereclauses, '?');
    unshift(@$bindvars, $idnum);
    push(@$whereclauses, sprintf("'%s'", $self->username), 'current_timestamp');

  } elsif ($action eq 'select') {

    # Use the configured date format for selecting dates
    my $col;
    foreach $col (@cols) {
      if ($col =~ /^DATE_/ or $col =~ /_DATE$/) {
        $col = sprintf("TO_CHAR(%s, '%s') as %s", 
	                                 $col, $self->dateformat, $col);
      }
    }

  }

  my @rv =  $self->TableOp($table, \@cols, $keycol, $action, 
			   $whereclauses, $bindvars, $orderby);

  if ($action eq 'insert') {
    return $@ ? undef : $idnum;
  } else {
    return @rv;
  }

  

} # End of CQ_Commands



##################
sub CQ_Instances {
##################

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = "RHN_COMMAND_QUEUE_INSTANCES";
  my $idseq  = "rhn_command_q_inst_recid_seq.NEXTVAL";
  my $keycol = 'RECID';
  my @cols   = qw(RECID            COMMAND_ID          NOTES            
                  EXPIRATION_DATE  NOTIFY_EMAIL        TIMEOUT
                  DATE_SUBMITTED   LAST_UPDATE_USER    LAST_UPDATE_DATE);
  my $idnum;

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    my $rv = $self->dbexec("SELECT $idseq FROM dual");
    $idnum = $rv->[0]->[0];
    unshift(@$whereclauses, '?');
    unshift(@$bindvars, $idnum);
    push(@$whereclauses, 'current_timestamp', sprintf("'%s'", $self->username), 'current_timestamp');

  } elsif ($action eq 'select') {

    # Use the configured date format for selecting dates
    my $col;
    foreach $col (@cols) {
      if ($col =~ /^DATE_/ or $col =~ /_DATE$/) {
        $col = sprintf("TO_CHAR(%s, '%s') as %s", 
	                                 $col, $self->dateformat, $col);
      }
    }

  }

  my @rv =  $self->TableOp($table, \@cols, $keycol, $action, 
			   $whereclauses, $bindvars, $orderby);

  if ($action eq 'insert') {
    return $@ ? undef : $idnum;
  } else {
    return @rv;
  }

} # End of CQ_Instances




##############
sub CQ_Execs {
##############

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = "RHN_COMMAND_QUEUE_EXECS";
  my $keycol = 'INSTANCE_ID,NETSAINT_ID';
  my @cols   = qw(INSTANCE_ID      NETSAINT_ID       TARGET_TYPE
                  DATE_ACCEPTED    DATE_EXECUTED     
		  EXIT_STATUS      EXECUTION_TIME
		  STDOUT           STDERR
                  LAST_UPDATE_DATE
                  );

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    push(@$whereclauses, 'current_timestamp');

  } elsif ($action eq 'select') {

    # Use the configured date format for selecting dates
    my $col;
    foreach $col (@cols) {
      if ($col =~ /^DATE_/ or $col =~ /_DATE$/) {
        $col = sprintf("TO_CHAR(%s, '%s') as %s", 
	                                 $col, $self->dateformat, $col);
      }
    }

  }

  return $self->TableOp($table, \@cols, $keycol, $action, 
			$whereclauses, $bindvars, $orderby);

} # End of CQ_Execs


###############
sub CQ_Params {
###############

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = "RHN_COMMAND_QUEUE_PARAMS";
  my $keycol = 'INSTANCE_ID,ORD';
  my @cols   = qw(INSTANCE_ID ORD VALUE);

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    # Nothing special

  } elsif ($action eq 'select') {

    # Nothing special

  }

  return $self->TableOp($table, \@cols, $keycol, $action, 
			$whereclauses, $bindvars, $orderby);

} # End of CQ_Params



#################
sub CQ_Sessions {
#################

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = "RHN_COMMAND_QUEUE_SESSIONS";
  my $keycol = 'CONTACT_ID';
  my @cols   = qw(CONTACT_ID SESSION_ID EXPIRATION_DATE
                  LAST_UPDATE_USER LAST_UPDATE_DATE);

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    push(@$whereclauses, sprintf("'%s'", $self->username), 'current_timestamp');

  } elsif ($action eq 'select') {

    # Use the configured date format for selecting dates
    my $col;
    foreach $col (@cols) {
      if ($col =~ /^DATE_/ or $col =~ /_DATE$/) {
        $col = sprintf("TO_CHAR(%s, '%s') as %s", 
	                                 $col, $self->dateformat, $col);
      }
    }

  }

  my @rv =  $self->TableOp($table, \@cols, $keycol, $action, 
			   $whereclauses, $bindvars, $orderby);

  if ($action eq 'insert' || $action eq 'update') {
    return $@ ? undef : 1;
  } else {
    return @rv;
  }

  

} # End of CQ_Sessions



##############
sub Customer {
##############

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = 'RHN_CUSTOMER_MONITORING';
  my $idseq  = 'CUSTOMER_RECID_SEQ.NEXTVAL';
  my $keycol = 'RECID';

  my @cols   = qw( RECID DESCRIPTION DELETED LAST_UPDATE_USER LAST_UPDATE_DATE
                   SCHEDULE_ID DEF_ACK_WAIT DEF_STRATEGY PREFERRED_TIME_ZONE
                   AUTO_UPDATE TYPE 
		  );
		  
  my $idnum;

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    my $rv = $self->dbexec("SELECT $idseq FROM dual");
    $idnum = $rv->[0]->[0];
    unshift(@$whereclauses, '?');
    unshift(@$bindvars, $idnum);
    push(@$whereclauses, sprintf("'%s'", $self->username), 'current_timestamp');

  } elsif ($action eq 'select') {

    # Use the configured date format for selecting dates
    my $col;
    foreach $col (@cols) {
      if ($col =~ /^DATE_/ or $col =~ /_DATE$/) {
        $col = sprintf("TO_CHAR(%s, '%s') as %s", 
	                                 $col, $self->dateformat, $col);
      }
    }

  }

  my @rv =  $self->TableOp($table, \@cols, $keycol, $action, 
			   $whereclauses, $bindvars, $orderby);

  if ($action eq 'insert') {
    return $@ ? undef : $idnum;
  } else {
    return @rv;
  }
  

} # End of Customer

##############
sub Netsaint {
##############

    # as of 2.10 the netsaint table no longer exists
    # This routine is now taken to mean "sat_cluster"

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = 'RHN_SAT_CLUSTER';
  my $idseq  = 'COMMAND_TARGET_RECID_SEQ.NEXTVAL';
  my $keycol = 'RECID';

  my @cols   = qw(RECID TARGET_TYPE CUSTOMER_ID DESCRIPTION LAST_UPDATE_USER
		  LAST_UPDATE_DATE PHYSICAL_LOCATION_ID PUBLIC_KEY
		  VIP DEPLOYED PEM_PUBLIC_KEY PEM_PUBLIC_KEY_HASH
		  );
		  
  my $idnum;

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    my $rv = $self->dbexec("SELECT $idseq FROM dual");
    $idnum = $rv->[0]->[0];
    unshift(@$whereclauses, '?');
    unshift(@$bindvars, $idnum);
    push(@$whereclauses, sprintf("'%s'", $self->username), 'current_timestamp');

  } elsif ($action eq 'select') {

    # Use the configured date format for selecting dates
    my $col;
    foreach $col (@cols) {
      if ($col =~ /^DATE_/ or $col =~ /_DATE$/) {
        $col = sprintf("TO_CHAR(%s, '%s') as %s", 
	                                 $col, $self->dateformat, $col);
      }
    }

  }

  my @rv =  $self->TableOp($table, \@cols, $keycol, $action, 
			   $whereclauses, $bindvars, $orderby);

  if ($action eq 'insert') {
    return $@ ? undef : $idnum;
  } else {
    return @rv;
  }
  

} # End of Netsaint

##########
sub Node {
##########

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = 'RHN_SAT_NODE';
  my $idseq  = 'COMMAND_TARGET_RECID_SEQ.NEXTVAL';
  my $keycol = 'RECID';

  my @cols   = qw(RECID
                  TARGET_TYPE
                  LAST_UPDATE_USER
                  LAST_UPDATE_DATE
                  MAC_ADDRESS
                  MAX_CONCURRENT_CHECKS
                  SAT_CLUSTER_ID
                  IP
                  SCHED_LOG_LEVEL
                  SPUT_LOG_LEVEL
                  DQ_LOG_LEVEL
                  );

  my $idnum;

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    my $rv = $self->dbexec("SELECT $idseq FROM dual");
    $idnum = $rv->[0]->[0];
    unshift(@$whereclauses, '?');
    unshift(@$bindvars, $idnum);
    push(@$whereclauses, sprintf("'%s'", $self->username), 'current_timestamp');

  } elsif ($action eq 'select') {

    # Use the configured date format for selecting dates
    my $col;
    foreach $col (@cols) {
      if ($col =~ /^DATE_/ or $col =~ /_DATE$/) {
        $col = sprintf("TO_CHAR(%s, '%s') as %s",
                                         $col, $self->dateformat, $col);
      }
    }

  }

  my @rv =  $self->TableOp($table, \@cols, $keycol, $action,
                           $whereclauses, $bindvars, $orderby);

  if ($action eq 'insert') {
    return $@ ? undef : $idnum;
  } else {
    return @rv;
  }

}

#################
sub LL_Netsaint {
#################

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = 'RHN_LL_NETSAINT';
  my $keycol = 'NETSAINT_ID';
  my @cols   = qw(NETSAINT_ID CITY);
  my $idnum;

  if ($action eq 'columns') {

    return @cols;

  }

  my @rv =  $self->TableOp($table, \@cols, $keycol, $action, 
			   $whereclauses, $bindvars, $orderby);

  if ($action eq 'insert') {
    return $@ ? undef : $idnum;
  } else {
    return @rv;
  }

  

} # End of LL_Netsaint





#############
sub Contact {
#############

  my $self          = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];

  my $table  = "RHN_CONTACT_MONITORING";
  my $idseq  = "CONTACT_RECID_SEQ";
  my $keycol = 'RECID';
  my @cols   = qw( RECID                       CUSTOMER_ID
                   CONTACT_LAST_NAME           CONTACT_FIRST_NAME
                   EMAIL_ADDRESS               PAGER
                   USERNAME                    PASSWORD
                   ROLES                       DELETED
                   SCHEDULE_ID                 NUM_USERID
                   PASSWORD_QUESTION           PASSWORD_ANSWER
                   PREFERRED_TIME_ZONE
                   SECURITY_ACCESS_VULNERABILITY
                   SECURITY_ACCESS_MANAGEMENT
                   FAILED_LOGINS               PRIVILEGE_TYPE_NAME
                   TASERIAL
                   LAST_UPDATE_USER            LAST_UPDATE_DATE
                  );
  my $idnum;

  if ($action eq 'columns') {

    return @cols;

  } elsif ($action eq 'insert') {

    my $rv = $self->dbexec("SELECT $idseq FROM dual");
    $idnum = $rv->[0]->[0];
    unshift(@$whereclauses, '?');
    unshift(@$bindvars, $idnum);
    push(@$whereclauses, sprintf("'%s'", $self->username), 'current_timestamp');

  } elsif ($action eq 'select') {

    # Use the configured date format for selecting dates
    my $col;
    foreach $col (@cols) {
      if ($col =~ /^DATE_/ or $col =~ /_DATE$/) {
        $col = sprintf("TO_CHAR(%s, '%s') as %s", 
	                                 $col, $self->dateformat, $col);
      }
    }

  }

  my @rv =  $self->TableOp($table, \@cols, $keycol, $action, 
			   $whereclauses, $bindvars, $orderby);

  if ($action eq 'insert') {
    return $@ ? undef : $idnum;
  } else {
    return @rv;
  }

  

} # End of Contact



###############################################
# CF_DB-specific SQL SELECT Methods
###############################################

####################
sub getCQ_Commands {
####################

  my $self    = shift;
  my $orderby = shift;

  # Rigged to deliberately ignore command 1, which is used by the UI
  # and should NOT be used by SputLite (or any other external program).

  my($dataref, $ordref) = 
      $self->CQ_Commands('select', ['recid != ?'], [1], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getCQ_Commands



########################
sub getCQ_CommandsLike {
########################

  my $self    = shift;
  my $desc    = shift;
  my $line    = shift;
  my $orderby = shift;

  # Rigged to deliberately ignore command 1, which is used by the UI
  # and should NOT be used by SputLite (or any other external program).

  my($dataref, $ordref) = 
      $self->CQ_Commands('select', ['recid != ?', 'upper(command_line) like upper(?)', 
                         'upper(description) like upper(?)'], [1, $line, $desc], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

}


##############################
sub getPermanent_CQ_Commands {
##############################

  my $self = shift;
  my $orderby = shift;

  # Rigged to deliberately ignore command 1, which is used by the UI
  # and should NOT be used by SputLite (or any other external program).

  my($dataref, $ordref) = $self->CQ_Commands('select', 
               ['permanent = ?', 'recid != ?'], [1, 1], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getPermanent_CQ_Commands


##################################
sub getPermanent_CQ_CommandsLike {
##################################

  my $self    = shift;
  my $desc    = shift;
  my $line    = shift;
  my $orderby = shift;

  # Rigged to deliberately ignore command 1, which is used by the UI
  # and should NOT be used by SputLite (or any other external program).

  my($dataref, $ordref) = $self->CQ_Commands('select', 
             ['permanent = ?', 'recid != ?','upper(description) like upper(?)', 
              'upper(command_line) like upper(?)'], [1, 1, $desc, $line ], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

}


############################
sub getCQ_Command_by_recid {
############################

  my $self    = shift;
  my $cid     = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->CQ_Commands('select', ['recid = ?'], [$cid], $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getCQ_Commands


#####################
sub getCQ_Instances {
#####################

  my $self = shift;
  my $orderby = shift;

  my($dataref, $ordref) = $self->CQ_Instances('select', [], [], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getCQ_Instances


#############################
sub getCQ_Instance_by_recid {
#############################

  my $self    = shift;
  my $iid     = shift;
  my $orderby = shift;

  my($dataref, $ordref) =
	$self->CQ_Instances('select', ['recid = ?'], [$iid], $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getCQ_Instances


#################
sub getCQ_Execs {
#################

  my $self = shift;
  my $orderby = shift;

  my($dataref, $ordref) = $self->CQ_Execs('select', [], [], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getCQ_Execs



################################
sub getCQ_Execs_by_instance_id {
################################

  my $self    = shift;
  my $iid     = shift;
  my $orderby = shift;

  my($dataref, $ordref) =
	$self->CQ_Execs('select', ['instance_id = ?'], [$iid], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getCQ_Execs_by_instance_id


####################################
sub getCQ_Execs_by_instance_target {
####################################

  my $self    = shift;
  my $iid     = shift;
  my $nsid    = shift;
  my $type    = shift;
  my $orderby = shift;

  my($dataref, $ordref) =
      $self->CQ_Execs('select', ['instance_id = ?', 'netsaint_id = ?', 'target_type = ?'], 
		      [$iid, $nsid, $type], $orderby);
  
  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getCQ_Execs_by_instance_netsaint


###############################################
sub getUnexpiredCQ_Execs_by_instance_netsaint {
###############################################

  my $self    = shift;
  my $iid     = shift;
  my $nsid    = shift;
  my $orderby = shift;

  my $tables   = "rhn_command_queue_instances ins,rhn_command_queue_execs exec";

  my @execcols = (map("exec.$_", $self->CQ_Execs('columns')));

  my @where    = ("netsaint_id = ?", 
                  "instance_id = ?",
		  "instance_id = ins.recid",
		  "expiration_date > current_timestamp");

  my @bind     = ($nsid, $iid); 

  my $col;
  foreach $col (@execcols) {
    if ($col =~ /^date_|_date$/i) {
      $col = sprintf("TO_CHAR(%s, '%s') as %s", $col, $self->dateformat, $col);
    }
  }

  my ($dataref, $ordref) =  $self->TableOp($tables, \@execcols, 'instance_id', 
                                           'select', \@where, \@bind, $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {

    # Remove the table prefix from column names in the return value
    my $record = $dataref->{$ordref->[0]};
    my($rv, $key);
    foreach $key (keys %$record) {
      print "+++\tKEY: $key\n";
      my $newkey = $key; $newkey =~ s/^.*\.//;
      $rv->{$newkey} = $record->{$key};
    }

    return $rv;

  } else {

    return undef;

  }

} # End of getCQ_Execs_by_instance_netsaint




###################################
sub getCurrent_CQ_Execs_by_target {
###################################

  my $self    = shift;
  my $nsid    = shift;
  my $type    = shift;
  my $orderby = shift;

  my @cols   = qw(instance_id netsaint_id command_line effective_user 
                  effective_group restartable notify_email timeout target_type);

$self->dprint(1, "*** *** DATEFORMAT IS:  ", $self->dateformat, " *** ***");
  push(@cols, sprintf("TO_CHAR(expiration_date, '%s') as expdate", 
                      $self->dateformat));

  my $tables = "rhn_command_queue_commands cmd, rhn_command_queue_instances ins," .
               "rhn_command_queue_execs exec";

  my @where  = ("netsaint_id = ?",
		"target_type = ?",
                "exec.instance_id = ins.recid",
		"ins.command_id = cmd.recid",
                "date_executed is null",
                "expiration_date > current_timestamp");

  $nsid = ($nsid eq 'NULL' or $nsid eq '' ? undef : $nsid);
  my @bind   = ($nsid, $type);

  my ($dataref, $ordref) =  $self->TableOp($tables, \@cols, 'instance_id', 
                                           'select', \@where, \@bind, $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getCurrent_CQ_Execs_by_netsaint_id


##################
sub getCQ_Params {
##################

  my $self    = shift;
  my $orderby = shift;

  my($dataref, $ordref) =
        $self->CQ_Params('select', [], [], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getCQ_Params


#################################
sub getCQ_Params_by_instance_id {
#################################

  my $self    = shift;
  my $iid     = shift;
  my $orderby = shift;

  my($dataref, $ordref) =
	$self->CQ_Params('select', ['instance_id = ?'], [$iid], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getCQ_Params_by_instance_id





##############################
sub getCQ_SessionBySessionId {
##############################

  my $self    = shift;
  my $sid     = shift;

  my($dataref, $ordref) = 
    $self->CQ_Sessions('select', ['session_id = ?'], [$sid]);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getCQ_SessionsBySessionId





#######################################
sub getUnexpiredCQ_SessionBySessionId {
#######################################

  my $self    = shift;
  my $sid     = shift;

  my($dataref, $ordref) = 
    $self->CQ_Sessions('select', ['session_id = ?', 
                                  'expiration_date > current_timestamp'], [$sid]);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getCQ_SessionsBySessionId


##########################
sub getCustomer_by_recid {
##########################

  my $self    = shift;
  my $cid     = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->Customer('select', ['recid = ?'], [$cid], $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getCustomer_by_recid


##################
sub getNetsaints {
##################

  my $self    = shift;
  my $nsid    = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->Netsaint('select', [], [], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getNetsaints

###################
sub getSatellites {
###################
  goto &getNetsaints;
}


##############
sub getNodes {
##############

  my $self    = shift;
  my $nodeid  = shift;
  my $orderby = shift;

  my($dataref, $ordref) =
    $self->Node('select', [], [], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getNodes


######################
sub getNode_by_recid {
######################

  my $self    = shift;
  my $nsid    = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->Node('select', ['recid = ?'], [$nsid], $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }
}


##########################
sub getNetsaint_by_recid {
##########################

  my $self    = shift;
  my $nsid    = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->Netsaint('select', ['recid = ?'], [$nsid], $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getNetsaint_by_recid


###########################
sub getSatellite_by_recid {
###########################
  goto &getNetsaint_by_recid;
}

###########################
sub getNetsaints_by_recid {
###########################

  my $self     = shift;
  my $nsid     = shift;
  my $orderby  = shift;
  my @nsids    = @$nsid;
  my @bindvars = map('?', @nsids);

  my($dataref, $ordref) = 
    $self->Netsaint('select', ['recid in (' . join(',', @bindvars) . ')'], 
                              [@nsids], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getNetsaints_by_recid




################################
sub getNetsaint_by_customer_id {
################################

  my $self    = shift;
  my $cid     = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->Netsaint('select', ['customer_id = ?'], [$cid], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getNetsaint_by_recid



#######################
sub getNetsaint_by_ip {
#######################

  my $self  = shift;
  my $ip    = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->Netsaint('select', ['smon_url = ?'], ["http://$ip"], $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getNetsaint_by_ip


########################
sub getNetsaint_by_mac {
########################

  my $self  = shift;
  my $mac    = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->Netsaint('select', ['mac_address = ?'], ["$mac"], $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getNetsaint_by_mac


###################################
sub getLL_Netsaint_by_netsaint_id {
###################################

  my $self    = shift;
  my $nsid    = shift;
  my $orderby = shift;

  my($dataref, $ordref) = 
    $self->LL_Netsaint('select', ['netsaint_id = ?'], [$nsid], $orderby);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getNetsaint_by_mac



##################
sub getCustomers {
##################

  my $self    = shift;
  my $nodeid  = shift;
  my $orderby = shift;

  my($dataref, $ordref) =
    $self->Customer('select', [], [], $orderby);

  return (wantarray ? ($dataref, $ordref) : $dataref);

} # End of getCustomers


##################################
sub getContactByCustomerUsername {
##################################

  my $self     = shift;
  my $customer = shift;
  my $username = shift;

  my($dataref, $ordref) = 
    $self->Contact('select', ['username = ?', 'customer_id = ?'], 
                             [$username, $customer]);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getContactByCustomerUsername



####################
sub getContactById {
####################

  my $self     = shift;
  my $recid    = shift;

  my($dataref, $ordref) = 
    $self->Contact('select', [ 'recid = ?' ], 
                             [ $recid ]);

  # This query should only return one row, so just return the record.
  if (scalar(@$ordref)) {
    return $dataref->{$ordref->[0]};
  } else {
    return undef;
  }

} # End of getContactById



###############################################
# CF_DB-specific SQL INSERT/UPDATE Methods
###############################################

######################
sub createCQ_Command {
######################

  my $self = shift;
  # Arguments: 
  #   0:RECID       1:DESCRIPTION   2:NOTES            3:COMMAND_LINE 
  #   4:PERMANENT   5:RESTARTABLE   6:EFFECTIVE_USER   7:EFFECTIVE_GROUP

  $self->CQ_Commands('insert', [qw(? ? ? ? ? ? ?)], \@_);

} # End of createCQ_Command


#######################
sub createCQ_Instance {
#######################

  my $self     = shift;

  # Arguments:
  #   0:COMMAND_ID  1:NOTES  2:EXPIRATION_DATE  3:NOTIFY_EMAIL  4:TIMEOUT

  # Pass date value verbatim; use bind variables for the rest.
  my @bindvars = qw(? ? ? ? ?);
  $bindvars[2] = splice(@_, 2, 1);

  $self->CQ_Instances('insert', \@bindvars, \@_);

} # End of createCQ_Instance



###################
sub createCQ_Exec {
###################

  my $self = shift;
  # Arguments:
  #   0:INSTANCE_ID   1:NETSAINT_ID      2:TARGET_TYPE    3:DATE_ACCEPTED  4:DATE_EXECUTED 
  #   5:EXIT_STATUS   6:EXECUTION_TIME   7:STDOUT         8:STDERR

  my @bindvars = qw(? ? ? ? ? ? ? ? ?);
  push(@_, undef, undef, undef, undef, undef, undef);

  $self->CQ_Execs('insert', \@bindvars, \@_); 

} # End of createCQ_Exec



###################
sub updateCQ_Exec {
###################

  my $self     = shift;
  my $iid      = shift;
  my $nsid     = shift;
  my $target_type = shift;
  my $values   = shift;
  my $where    = ['instance_id = ?', 'netsaint_id = ?', 'target_type = ?'];
  my $bindvars = shift || [];
  push(@$bindvars, $iid, $nsid, $target_type);

  # Arguments:
  #   0:INSTANCE_ID   1:NETSAINT_ID      [VALUES TO SET]

  $self->CQ_Execs('update', $where, $bindvars, $values); 


} # End of updateCQ_Exec


####################
sub createCQ_Param {
####################

  my $self = shift;
  # Arguments:
  #   0:INSTANCE_ID   1:ORD      2:VALUE

  my @bindvars = qw(? ? ?);

  $self->CQ_Params('insert', \@bindvars, \@_); 

} # End of createCQ_Param





#############################
sub updateNetsaintPublicKey {
#############################

  my $self     = shift;
  my $nsid     = shift;
  my $key      = shift;
  my $where    = ['recid = ?'];
  my $bindvars = shift || [];
  push(@$bindvars, $nsid);

  # Arguments:
  #   0:NETSAINT_ID      1:PUBLIC_KEY

  $self->Netsaint('update', $where, $bindvars, ["public_key = '$key'"]); 


} # End of updateNetsaintPublicKey




######################
sub createCQ_Session {
######################

  my $self     = shift;
  my $contact  = shift;
  my $sid      = shift;
  my $exp      = shift;
  my $bindvars = [];

  # Arguments:
  #   0:CONTACT_ID         1:SESSION_ID       2:EXPIRATION_DATE (Unix time)

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($exp);
  my $expdate = sprintf("%-04d-%-02d-%-02d %-02d:%-02d:%-02d",
                         $year+1900, $mon+1, $mday, $hour, $min, $sec);

  my $values   = ['?', '?', "TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS')"];
  push(@$bindvars, $contact, $sid, $expdate);

  $self->CQ_Sessions('insert', $values, $bindvars); 

} # End of createCQ_Session


######################
sub updateCQ_Session {
######################

  my $self     = shift;
  my $contact  = shift;
  my $sid      = shift;
  my $exp      = shift;
  my $bindvars = [];

  # Arguments:
  #   0:CONTACT_ID         1:SESSION_ID       2:EXPIRATION_DATE (Unix time)

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($exp);
  my $expdate = sprintf("%-04d-%-02d-%-02d %-02d:%-02d:%-02d",
                         $year+1900, $mon+1, $mday, $hour, $min, $sec);

  my $values   = ['session_id = ?',
                  "expiration_date = TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS')"]; 

  push(@$bindvars, $sid, $expdate);

  my $where    = ['contact_id = ?'];
  push(@$bindvars, $contact);

  $self->CQ_Sessions('update', $where, $bindvars, $values); 

} # End of updateCQ_Session

#################
sub get_sysdate {
#################
  my $self = shift();

  my $statement = sprintf("SELECT TO_CHAR(current_timestamp, '%s') as current_time FROM dual",$self->dateformat);
  my $ref       = $self->dbexec($statement);

  return $ref->[0]->[0];
} 
