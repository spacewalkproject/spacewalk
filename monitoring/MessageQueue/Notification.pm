package NOCpulse::Notification;

use strict;
use URI::Escape;

use NOCpulse::QueueEntry;
@NOCpulse::Notification::ISA = qw ( NOCpulse::QueueEntry );


sub time { shift->_elem('time', @_); }
sub checkCommand { shift->_elem('checkCommand', @_); }
sub clusterDesc { shift->_elem('clusterDesc', @_); }
sub clusterId { shift->_elem('clusterId', @_); }
sub commandLongName { shift->_elem('commandLongName', @_); }
sub customerId { shift->_elem('customerId', @_); }
sub groupId { shift->_elem('groupId', @_); }
sub groupName { shift->_elem('groupName', @_); }
sub hostAddress { shift->_elem('hostAddress', @_); }
sub hostName { shift->_elem('hostName', @_); }
sub hostProbeId { shift->_elem('hostProbeId', @_); }
sub message { shift->_elem('message', @_); }
sub osName { shift->_elem('osName', @_); }
sub physicalLocationName { shift->_elem('physicalLocationName', @_); }
sub probeDescription { shift->_elem('probeDescription', @_); }
sub probeGroupName { shift->_elem('probeGroupName', @_); }
sub probeId { shift->_elem('probeId', @_); }
sub probeType { shift->_elem('probeType', @_); }
sub snmp { shift->_elem('snmp', @_); }
sub snmpPort { shift->_elem('snmpPort', @_); }
sub state { shift->_elem('state', @_); }
sub subject { shift->_elem('subject', @_); }
sub type { shift->_elem('type', @_); }

sub as_url_query
{
    my $self = shift;
    my @fields;
    
    push(@fields, "time=" .
	 uri_escape($self->time, $NOCpulse::QueueEntry::badchars));
    push(@fields, "checkCommand=" .
	 uri_escape($self->checkCommand, $NOCpulse::QueueEntry::badchars));
    push(@fields, "clusterDesc=" .
	 uri_escape($self->clusterDesc, $NOCpulse::QueueEntry::badchars));
    push(@fields, "clusterId=" .
	 uri_escape($self->clusterId, $NOCpulse::QueueEntry::badchars));
    push(@fields, "commandLongName=" .
	 uri_escape($self->commandLongName, $NOCpulse::QueueEntry::badchars));
    push(@fields, "customerId=" .
	 uri_escape($self->customerId, $NOCpulse::QueueEntry::badchars));
    push(@fields, "groupId=" .
	 uri_escape($self->groupId, $NOCpulse::QueueEntry::badchars));
    push(@fields, "groupName=" .
	 uri_escape($self->groupName, $NOCpulse::QueueEntry::badchars));
    push(@fields, "hostAddress=" .
	 uri_escape($self->hostAddress, $NOCpulse::QueueEntry::badchars));
    push(@fields, "hostName=" .
	 uri_escape($self->hostName, $NOCpulse::QueueEntry::badchars));
    push(@fields, "hostProbeId=" .
	 uri_escape($self->hostProbeId, $NOCpulse::QueueEntry::badchars));
    push(@fields, "message=" .
	 uri_escape($self->message, $NOCpulse::QueueEntry::badchars));
    push(@fields, "osName=" .
	 uri_escape($self->osName, $NOCpulse::QueueEntry::badchars));
    push(@fields, "physicalLocationName=" .
	 uri_escape($self->physicalLocationName, $NOCpulse::QueueEntry::badchars));
    push(@fields, "probeDescription=" .
	 uri_escape($self->probeDescription, $NOCpulse::QueueEntry::badchars));
    push(@fields, "probeGroupName=" .
	 uri_escape($self->probeGroupName, $NOCpulse::QueueEntry::badchars));
    push(@fields, "probeId=" .
	 uri_escape($self->probeId, $NOCpulse::QueueEntry::badchars));
    push(@fields, "probeType=" .
	 uri_escape($self->probeType, $NOCpulse::QueueEntry::badchars));
    push(@fields, "snmp=" .
	 uri_escape($self->snmp, $NOCpulse::QueueEntry::badchars));
    push(@fields, "snmpPort=" .
	 uri_escape($self->snmpPort, $NOCpulse::QueueEntry::badchars));
    push(@fields, "state=" .
	 uri_escape($self->state, $NOCpulse::QueueEntry::badchars));
    push(@fields, "subject=" .
	 uri_escape($self->subject, $NOCpulse::QueueEntry::badchars));
    push(@fields, "type=" .
	 uri_escape($self->type, $NOCpulse::QueueEntry::badchars));

    return join('&', @fields);
}


sub dehydrate
{
    my $self = shift;

    return join("\n",
		$self->time, 
		uri_escape($self->checkCommand), 
		uri_escape($self->clusterDesc), 
		$self->clusterId, 
		uri_escape($self->commandLongName), 
		$self->customerId, 
		$self->groupId, 
		uri_escape($self->groupName), 
		uri_escape($self->hostAddress), 
		uri_escape($self->hostName), 
		$self->hostProbeId, 
		uri_escape($self->message), 
		uri_escape($self->osName), 
		uri_escape($self->physicalLocationName), 
		uri_escape($self->probeDescription), 
		uri_escape($self->probeGroupName), 
		$self->probeId, 
		$self->probeType, 
		$self->snmp, 
		$self->snmpPort, 
		$self->state, 
		uri_escape($self->subject),
		$self->type
		);
}


sub hydrate
{
   my $class = shift;
   my $string = shift;

   my $self = NOCpulse::Notification->newInitialized();

   my @parts = split("\n", $string);

   $self->time($parts[0]);
   $self->checkCommand(uri_unescape($parts[1]));
   $self->clusterDesc(uri_unescape($parts[2]));
   $self->clusterId($parts[3]);
   $self->commandLongName(uri_unescape($parts[4]));
   $self->customerId($parts[5]);
   $self->groupId($parts[6]);
   $self->groupName(uri_unescape($parts[7]));
   $self->hostAddress(uri_unescape($parts[8]));
   $self->hostName(uri_unescape($parts[9])); 
   $self->hostProbeId($parts[10]); 
   $self->message(uri_unescape($parts[11]));
   $self->osName(uri_unescape($parts[12]));
   $self->physicalLocationName(uri_unescape($parts[13]));
   $self->probeDescription(uri_unescape($parts[14]));
   $self->probeGroupName(uri_unescape($parts[15]));
   $self->probeId($parts[16]);
   $self->probeType($parts[17]);
   $self->snmp($parts[18]);
   $self->snmpPort($parts[19]);
   $self->state($parts[20]);
   $self->subject(uri_unescape($parts[21]));
   $self->type($parts[22]);
   
   return $self;
}

1;

