package NOCpulse::SNMPQueue;

use strict;
use NOCpulse::NPRecords;
use Net::SNMP;
use URI::Escape;
use URI;
use NOCpulse::SMONQueue;

@NOCpulse::SNMPQueue::ISA = qw ( NOCpulse::SMONQueue );

#############################################
# Special constants for the NOCpulse SNMP MIB

# Base OID
$NOCpulse::SNMPQueue::baseoid        = '1.3.6.1.4.1.9282.1.1.1.1';

# OIDs for NOCpulse SNMP traps.  
# Must be in this order for Sprint.  (Don't ask.)
@NOCpulse::SNMPQueue::NPOID = (
  {
    'name'  => 'system.sysUptime.0',
    'oid'   => '1.3.6.1.2.1.1.3.0',
    'type'  => TIMETICKS,
  },
  {
    'name'  => 'snmpTrapOID.0',
    'oid'   => '1.3.6.1.6.3.1.1.4.1.0',
    'type'  => OBJECT_IDENTIFIER,
  },
  {
    'name'  => 'notifCommandName',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.14',
    'type'  => OCTET_STRING,
  },
  {
    'name'  => 'notifType',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.7',
    'type'  => INTEGER,
  },
  {
    'name'  => 'notifOperationCenter',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.4',
    'type'  => OCTET_STRING,
  },
  {
    'name'  => 'notifUrl',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.9',
    'type'  => OCTET_STRING,
  },
  {
    'name'  => 'notifOsType',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.8',
    'type'  => OCTET_STRING,
  },
  {
    'name'  => 'notifMessage',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.10',
    'type'  => OCTET_STRING,
  },
  {
    'name'  => 'notifProbeID',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.2',
    'type'  => INTEGER32,
  },
  {
    'name'  => 'notifHostIP',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.12',
    'type'  => IPADDRESS,
  },
  {
    'name'  => 'notifSeverity',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.6',
    'type'  => INTEGER,
  },
  {
    'name'  => 'notifCommandID',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.13',
    'type'  => INTEGER32,
  },
  {
    'name'  => 'notifProbeClass',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.3',
    'type'  => INTEGER,
  },
  {
    'name'  => 'notifHostName',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.11',
    'type'  => OCTET_STRING,
  },
  {
    'name'  => 'notifSupportCenter',
    'oid'   => '1.3.6.1.4.1.9282.1.1.1.5',
    'type'  => OCTET_STRING,
  },
);


sub new
{
    my $class = shift;
    my %args = @_;

    my $self = NOCpulse::SMONQueue->new(%args);
    bless $self, $class;
    
    # Config for SNMP queries
    $self->last_snmp_query(0);   # Time of last request
    $self->snmp_query_freq(60);  # Min time between requests
    $self->last_snmp_ndqed(0);   # Number of SNMP alerts dequeued on last run
    
    # Always add the SNMP trap log
    my $snmplogobject   = new NOCpulse::Debug;
    my $snmplogfile     = $self->config()->get('queues',   'snmplog');
    my $snmplogbasename = $snmplogfile; $snmplogbasename =~ s,^.*/,,;
    my $snmplog         = $snmplogobject->addstream(LEVEL  => 1,
						    FILE   => $snmplogfile,
						    APPEND => 1);
    $snmplog->autoflush(1);

    $self->snmplog($snmplog);
   
    return $self; 
}

sub snmplog         { shift->_elem('snmplog',         @_); }
sub last_snmp_query { shift->_elem('last_snmp_query', @_); }
sub snmp_query_freq { shift->_elem('snmp_query_freq', @_); }
sub last_snmp_ndqed { shift->_elem('last_snmp_ndqed', @_); }

sub id
{
    return 'snmp';
}

sub name
{
    return "SNMP";
}

sub send_as_snmp_trap
{
    my $self = shift;

    my $record     = shift;
    my @varbinds   = ();
    my @csvfields  = ();
    my $errno      = 0;
    my $timeticks  = $self->gettimeticks();
    
    # Map queuefile parameters to SNMP varbind values
    my %VALUE;  
    
    # Fetch SNMP host and port from _QUEUE_PARAMS
    my $host = $record->{'DEST_IP'};
    my $port = $record->{'DEST_PORT'};
    push(@csvfields, time, "host => $host", "port => $port");
    
    $self->dprint(1, "\tSending via SNMP to ${host}:${port}\n");
    
    # Set notifOperationCenter, notifOsType, and notifMessage
    $VALUE{'ip'}                   = $host;
    $VALUE{'port'}                 = $port;
    $VALUE{'notifOperationCenter'} = $record->{'OP_CENTER'};
    $VALUE{'notifOsType'}          = $record->{'OS_NAME'};
    $VALUE{'notifMessage'}         = $record->{'MESSAGE'};
    $VALUE{'notifMessage'}         =~ s/\\n/\n/g;  # Remove newline encoding
    $VALUE{'notifHostIP'}          = $record->{'HOST_IP'};
    $VALUE{'notifCommandID'}       = $record->{'COMMAND_ID'};
    $VALUE{'notifCommandName'}     = $record->{'COMMAND_NAME'};
    $VALUE{'notifHostName'}        = $record->{'HOST_NAME'};
    $VALUE{'notifProbeID'}         = $record->{'PROBE_ID'};
    $VALUE{'notifUrl'}             = $record->{'NOTIF_URL'};
    $VALUE{'notifType'}            = $record->{'NOTIF_TYPE'};
    $VALUE{'notifSeverity'}        = $record->{'SEVERITY'};
    $VALUE{'notifProbeClass'}      = $record->{'PROBE_CLASS'};
    $VALUE{'notifSupportCenter'}   = $record->{'SUPPORT_CENTER'};
    
    # The following varbinds are required for all SNMPv2 traps
    $VALUE{'system.sysUptime.0'} = $timeticks;
    $VALUE{'snmpTrapOID.0'}      = $NOCpulse::SNMPQueue::baseoid;
    
    # Add varbinds for notification parameters
    my $rec;
    foreach $rec (@NOCpulse::SNMPQueue::NPOID) {
	$self->dprint(3, "\t\tAdding varbind:  OID $rec->{'oid'} ",
		       "(\"$rec->{'name'}\", type $rec->{'type'}) ",
		       "= $VALUE{$rec->{'name'}}\n");
	
	unless (defined($VALUE{$rec->{'name'}})) {
	    # Assign acceptable values for undefs
	    if ($rec->{'type'} == OCTET_STRING) {
		$VALUE{$rec->{'name'}} = '';
	    } elsif ($rec->{'type'} == IPADDRESS) {
		$VALUE{$rec->{'name'}} = '0.0.0.0';
	    } else {
		$VALUE{$rec->{'name'}} = 0;
	    }
	}
	
	push(@varbinds, $rec->{'oid'}, 
	     $rec->{'type'},
	     $VALUE{$rec->{'name'}});
	
	push(@csvfields, "$rec->{'name'} => " . 
	     $self->encode($VALUE{$rec->{'name'}}));
    }
    
    # Start the session
    my ($session, $error) = Net::SNMP->session(hostname  => $VALUE{'ip'},
					       port      => $VALUE{'port'},
					       version   => 2);
    
    if (! defined($session))
    {
	$@ = "Error creating SNMP session: $error";
	$errno = 1;
    }
    else
    {
	my $value = $session->trap(enterprise   => $NOCpulse::SNMPQueue::baseoid,
				   generictrap  => '6',
				   specifictrap => '0',
				   timestamp    => $timeticks,
				   varbindlist  => \@varbinds);
	
	unless (defined($value)) {
	    $@ = "Unable to send SNMP trap:  " . $session->error();
	    $errno = 2;
	}
	$session->close();
    }
    
    # Create a CSV string to write to the logfile
    my $csvstring = $self->list2csv(@csvfields, $errno, $@);
    
    return($errno, $csvstring);
}

sub dequeue
{
    my $self = shift;
    my $smon = shift;

    my $dqlimit  = 500; # !!!!!
    my $dequeued = 0;

    $self->dprint(3, "Entering dequeue_snmp()\n");
    
    # Keep from killing the database with frequent queries
    if ($self->last_snmp_ndqed == 0 and time - $self->last_snmp_query < $self->snmp_query_freq) {
	
	$self->dprint(3, "\tNot querying for SNMP alerts (last queried ",
		       scalar(localtime($self->last_snmp_query)), ", current time is ", 
		       scalar(localtime(time)), ", freq is ", $self->snmp_query_freq, 
		       ", dequeued ".$self->last_snmp_ndqed." last time)\n");
	return 0;
	
    }
    else
    {
	$self->last_snmp_query(time);
    }
    
    # First, need to fetch the ID of the last sent message.
    my $statefile = $self->config()->get('queues', 'snmplast');
    my $last;
    if (-f $statefile) {
	chomp($last = $self->config()->getContents('queues', 'snmplast'));
    } else {
	# State file wasn't created yet -- create it.
	local * FILE;
	open(FILE, '>', $statefile) or die "Couldn't create $statefile: $!";
	print FILE "0";
	close(FILE);
	$last = 0;
    }
    $self->dprint(3, "\tLast SNMP alert sent: $last\n");
   
    my $cluster_id = $self->cluster_id(); 
    
    # Next, need to fetch SNMP alerts from the database
    my $uri      = new URI($self->config()->get('queues', 'snmp_download_url'));
    my $path     = $uri->path() . "?cluster_id=${cluster_id}&last_recid=$last";
    
    $self->dprint(3, "\tFetching SNMP alerts from $path\n");
    
    my($code, $msg, $body) = $smon->connection()->ssl_get($path);
    
    if ($code != 200) {
	
	my $subject = $self->id()." queue send error";
	my $message = "Couldn't send: ";
	if (defined($code)) {
	    $message .= "$code $msg\n";
	    $message .= "Content: $body\n" if (length($body));
	} else {
	    $message .= "$@\n";
	}
	$self->dprint(1, "\t\tFailed:  $subject: $message");
	$self->gritcher()->gritch($subject, $message);
	
    } else {
	
        my $xml = $body;
	
	# Dump it XML
	$self->dprint(5, "\tXML:\n$xml\n");
	
	# And soak it up
	SNMPAlertRecord->LoadFromXML($xml, 'RECID');
	
	my $nalerts = SNMPAlertRecord->InstanceCount;
	
	if ($nalerts) {
	    $self->dprint(1, "Draining queue ".$self->id()." ($nalerts entries, ",
			   "limit $dqlimit)\n");
	    
	    my $sorter = sub {
		$_[0]->{'RECID'} <=> $_[1]->{'RECID'}
	    };
	    
	    my $dequeuer = sub {
		$last = $_[0]->{'RECID'}; 
		$self->dprint(3, "\tDequeueing $last (dqlimit $dqlimit, dequeued $dequeued)\n");
		if ($dqlimit == 0 or $dequeued <= $dqlimit) {
		    $dequeued++;
		    my($errno, $csvstring) = $self->send_as_snmp_trap(@_);
		    if ($errno) {
			$self->dprint(1, "\tERROR: $errno ($@)\n") if ($errno);
		    } else {
			# Log the trap to the SNMP log
			$self->dprint(1, "\tSuccess!\n") if ($errno);
			$self->snmplog->dprint(0, "$csvstring\n");
		    }
		}
	    };
	    
	    SNMPAlertRecord->Map($dequeuer, $sorter);
	    
	    $self->dprint(1, "\tDequeued $dequeued alerts\n");
	    $self->dprint(3, "\tLast SNMP alert sent: $last\n");
	    
	    # Save the last processed recid for later
	    local * FILE;
	    open(FILE, '>', $statefile) or die "Couldn't create $statefile: $!";
	    print FILE "$last";
	    close(FILE);
	}
	
	SNMPAlertRecord->ReleaseAllInstances;
    }
    
    $self->last_snmp_ndqed($dequeued);
    
    return $dequeued;
}

sub gettimeticks
{
    my $self = shift;
    
    local * UPTIME;
    open(UPTIME, '<', '/proc/uptime');
    my $uptime = <UPTIME>;
    close(UPTIME);
    
    my $ticks = int((split(/ /, $uptime))[0] * 100);
    
    return($ticks);
}

sub encode
{
  my $self = shift;
  # Encode key/value pairs for the queue file -- URL-encode newlines
  # and carriage returns efficiently
  my $str = shift;
  $str =~ s/[%\n\cM]/"%" . sprintf("%02X",ord($&))/ge;
  return $str;
}

sub list2csv
{
    my $self = shift;
    my @safefields;
    my $param;
    
    foreach $param (@_) {
	if ($param =~ /,/) {
	    $param =~ s/"/""/g;
            $param = sprintf('"%s"', $param);
	}
        push(@safefields, $param);
    }
  
    return join(',', @safefields);
}


sub _elem
{
    my $self = shift;
    my $elem = shift;
    my $old = $self->{$elem};
    $self->{$elem} = shift if (scalar(@_));
    return $old;
}

1;
