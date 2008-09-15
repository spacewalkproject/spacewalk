package NOCpulse::Notif::PhoneContactMethod;

@ISA = qw(NOCpulse::Notif::ContactMethod);       

use strict;
use NOCpulse::Notif::ContactMethod;

#############
sub deliver {
#############
  return undef
}

1;


__END__


=head1 NAME

NOCpulse::Notif::Phone - OBSOLETE.  A ContactMethod that delivers its alert notification via voice phone.

=head1 DESCRIPTION

THIS CLASS IS OBSOLETE.  It serves as a placeholder for future additions to the system.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

OBSOLETE.  Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item deliver ( )

OBSOLETE.  Return a command line string which when executed will delivery the notification to this destination.

=back

=head1 BUGS

No known bugs; however, this class is deemed OBSOLETE and is void of behavior.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::ContactMethod>
B<NOCpulse::Notif::EmailContactMethod>
B<NOCpulse::Notif::PagerContactMethod>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Schedule>
B<NOCpulse::Notif::MessageFormat>
B<$NOTIFICATION_HOME/scripts/notifier>

=cut
