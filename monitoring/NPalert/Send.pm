package NOCpulse::Notif::Send;             

use strict;
use Class::MethodMaker
  new_hash_init => 'new',                      
  boolean       => [ qw ( is_completed is_escalation auto_ack requires_ack)],
  get_set       => [ qw ( send_id ack_wait scheduled_time send_time 
                          acknowledgement destination server_id alert_id ) ];   

use Date::Format;
use NOCpulse::Notif::ContactMethod;
use NOCpulse::Notif::PagerContactMethod;
use NOCpulse::Notif::SendInfo;
use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant DEF_UNIX_DATE_FMT => '%m-%d-%Y %H:%M:%S';
my $SECS  = 1;
my $MINS  = 60 * $SECS;
my $HOURS = 60 * $MINS;

# Note: ack_wait is in minutes 

##################
sub as_send_info {
##################
  my ($self,$alert)=@_;

  die "Alert undefined" unless $alert;


  my $dest=$self->destination();
  my $contact_id=$dest ? $dest->contact_id() : undef;
  my %info=( 'customerId'  => $alert->customerId,
             'hostProbeId' => $alert->hostProbeId,
             'probeId'     => $alert->probeId,
             'sendId'      => $self->send_id,
             'contactId'   => $contact_id,
             'infoTime'    => time(),
             'alertId'     => $alert->alert_id,
             'expiration'  => $self->expire_time,
             'completed'   => $self->is_completed
            );
  my $send_info=NOCpulse::Notif::SendInfo->new(%info);
  return $send_info;
}

#################
sub expire_time {
#################
  my $self=shift;

  return undef unless defined($self->send_time);
  return $self->send_time + $self->ack_wait * 60;
}

#################
sub has_expired {
#################
  my $self=shift;
  my $current_time=time();
                           
  $Log->log(9,"current time is $current_time\n");
  $Log->log(9,"send time    is ", $self->send_time , "\n");
  $Log->log(9,"expire time  is ", $self->expire_time , "\n");
  return 0 unless defined($self->send_time);
  return $self->expire_time <= $current_time
}                    

#########
sub ack {
#########
  my ($self,$operation)=@_;

  my ($package, $filename, $line) = caller;

  unless (grep { /^$operation$/}  qw (ack nak clear expired)) {
    die "invalid operation $operation at $package :: $filename :: $line";
  }

  $self->acknowledgement($operation);
  $self->set_is_completed;
}                              

#################
sub printString {
#################
  my $self=shift;
  my $str="Send [" . $self->send_id . "] ";
  $str .= "Alert [" . $self->alert_id . "]";
  $str .= " " . $self->destination->printString if $self->destination;
}

##########
sub show {
##########
  my $self=shift;
  my @array;
  push(@array,$self->printString);
  push(@array,'scheduled: ' . time2str(DEF_UNIX_DATE_FMT,$self->scheduled_time));
  push(@array,'sent: ' . time2str(DEF_UNIX_DATE_FMT,$self->send_time));
  push(@array,'ack wait: ' . $self->ack_wait_string, 'ack: '. ($self->acknowledgement || '(none)'), 'completed: ' . ($self->is_completed ? 'yes' : 'no'));
  return join("\n\t\t",@array);
}

#####################
sub ack_wait_string {
#####################
  my $self= shift;
  if ($self->is_completed) {
    return '(completed)'
  }
  unless ($self->send_time) {
    return 'N/A'
  }
  my $remainder=$self->expire_time() - time();
  if ($remainder < 0) {
    return 'expired'
  }
  $Log->log(9,"Remainder is $remainder\n");
  my $hours=int($remainder / $HOURS);
  $remainder=$remainder % $HOURS;
  my $minutes=int($remainder / $MINS);
  my $seconds=$remainder % $MINS;
 
  return sprintf("%2dh%2dm%2ds",$hours,$minutes,$seconds);
}

######################
sub update_send_info {
######################
  my ($self,$info)=@_;

  my $dest=$self->destination();
  my $contact_id=$dest ? $dest->contact_id() : undef;
  $info->sendId($self->send_id);
  $info->contactId($contact_id);
  $info->expiration($self->expire_time);
  $info->completed($self->is_completed);

  return $info;
}

1;


__END__

=head1 NAME

NOCpulse::Notif::Send - An object representing the individual delivery of a notification.

=head1 SYNOPSIS

  # Create a new send
  $send=NOCpulse::Notif::Send->new(
    'destination' => $destination,
    'ack_wait'    => 1,          #One minute wait for an acknowledgement
    'alert_id'    => $alert_id)

  # Check whether the send has not received an acknowledgement 
  #within the assigned wait period
  $boolean=$send->has_expired;

  # Process an acknowledgement
  $send->ack('ack',$escalator);

=head1 DESCRIPTION

The C<Schedule> object represents a person or resource's schedule of availability.  It stores 7 days of time ranges or
 ScheduleDays.  It uses these ScheduleDays to determine whether or not this schedule is active for a given day and tim
e represented with a UNIX timestamp.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item ack ( $operation )

Process the specified acknowledgement operation.

=item ack_wait ( [$number] )

Get or set the acknowledgement wait time for this send, i.e. the number of minutes to wait for an acknowledgement to this send.

=item ack_wait_string ()

Return the number of minutes and seconds remaining until the send expires in NNhNNmNNs form.

=item acknowledgement ( ['ack','clear','expired','nak'] )

Get or set the initial acknowledgement for this send.

=item alert_id ( [$number] )

Get or set the alert id of the alert for which this send was issued.

=item as_send_info ( $alert )

Return a SendInfo object about this send and the specified alert,
pertinent to the escalator.

=item auto_ack ( [0|1] )

Get or set whether this send is to be automatically acknowledged.

=item destination ( [$destination] )

Get or set the Destination object to receive this send.

=item expire_time ( )

Return a time stamp that this send will be considered expired and will trigger the next send in an escalation, if applicable.

=item has_expired ( )

Return a true value if the acknowledgement wait period has completed and the next send in an escalation need to be trigger, if applicable.

=item is_completed ( [0|1] )

Get or set whether this send is completed.

=item is_escalation ( [0|1] )

Get or set whether this send is part of an escalation.

=item printString ( )

Return a string reprsenting this send.

=item requires_ack ( [0|1] )

Get or set whether this send requires an acknowledgement from the contact method destination.

=item scheduled_time ( [$timestamp] )

Get or set the time that this sends was scheduled with the escalator.  This has nothing to do with the time this send was actually launched by the escalator.

=item send_id ( [$number] )

Get or set the send id associated with this send.

=item send_time ( [$timestamp] )

Get or set the time this send was issued as a UNIX timestamp.

=item server_id ( [$number] )

Gets or sets the notification server id of the machine handling this send.

=item show ( )

Returning a string, representing the state of this object in detail.

=item update_send_info ( )

Update a given SendInfo object with information about this send.  Returns the SendInfo object.


=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Strategy>
B<NOCpulse::Notif::Escalator>
B<notif-launcher>
B<notif-escalator>
B<notifier>

=cut
