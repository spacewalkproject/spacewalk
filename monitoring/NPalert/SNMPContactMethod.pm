package NOCpulse::Notif::SNMPContactMethod;

@ISA = qw(NOCpulse::Notif::ContactMethod);       

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [ qw ( ip port) ];

use NOCpulse::Notif::ContactMethod;
use Date::Format;
use NOCpulse::Notif::AlertDB;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use NOCpulse::Config;

my $np_cfg       = new NOCpulse::Config;
my $snmp_url     = $np_cfg->get('notification','snmp_notif_url');

use constant DEF_UNIX_DATE_FMT => '%m-%d-%Y %H:%M:%S';


#############
sub deliver {
#############
  my ($self,$alert,$db,$smtp)=@_;

  my($string,$sat_cluster_id)=split(/\//,$alert->snmpPort);
  my($dest_ip,$dest_port)=split(/:/,$string);

  my $record = { 
#   RECID                (COMPLETED BY CREATE CALL)
    SENDER_CLUSTER_ID => $alert->clusterId,
    DEST_IP           => $self->ip,
    DEST_PORT         => $self->port,
    DATE_GENERATED    => $alert->time,
    DATE_SUBMITTED    => $alert->current_time,
    COMMAND_NAME      => $alert->commandLongName,
#   NOTIF_TYPE           (DERIVED LATER)
    OP_CENTER         => $alert->physicalLocationName,
#   NOTIF_URL         => (DERIVED LATER)
    OS_NAME           => $alert->osName,
    MESSAGE           => $alert->message,
    PROBE_ID          => $alert->probeId,
    HOST_IP           => $alert->hostAddress,
#   SEVERITY             (DERIVED LATER)
    COMMAND_ID        => $alert->checkCommand,
#   PROBE_CLASS          (DERIVED LATER) 
    HOST_NAME         => $alert->hostName,
#   SUPPORT_CENTER       (LEFT NULL) 
    SEND_ID           => $alert->send_id
  };
  
  #The following code has been swiped from MessageQueue/dequeue and modified
  #to suit the needs of notification
  # BEGIN 'THEFT'           
    
  # This should be constructed somehow -- waiting for UI guys.
  $record->{'notif_url'}=sprintf("%s?function=host&id=%s",
    $snmp_url,$alert->hostProbeId);

  # For OK messages, set notifType = 2 (clear alert).
  # For others, set notifType = 1 (alert), and set notifSeverity
  # to 1 for UNKNOWN, 3 for WARN and 5 for CRITICAL.

  if ( ( $alert->state eq 'WARN') or
       ( $alert->state eq 'WARNING' ) ) {
      
    $record->{'NOTIF_TYPE'} = 1;
    $record->{'SEVERITY'}   = 3;

  } elsif ($alert->servicestate eq 'CRITICAL') {

    $record->{'NOTIF_TYPE'} = 1;
    $record->{'SEVERITY'}   = 5;

  } elsif ($alert->servicestate eq 'OK') {

    $record->{'NOTIF_TYPE'} = 2;
    $record->{'SEVERITY'}   = 0;

  } else {

    # UNKNOWN state (or unknown state :)
    $record->{'NOTIF_TYPE'} = 1;
    $record->{'SEVERITY'}   = 1;

  }

  # Set notifProbeClass from probeGroupName.

  # For probe classification
  my %class_map = (
    # 'host' class -- host monitoring
    1 => [qw(logagent satellite storage tools unix windows)],

    # 'net' class -- network monitoring
    2 => [qw(netservice networking)],

    # Everything else is application monitoring (default, so no list)
    3 => [],
  );

  my $class;
  my $probegroup = $alert->probeGroupName;

  $record->{'PROBE_CLASS'} = 3;  # Default to app monitoring
  foreach $class (keys %class_map) {
    if (grep(/$probegroup/, @{$class_map{$class}})) {
      $record->{'PROBE_CLASS'} = $class;
      last;
    }
  }
  # END 'THEFT'


  $Log->log(3,"storing SNMP record in the database\n");

  my ($errcode,$errstring)=$db->dbexecute('create_snmp_alert',
    $record->{SENDER_CLUSTER_ID},
    $record->{DEST_IP},
    $record->{DEST_PORT},
    time2str(DEF_UNIX_DATE_FMT,$record->{DATE_GENERATED}),
    time2str(DEF_UNIX_DATE_FMT,$record->{DATE_SUBMITTED}),
    $record->{COMMAND_NAME},
    $record->{NOTIF_TYPE},
    $record->{OP_CENTER},
    $record->{NOTIF_URL},
    $record->{OS_NAME},
    $record->{MESSAGE},
    $record->{PROBE_ID},
    $record->{HOST_IP},
    $record->{SEVERITY},
    $record->{COMMAND_ID},
    $record->{PROBE_CLASS},
    $record->{HOST_NAME});

  if ($errcode) {
    $Log->log(1,"SMTP message commit error $errcode: $errstring\n");
  } else {
    ($errcode)=$db->commit;
    $Log->log(1,"Unable to commit SMTP message") if $errcode;
  }
  return $errcode;
}

1;


=head1 NAME

NOCpulse::Notif::SNMPContactMethod - A ContactMethod that delivers its alert notification via SNMP trap.

=head1 SYNOPSIS

# Create a new snmp contact method
$method=NOCpulse::Notif::SNMPContactMethod->new(
  'ip'             => 'nowhere.nocpulse.com',
  'port'           => 5050,
  'schedule'       => $schedule,
  'message_format' => $message_format );

# Create a new strategy for this alert
$strategy=$method->new_strategy_for_alert->($alert);

# Create the command that will send a specified alert to this destination
$cmd=$method->send($alert);

=head1 DESCRIPTION

The C<SNMPContactMethod> object is a type of ContactMethod that sends notifications by sending an SNMP trap.  A record is queued in the database for later delivery.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item deliver ( $alert, $db, $smtp )

Launch a send to this contact method.

=item ip ( [$ip] )

Get or set the ip to use for the snmp trap.

=item port ( [$port] )

Get or set the port to use for the snmp trap.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::ContactMethod>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Schedule>
B<notifier>

=cut
