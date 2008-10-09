package NOCpulse::Notif::Customer;             

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [ qw(auto_update def_ack_wait description def_strategy 
                        preferred_time_zone schedule_id 
                        deleted type last_update_user last_update_date )],
  key_attrib    => [ qw(recid)],
  list          => [ qw (redirects) ];

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

##############
sub redirect {
##############
  my ($self,$alert)=@_;

  my $arrayref=$self->redirects();
  foreach(@$arrayref) {
    $_->redirect($alert);
  }
}

#################
sub addRedirect {
#################
  my $self=shift();
  my $redirect=shift();
  $self->redirects_push($redirect);
}

1;

__END__

=head1 NAME

NOCpulse::Notif::Customer - An object that represents a CommandCenter customer.

=head1 SYNOPSIS

# Create a new customer
$customer=NOCpulse::Notif::Customer->new(
  'recid' => $number,
  'description' => $name);

# Add a new redirect
$customer->addRedirect($redirect);

# Apply all redirects to an alert
$customer->redirect($alert);

=head1 DESCRIPTION

The C<Customer> object is simple representation of a CommandCenter customer for the notification system.
ame time.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item auto_update  ( [$boolean] ) 

OBSOLETE.  Get or set whether this customer is to receive automatic updates for the Windows service.

=item def_ack_wait ( [$number] )

Get or set the default acknowledgement wait period for escalation groups for this customer.

=item def_strategy ( [$string] ) 

Get or set the default contact group strategy for this customer.

=item deleted ( [ 0 | 1 ] )

OBSOLETE.  Get or set whether this customer is deleted.

=item description ( [$string] )

Get or set this customer's name.

=item addRedirect( $redirect )

Add a new redirect to the list of those to be applied to this customer.

=item last_update_date ( [$timestamp] )

OBSOLETE.

=item last_update_user ( [$string] )

OBSOLETE.

=item recid ( [$number] )

Get or set this object's unique identifier in the database.

=item redirect ( )

Apply the list of redirects for this customer to the specified alert.

=item redirects ( )

Return the list of redirects associated with this customer.  (Treat as Class::MethodMaker type list.)

=item preferred_time_zone ( [$olson_string] )

Get or set the preferred time zone for this customer.

=item schedule_id ( [$number] )

Get or set the recid of the default contact method schedule for this customer.

=item type ( [$string] )

OBSOLETE.  Get or set the type of this customer.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2005-02-10 22:45:14 $

=head1 SEE ALSO

B<NOCpulse::Notif::Redirect>
B<notifserver.pl>

=cut
