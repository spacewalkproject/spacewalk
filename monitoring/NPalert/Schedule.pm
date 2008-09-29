package NOCpulse::Notif::Schedule;             

## Schedules are stored in GMT.

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw(description comment)],
  hash          => [qw(days)];

use NOCpulse::Notif::ScheduleDay;
use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

#############
sub add_day {
#############
  my ($self,$dayNum,$scheduleDay)=@_;
  my $days=$self->days();
  $days->{$dayNum}=$scheduleDay;
}

##################
sub timeIsActive {
##################
  my ($self,$timestamp)=@_;
  
  my $wday; 
  (undef, undef, undef, undef, undef, undef, $wday)=gmtime($timestamp);

  my $day=$self->days->{$wday};
  return $day->timeIsActive($timestamp);
}

__END__

=head1 NAME

NOCpulse::Notif::Schedule - An object representing a person or resource's schedule of availabitity.

=head1 SYNOPSIS

# Create a new, empty schedule
$redirect=NOCpulse::Notif::Schedule->new(
  'description' => 'test schedule',
  'comment'     => 'this is only a test!');

# Add a schedule day
$day=NOCpulse::Notif::ScheduleDay->new();
$schedule->add_day(0,$day);

# Check to see if schedule is active for a given time
$boolean=$schedule->timeIsActive($timestamp);

=head1 DESCRIPTION

The C<Schedule> object represents a person or resource's schedule of availability.  It stores 7 days of time ranges or ScheduleDays.  It uses these ScheduleDays to determine whether or not this schedule is active for a given day and time represented with a UNIX timestamp.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item add_day ( $dow, $schedule_day )

Add a ScheduleDay for the specified day of week, 0-6, where 0 is Sunday.

=item comment ( [$string] )

Get or set a descriptive comment about this schedule.

=item days ( )

Return the hash containing the ScheduleDays defining this schedule.  (Treat as Class::MethodMaker type hash.)

=item description ( [$string] )

Get or set a string that names or describes this schedule.

=item timeIsActive ( $timestamp )

Return a true value if the specified timestamp denotes an active time in the schedule.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::ScheduleDay>
B<NOCpulse::Notif::ContactMethod>
B<notifserver.pl>

=cut
