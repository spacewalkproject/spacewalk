package NOCpulse::Notif::ScheduleDay;             

## Note ScheduleDay is stored in GMT.  Comparisons assume GMT.

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  key_attrib    => 'recid',
  get_set       => [qw(dayNum start1 end1 start2 end2 start3 end3 start4 end4)];

use Time::Local;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

##################
sub timeIsActive {
##################
  my ($self,$timestamp)=@_;  # Assume timestamp is in GMT

  my $midnight=$self->_midnightForDay($timestamp);
  my $secsSinceMidnight=$timestamp - $midnight;


  $Log->log(9,"timestamp is ", scalar(gmtime($timestamp)), ", $timestamp\n");
  $Log->log(9,"midnight is ", scalar(gmtime($midnight)), ", secs since midnight: ", $secsSinceMidnight, "\n");

  my @start=($self->start1(),$self->start2(),$self->start3(),$self->start4());
  my @end=($self->end1()  ,$self->end2(),  $self->end3(),  $self->end4());

  foreach (0..3) {

    $Log->log(9, "\tstart: $start[$_] end: $end[$_] time: $secsSinceMidnight\n");
    next unless defined($start[$_]) && defined($end[$_]);
    if (($start[$_] <= $secsSinceMidnight) && ($end[$_] >= $secsSinceMidnight)) {
      return 1
    }
  }
  return 0
}

#####################
sub _midnightForDay {
#####################

  my $self = shift();
  my $timestamp = shift();
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($timestamp);
  my $retval = timegm(0, 0, 0, $mday, $mon, $year);
  return $retval
}

1;

__END__

=head1 NAME

NOCpulse::Notif::ScheduleDay - An object representing a single GMT day of a person or resource's schedule of availabitity.

=head1 SYNOPSIS

# Create a new schedule day active from midnight to 8 AM, and 1 to 5 pm, Monday.
$schedule_day=NOCpulse::Notif::ScheduleDay->new(
  'dayNum' => 1,
  'start1' => 0,
  'end1'   =>  8 * 60 * 60,
  'start2' => 13 * 60 * 60,
  'end2'   => 18 * 60 * 60);

# Check to see if schedule day is active for a given time
$boolean=$schedule_day->timeIsActive($timestamp);

=head1 DESCRIPTION

The C<ScheduleDay> object represents a single day of a week of a person or resource's schedule of availability.  It stores 4 time ranges, or periods when the day is considered active.  It uses these ranges to determine whether or not this schedule is active for the time represented by a UNIX timestamp.  Everything is assumed to be GMT.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item dayNum ( $number )

Get or set the day of the week this represents.  0 = Sunday, 1 = Monday, ...

=item end1 ( [$seconds] )

Get or set the time in seconds since midnight that the first time range ends.

=item end2 ( [$seconds] )

Get or set the time in seconds since midnight that the second time range ends.

=item end3 ( [$seconds] )

Get or set the time in seconds since midnight that the third time range ends.

=item end4 ( [$seconds] )

Get or set the time in seconds since midnight that the fourth time range ends.

=item recid ( [$number] )

Get or set the unique sequence number representing this object in the database.

=item start1 ( [$seconds] )

Get or set the time in seconds since midnight that the first time range starts.

=item start2 ( [$seconds] )

Get or set the time in seconds since midnight that the second time range starts.

=item start3 ( [$seconds] )

Get or set the time in seconds since midnight that the third time range starts.

=item start4 ( [$seconds] )

Get or set the time in seconds since midnight that the fourth time range starts.

=item timeIsActive ( $timestamp )

Return a true value if the specified timestamp denotes a time with is in one of this days' active ranges.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>


Last update: $Date: 2004-12-15 23:09:26 $

=head1 SEE ALSO

B<NOCpulse::Notif::Schedule>
B<$NOTIFICATION_HOME/scripts/notifserver.pl>

=cut
