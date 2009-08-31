package NOCpulse::NPRecords;

use NOCpulse::DBRecord;

############################################
package CFDBRecord;
use strict;
use vars qw(@ISA);
@ISA=qw(NOCpulse::DBRecord);

sub DBD
{
        my ($class,$config) = @_;
        $class = ref($class) || $class;
        return $config->val('cf_db','dbd');
}
 
sub DBName
{
        my ($class,$config) = @_;
        $class = ref($class) || $class;
        return $config->val('cf_db','name');
}
 
sub Username
{
        my ($class,$config) = @_;
        $class = ref($class) || $class;
        return  $config->val('cf_db','username');
}
 
sub Password
{
        my ($class,$config) = @_;
        $class = ref($class) || $class;
        return $config->val('cf_db','password');
}

############################################
# Nolog instance ("config state")
package CSDBRecord;
use strict;
use vars qw(@ISA);
@ISA=qw(NOCpulse::DBRecord);

sub DBD
{
        my ($class,$config) = @_;
        $class = ref($class) || $class;
        return $config->val('cs_db','dbd');
}

sub DBName
{
        my ($class,$config) = @_;
        $class = ref($class) || $class;
        return $config->val('cs_db','name');
}

sub Username
{
        my ($class,$config) = @_;
        $class = ref($class) || $class;
        return  $config->val('cs_db','username');
}

sub Password
{
        my ($class,$config) = @_;
        $class = ref($class) || $class;
        return $config->val('cs_db','password');
}

############################################
package ProbeRecord;
use strict;
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

sub LoadForSatellite
{
	my ($class, $satClusterId) = @_;
        $class = ref($class) || $class;

	# Not all probes have this - save it for future reference.
	$class->setClassVar('netsaintId', $satClusterId);

        my %probe_col_aliases =
          ('probe.command_id'                    => 'check_command',
           'probe.check_interval_minutes'        => 'check_interval',
           'probe.contact_group_id'              => 'contact_groups',
           'probe.customer_id'                   => undef,
           'probe.description'                   => undef,
           'probe.max_attempts'                  => undef,
           'probe.notification_interval_minutes' => 'notification_interval',
           'probe.notify_critical'               => undef,
           'probe.notify_recovery'               => undef,
           'probe.notify_warning'                => undef,
           'probe.notify_unknown'                => undef,
           "'ServiceProbe'"                      => 'probe_type',
           'probe.recid'                         => undef,
           'probe.retry_interval_minutes'        => 'retry_interval',
          );
        my @probe_cols = ();
        while (my ($column, $alias) = each %probe_col_aliases) {
            $column .= " as $alias" if $alias;
            push(@probe_cols, $column);
        }
        my $probe_col_str = join(",\n" . ' ' x 17,  @probe_cols);

        my $host_col_str = q{
                 host.ip as "hostAddress",
                 host.name as "hostName",
                 host.os_id};

	my $sql = qq{
          SELECT $probe_col_str, /* Checks */
                 check_probe.sat_cluster_id as netsaint_id,
                 $host_col_str
	  FROM   probe, check_probe, host
          WHERE  check_probe.probe_id = probe.recid
          AND    check_probe.host_id = host.recid
          AND    check_probe.sat_cluster_id = ?
          };

        $class->LoadFromSqlWithBind($sql, [$satClusterId], 'RECID');

        # If there aren't any....
        $class->InstanceCount > 0 or return 0;

	# Fetch OS IDs and names for later mapping
	CFDBRecord->LoadFromSql("SELECT recid, os_name FROM os", 'RECID');
	my $os = CFDBRecord->Instances;
	CFDBRecord->ReleaseAllInstances;

	# Add OS name to probe records
	$class->Map(
	  sub {
	    my $self = shift;

	    # Map the OS name
	    my $probe = $self;
	    my $osid = $probe->get('OS_ID');
	    if ($osid && $os->{$osid}) {
	      $self->addInstVar('os_name', $os->{$osid}->get('OS_NAME'));
	    } else {
	      $self->addInstVar('os_name', 'UNKNOWN');
	    }
	  }
	);



	# Gather up a unique list of all contact group recids for all probes
	my %contactGroups;
	$class->Map(
		sub {
			my $self = shift();
			my $groupnum;
			foreach $groupnum (@{$self->get_CONTACT_GROUPS}) {
				if ($groupnum) {
					$contactGroups{$groupnum} = undef;
				}
			}
		}
	);

	my @contactGroupIds = keys %contactGroups;
	my @placeholder = ();
	foreach my $id (@contactGroupIds) {
	   push(@placeholder, '?');
	}

        if (@contactGroupIds) {

          # At this point, CONTACT_GROUPS are all recids
          # Need to add a 'queue_urls' field for SNMP destinations.
          my $sql = "SELECT     g.recid || '.' || map.order_number as id,
                                g.recid as contact_group_id,
                                g.contact_group_name,
                                m.method_type_id,
                                m.method_name,
                                m.recid as member_id,
                                m.snmp_host,
                                m.snmp_port,
                                m.sender_sat_cluster_id
                      FROM      contact_groups g, contact_methods m,
                                contact_group_members map
                      WHERE     map.contact_group_id = g.recid
                      AND       map.member_contact_method_id = m.recid
                      AND       g.recid in (".join(', ', @placeholder).')';

          CFDBRecord->LoadFromSqlWithBind($sql, \@contactGroupIds, 'ID');
          my %snmpdests;
          CFDBRecord->Map(
                  sub {
                          my $record = shift();
                          if ($record->get_METHOD_TYPE_ID == 5) {
                            # We have an SNMP destination!
                            my $gid  = $record->get_CONTACT_GROUP_ID;
                            my $host = $record->get_SNMP_HOST;
                            my $port = $record->get_SNMP_PORT;
                            my $sat  = $record->get_SENDER_SAT_CLUSTER_ID;
                            push(@{$snmpdests{$gid}}, "notif://${host}:$port/$sat");
                          }
                  }
          );
          CFDBRecord->ReleaseAllInstances;


	# Now %snmpdests contains a list of SNMP destinatios for each
	# contact group.
	$sql = "SELECT recid,contact_group_name,customer_id
		FROM   contact_groups
		WHERE  recid in (".join(', ', @placeholder).")";
        CFDBRecord->LoadFromSqlWithBind($sql, \@contactGroupIds, 'RECID');
        $class->Map(
                sub {
			# Set up name equivalent arrays of contact group names
			# for each probe object.  Required by notification system.
                        my $self = shift();
                        $self->addInstVar('contactGroupNames',[]);
                        $self->addInstVar('contactGroupCustomers',[]);
			$self->addInstVar('queue_urls',[]);
			my $groupNames = $self->get_contactGroupNames;
			my $groupCusts = $self->get_contactGroupCustomers;
			my $groupnum;
			my $grouprec;
			foreach $groupnum (@{$self->get_CONTACT_GROUPS}) {
				if ($groupnum) {
					if ($grouprec = CFDBRecord->Called($groupnum)) {
						push(@$groupNames,$grouprec->get_CONTACT_GROUP_NAME);
						push(@$groupCusts,$grouprec->get_CUSTOMER_ID);

					} else {
						#print "$groupnum has no associated contact group record\n";
					}
				} else {
					#print $self->get_RECID.' '.$self->get_PROBE_TYPE." had blank groupnum\n";
				}
			}
                }
        );
        CFDBRecord->ReleaseAllInstances;

        }


	# Fetch service probes and host probes for all sats/scouts ...
	my $probeSubquery = "
              SELECT probe_id
              FROM   host_probe
              WHERE  sat_cluster_id = ?
              UNION
              SELECT probe_id
              FROM   check_probe
              WHERE  sat_cluster_id = ?
              UNION
              SELECT probe_id
              FROM   sat_cluster_probe
              WHERE  sat_cluster_id = ?
              UNION
              SELECT probe_id
              FROM   url_probe
              WHERE  sat_cluster_id = ?
	";

	# Load up the commands table and add the command group name to the probe records
	CommandRecord->LoadFromSqlWithBind('
           select c.recid, c.name, c.description, c.command_class, c.group_name
           from command c, probe p
           where p.command_id = c.recid
           and p.recid in ('.$probeSubquery.')',
          [$satClusterId, $satClusterId, $satClusterId, $satClusterId],
          'RECID');
	$class->Map(
	        sub {
		  my $record = shift;
		  my $cmd    = $record->get_CHECK_COMMAND;
		  my $cmdRec = CommandRecord->Called($cmd);
		  my $grnam  = $cmdRec->get_GROUP_NAME || $record->get_PROBE_TYPE;
		  my $lnam   = $cmdRec->get_DESCRIPTION || $record->get_PROBE_TYPE;

		  $record->addInstVar('command_group_name', $grnam);
		  $record->addInstVar('command_long_name',  $lnam);
		}
	);

        # Load the command metrics.
	CommandMetricRecord->LoadFromSqlWithBind("
          select m.command_class, m.metric_id, m.label, m.description,
                 u.unit_label, u.description as unit_description
          from metrics m, units u, command c, probe p
          where m.command_class = c.command_class
          and m.storage_unit_id = u.unit_id
          and p.command_id = c.recid
          and p.recid in  ($probeSubquery)",
          [$satClusterId, $satClusterId, $satClusterId, $satClusterId],
          'COMMAND_CLASS', 'METRIC_ID');

	# Load the command parameters.
	CommandParameterRecord->LoadFromSqlWithBind("
          select cp.command_id, cp.param_name, cp.param_type, cp.mandatory, cp.description,
                 command.command_class,
                 'NA' as threshold_type_name, 'NA' as threshold_metric_id
          from command_parameter cp, probe p, command
          where cp.param_type = 'config'
          and p.command_id = cp.command_id
          and p.recid in ($probeSubquery)
          and command.recid = cp.command_id
          union
          select cp.command_id, cp.param_name, cp.param_type, cp.mandatory, cp.description,
                 command.command_class,
                 ct.threshold_type_name, ct.threshold_metric_id
          from command_parameter cp, command_parameter_threshold ct, probe p, command
          where cp.param_type = 'threshold'
          and p.command_id = cp.command_id
          and ct.command_id = cp.command_id
          and ct.param_name = cp.param_name
          and command.recid = cp.command_id
          and p.recid in  ($probeSubquery)",
          [$satClusterId, $satClusterId, $satClusterId, $satClusterId,
           $satClusterId, $satClusterId, $satClusterId, $satClusterId],
          'COMMAND_ID', 'PARAM_NAME', 'THRESHOLD_TYPE_NAME');

	# Load the probe parameter values.
	ProbeParamValueRecord->LoadFromSqlWithBind('
          select probe_id, command_id, param_name, value
          from probe_param_value
          where probe_id in ('.$probeSubquery.')',
          [$satClusterId, $satClusterId, $satClusterId, $satClusterId],
          ('PROBE_ID', 'PARAM_NAME'));

	# Set up parsed command line and host info for probe records
        $class->Map(sub {
                        my $self = shift();
                        $self->addInstVar('parsedCommandLine',
                                          $self->commandLine($self->get_hostAddress,
                                                            $self->get_CUSTOMER_ID,
                                                            $self->get_NETSAINT_ID));
                    }
        );
}




sub get_CONTACT_GROUPS
{
	my $self = shift();
	# This will always return an array - performs "lazy
	# reinitialization" of any field that isn't already
	# an array.
	if (! (ref($self->{'CONTACT_GROUPS'}) eq 'ARRAY')) {
		my $groups = $self->{'CONTACT_GROUPS'};
		my @grouplist;
		if (defined($groups)) {
			push(@grouplist,$groups);
		}
		$self->{'CONTACT_GROUPS'} = \@grouplist;
	}
	return $self->{'CONTACT_GROUPS'}
}

sub addContact
{
	my ($self,$contactGroupId) = @_;
	# Safe to call at any time as the get_CONTACT_GROUPS
	# method converts the contact groups instvar to
	# an array.
	my $contacts = $self->get_CONTACT_GROUPS;
	push(@$contacts,$contactGroupId);
}

sub command
{
	my $self = shift();
	return CommandRecord->Called($self->get_CHECK_COMMAND);
}


sub commandLine {
   my ($self, $host_ip, $cust_id, $sat_cluster_id) = @_;

   # The hash holding {param, value} pairs
   my %args = (probe => $self->command->get_COMMAND_CLASS);

   # Param value keys are of the form probe_id,param_name, so get the prefix
   # to select out params for this probe.
   my $keyPrefix =  $self->get_RECID.',';

   my $paramHashRef = ProbeParamValueRecord->Instances;

   foreach my $key (keys %$paramHashRef) {
      if (index($key, $keyPrefix) == 0) {
	 my $paramObj = $paramHashRef->{$key};
	 my $value = $paramObj->{VALUE};
	 my $valueLength = length($value);
	 if (index($value, '$') == 0 && rindex($value, '$') == $valueLength-1) {
	    # This is a macro to expand.  We only use
            # HOSTADDRESS, ASSET, CUST, and SAT so that's all we'll worry about here.
	    $value = substr($value, 1, $valueLength-2); # Strip off the dollar signs
	    if ($value eq 'CUST') {
	       $value = $cust_id;
	    } elsif ($value eq 'ASSET') {
	       $value =  -1;    # Not actually used, but put in a value for safety
	    } elsif ($value eq 'HOSTADDRESS') {
	       $value = $host_ip;
	    } elsif ($value eq 'SAT') {
	       $value = $sat_cluster_id;
	    }
	 }
	 $args{$paramObj->{PARAM_NAME}} = $value;
      }
   }
   return \%args;
}

sub briefDescription {
   my $self = shift();
   return " RECID: ".$self->get_RECID.
          " TYPE: ".$self->get_PROBE_TYPE.
          " HOST: ".$self->get_hostName.
          " DESCRIPTION: ".$self->get_DESCRIPTION.
          "\n";
}


sub description {
   my $self = shift();
   my $groups = $self->get_CONTACT_GROUPS;
   return " RECID: ".$self->get_RECID.
          "\n TYPE: ".$self->get_PROBE_TYPE.
          "\n HOST: ".$self->get_hostName." (".$self->get_hostRecid.")".
          "\n DESCRIPTION: ".$self->get_DESCRIPTION.
          "\n CHECK INTERVAL: ".$self->get_CHECK_INTERVAL.
          "\n RETRY INTERVAL: ".$self->get_RETRY_INTERVAL.
          "\n MAX ATTEMPTS BEFORE FAILURE: ".$self->get_MAX_ATTEMPTS.
          "\n CONTACT_GROUPS: ".join(',',@$groups).
          "\n NOTIFICATION_INTERVAL: ".$self->get_NOTIFICATION_INTERVAL.
          "\n NOTIFY ON CRITICAL: ".$self->get_NOTIFY_CRITICAL.
          "\n NOTIFY ON UNKNOWN: ".$self->get_NOTIFY_UNKNOWN.
          "\n NOTIFY ON WARNING: ".$self->get_NOTIFY_WARNING.
          "\n NOTIFY ON RECOVERY: ".$self->get_NOTIFY_RECOVERY.
          "\n";
}

############################################
package CommandRecord;
use strict;
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

sub LoadAll
{
	my ($class) = @_;
	$class->LoadFromSql("
           select recid, name, description, command_class, group_name, for_host_probe
           from command", 'RECID');
}

############################################
package CommandParameterRecord;
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

############################################
package CommandMetricRecord;
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

############################################
package ProbeParamValueRecord;
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

############################################
package NetsaintRecord;
# This will be obsolete very shortly
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

############################################
package SatClusterRecord;
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

############################################
package SatNodeRecord;
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

############################################
package SNMPAlertRecord;
use strict;
use vars qw(@ISA);
@ISA=qw(CFDBRecord);

sub LoadForSatCluster
{
	my ($class,$satClusterId) = @_;
        $class = ref($class) || $class;

	# Fetch service probes and host probes for all sats/scouts ...
	my $alertquery = "
	SELECT 	*
	FROM 	snmp_alert
	WHERE 	sender_cluster_id = $satClusterId";

	# Just Do Me
	$class->LoadFromSql($alertquery,'RECID');

        # DAP - if there aren't any....
        if (! $class->InstanceCount) {
                return undef;
        }

}


sub ClearForSatCluster
{
	my ($class, $satClusterId, $lastRecid) = @_;
        $class = ref($class) || $class;

	if ($satClusterId !~ /^\d+$/ or $lastRecid !~ /^\d+$/) {
	  $@ = "Two numeric arguments required";
	  return undef;
	}

	# Delete SNMP alerts for $satClusterId up to and including $lastRecid
	my $alertquery = "
	DELETE 	from snmp_alert
	WHERE 	sender_cluster_id = $satClusterId
	AND     recid <= $lastRecid";

	# Just Do Me
	my $sth = $class->DoSql($alertquery);
	my $rows = $sth->rows();
	$class->Commit;

	# Clear any loaded instances
	$class->ReleaseAllInstances;

	return $rows;
}

1;
