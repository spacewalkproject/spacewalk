package NOCpulse::Notif::ContactMethod;
@ISA = qw(NOCpulse::Notif::Destination);       

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  key_attrib    => 'recid',
  get_set       => [ qw ( schedule message_format olson_tz_id
                          contact_id ) ],
  abstract      => 'deliver';

use NOCpulse::Notif::BroadcastStrategy;
use NOCpulse::Notif::Destination;
use NOCpulse::Notif::MessageFormat;
use NOCpulse::Notif::Schedule;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

############################
sub new_strategy_for_alert {
############################
  my ($self,$alert)=@_;
  my $strategy= NOCpulse::Notif::BroadcastStrategy->new_for_method($self,$alert);
  $strategy->alert($alert);
  $strategy->ack_method('NoAck');
  return $strategy;
}

##########
sub send {
##########
  my ($self,$send,$alert,$db,$smtp)=@_;

# Check the ContactMethod's schedule
  my $schedule=$self->schedule;

  if (!defined($schedule) || $schedule->timeIsActive($alert->time())) {

    $Log->log(3,"Schedule is active...\n");
    #The schedule is active, prepare to send....

    #Calculate the send id
    my $send_id=sprintf("%02d%s",$alert->server_id,$send->send_id);
    $alert->send_id($send_id);
    $alert->requires_ack($send->requires_ack);
    $alert->ack_wait($send->ack_wait);

    $Log->log(3,"Formatting message...\n");
    my $format=$self->message_format();
    if ($alert->subject) {
      #Adhoc message -- no special formatting
      $alert->fmt_message($alert->message);
      $alert->fmt_subject($alert->subject);
    }
    elsif (defined($format)) {
      $format->format_message($alert,$self->olson_tz_id);
    } else {
       
      $Log->log(1,"!!!Message format undefined!!!\n");
      $@ ="Message format undefined";
    }
    $Log->log(3,"Delivering...\n");

    my $rv=$self->deliver($alert,$db,$smtp);  #There must be a more elegant way

    $alert->send_id(undef);

    return (0,$rv);

  } else {
    # The schedule is not active.
   $Log->log(1,"Contact method is off duty\n");
   $@ = "Off-duty";

    return $@
  }
}

#################
sub designation {
#################
  return 'i'
}

1;

__END__

=head1 NAME

NOCpulse::Notif::ContactMethod - An abstract base class that defines the protocol for processing and sending an alert to an individual.

=head1 DESCRIPTION

The C<ContactMethod> abstract base class defines the behavior for all contact method types.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object, initializing it with the specified arguments.

=back

=head1 METHODS

=over 4

=item contact_id ( [$number] )

Get or set the recid of the B<Contact> that owns this contact method.

=item deliver ( [$alert] )

Abstract method.  Subclasses muyst define behavior to deliver a formatted alert to its destination.

=item designation ( )

Return the character designation for this type of destination, for use in printString.

=item recid ( [$number] )

Get or set this object's unique identifier in the database.

=item schedule ( [$schedule] )

Get or set the Schedule object associated with this contact method.

=item message_format ( [$format] )

Get or set the MessageFormat object associated with this contact method.

=item new_strategy_for_alert ( $alert )

Create and return a new Strategy object of the appropriate type for the given alert.  As this is only a single destination it create a BroadcastStrategy with 'NoAck' acknowledgement type.

=item olson_tz_id ( [$olson_string] ) 

Get or set the preferred time zone for this contact's schedules.

=item send ( $alert )

Apply the Schedule and MessageFormat to the alert, if provided, and return a command line command that delivers the alert.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2005-02-10 22:45:14 $

=head1 SEE ALSO

B<NOCpulse::Notif::Destination>
B<NOCpulse::Notif::EmailContactMethod>
B<NOCpulse::Notif::PagerContactMethod>
B<NOCpulse::Notif::ContactGroup>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Escalator>
B</usr/bin/notifserver.pl>

=cut
