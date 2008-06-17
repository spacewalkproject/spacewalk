package NOCpulse::Notif::SendInfo;             

use strict;
use Class::MethodMaker
  new_hash_init => 'new', 
  grouped_fields => [
    all_fields => [ qw ( alertId contactId completed customerId expiration 
                          hostProbeId probeId sendId infoTime) ] ] ; 

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


### CLASS METHODS

#################
sub from_string {
#################
  my $class=shift;
  my $string=shift;
  my %hash=split(/,/,$string);
  my $instance=$class->new(%hash);
  return $instance;
}


### INSTANCE METHODS

##################
sub store_string {
##################
  my $self=shift;
  my %hash = map { $_ => $self->{$_} } $self->all_fields;
  my $string=join(',',%hash);
  return $string;
}


1;

__END__

=head1 NAME

NOCpulse::Notif::SendInfo -- An object representing a concise summary of a Send, used by the Escalator for easy persistence on disk.

=head1 SYNOPSIS

  # Create a new send information object

  my $send = NOCpulse::Notif::Send->new;
  my $send_info = $send->as_send_info;

  # Update a send information object
  $send->update_send_info($send_info);

  # Store a send information object as a string
  my $string = $send_info->store_string;

  # Revive a send information object from a string
  my $info = NOCpulse::Notif::SendInfo->from_string($string);

=head1 DESCRIPTION

The C<SendInfo> object represents a Send in a concise manner for use by the Escalator and storage on disk and in dbm files.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=item from_string ( $string )

Create a new object from the given string.

=back

=head1 METHODS

=over 4

=item alertId ( [ $alertId ] )

Get or set the alert id associated with the represented send.

=item all_fields ( )

Return a list of all the data fields encapsulated in this object.

=item contactId ( [ $contactId ] )

Get or set the contact id associated with the represented send.

=item completed ( [ (0|1) ] )

Get or set whether the represented send is completed.

=item customerId ( [ $customerId ] )

Get or set the customer id associated with the represented send.

=item expiration ( [ $timestamp ] )

Get or set the unix timestamp denoting when the represented send will expire.

=item hostProbeId ( [ $hostProbeId ] )

Get or set the host probe id associated with the represented send.

=item infoTime ( [ $infoTime ] )

Get or set the time this object was last updated.

=item probeId ( [ $probeId ] )

Get or set the host probe id associated with the represented send.

=item sendId ( [ $sendId ] )

Get or set the send id associated with the represented send.

=item store_string ( )

Return a string representing this object for storage purposes.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $
