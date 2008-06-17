package NOCpulse::Notif::Destination;

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw( customer_id name )],
  abstract      => [qw( recid send new_strategy_for_alert designation)];

#################
sub printString {
#################
  my $self=shift;
  return join('_',$self->customer_id, $self->designation . $self->recid, $self->name);
}

1;

__END__

=head1 NAME

NOCpulse::Notif::Destination - An abstract base class that defines the protocol for sending an alert to a group or to an individual.

=head1 DESCRIPTION

The C<Destination> abstract base class defines the behavior for all contact method and group types.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )
Create a new object with the supplied arguments, if any.

=back 

=head1 METHODS

=over 4

=item customer_id ( [$number] )

Get or set the unique identifier, as stored in the database, for the customer to which this destination belongs.

=item designation ( )

Abstract method.  Subclass must define behavior to create and return a new Strategy object of the appropriate type for the given alert.

=item name ( [$name] )

Get or set the name of this destination.

=item new_strategy_for_alert ( $alert )

Abstract method.  Subclass must define behavior to return a new Strategy object for itself.

=item printString ( )

Return a descriptive string representing this destination.

=item recid ( [$number] )

Get or set this object's unique identifier in the database.

=item send ( $alert )

Abstract method.  Subclasses must define behavior to send an alert to the destinations it represents, applying formats, sschedules or strategies if necessary.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::ContactMethod>
B<NOCpulse::Notif::ContactGroup>
B<NOCpulse::Notif::Alert>
B<$NOTIFICATION_HOME/scripts/notifserver.pl>

=cut
