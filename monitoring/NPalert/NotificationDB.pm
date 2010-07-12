package NOCpulse::Notif::NotificationDB;

use strict;
use Data::Dumper;
use Error qw(:try);
use Date::Parse;
use Date::Format;

use NOCpulse::Config;
use NOCpulse::Probe::DataSource::AbstractDatabase qw(:constants);
use NOCpulse::Probe::DataSource::Oracle;
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

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant ORA_TABLE_NOT_FOUND => 942;

my $cfg = new NOCpulse::Config;

my %INIT_ARGS = (
                 ORACLE_HOME  => $cfg->get('oracle', 'ora_home'),
                 ora_port     => $cfg->get('oracle', 'ora_port'),
                 ora_host     => $cfg->get('hosts',  'cfdb'),
                 ora_sid      => $cfg->get('cf_db',  'name'),
                 ora_user     => $cfg->get('cf_db',  'notification_username'),
                 ora_password => $cfg->get('cf_db',  'notification_password'),
                 use_tnsnames => 1,
                );

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

# Constants

use constant DEF_DB_DATE_FMT      => 'MM-DD-YYYY HH24:MI:SS';
use constant SORTABLE_DB_DATE_FMT => 'YYYYMMDDHH24MISS';
use constant DEF_UNIX_DATE_FMT    => '%m-%d-%Y %H:%M:%S';

# Global variable initialization
use vars qw(%DETAIL);

##########
sub init {
##########
  my $self = shift;
  my %args = (%INIT_ARGS, @_);

  $self->SUPER::init(\%field_map, %args);
  $self->timeout_seconds(60);
  $self->pre_init_details();

  return $self;
} ## end sub init

sub connect {
  my ($self, %paramHash) = @_;
  my $cfg = new NOCpulse::Config;
  $ENV{'ORACLE_HOME'} = $cfg->get('oracle', 'ora_home');
  my $DBD     = $cfg->get('cf_db', 'dbd');
  my $DBNAME  = $cfg->get('cf_db', 'name');
  my $DBUNAME = $cfg->get('cf_db', 'notification_username');
  my $DBPASS  = $cfg->get('cf_db', 'notification_password');

  my $PrintError = $paramHash{PrintError} || 0;
  my $RaiseError = $paramHash{RaiseError} || 0;
  my $AutoCommit = $paramHash{AutoCommit} || 0;

  # Disconnect prior session, if exists
  if ($self->dbh) {
    $self->disconnect;
  }

  # Open a connection to the DB
  my $dbh = DBI->connect("DBI:$DBD:$DBNAME", $DBUNAME, $DBPASS,
                 { RaiseError => $RaiseError, AutoCommit => $AutoCommit });

  return $self->dbh;
}

sub execute {
    my ($self, $sql, $tables_used_arr, $fetch_one, @bind_vars) = @_;

    return $self->SUPER::execute($sql, ORA_TABLE_NOT_FOUND,
                                 $tables_used_arr, $fetch_one, @bind_vars);
}

###################
# RECORD CREATION #
###################

sub create_redirect_email_target {
  shift->_create('RHN_REDIRECT_EMAIL_TARGETS', @_);
}

sub create_redirect_group_target {
  shift->_create('RHN_REDIRECT_GROUP_TARGETS', @_);
}

sub create_redirect_method_target {
  shift->_create('RHN_REDIRECT_METHOD_TARGETS', @_);
}

# Records requiring sequence
sub create_snmp_alert {
  shift->_create_with_seq('RECID', 'RHN_SNMP_ALERT_RECID_SEQ', 'SNMP_ALERT',
                          @_);
}

sub create_current_alert {
  shift->_create_with_seq('RECID', 'RHN_CURRENT_ALERTS_RECID_SEQ',
                          'RHN_RHN_CURRENT_ALERTS', @_);
}

sub create_redirect {
  shift->_create_with_seq('RECID', 'RHN_REDIRECTS_RECID_SEQ', 'RHN_REDIRECTS',
                          @_);
}

sub create_redirect_criteria {
  shift->_create_with_seq('RECID', 'RHN_REDIRECT_CRIT_RECID_SEQ',
                          'RHN_REDIRECT_CRITERIA', @_);
}

#################################
# SINGLE-TABLE RECORD SELECTION #

#################################
# SINGLE-TABLE RECORD SELECTION #
#################################

# # Single record selection
sub select_contact_group { shift->_select_record('RHN_CONTACT_GROUPS', @_) }
sub select_current_alert { shift->_select_record('RHN_CURRENT_ALERTS', @_) }
sub select_customer    { shift->_select_record('RHN_CUSTOMER_MONITORING', @_) }
sub select_host        { shift->_select_record('RHN_HOST_MONITORING',     @_) }
sub select_probe       { shift->_select_record('RHN_PROBE',               @_) }
sub select_redirect    { shift->_select_record('RHN_REDIRECTS',           @_) }
sub select_sat_cluster { shift->_select_record('RHN_SAT_CLUSTER',         @_) }
sub select_snmp_alert  { shift->_select_record('RHN_SNMP_ALERT',          @_) }

# Multiple record selection
sub select_contacts  { shift->_select_records('RHN_CONTACT_MONITORING',  @_) }
sub select_customers { shift->_select_records('RHN_CUSTOMER_MONITORING', @_) }
sub select_hosts     { shift->_select_records('RHN_HOST_MONITORING',     @_) }

sub select_notification_formats {
  shift->_select_records('RHN_NOTIFICATION_FORMATS', @_);
}
sub select_notifservers   { shift->_select_records('RHN_NOTIFSERVERS',   @_) }
sub select_probe_types    { shift->_select_records('RHN_PROBE_TYPES',    @_) }
sub select_redirects      { shift->_select_records('RHN_REDIRECTS',      @_) }
sub select_redirect_types { shift->_select_records('RHN_REDIRECT_TYPES', @_) }

sub select_redirect_email_targets {
  shift->_select_records('RHN_REDIRECT_EMAIL_TARGETS', @_);
}

sub select_redirect_group_targets {
  shift->_select_records('RHN_REDIRECT_GROUP_TARGETS', @_);
}

sub select_redirect_match_types {
  shift->_select_records('RHN_REDIRECT_MATCH_TYPES', @_);
}

sub select_redirect_method_targets {
  shift->_select_records('RHN_REDIRECT_METHOD_TARGETS', @_);
}
sub select_sat_clusters { shift->_select_records('RHN_SAT_CLUSTER', @_) }
sub select_schedules    { shift->_select_records('RHN_SCHEDULES',   @_) }

# Complex selection

################################
# MULTI-TABLE RECORD SELECTION #
################################

############################
sub select_contact_methods {
############################
  my $self   = shift;
  my $table  = 'RHN_CONTACT_METHODS';
  my $table2 = 'RHNUSERINFO';
  my $table3 = 'RHNTIMEZONE';

  my $sql = <<EOSQL;
SELECT 
    $table.contact_id, $table.email_address, $table.method_name, 
    $table.method_type_id, $table.notification_format_id, 
    $table.pager_email, $table.pager_max_message_length, 
    $table.pager_split_long_messages, $table.recid, $table.schedule_id, 
    nvl(substr($table3.olson_name,1,40),'GMT') as olson_tz_id,
    $table.snmp_host, $table.snmp_port
FROM 
    $table, $table2, $table3
WHERE
    $table.contact_id = $table2.user_id
AND $table3.id (+) = $table2.timezone_id
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF);
} ## end sub select_contact_methods

##########################
sub select_schedule_days {
##########################
  my $self  = shift;
  my $table = 'RHN_SCHEDULE_DAYS';
  my $sql   = <<EOSQL;
SELECT 
  RECID, SCHEDULE_ID, ORD, 
  TO_CHAR(START_1,'HH24:MI') AS START_1,
  TO_CHAR(END_1,'HH24:MI') AS END_1,
  TO_CHAR(START_2,'HH24:MI') AS START_2,
  TO_CHAR(END_2,'HH24:MI') AS END_2,
  TO_CHAR(START_3,'HH24:MI') AS START_3,
  TO_CHAR(END_3,'HH24:MI') AS END_3,
  TO_CHAR(START_4,'HH24:MI') AS START_4,
  TO_CHAR(END_4,'HH24:MI') AS END_4,
  LAST_UPDATE_USER, LAST_UPDATE_DATE
FROM 
    $table
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF);
} ## end sub select_schedule_days

#############################
sub select_global_redirects {
#############################
  my $self  = shift;
  my $table = 'RHN_REDIRECTS';

  my $fmt = DEF_DB_DATE_FMT;
  my $sql = <<EOSQL;
      SELECT 
        RECID,
        CUSTOMER_ID,
        CONTACT_ID,
        REDIRECT_TYPE,
        DESCRIPTION,
        REASON,
        TO_CHAR(EXPIRATION,'$fmt') as EXPIRATION,
        LAST_UPDATE_USER,
        TO_CHAR(LAST_UPDATE_DATE,'$fmt') as LAST_UPDATE_DATE,
        TO_CHAR(START_DATE,'$fmt') as START_DATE,
        RECURRING,
        RECURRING_FREQUENCY,
        RECURRING_DURATION
      FROM   $table
      WHERE CUSTOMER_ID is NULL
EOSQL

  my $records = $self->execute($sql, $table, FETCH_ARRAYREF);

  # Convert database string results to unix timestamps
  my ($DATES) = $self->_details($table, 'dates');
  foreach my $record (@$records) {
    foreach my $col (@$DATES) {
      $record->{$col} = $self->string_to_timestamp($record->{$col});
    }
  }
  return $records;
} ## end sub select_global_redirects

#############################
sub select_active_redirects {
#############################
  my $self  = shift;
  my $table = 'RHN_REDIRECTS';

  my $fmt = DEF_DB_DATE_FMT;
  my $sql = <<EOSQL;
      SELECT 
        RECID,
        CUSTOMER_ID,
        CONTACT_ID,
        REDIRECT_TYPE,
        DESCRIPTION,
        REASON,
        TO_CHAR(EXPIRATION,'$fmt') as EXPIRATION,
        LAST_UPDATE_USER,
        TO_CHAR(LAST_UPDATE_DATE,'$fmt') as LAST_UPDATE_DATE,
        TO_CHAR(START_DATE,'$fmt') as START_DATE,
        RECURRING,
        RECURRING_FREQUENCY,
        RECURRING_DURATION
      FROM   $table
      WHERE  EXPIRATION >= SYSDATE
      AND    START_DATE <= SYSDATE + 1
EOSQL

  my $redirptr = $self->execute($sql, $table, FETCH_ARRAYREF);
  my %hash = map {
    $_->{EXPIRATION} = $self->string_to_timestamp($_->{EXPIRATION})
      if $_->{EXPIRATION};
    $_->{START_DATE} = $self->string_to_timestamp($_->{START_DATE})
      if $_->{START_DATE};
    $_->{LAST_UPDATE_DATE} = $self->string_to_timestamp($_->{LAST_UPDATE_DATE});
    $_->{TARGETS}          = [];
    $_->{'RECID'} => $_
  } @$redirptr;

  my $redirect_list = join(',', keys(%hash));

  if ($redirect_list) {
    $table = 'RHN_REDIRECT_EMAIL_TARGETS';
    my $table2 = 'RHN_REDIRECTS';
    $sql = <<EOSQL;
      SELECT 
        $table.REDIRECT_ID as REDIRECT_ID,
        $table.EMAIL_ADDRESS as EMAIL_ADDRESS
      FROM 
        $table, $table2
      WHERE 
        $table2.EXPIRATION >= SYSDATE
        AND    $table2.START_DATE <= SYSDATE + 1
        AND    $table.REDIRECT_ID = $table2.RECID
EOSQL

    my $targetptr = $self->execute($sql, $table, FETCH_ARRAYREF);

    foreach (@$targetptr) {
      my $hashptr = $hash{ $_->{REDIRECT_ID} };
      next unless $hashptr;
      my $arrayptr = $hashptr->{TARGETS};
      if ($_->{EMAIL_ADDRESS}) {
        push(@$arrayptr, 'e' . $_->{EMAIL_ADDRESS});
      }
    }

    $table  = 'RHN_REDIRECT_METHOD_TARGETS';
    $table2 = 'RHN_REDIRECTS';
    $sql    = <<EOSQL;
      SELECT 
        $table.REDIRECT_ID as REDIRECT_ID,
        $table.CONTACT_METHOD_ID as CONTACT_METHOD_ID
      FROM 
        $table, $table2
      WHERE 
               $table2.EXPIRATION >= SYSDATE
        AND    $table2.START_DATE <= SYSDATE + 1
        AND    $table.REDIRECT_ID = $table2.RECID
EOSQL

    $targetptr = $self->execute($sql, $table, FETCH_ARRAYREF);

    foreach (@$targetptr) {
      my $hashptr = $hash{ $_->{REDIRECT_ID} };
      next unless $hashptr;
      my $arrayptr = $hashptr->{TARGETS};
      if ($_->{CONTACT_METHOD_ID}) {
        push(@$arrayptr, 'i' . $_->{CONTACT_METHOD_ID});
      }
    }
    $table  = 'RHN_REDIRECT_GROUP_TARGETS';
    $table2 = 'RHN_REDIRECTS';
    $sql    = <<EOSQL;
      SELECT 
        $table.REDIRECT_ID as REDIRECT_ID,
        $table.CONTACT_GROUP_ID  as CONTACT_GROUP_ID
      FROM 
        $table, $table2
      WHERE 
               $table2.EXPIRATION >= SYSDATE
        AND    $table2.START_DATE <= SYSDATE + 1
        AND    $table.REDIRECT_ID = $table2.RECID
EOSQL

    $targetptr = $self->execute($sql, $table, FETCH_ARRAYREF);

    foreach (@$targetptr) {
      my $hashptr = $hash{ $_->{REDIRECT_ID} };
      next unless $hashptr;
      my $arrayptr = $hashptr->{TARGETS};
      if ($_->{CONTACT_GROUP_ID}) {
        push(@$arrayptr, 'g' . $_->{CONTACT_GROUP_ID});
      }
    }
  } ## end if ($redirect_list)

  return $redirptr;
} ## end sub select_active_redirects

#####################################
sub select_active_redirect_criteria {
#####################################
  my $self   = shift;
  my $table  = 'RHN_REDIRECT_CRITERIA';
  my $table2 = 'RHN_REDIRECTS';

  my $sql = <<EOSQL;
      SELECT 
        $table.RECID,
        $table.REDIRECT_ID,
        $table.MATCH_PARAM,
        $table.MATCH_VALUE,
        $table.INVERTED
      FROM   $table, $table2
      WHERE  $table2.EXPIRATION >= SYSDATE
      AND    $table2.START_DATE <= SYSDATE + 1
      AND    $table2.RECID = $table.REDIRECT_ID
      ORDER BY $table.REDIRECT_ID, $table.MATCH_PARAM
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF);
} ## end sub select_active_redirect_criteria

###########################
sub select_contact_groups {
###########################
  my $self  = shift;
  my $table = 'RHN_CONTACT_GROUPS';
  my $sql   = <<EOSQL;
    select g.*,  
           (contact_strategy || ':' || ack_completed  || 'Ack') as strategy
     from  $table g, 
           strategies s
     where g.strategy_id = s.recid
EOSQL

  return $self->execute($sql, undef, FETCH_ARRAYREF);
} ## end sub select_contact_groups

#######################################
sub select_contact_groups_and_members {
#######################################
  my $self      = shift;
  my $groupptr  = $self->select_contact_groups;
  my %grouphash = map { $_->{MEMBERS} = []; $_->{'RECID'} => $_ } @$groupptr;

  my $table = 'RHN_CONTACT_GROUP_MEMBERS';
  my $sql   = <<EOSQL;
    select * 
    from $table
    order by contact_group_id, order_number
EOSQL

  my $memberptr = $self->execute($sql, $table, FETCH_ARRAYREF);

  foreach (@$memberptr) {
    my $item =
      $_->{MEMBER_CONTACT_GROUP_ID}
      ? 'g' . $_->{MEMBER_CONTACT_GROUP_ID}
      : 'i' . $_->{MEMBER_CONTACT_METHOD_ID};

    my $hashptr  = $grouphash{ $_->{CONTACT_GROUP_ID} };
    my $arrayptr = $hashptr->{MEMBERS};
    push(@$arrayptr, $item);
  } ## end foreach (@$memberptr)
  return $groupptr;
} ## end sub select_contact_groups_and_members

###########################################
sub select_customers_and_active_redirects {
###########################################
  my $self         = shift;
  my $customerptr  = $self->select_customers;
  my %customerhash =
    map { $_->{REDIRECTS} = []; $_->{'RECID'} => $_ } @$customerptr;

  my $redirectsptr = $self->select_active_redirects;

  foreach (@$redirectsptr) {

    my $hashptr  = $customerhash{ $_->{CUSTOMER_ID} };
    my $arrayptr = $hashptr->{REDIRECTS};
    push(@$arrayptr, $_->{RECID});
  }
  return $customerptr;
} ## end sub select_customers_and_active_redirects

#####################################
sub select_schedule_and_zone_combos {
#####################################
  my $self = shift;

  my $table          = 'RHN_CONTACT_METHODS';
  my $support_table1 = 'RHNUSERINFO';
  my $support_table2 = 'RHNTIMEZONE';
  my $sql            = <<EOSQL;
    SELECT 
      distinct 
        schedule_id, 
        nvl(substr($support_table2.olson_name,1,40),'GMT') as olson_tz_id
    FROM  $table, $support_table1, $support_table2
    WHERE schedule_id is not null
    AND   $table.contact_id = $support_table1.user_id
    AND   $support_table2.id (+) = $support_table1.timezone_id
EOSQL

  return $self->execute($sql, undef, FETCH_ARRAYREF);
} ## end sub select_schedule_and_zone_combos

##################################
sub select_host_by_host_probe_id {
##################################
  # for notifserver-test.cgi #
  my $self   = shift;
  my $id     = shift;
  my $table  = 'RHN_HOST_MONITORING';
  my $table2 = 'RHN_HOST_PROBE';

  my $sql = <<EOSQL;
      SELECT $table.*
      FROM $table, $table2
      WHERE $table2.probe_id = ?
      AND   $table2.host_id = $table.recid
EOSQL

  my $records = $self->execute($sql, $table, FETCH_ARRAYREF, $id);
  return $records->[0];
} ## end sub select_host_by_host_probe_id

############################################
sub select_service_probes_by_host_probe_id {
############################################
  # for notifserver-test.cgi and redirmgr.cgi #
  my $self   = shift;
  my $id     = shift;
  my $table  = 'RHN_PROBE';
  my $table2 = 'RHN_HOST_PROBE';
  my $table3 = 'RHN_HOST_MONITORING';
  my $table4 = 'RHN_CHECK_PROBE';

  my $sql = <<EOSQL;
      SELECT $table.recid as recid, 
             $table.description as description
      FROM   $table, $table2, $table3, $table4
      WHERE  $table2.probe_id  = ?
        AND  $table2.host_id   = $table3.recid
        AND  $table3.recid     = $table4.host_id
        AND  $table4.probe_id  = $table.recid
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF, $id);
} ## end sub select_service_probes_by_host_probe_id

######################################
sub select_service_probes_by_host_id {
######################################
  # for notifserver-test.cgi and redirmgr.cgi #
  my $self         = shift;
  my $id           = shift;
  my $probe_table  = 'RHN_PROBE';
  my $host_table   = 'RHN_HOST_MONITORING';
  my $svc_ck_table = 'RHN_CHECK_PROBE';

  my $sql = <<EOSQL;
      SELECT $probe_table.recid as recid, 
             $probe_table.description as description
      FROM   $probe_table, $host_table, $svc_ck_table
      WHERE  $host_table.recid     = $svc_ck_table.host_id
      AND    $svc_ck_table.probe_id  = $probe_table.recid
      AND    $host_table.recid = ?
EOSQL

  return $self->execute($sql, $probe_table, FETCH_ARRAYREF, $id);
} ## end sub select_service_probes_by_host_id

################################
################################
sub select_URLs_by_customer_id {
################################
  # for notifserver-test.cgi #
  my $self   = shift;
  my $id     = shift;
  my $table  = 'RHN_URL_PROBE_ROLE';
  my $table2 = 'RHN_URL_PROBE_STEP';

  my $sql = <<EOSQL;
  SELECT 
          s.url_probe_id as url_probe_id, 
          s.description as description, 
          s.url as url
  FROM 
          $table r, 
          $table2 s

  WHERE   r.url_probe_id = s.url_probe_id
  AND     r.customer_id = ? 
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF, $id);
} ## end sub select_URLs_by_customer_id

#######################################
sub select_host_probes_by_customer_id {
#######################################
  # for notifserver-test.cgi and redirmgr.cgi #
  my $self   = shift;
  my $id     = shift;
  my $table  = 'RHN_PROBE';
  my $table2 = 'RHN_HOST_PROBE';
  my $table3 = 'RHN_HOST_MONITORING';

  my $sql = <<EOSQL;
    select $table.recid as recid,  
    $table3.name as host_name 
    from   $table, 
     $table2, 
     $table3
    where  $table.recid     = $table2.probe_id
    and  $table2.host_id    = $table3.recid
    and  $table.customer_id = ?
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF, $id);
} ## end sub select_host_probes_by_customer_id

##########################################
sub select_scout_clusters_by_customer_id {
##########################################
  # for notifserver-test.cgi #
  my $self   = shift;
  my $id     = shift;
  my $table  = 'RHN_SAT_CLUSTER';
  my $table2 = 'RHN_LL_NETSAINT';

  my $sql = <<EOSQL;
    SELECT
            recid,
            description
    FROM        
            $table sc,
            $table2 ll
    WHERE    
            customer_id    = ?
    AND     ll.netsaint_id = sc.recid
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF, $id);
} ## end sub select_scout_clusters_by_customer_id

#######################################
sub select_sat_node_by_sat_cluster_id {
#######################################
  # for notifserver-test.cgi #
  my $self  = shift;
  my $id    = shift;
  my $table = 'RHN_SAT_NODE';

  my $sql = <<EOSQL;
    SELECT *
    FROM   $table
    WHERE  sat_cluster_id = ?
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF, $id);
} ## end sub select_sat_node_by_sat_cluster_id

#############################################
sub select_redirect_criteria_by_redirect_id {
#############################################
  # for redirmgr.cgi #
  my $self  = shift;
  my $id    = shift;
  my $table = 'RHN_REDIRECT_CRITERIA';

  my $sql = <<EOSQL;
    SELECT *
    FROM   $table
    WHERE  redirect_id = ?
    ORDER BY match_param
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF, $id);
} ## end sub select_redirect_criteria_by_redirect_id

#######################################
sub select_current_alert_by_ticket_id {
#######################################
  my $self  = shift;
  my $id    = shift;
  my $table = 'RHN_CURRENT_ALERTS';

  my $sql = <<EOSQL;
    SELECT *
    FROM   $table
    WHERE  ticket_id = ?
EOSQL

  my $records = $self->execute($sql, $table, FETCH_ARRAYREF, $id);
  return $records->[0];
} ## end sub select_current_alert_by_ticket_id

###########################################
sub select_contact_methods_by_customer_id {
###########################################
  # for redirmgr.cgi #
  my $self   = shift;
  my $id     = shift;
  my $table  = 'RHN_CONTACT_METHODS';
  my $table2 = 'RHN_CONTACT_MONITORING';

  my $sql = <<EOSQL;
    SELECT $table.*
    FROM   $table, $table2 
    WHERE  $table2.CUSTOMER_ID = ?
    AND    $table.CONTACT_ID = $table2.RECID
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF, $id);
} ## end sub select_contact_methods_by_customer_id

########################################
sub select_sat_clusters_by_customer_id {
########################################
  # for redirmgr.cgi #
  my $self  = shift;
  my $id    = shift;
  my $table = 'RHN_SAT_CLUSTER';

  my $sql = <<EOSQL;
    SELECT *
    FROM   $table
    WHERE  CUSTOMER_ID = ?
EOSQL

  return $self->execute($sql, $table, FETCH_ARRAYREF, $id);
} ## end sub select_sat_clusters_by_customer_id

# ################################

# ################################
# # SINGLE-TABLE RECORD DELETION #

# ################################
# # SINGLE-TABLE RECORD DELETION #
# ################################

# # Single record deletion
sub delete_redirect { shift->_delete_record('RHN_REDIRECT', @_) }

# # Multiple record deletion
# sub delete_boxes           { shift->_delete_records('BOX',               @_) }
# sub delete_components      { shift->_delete_records('COMPONENT',         @_) }
sub delete_redirect_criteria {
  shift->_delete_records('RHN_REDIRECT_CRITERIA', @_);
}

sub delete_redirect_email_targets {
  shift->_delete_records('RHN_REDIRECT_EMAIL_TARGETS', @_);
}

sub delete_redirect_group_targets {
  shift->_delete_records('RHN_REDIRECT_GROUP_TARGETS', @_);
}

sub delete_redirect_method_targets {
  shift->_delete_records('RHN_REDIRECT_METHOD_TARGETS', @_);
}

# ###############################
# # SINGLE-TABLE RECORD UPDATES #
# ###############################
#
#  Sample usage:
#  $rv = $rdb->update_box(
#               BOX_TYPE        => $boxtype,
#              BOX_NAME        => $boxname,
#              set             => {
#                  POSTINSTALL  => $teststr,
#                  PARTITIONING => $teststr,
#                },
#          );
#
# # Single record update
sub update_current_alert { shift->_update_record('RHN_CURRENT_ALERTS', @_) }
sub update_redirect      { shift->_update_record('RHN_REDIRECTS',      @_) }

# # Multiple record update
# sub update_boxes             { shift->_update_records('BOX',               @_) }
# sub update_components        { shift->_update_records('COMPONENT',         @_) }

# ######################
# # COMPLEX OPERATIONS #
# ######################

#######################################
sub update_current_alert_by_ticket_id {
#######################################
  my ($self, %args) = @_;

  my $ticket_id = $args{TICKET_ID};
  unless ($ticket_id) {
    throw NOCpulse::Probe::DataSource::ConfigError(
                                          "ticket_id not defined as parameter");
  }

  my $escalate;
  if ($args{'escalate'}) {
    $escalate = $args{'escalate'};
    delete($args{'escalate'});
  }

  my $record = $self->select_current_alert_by_ticket_id($ticket_id);
  unless ($record) {
    throw NOCpulse::Probe::DataSource::ConfigError(
                  "current alerts record for ticket_id $ticket_id not found\n");
  }

  delete($args{TICKET_ID});
  $args{RECID} = $record->{RECID};

  if ($escalate) {
    my $hashptr = $args{set};
    $hashptr = {} unless $hashptr;
    $hashptr->{ESCALATION_LEVEL} = $record->{ESCALATION_LEVEL} + $escalate;
    $args{set} = $hashptr;
  }

  $self->update_current_alert(%args);
} ## end sub update_current_alert_by_ticket_id

sub select_max_last_update_date {
  my ($self, $table) = @_;

  my $fmt = SORTABLE_DB_DATE_FMT;
  my $sql = <<EOSQL;
    SELECT TO_CHAR(MAX(last_update_date),'$fmt') as last_update_date
    FROM   $table
EOSQL

  my $records = $self->execute($sql, $table, FETCH_ARRAYREF);
  my $record = shift(@$records);
  my $date;
  $date = $record->{LAST_UPDATE_DATE} if $record;
  return $date;
} ## end sub select_max_last_update_date

##################
# SCHEMA DETAILS #
##################

###################
sub _init_details {
###################

  my ($self, $table) = @_;

  # Initialize the hash
  my (@cols, @pk, %defaults, @dates);

  # Process the table description
  my $ref = $self->_select_table_description($table);
  unless (@$ref) {

    # This might be a view
  }
  foreach (@$ref) {
    push(@cols, $_->{COLUMN_NAME});
    push(@dates, $_->{COLUMN_NAME}) if $_->{DATA_TYPE} eq 'DATE';
    $defaults{ $_->{COLUMN_NAME} } = 'sysdate'
      if $_->{COLUMN_NAME} eq 'LAST_UPDATE_DATE';
  }

  # Process primary key info
  $ref = $self->_select_table_primary_keys($table);
  map { push(@pk, $_->{COLUMN_NAME}) } @$ref;

  $DETAIL{$table}->{cols}     = \@cols;
  $DETAIL{$table}->{dates}    = \@dates;
  $DETAIL{$table}->{defaults} = \%defaults;
  $DETAIL{$table}->{pk}       = \@pk;

  return $DETAIL{$table}

    # Sample format, note additional defaults may need to be added manually

    #  %DETAIL = (
    #
    #    'CONTACT'            => {
    #
    #      'cols', 'defaults', 'dates');
    #      'cols'     => [qw(RECID DESCRIPTION DELETED LAST_UPDATE_USER
    #                        LAST_UPDATE_DATE SCHEDULE_ID DEF_ACK_WAIT
    #                        DEF_STRATEGY PREFERRED_TIME_ZONE
    #                        SECURITY_SERVICE_VULNERABILITY
    #                        SECURITY_SERVICE_MANAGEMENT AUTO_UPDATE
    #                        TYPE )],
    #
    #      'pk'       => [qw(RECID)],
    #
    #      'defaults' => { LAST_UPDATE_DATE => 'sysdate'}
    #    }
    #  )
} ## end sub _init_details

######################
# INTERNAL FUNCTIONS #
######################

##############
sub _details {
##############
  my $self = shift;
  my ($table, @req) = @_;
  $table = uc($table);
  my @rv;

  foreach my $req (@req) {
    unless (exists($DETAIL{$table})) {
      $self->_init_details($table);
    }
    if (exists($DETAIL{$table}->{$req})) {

      push(@rv, $DETAIL{$table}->{$req});

    } else {

      throw NOCpulse::Probe::DataSource::ConfigError(
                        "Unknown field '$req' requested from $table details\n");

    }
  } ## end foreach my $req (@req)

  return wantarray ? @rv : $rv[0];

} ## end sub _details

#############
sub _create {
#############
  my $self   = shift;
  my $table  = shift;
  my %fields = @_;

  my ($COLS, $DEFAULT, $DATES) =
    $self->_details($table, 'cols', 'defaults', 'dates');

  my ($COLSTR) = join(',', @$COLS);

  my (@bindvars, @bindvals);
  foreach my $item (@$COLS) {
    my $col = uc($item);
    $fields{$col} = $DEFAULT->{$col} unless (exists($fields{$col}));
    if (grep { /^$col$/ } @$DATES) {

      # Fancy stuff for dates
      if ($fields{$col} =~ /sysdate/i) {
        push(@bindvars, $fields{$col});
      } else {
        push(@bindvars, "TO_DATE(?, '" . DEF_DB_DATE_FMT . "')");
        push(@bindvals, $self->timestamp_to_string($fields{$col}));
      }
    } else {
      push(@bindvars, '?');
      push(@bindvals, $fields{$col});
    }
  } ## end foreach my $item (@$COLS)
  my $BVSTR = join(',', @bindvars);

  my $sql = "INSERT INTO $table ($COLSTR) VALUES ($BVSTR)";

  return $self->execute($sql, $table, FETCH_ROWCOUNT, @bindvals);
} ## end sub _create

######################
sub _create_with_seq {
######################
  my ($self, $col, $seq, $table, %args) = @_;

  my $x = 'DUAL';

  my $sql = <<EOSQL;
    SELECT $seq.NEXTVAL as id
    FROM   $x
EOSQL

  my $records = $self->execute($sql, $x, FETCH_ARRAYREF);
  my $id = $records->[0]->{'ID'};
  $args{$col} = $id;

  return ($self->_create($table, %args), $id);
} ## end sub _create_with_seq

####################
sub _select_record {
####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my $pk = $self->_details($table, 'pk');

  $self->_check_reqs($pk, \%args, 2);

  my $records = $self->_select_records($table, %args);

  return $records->[0];

} ## end sub _select_record

#####################
sub _select_records {
#####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;
  my ($sql, $selectphrase, $wherephrase, $bindvals);

  $selectphrase = $self->_selectphrase($table);

  if (%args) {
    ($wherephrase, $bindvals) = $self->_wherephrase($table, \%args);

    $sql = <<EOSQL;
       SELECT $selectphrase
       FROM   $table
       WHERE  $wherephrase
EOSQL

  } else {
    $sql = <<EOSQL;
       SELECT $selectphrase
       FROM   $table
EOSQL
  }

  my $records = $self->execute($sql, $table, FETCH_ARRAYREF, @$bindvals);

  # Convert database string results to unix timestamps
  my ($DATES) = $self->_details($table, 'dates');
  foreach my $record (@$records) {
    foreach my $col (@$DATES) {
      $record->{$col} = $self->string_to_timestamp($record->{$col});
    }
  }
  return $records;
} ## end sub _select_records

####################
sub _delete_record {
####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my $pk = $self->_details($table, 'pk');

  $self->_check_reqs($pk, \%args, 2);

  return $self->_delete_records($table, %args);

} ## end sub _delete_record

#####################
sub _delete_records {
#####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my ($wherephrase, $bindvals) = $self->_wherephrase($table, \%args);

  my $sql = <<EOSQL;
    DELETE
    FROM   $table
    WHERE $wherephrase
EOSQL

  return $self->execute($sql, $table, FETCH_ROWCOUNT, @$bindvals);
} ## end sub _delete_records

####################
sub _update_record {
####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my $pk = $self->_details($table, 'pk');

  $self->_check_reqs($pk, \%args, 2);

  return $self->_update_records($table, %args);

} ## end sub _update_record

#####################
sub _update_records {
#####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  $self->_check_reqs(['set'], \%args, 3);

  my $set = delete($args{'set'});

  my ($setphrase, $sbindvals) = $self->_wherephrase($table, $set, ',');
  my ($wherephrase, $wbindvals) = $self->_wherephrase($table, \%args);

  my $sql = <<EOSQL;
    UPDATE $table
    SET    $setphrase
    WHERE  $wherephrase
EOSQL

  return $self->execute($sql, $table, FETCH_ROWCOUNT, @$sbindvals, @$wbindvals);

} ## end sub _update_records

#################
sub _check_reqs {
#################
  my ($self, $reqs, $args, $clvl) = @_;
  $clvl ||= 1;

  foreach my $req (@$reqs) {
    unless (exists($args->{$req})) {
      my ($package, $filename, $line, $subroutine) = caller($clvl);
      throw NOCpulse::Probe::DataSource::ConfigError(
               "\n  Missing required params  for $subroutine: ($req) @$reqs\n");
    }
  }
} ## end sub _check_reqs

###################
sub _wherephrase {
##################
  my ($self, $table, $args, $conj) = @_;

  $conj ||= 'AND';

  # Construct part of a WHERE clause with bind variables
  # given a hash of column => value pairs

  my $DATES = $self->_details($table, 'dates');

  my (@bindvals, @wherephrases);
  while (my ($item, $val) = each %$args) {
    my $col = uc($item);
    if (grep { /^$col$/ } @$DATES) {
      if ($val =~ /sysdate/i) {
        push(@wherephrases, "$col = $val");
      } else {
        push(@wherephrases, "$col = TO_DATE(?, '" . DEF_DB_DATE_FMT . "')");
        push(@bindvals,     $self->timestamp_to_string($val));
      }
    } else {
      push(@wherephrases, "$col = ?");
      push(@bindvals,     $val);
    }
  } ## end while (my ($item, $val) =...

  return (join(" $conj ", @wherephrases), \@bindvals);
} ## end sub _wherephrase

###################
sub _selectphrase {
###################
  my ($self, $table) = @_;

  my ($cols, $dates) = $self->_details($table, 'cols', 'dates');
  my %fields = map { $_ => $_ } @$cols;
  map { $fields{$_} = $self->_date_to_string($_) } @$dates;

  return join(",\n", values(%fields)) . "\n";
} ## end sub _selectphrase

###############################
sub _select_table_description {
###############################

  my ($self, @args) = @_;

  my $table = 'ALL_TAB_COLUMNS';

  my $sql = <<EOSQL;
    SELECT   
      column_name,
      data_type,
      data_precision,
      nullable
    FROM     
      all_tab_columns
    WHERE    UPPER(table_name) = UPPER(?)
    ORDER BY column_id
EOSQL

  my $result = $self->execute($sql, $table, FETCH_ARRAYREF, @args);
  return $result;
} ## end sub _select_table_description

################################
sub _select_table_primary_keys {
################################

  my ($self, @args) = @_;

  my $table = 'ALL_CONSTRAINTS';

  my $sql = <<EOSQL;
    SELECT ac.constraint_name,
           ac.table_name,
           acc.column_name
    FROM   all_constraints ac,
           all_cons_columns acc
    WHERE  UPPER(ac.table_name) = UPPER(?)
      AND  ac.constraint_type = 'P'
      AND  ac.constraint_name = acc.constraint_name
      AND  ac.owner = acc.owner
    ORDER BY ac.constraint_name, acc.position
EOSQL

  my $result = $self->execute($sql, $table, FETCH_ARRAYREF, @args);
  return $result;
} ## end sub _select_table_primary_keys

#####################
# UTILITY FUNCTIONS #
#####################

sub dbIsOkay {
  my $self  = shift;
  my $table = 'dual';

  eval {
    my $sql = <<EOSQL;
      SELECT 1 as recid
      FROM   $table
EOSQL

    my $records = $self->execute($sql, $table, FETCH_ARRAYREF);
    my $recid = $records->[0]->{'RECID'};
    $@ = "Database is not okay" unless $recid == 1;
  };

  return 0 if $@;
  return 1;
} ## end sub dbIsOkay

sub _date_to_string {
  my ($self, $field_name) = @_;
  $field_name = uc($field_name);
  return "TO_CHAR($field_name,'"
    . $self->db_date_format()
    . "') AS $field_name";
}

sub db_date_format {
  return DEF_DB_DATE_FMT;
}

sub timestamp_to_string {
  my ($self, $timestamp, $fmt_string) = @_;
  if (defined($timestamp)) {
    if ($fmt_string) {
      return time2str($fmt_string, $timestamp);
    } else {
      return time2str(DEF_UNIX_DATE_FMT, $timestamp);
    }
  } else {
    return '';
  }
} ## end sub timestamp_to_string

#########################
sub string_to_timestamp {
#########################
  my ($self, $string) = @_;
  my $retval = str2time($string);
  return $retval;
}

######################
sub pre_init_details {
######################
  my $self = shift;

  $DETAIL{ARCHIVE_MASTER} = {
    'cols' => [
      qw(CUSTOMER_ID ARCHIVE_ID ACTIVITY_CODE ARCHIVE_DATE TABLE_NAME
        KEY_COL_1 KEY_COL_2 KEY_COL_3 KEY_COL_4 KEY_COL_5 ARCHIVE_USER )
    ],

    'pk' => [qw(CUSTOMER_ID)],

    'defaults' => { ARCHIVE_DATE => 'sysdate' },

    'dates' => [qw (ARCHIVE_DATE)]
                            };
  $DETAIL{CONTACT} = {
    'cols' => [
      qw( RECID CUSTOMER_ID CONTACT_LAST_NAME CONTACT_FIRST_NAME EMAIL_ADDRESS
        PAGER USERNAME ROLES DELETED LAST_UPDATE_USER LAST_UPDATE_DATE
        SCHEDULE_ID PREFERRED_TIME_ZONE PRIVILEGE_TYPE_NAME )
    ],

    'pk' => [qw(RECID)],

    'defaults' => { LAST_UPDATE_DATE => 'sysdate' },

    'dates' => [qw (LAST_UPDATE_DATE)]
                     };
  $DETAIL{CONTACT_GROUPS} = {
    'cols' => [
      qw(RECID CONTACT_GROUP_NAME CUSTOMER_ID STRATEGY_ID ACK_WAIT
        ROTATE_FIRST LAST_UPDATE_USER LAST_UPDATE_DATE NOTIFICATION_FORMAT_ID)
    ],

    'pk' => [qw(RECID)],

    'defaults' =>
      { LAST_UPDATE_DATE => 'sysdate', NOTIFICATION_FORMAT_ID => 4 },

    'dates' => [qw (LAST_UPDATE_DATE)]
                            };
  $DETAIL{CONTACT_METHODS} = {
    'cols' => [
      qw(RECID METHOD_NAME CONTACT_ID SCHEDULE_ID METHOD_TYPE_ID
        PAGER_TYPE_ID PAGER_PIN PAGER_EMAIL PAGER_MAX_MESSAGE_LENGTH
        PAGER_SPLIT_LONG_MESSAGES EMAIL_ADDRESS
        EMAIL_REPLY_TO LAST_UPDATE_USER
        LAST_UPDATE_DATE SNMP_HOST SNMP_PORT NOTIFICATION_FORMAT_ID
        SENDER_SAT_CLUSTER_ID )
    ],

    'pk' => [qw(RECID)],

    'defaults' =>
      { LAST_UPDATE_DATE => 'sysdate', NOTIFICATION_FORMAT_ID => 4 },

    'dates' => [qw (LAST_UPDATE_DATE)]
                             };
  $DETAIL{RHN_CUSTOMER_MONITORING} = {
    'cols' => [
      qw(RECID DESCRIPTION SCHEDULE_ID DEF_ACK_WAIT DEF_STRATEGY
        PREFERRED_TIME_ZONE AUTO_UPDATE )
    ],
    'pk' => [qw(RECID)],

    'defaults' => {},

    'dates' => []
                                     };
  $DETAIL{REDIRECTS} = {
    'cols' => [
      qw(RECID CUSTOMER_ID CONTACT_ID REDIRECT_TYPE DESCRIPTION
        REASON EXPIRATION LAST_UPDATE_USER LAST_UPDATE_DATE START_DATE )
    ],

    'pk' => [qw(RECID)],

    'defaults' => { LAST_UPDATE_DATE => 'sysdate' },

    'dates' => [qw (EXPIRATION LAST_UPDATE_DATE START_DATE)]
                       };
  $DETAIL{REDIRECT_CRITERIA} = {
    'cols' => [qw(RECID REDIRECT_ID MATCH_PARAM MATCH_VALUE INVERTED)],

    'pk' => [qw(RECID)],

    'defaults' => {},

    'dates' => []
                               };
  $DETAIL{REDIRECT_EMAIL_TARGETS} = {
    'cols' => [qw(REDIRECT_ID EMAIL_ADDRESS )],

    'pk' => [qw(REDIRECT_ID EMAIL_ADDRESS )],

    'defaults' => {},

    'dates' => []
                                    };
  $DETAIL{REDIRECT_GROUP_TARGETS} = {
    'cols' => [qw(REDIRECT_ID CONTACT_GROUP_ID )],

    'pk' => [qw(REDIRECT_ID CONTACT_GROUP_ID )],

    'defaults' => {},

    'dates' => []
                                    };
  $DETAIL{REDIRECT_METHOD_TARGETS} = {
    'cols' => [qw(REDIRECT_ID CONTACT_METHOD_ID )],

    'pk' => [qw(REDIRECT_ID CONTACT_METHOD_ID )],

    'defaults' => {},

    'dates' => []
                                     };
  $DETAIL{REDIRECT_TYPES} = {
    'cols' => [qw(NAME DESCRIPTION LONG_NAME)],

    'pk' => [qw(NAME)],

    'defaults' => {},

    'dates' => []
                            };
  $DETAIL{REDIRECT_MATCH_TYPES} = {
    'cols' => [qw(NAME)],

    'pk' => [qw(NAME)],

    'defaults' => {},

    'dates' => []
                                  };
  $DETAIL{SAT_CLUSTER} = {
    'cols' => [
      qw(RECID TARGET_TYPE CUSTOMER_ID DESCRIPTION LAST_UPDATE_USER
        LAST_UPDATE_DATE PHYSICAL_LOCATION_ID VIP DEPLOYED)
    ],

    'pk' => [qw(RECID)],

    'defaults' => { LAST_UPDATE_DATE => 'sysdate' },

    'dates' => [qw(LAST_UPDATE_DATE)]
                         };
} ## end sub pre_init_details

1;

__END__

=head1 NAME

NOCpulse::Notif::NotificationDB - An interface to the configuration database, primarily used for the notification system.

=head1 SYNOPSIS

# Create a new interface to the database
$ndb=NOCpulse::Notif::NotificationDB->new();

# Select the customer record with a recid of 1
$hash = $ndb->select_customer('RECID' => '1');

# Return a reference to an array with all the probe types
$arrayref = ndb->select_probe_types();

# Update a redirect, specified by recid, with new information
$ndb->update_redirect( RECID            => $redirid,
                       set => {
                         CUSTOMER_ID      => $custID,
                         CONTACT_ID       => $contactID,
                         REDIRECT_TYPE    => $optype,
                         DESCRIPTION      => $description,
                         REASON           => $reason,
                         EXPIRATION       => $expire,
                         LAST_UPDATE_USER => 'redirmgr',
                         LAST_UPDATE_DATE => time(),
                         START_DATE       => $start_date } );
                       }

# Delete all the redirect criteria associated with a specific redirect recid
$ndb->delete_redirect_criteria( REDIRECT_ID => $rid );

# Commit the transactions to the database
$ndb->commit();

# Rollback the transactions from the database
$ndb->rollback();

=head1 DESCRIPTION

The C<NotificationDB> object is provides an interface to query, create, update, and delete database information.  It uses connection information provided by NOCpulse::Config.
=head1 METHODS

=over 4

=item create_current_alert ( %args )

Create a row in the database in the current_alerts table, where the keys of %args represent the column names and the values of %args represent the respective values for that column.  Automatically generates a recid without having to pass one as a parameter in %args.

=item create_redirect ( %args )

Create a row in the database in the redirects table, where the keys of %args represent the column names and the values of %args represent the respective values for that column.  Automatically generates a recid without having to pass one as a parameter in %args.

=item create_redirect_criteria ( %args )

Create a row in the database in the redirect_criteria table, where the keys of %args represent the column names and the values of %args represent the respective values for that column.  Automatically generates a recid without having to pass one as a parameter in %args.

=item create_redirect_email_target  ( %args )

Create a row in the database in the redirect_email_targets table, where the keys of %args represent the column names and the values of %args represent the respective values for that column.

=item create_redirect_group_target  ( %args )

Create a row in the database in the redirect_group_targets table, where the keys of %args represent the column names and the values of %args represent the respective values for that column.

=item create_redirect_method_target ( %args )

Create a row in the database in the redirect_methodtargets table, where the keys of %args represent the column names and the values of %args represent the respective values for that column.

=item create_snmp_alert ( %args )

Create a row in the database in the snmp_alert table, where the keys of %args represent the column names and the values of %args represent the respective values for that column.  Automatically generates a recid without having to pass one as a parameter in %args.

=item dbIsOkay ( )

Returns a true value if the database connection is still active.

=item db_date_format ( )

Return the preferred database date format used by this object.

=item delete_redirect ( %args )

Delete the record specified by the arguments from the redirect table.

=item delete_redirect_criteria ( %args )

Delete the record matching the specified by the arguments from the redirect_criteria table.

=item delete_redirect_email_targets  ( %args )

Delete all the records matching the specified by the arguments from the redirect_email_targets table.

=item delete_redirect_group_targets  ( %args )

Delete all the records matching the specified by the arguments from the redirect_group_targets table.

=item delete_redirect_method_targets ( %args )

Delete all the records matching the specified by the arguments from the redirect_method_targets table.

=item init ( %args )

Initialize the object with the specified values for attributes.

=item pre_init_details ( )

Initialize the table details for highly used tables.  Speeds up queries by eliminating on demand table description queries.

=item select_URLs_by_customer_id ( $customer_id )

Select the probe id, description, and url being probed, for the customer denoted by the given customer_id number.

=item select_active_redirect_criteria ( )

Return a reference to an array containing hashes storing redirect criteria for all currently active redirects.

=item select_active_redirects  ( )

Return a reference to an array containing hashes storing all currently active redirects.

=item select_contact_group ( %args )

Return a reference to a hash containing the contact group specified by the given arguments.

=item select_contact_groups {

Return a reference to an array of hashes containing the contact groups specified by the given arguments.

=item select_contact_groups_and_members ( )

Return a reference to an array of hashes containing all contact groups.  Each contact group has will have a key named 'MEMBERS' whose corresponding value is an array of group member descriptors.

=item select_contact_methods ( %args )

Return a reference to an array of hashes containing the contact methods specified by the given arguments.

=item select_contact_methods_by_customer_id ( $customer_id )

Return a reference to an array of hashes containing the contact methods that belong to the customer whose id is specified.

=item select_contacts ( %args )

Return a reference to an array of hashes containing the contacts specified by the given arguments.

=item select_current_alert ( %args )

Return a reference to a hash containing the contact group specified by the given arguments.

=item select_current_alert_by_ticket_id ( $ticket_id )

Return a reference to a hash containing the current alert information with the given ticket id.

=item select_customer ( %args )

Return a reference to a hash containing the customer specified by the given arguments.

=item select_customers ( %args )

Return a reference to an array of hashes containing the customers specified by the given arguments.

=item select_customers_and_active_redirects ( )

Return a reference to an array of hashes containing all customers.  Each customer hash has will have a key named 'REDIRECTS' whose corresponding value is an array of that customers active redirect unique recids.

=item select_global_redirects ( )

Return a reference to an array of hashes containing information about redirects that apply to all customers.

=item select_host ( %args )

Return a reference to a hash containing the host specified by the given arguments.

=item select_hosts ( %args )

Return a reference to an array of hashes containing the hosts specified by the given arguments.

=item select_host_by_host_probe_id ( $probe_id )

Return a reference to a hash containing the probe specified by the given probe id.

=item select_host_probes_by_customer_id ( $customer_id )

Return a reference to an array of hashes containing the probes that belong to the customer whose id was specified.

=item select_notification_formats ( %args )

Return a reference to an array of hashes containing the notification format specified by the given arguments.

=item select_notifservers ( %args )

Return a reference to an array of hashes containing the notification servers specified by the given arguments.

=item select_probe ( %args )

Return a reference to a hash containing the probe specified by the given arguments.

=item select_probe_types ( %args )

Return a reference to an array of hashes containing the probe types specified by the given arguments.

=item select_redirect ( %args )

Return a reference to a hash containing the redirect specified by the given arguments.

=item select_redirect_criteria_by_redirect_id ( $redirect_id )

Return a reference to an array of hashes containing the redirect criteria that belong to the redirect whose id was specified.

=item select_redirect_email_targets ( %args )

Return a reference to an array of hashes containing the redirect email targets specified by the given arguments.

=item select_redirect_group_targets ( %args )

Return a reference to an array of hashes containing the redirect group targets specified by the given arguments.

=item select_redirect_match_types ( %args )

Return a reference to an array of hashes containing the redirect match types specified by the given arguments.

=item select_redirect_method_targets ( %args )

Return a reference to an array of hashes containing the redirect method targets specified by the given arguments.

=item select_redirect_types ( %args )

Return a reference to a hash containing the redirect type specified by the given arguments.

=item select_redirects ( %args )

Return a reference to an array of hashes containing the redirects specified by the given arguments.

=item select_sat_cluster ( %args )

Return a reference to a hash containing the satellite cluster specified by the given arguments.

=item select_sat_clusters ( %args )

Return a reference to an array of hashes containing the satellite clusters specified by the given arguments.

=item select_sat_clusters_by_customer_id ( $customer_id )

Return a reference to an array of hashes containing the satellite clusters that belong to the customer specified by the given id.

=item select_sat_node_by_sat_cluster_id ( $sat_cluster_id )

Return a reference to an array of hashes containing the satellite node that belongs to the satellite cluster specified by the given id.

=item select_schedule_and_zone_combos ( )

Return a reference to an array of hashes containing the schedule id and schedule time zone combinations for contact nethods, contacts and customers.

=item select_schedule_days ( )

Return a reference to an array of hashes containing all the schedule days in the database.

=item select_schedules ( %args )

Return a reference to an array of hashes containing the redirect method targets specified by the given arguments.

=item select_scout_clusters_by_customer_id ( $customer_id )

Return a reference to an array of hashes containing the recid and description of all a specified customer's urls.

=item select_service_probes_by_host_id ( $host_id )

Return a reference to an array of hashes containing service probe details for all service probes associated with the specified host by the given id.

=item select_service_probes_by_host_probe_id ( $probe_id )

Return a reference to an array of hashes containing service probe details for all service probes associated with the specified host probe by the given id.

=item select_snmp_alert ( %args )

Return a reference to a hash containing the snmp alert specified by the given arguments.

=item string_to_timestamp ( $date_string )

Given a date string, return the corresponding UNIX timestamp.

=item timestamp_to_string ( $timestamp )

Given a timestamp, return a string containing the date and time reprsented by the timestamp.

=item update_current_alert ( %args )

Update the database record, specified by the given arguments, in the current_alerts table with information specified in the 'set' portion of the argument hash.

=item update_current_alert_by_ticket_id {

Update the database record, specified by the given arguments, in the current_alerts table with information specified in the 'TICKET_ID' portion of the argument hash.

=item update_redirect ( %args )

Update the database record, specified by the given arguments, in the redirect table with information specified in the 'set' portion of the argument hash.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2005-06-16 19:03:07 $

=head1 SEE ALSO

B<NOCpulse::Probe::DataSource::AbstractDatabase>
B<NOCpulse::Probe::DataSource::Oracle>
B<NOCpulse::Probe::Error>
B<NOCpulse::Config>
B<generate-config>
B</var/www/cgi-bin/alertmgr.cgi>
B</var/www/cgi-bin/redirmgr.cgi>

=cut
