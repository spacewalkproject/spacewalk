
package Probe;

use strict;

use NOCpulse::CommandLineApplicationComponent;
use NOCpulse::Scheduler::Event::PluginEvent;
use NOCpulse::PlugFrame::ProbeState;
use NOCpulse::TimeSeriesDatapoint;
use NOCpulse::TimeSeriesQueue;
use NOCpulse::Notification;
use NOCpulse::NotificationQueue;
use NOCpulse::StateChange;
use NOCpulse::StateChangeQueue;
use NOCpulse::Config;
use NOCpulse::Gritch;
use Date::Manip;
use POSIX qw(strftime ceil);
use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);

@Probe::ISA=qw(CommandLineApplicationComponent);


sub registerSwitches
{
        my $self = shift();
	# NOTE: Override this and fill it with calls to 
	# $self->registerSwitch(name,spec,required,default,usage)
	# if your module needs switches. 
}

sub run
{
    my $self = shift();
    # You **must** override this.  This is where your probe subclass does it's work,
    # records it's results, and determines it's exit status.
    # $self->recordResult(metricName,objectName,value,[time]);
    # $self->setStatus('OK');
}

sub instVarDefinitions
{
	# If you choose to override this, be absolutely certain that
        # you call $self->SUPER::instVarDefinitions from your subclass!
        my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('plugin');
        $self->addInstVar('memory', undef);
        $self->addInstVar('status');
        $self->addInstVar('statusStrings');
        $self->addInstVar('shellModule');
}


############################ Internal/private stuff below - don't modify or override! #############################
sub initialize
{
    # DO NOT OVERRIDE
    my ($self,$plugin,$probeRecord) = @_;

    $self->SUPER::initialize;
    $self->set_plugin($plugin);
    $self->set_shellModule($plugin->get_shellModule);
    $self->set_status('UNKNOWN');
    $self->set_statusStrings([]);
    $self->{'timeSeries'} = [];
    if ($probeRecord) {
	$self->addInstVar('probeRecord',$probeRecord);
    }
    return $self;
}

sub registerMetrics
{
}

sub registerMetric {
}

# DAP Override persistent object per-class logic as all our objects have unique IDs

sub databaseType {
   my $class = shift();
   return Probe->ConfigValue('databaseType');
}

sub databaseFilename {
   my $class = shift();
   if ($main::ProbeDatabaseFile) {
      my $result = $class->databaseDirectory.'/'.$main::ProbeDatabaseFile.$class->databaseType->fileExtension;
      return $result;
   } else {
      return $class->databaseDirectory.'/Probe'.$class->databaseType->fileExtension;
   }
}

sub database
{
    my $class = 'Probe';
	
    if (!defined $class->getClassVar('database')) {
	my $database;
	$database = $class->databaseType->newInitialized($class->databaseFilename);
	$class->setClassVar('database',$database);
	return $database;
    } else {
	return $class->getClassVar('database');
    }
}

sub instances
{
    my $class = 'Probe';

    if (!defined $class->getClassVar('objects')) {
        $class->setClassVar('objects',{});
    }
    return $class->getClassVar('objects');
}

################## end Persistent Object overrides ################

sub get_probeRecord {
   my ($self, $id) = @_;
   my $probeRec = $self->get('probeRecord');
   if (! defined($probeRec) && defined($id)) {
      $probeRec = ProbeRecord->Called($id);
      $self->set_probeRecord($probeRec);
   }
   return $probeRec;
}

sub debugging {
   my $self = shift();
   return $self->get_plugin->switchValue('debug');
}

sub get_memory
{
	# Returns a lazily-initialized ProbeState object.
	my $self = shift();
	if (! defined($self->get('memory'))) {
		$self->set_memory(ProbeState->newInitializedNamed($self->get_name));
	}
	return $self->get('memory');
}

sub persist
{
	my $self = shift();

	# Remove data that need not be stored with the probe.
	$self->set_memory(undef);
	$self->set_plugin(undef);
	$self->set_probeRecord(undef);

	return $self->SUPER::persist;
}


sub needsCommandShell
{
        # DO NOT OVERRIDE
	# If you probe needs a shell, use the ShellProbe class - it has a
        # bunch of shell IO behavior
	my $self = shift();
	return 0;
}

sub setStatus {
      # DO NOT OVERRIDE
      my $self = shift();
      $self->set_status(shift());
}

sub recordResult
{
    # DO NOT OVERRIDE
    
    my $self = shift;
    my $metricPath = shift;
    my $unused = shift;
    my $v = shift;
    my $t = shift || time();

    my ($junk, $metricName) = split("->", $metricPath, 2);
    
    $self->dprint(5,'recordResult metric: '.$metricName.' value: '.$v.' time: '.$t, "\n");

    if ($self->has_probeRecord) {
       my @oidParts = ($self->get_probeRecord->get_CUSTOMER_ID,
		       $self->get_probeRecord->get_RECID,
		       $metricName);
       my $oid = join('-', @oidParts);

       my $tsdp = TimeSeriesDatapoint->newInitialized();
       $tsdp->oid($oid);    
       $tsdp->t($t);
       $tsdp->v($v);
    
       push @{$self->{'timeSeries'}}, $tsdp;
    } else {
       $self->dprint(5,"recordResult: No probe record, nothing recorded\n");
    }
} 

sub addStatusString
{
        # DO NOT OVERRIDE
        my ($self,@messages) = @_;
	$self->dprint(5,'Adding status string: '.join(' ',@messages),"\n");
        push(@{$self->get_statusStrings},join(' ',@messages));
}

sub get_lastNotificationForStatus
{
	my ($self,$status) = @_;
	return $self->get_memory->get('last'.$status.'Notification');
}

sub set_lastNotificationForStatus
{
	my ($self,$status,$value) = @_;
	return $self->get_memory->set('last'.$status.'Notification',$value);
}

sub prepareNotification
{
    my $self = shift;
    my $now = shift;

    my $notification = Notification->newInitialized();

    $notification->time($now);
    $notification->state($self->get_status);
    $notification->checkCommand($self->get_probeRecord->get_CHECK_COMMAND);
    $notification->commandLongName($self->get_probeRecord->get_command_long_name);
    $notification->clusterId($self->get_plugin->get_cluster->get_id);
    $notification->clusterDesc($self->get_plugin->get_cluster->get_description);
    $notification->customerId($self->get_probeRecord->get_CUSTOMER_ID);

    if ( $self->get_probeRecord->get_PROBE_TYPE eq 'ServiceProbe' )
    {
	$notification->type('service');
	$notification->probeId($self->get_probeRecord->get_RECID);
	$notification->probeType($self->get_probeRecord->get_PROBE_TYPE);
	$notification->probeDescription($self->get_probeRecord->get_DESCRIPTION);
	$notification->message($self->statusMessage);
	$notification->hostAddress($self->get_probeRecord->get_hostAddress); # vs ADDRESS ??
	$notification->probeGroupName($self->get_probeRecord->get_command_group_name);
	$notification->physicalLocationName($self->get_probeRecord->get_physical_location_name);
	$notification->osName($self->get_probeRecord->get_os_name);
	$notification->hostName($self->get_probeRecord->get_hostName);
	$notification->hostProbeId($self->get_probeRecord->get_hostRecid);
    }
    elsif ( $self->get_probeRecord->get_PROBE_TYPE eq 'LongLegs' )
    {
	$notification->type('longlegs');
	$notification->probeId($self->get_probeRecord->get_RECID);
	$notification->probeType($self->get_probeRecord->get_PROBE_TYPE);
	$notification->probeDescription($self->get_probeRecord->get_DESCRIPTION);
	$notification->message($self->statusMessage);
    }
    else 
    {
	# assert: $self->get_probeRecord->get_PROBE_TYPE eq 'HostProbe'

	$notification->type('host');
	$notification->hostAddress($self->get_probeRecord->get_hostAddress);
	$notification->probeGroupName($self->get_probeRecord->get_command_group_name);
	$notification->physicalLocationName($self->get_probeRecord->get_physical_location_name);
	$notification->osName($self->get_probeRecord->get_os_name);
	$notification->hostName($self->get_probeRecord->get_hostName);
	$notification->hostProbeId($self->get_probeRecord->get_hostRecid);
	$notification->probeDescription($self->get_probeRecord->get_DESCRIPTION);
    }

    return $notification;
}

sub distributeNotification
{
    my $self = shift;
    my $notification = shift;
    my $notificationqueue = shift;

    # probeRecord will have three parallel arrays:
    # 	CONTACT_GROUPS (cg recids)
    #	contactGroupNames (cg names)
    #	contactGroupCustomers (cg cust ids)
    # All same size, elements line up, so need to iterate by index

    my $cgRecids = $self->get_probeRecord->get_CONTACT_GROUPS;
    my $cgNames = $self->get_probeRecord->get_contactGroupNames;
    # my $cgCusts = $self->get_probeRecord->get_contactGroupCustomers;

    my $index = 0;
    while ($index < scalar(@$cgRecids))
    {
	my $groupId = $$cgRecids[$index];
	my $groupName = $$cgNames[$index];
	$notification->groupId($groupId);
	$notification->groupName($groupName);
	$notificationqueue->enqueue($notification);
	$index++;
    }

    # need to clear groupId and groupName ?

    my $queueUrls = $self->get_probeRecord->get_queue_urls;
    my $queueUrl;
    foreach $queueUrl (@$queueUrls)
    {
 	$notification->snmp(1);
        $queueUrl =~ /(.*)\:\/\/(.*)/;
        my $snmpPort = $2;
	$notification->snmpPort($snmpPort);
	$notificationqueue->enqueue($notification);
    }

}


sub nextRunTime
{
    my $self = shift();
    
    # This gets called by Plugin::asInitialEvent (and others).
    # The conditional allows for some spreading out of run times
    # for have-never-been-run probes.

    if (! $self->get_memory->get_nextRunTime)
    {
	$self->get_memory->set_nextRunTime(time() + ceil(rand($self->get_probeRecord->get_CHECK_INTERVAL * 60)));
	#print "Set randomized start time to ".$self->get_memory->get_nextRunTime."\n";
    }
    
    return $self->get_memory->get_nextRunTime;
}

sub handleDown
{
    my $self = shift;
    my $timeNow = shift;
    my $notificationqueue = shift;

    $self->get_memory->set_failures($self->get_memory->get_failures + 1);

    if ($self->get_memory->get_failures >= $self->get_probeRecord->get_MAX_ATTEMPTS) {
        # I have failed enough so that I need to do notification.
        my $status = $self->get_status;
	    
        if (
            ( ( $status eq 'WARN' )     and $self->get_probeRecord->get_NOTIFY_WARNING ) or
            ( ( $status eq 'UNKNOWN' )  and $self->get_probeRecord->get_NOTIFY_UNKNOWN ) or
            ( ( $status eq 'CRITICAL' ) and $self->get_probeRecord->get_NOTIFY_CRITICAL )
           ) {
            if (($self->get_lastNotificationForStatus($status) + 
                 ($self->get_probeRecord->get_NOTIFICATION_INTERVAL * 60)) <= $timeNow) {
                my $notification = $self->prepareNotification($timeNow);
                $self->distributeNotification($notification, $notificationqueue);
                $self->set_lastNotificationForStatus($status, $timeNow);
            }
        }
    }
}

sub handleRecover
{
    my $self = shift;
    my $timeNow = shift;
    my $notificationqueue = shift;

    $self->get_memory->set_failures(0);

    if ($self->get_probeRecord->get_NOTIFY_RECOVERY) {
	$self->set_lastNotificationForStatus('WARN',0);
	$self->set_lastNotificationForStatus('CRITICAL',0);
	$self->set_lastNotificationForStatus('UNKNOWN',0);

	my $notification = $self->prepareNotification($timeNow);
	$self->distributeNotification($notification, $notificationqueue);
    }

}


sub get_translatedStatus
{
    my $self = shift;

    my $state = $self->get_status;
    if ($self->get_probeRecord->get_PROBE_TYPE eq 'HostProbe')
    {
        $state = 'UP' if ($state eq 'OK');
        $state = 'DOWN' if ($state eq 'WARN');
        $state = 'DOWN' if ($state eq 'CRITICAL');
    }
    elsif ( $state eq 'WARN' )
    {
        $state = 'WARNING';
    }
    
    return $state;
}

sub stateHasChanged
{
    my $self = shift;
    
    

    return $self->get_status ne $self->get_memory->get_lastStatus;
}

sub changeState
{
    my $self = shift;
    my $timeNow = shift;
    my $statechangequeue = shift;
    
    my $stateChange = StateChange->newInitialized();
    
    $stateChange->desc($self->statusMessage);
    $stateChange->t($timeNow);

    my $probe_id = $self->get_probeRecord->get_RECID;
   
    my $cluster = $self->get_plugin->get_cluster;
 
    if ($self->get_probeRecord->get_PROBE_TYPE eq 'LongLegs') {
	my $cluster_id = $cluster->get_id();
	$stateChange->oid($probe_id.'-'.$cluster_id);
    }
    else {
	$stateChange->oid($probe_id);
    }

    my $state = $self->get_translatedStatus();
    $stateChange->state($state);
    
    $self->get_memory->set_lastStatusChange($timeNow);

    $statechangequeue->enqueue($stateChange);
}

sub _run
{
    # This is the protocol Plugin uses to invoke the probe.  It's a wrapper
    # to the user's run() method as we need to take care of some business
    # after the probe is done doing it's probing.

    my ($self, $doProbe) = @_;

    $self->dprint(9,"entering _run\n");
    
    my $startTime = [gettimeofday];
    my ($scheduledRunTime,$latency);
    if ($self->has_probeRecord) {
	$scheduledRunTime = $self->get_memory->get_nextRunTime || $startTime->[0];
	$latency = $startTime->[0] - $scheduledRunTime;
	$latency = 0 if ($latency < 0);
	# Save this stuff in case we get killed during run() so we
	# don't throw latency etc all akilter.
	$self->get_memory->set_lastExecTime($startTime->[0]);
	$self->get_memory->set_lastLatency($latency);
	$self->get_memory->persist; # Possible source of delays/cpu loading/io loading, etc - keep eyes open
    }
    $self->set_status('UNKNOWN');
    my $execErr;

    if ( $doProbe ) {
       eval {
	   $self->run();
       };
       $execErr = $@;
       if ($execErr) {
	  # Code failure of some kind. Replace whatever the status string was with
	  # the "internal problem" message, and print the full error to the log.
	  $self->setStatus('UNKNOWN');
	  $self->set_statusStrings([NOCpulse::Scheduler::Event::PluginEvent::CodeFailureMessage()]);
	  print STDERR 'Error executing probe '.(ref $self).': '.$execErr;
       }
    }	
    if ( $self->has_probeRecord )
    {
	# I'm running as a thawed instance (implies satellite or interactive --saveid)

        $self->dprint(4, "constructing queue objects\n");

        my $cfg = $self->get_plugin()->get_npconfig();
        my $debug = $self->get_plugin()->debugObject();
        my $gritcher = new NOCpulse::Gritch($cfg->get('queues', 'gritchdb'));

        my $notificationqueue = NotificationQueue->new( Debug => $debug, Config => $cfg, Gritcher => $gritcher );

	if ($execErr) {
		# Gritch about the code error.
		my $codeGritcher = new NOCpulse::Gritch($cfg->get('satellite', 'gritchdb'));
		$codeGritcher->recipient($notificationqueue);
		my $truncatedStdErr = substr($execErr, 0, 1400);
		my $recid = $self->get_probeRecord->get_RECID;
		$codeGritcher->gritch("Probe ".ref($self)." code failed: $truncatedStdErr",
				      "Probe $recid code caused a Perl error: $truncatedStdErr\n");
	}

	$self->dprint(9,"entering notif decision: ",
		      ' status = ',$self->get_status,
		      ' type = ',$self->get_probeRecord->get_PROBE_TYPE,
		      ' lastStatus = ',$self->get_memory->get_lastStatus,
		      ' failures = ',$self->get_memory->get_failures,
		      ' max attempts = ',
		      $self->get_probeRecord->get_MAX_ATTEMPTS, "\n");
	
	my $timeNow = time();
	my $nextRunTime;
	
	if ($self->get_status ne 'OK')
	{
	    $nextRunTime = $timeNow + ($self->get_probeRecord->get_RETRY_INTERVAL * 60);
	    $self->handleDown($timeNow, $notificationqueue);
	}
	elsif ( ( defined $self->get_memory->get_lastStatus ) and
		( $self->get_memory->get_lastStatus ne 'OK' ) )
	{
	    $nextRunTime = $timeNow + ($self->get_probeRecord->get_CHECK_INTERVAL * 60);
	    $self->handleRecover($timeNow, $notificationqueue);
	}
	else
	{
	    $nextRunTime = $timeNow + ($self->get_probeRecord->get_CHECK_INTERVAL * 60);
	}
	
	if ( $self->stateHasChanged() )
	{
	    my $statechangequeue = StateChangeQueue->new( Debug => $debug, Config => $cfg, Gritcher => $gritcher );
	    $self->changeState($timeNow, $statechangequeue);
	}
	
	if ($self->get_plugin->configValue('enqueueMetrics') eq 'Y')
	{ 
	    my $timeseriesqueue = TimeSeriesQueue->new( Debug => $debug, Config => $cfg, Gritcher => $gritcher );
	    $timeseriesqueue->enqueue(@{$self->{'timeSeries'}});
	}

	my $stopTime = [gettimeofday];
	my $interval = tv_interval($startTime, $stopTime);

	# Save current state for next run.
	$self->get_memory->set_lastExecutionTime($interval);
	$self->get_memory->set_lastStatus($self->get_status);
	$self->get_memory->set_lastStatusMessage($self->statusMessage);
	$self->get_memory->set_nextRunTime($nextRunTime);
	$self->get_memory->set_lastTranslatedStatus($self->get_translatedStatus);
        
        # Make sure we save our own state...
	$self->get_memory->set_readOnly(0);
	$self->get_memory->persist();

	$self->dprint(9,"leaving _run: ",
		      ' status = ',$self->get_status,
		      ' type = ',$self->get_probeRecord->get_PROBE_TYPE,
		      ' lastStatus = ',$self->get_memory->get_lastStatus,
		      ' failures = ',$self->get_memory->get_failures,
		      ' max attempts = ',$self->get_probeRecord->get_MAX_ATTEMPTS, "\n");
	
    }
}

sub handleTimeout
{
    my $self = shift();
    $self->set_status('UNKNOWN');
    $self->addStatusString('Probe timed out');
    return $self->_run(0,[]);
}

sub statusMessage
{
    my $self = shift();
    my $output = '';
    if (scalar(@{$self->get_statusStrings})) {
	$output = join(' ', @{$self->get_statusStrings});
	# Escape the eol control characters so that they can be handled in HTML.
	$output =~ s/\r/\\r/g;
	$output =~ s/\n/\\n/g;
	$output .= "\n";
    }
    return $output;
}

sub dprint
{
    my ($self,$level,@stuff) = @_;
    $self->SUPER::dprint($level,ref($self).'('.$self->get_name.") ",@stuff);
}

sub printUsageNotes {
    my ($self) = @_;
    if ($self->has_probeRecord) {
	$self->print("\nProbe record summary:\n\n");
	$self->print($self->get_probeRecord->description);
	$self->print("\n");
	$self->print("Probe memory:\n\n");
	$self->print($self->get_memory->asString);
	#$self->print("*"x80,"\n");
    }
}

1;

__END__
=head1 NAME

Probe - an abstract superclass for creating probes within the NOCpulse PlugFrame framework.


=head1 DESCRIPTION

A probe is a piece of software that measures and reports on some
aspect of a service or resource, optionally triggering state change
events based on thresholds, and optionally returning metrics for use
in trend reporting.

In addition to the things that CommandLineApplicationComponent provides, the Probe class 
provides facilities for:

 * interacting with the driver layer (Plugin) in terms of status messages and exit levels.
 
 * a protocol for the execution of the probe logic itself
 
 * access to a mechanism that allows for transparent persistence of otherwise transient state data


=head1 REQUIRES

CommandLineApplicationComponent, ProbeState

=cut

=head1 INSTANCE METHODS

=over 4

=item registerSwitches()

Protocol method - you must override it.

Override registerSwitches() with a method that makes calls to
addSwitch() (see CommandLineApplicationComponent)

=cut
        
=item run()

Protocol method - you must override it.

Override run() with a method that does your probe/test/record logic.  Usually this will mean
that you will be making calls to addMessage(), setStatus(), and recordResult()

=cut
        

=item instVarDefinitions()

Defines the following:

plugin - holds a pointer to the Plugin instance that created the probe object

memory - holds a pointer to a ProbeState instance (with which you store and retrieve otherwise transient state)

You may override this if you need to define additional instance variables.  If you do,
be sure that your method follows this pattern:

{
   my $self = shift()
   $self->SUPER::instVarDefinitions()
   $self->addInstVar('nameOfIt');
}

=cut

=item initialize(<plugin>,<@params>)

Calls SUPER::initialize(), sets the plugin property to the plugin instance passed in,
sets the memory property to a new (or un-serialized) instance of a ProbeState object,
returns self.  Other params may be passed as well - be sure to forward them to the SUPER.

If you need to override this method, be sure it follows this pattern:

{
    my ($self,$plugin,@params) = @_;
    $self->SUPER::initialize($plugin,@params);
    <your code>;
    return $self;
}

=cut
    

=item registerMetrics()

Deprecated method, never called.

=cut


=item registerMetric(<metricName>)

Deprecated method that now has no effect, and eventually will be removed. It formerly
registered a metric as being a part of this probe.

=cut


=item database()

Returns the databaseType instance for this class

=cut


=item instances()

Returns a hash of all the instances of the class B<currently in memory>

=cut


=item needsCommandShell()

Returns zero.  ShellProbe based derivatives return 1.  You will probably never need to override
this or access it.

=cut
        

=item setStatus(<statusName>)

Tells the plugin to set up for exiting with the given statusName.  Status names are listed in
the Plugin class documentation.

=cut
        

=item recordResult(<metricName>,<objectName>,<value>,[<time>])

Sends <value> into the metric named <metricName> optionally setting 
the time to <time>.

NOTE: <objectName> is kruft - please supply undef and pay no attention to
the man behind the curtain :)

=cut
    

=item addStatusString(<string>)

Adds the string you provide to the list of status strings that the plugin will return as a 
status string.

=cut
        
 
=item statusMessage()
 
Constructs a properly formatted status message from the list of messages created
via calls to addStatusString() (above)
 
=cut
    
