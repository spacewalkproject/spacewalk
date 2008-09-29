package NOCpulse::Notif::RotateFirstEscalateStrategy;             

@ISA= qw(NOCpulse::Notif::EscalateStrategy);
use strict;
use NOCpulse::Notif::Strategy;
use NOCpulse::Notif::EscalateStrategy;
use NOCpulse::Notif::Send;

###################
sub new_for_group {
###################
  my ($class,$group,$alert) = @_;

  my $instance = $class->new('ack_wait' => $group->ack_wait);
  my $group_size=@{$group->destinations};
  $group_size--;  #arrays start at zero
 
  my @destinations=$group->rotate_first_destination;

  @{$instance->sends}=map { NOCpulse::Notif::Send->new('destination' => $_,
                                                       'ack_wait'    => $group->ack_wait,
                                                       'alert_id'    => $alert->alert_id)} @destinations;
  return $instance
}

1;

__END__

=head1 NAME

NOCpulse::Notif::RotateFirstEscalateStrategy - An EscalateStrategy that changes the first destination each time.

=head1 SYNOPSIS

# Create an empty strategy, not very useful
$strategy = NOCpulse::Notif::RotateFirstEscalateStrategy->new(
  'ack_wait' => $minutes );

# Create a new escalate strategy for a contact group
$strategy = NOCpulse::Notif::RotateFirstEscalateStrategy->new_for_group($contact_group);

# Create a new escalate strategy for a contact method
$strategy = NOCpulse::Notif::RotateFirstEscalateStrategy->new_for_method($contact_method);

# Return the initial sends for this strategy
my @sends=$strategy->start_sends;

# Apply a send's acknowledgement to this strategy
$strategy->ack($send);

=head1 DESCRIPTION

The C<RotateFirstEscalateStrategy> object is a type of Strategy that sends to each member destination in turn, until a positive acknowldegement is received or the end of the member list is reached.  It will wait the specified number of ack_wait minute for an acknowledgement.  It also sends the initial send to a different group member each time a notification is issued to the group.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=item new_for_group ( $contact_group )

Create a new strategy for the specified ContactGroup, rotating the first destination.

=back

=head1 BUGS

Each time a new config is loaded, the first destination is reset to the first member of the group.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Strategy>
B<NOCpulse::Notif::EscalateStrategy>
B<NOCpulse::Notif::Send>
B<NOCpulse::Notif::Escalator>
B<notifserver.pl>
B<generate-config>

=cut
