package test::TestSchedule;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::Schedule;
use NOCpulse::Notif::ScheduleDay;
use Data::Dumper;
use Date::Parse;

my $MODULE = 'NOCpulse::Notif::Schedule';

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj = $MODULE->new();

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");
        
}

############
sub set_up {
############
  my $self = shift;
  # This method is called before each test.

  $self->{'one'}  =$MODULE->new();

  my $i;
  for ($i=0; $i<=6; $i++) {
    my $day=NOCpulse::Notif::ScheduleDay->new( start1 => 0,            #00:00:00
                              end1   =>  1 * 60 * 60, #01:00:00
                              start2 => 23 * 60 * 60, #23:00:00
                              end1   => 23 * 60 * 60 + 59 * 60 + 59, #23:59:59
                              start2 => undef,
                              end2   => undef,
                              start3 => undef,
                              end3   => undef,
                              start4 => undef,
                              end4   => undef,
                             );
    $self->{'one'}->add_day($i,$day);
  }

  $self->{'two'}  =$MODULE->new();
  for ($i=1; $i<=5; $i++) {
    my $day=NOCpulse::Notif::ScheduleDay->new( start1 => 1,            #00:00:01
                              end1   =>  1 * 60 * 60, #01:00:00
                              start2 => 23 * 60 * 60, #23:00:00
                              end1   => 23 * 60 * 60 + 59 * 60 + 58, #23:59:58
                              start2 => undef,
                              end2   => undef,
                              start3 => undef,
                              end3   => undef,
                              start4 => undef,
                              end4   => undef);
    $self->{'two'}->add_day($i,$day);
  }
  foreach $i (0,6) {
    my $day=NOCpulse::Notif::ScheduleDay->new( start1 => undef,
                              end1   => undef,
                              start2 => undef,
                              end1   => undef,
                              start2 => undef,
                              end2   => undef,
                              start3 => undef,
                              end3   => undef,
                              start4 => undef,
                              end4   => undef);
    $self->{'two'}->add_day($i,$day);
  }
}

# INSERT INTERESTING TESTS HERE

##################
sub test_add_day {
##################

  my $self=shift();
  my $day0=NOCpulse::Notif::ScheduleDay->new( start1 => 0,            #00:00:00
                             end1   =>  1 * 60 * 60, #01:00:00
                             start2 => undef,
                             end2   => undef,
                             start3 => undef,
                             end3   => undef,
                             start4 => undef,
                             end4   => undef,
                             dayNum => 0 );

  my $day1=NOCpulse::Notif::ScheduleDay->new( start1 => 0,
                             end1   =>  2 * 60 * 60,
                             start2 => undef,
                             end2   => undef,
                             start3 => undef,
                             end3   => undef,
                             start4 => undef,
                             end4   => undef,
                             dayNum => 1 );

  $self->{'one'}->add_day(0,$day0);
  $self->{'one'}->add_day(1,$day1);

  my $expected_result = 1 * 60 * 60;
  my $result = $self->{'one'}->days->{0}->end1();
  $self->assert($expected_result = $result, "day0 end");

  $expected_result = 2 * 60 * 60;
  $result = $self->{'one'}->days->{1}->end1();
  $self->assert($expected_result = $result, "day1 end");
}

#######################
sub test_timeIsActive {
#######################
# midnight Sunday
  my $self=shift();
  my $timestamp=str2time("Sun Jul 14 0:00:00 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"midnight Sunday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 0;
  $self->assert($result == $expected_result,"midnight Sunday, no (two)");
}

#########################
sub test_timeIsActive_2 {
#########################
# one second after midnight Sunday
  my $self=shift();
  my $timestamp=str2time("Sun Jul 14 0:00:01 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"midnight + 1 Sunday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 0;
  $self->assert($result == $expected_result,"midnight + 1 Sunday, no (two)");
}
#########################
sub test_timeIsActive_3 {
#########################
# 23:59:59 Sunday
  my $self=shift();
  my $timestamp=str2time("Sun Jul 14 23:59:59 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"23:59:59 Sunday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 0;
  $self->assert($result == $expected_result,"23:59:59 Sunday, no (two)");
}
#########################
sub test_timeIsActive_4 {
#########################
# midnight Monday
  my $self=shift();
  my $timestamp=str2time("Mon Jul 15 0:00:00 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"0:00:00 Monday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 0;
  $self->assert($result == $expected_result,"0:00:00 Monday, no (two)");
}
#########################
sub test_timeIsActive_5 {
#########################
# one second after midnight Monday
  my $self=shift();
  my $timestamp=str2time("Mon Jul 15 0:00:01 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"midnight + 1 Monday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 1;
  $self->assert($result == $expected_result,"midnight + 1 Monday, yes (two)");
}
#########################
sub test_timeIsActive_6 {
#########################
# 23:59:59 Monday
  my $self=shift();
  my $timestamp=str2time("Mon Jul 15 23:59:59 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"23:59:59 Monday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 0;
  $self->assert($result == $expected_result,"23:59:59 Monday, no (two)");
}
#########################
sub test_timeIsActive_7 {
#########################
# midnight Saturday
  my $self=shift();
  my $timestamp=str2time("Sat Jul 13 0:00:00 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"midnight Saturday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 0;
  $self->assert($result == $expected_result,"midnight Saturday, no (two)");

}
#########################
sub test_timeIsActive_8 {
#########################
# one second after midnight Saturday
  my $self=shift();
  my $timestamp=str2time("Sat Jul 13 0:00:01 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"midnight + 1 Saturday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 0;
  $self->assert($result == $expected_result,"midnight + 1 Saturday, no (two)");
}
#########################
sub test_timeIsActive_9 {
#########################
# 23:59:59 Saturday
  my $self=shift();
  my $timestamp=str2time("Sat Jul 13 23:59:59 GMT 2002");
  my $result = $self->{'one'}->timeIsActive($timestamp);
  my $expected_result = 1;
  $self->assert($result == $expected_result,"23:59:59 Saturday, yes (one)");
  $result = $self->{'two'}->timeIsActive($timestamp);
  $expected_result = 0;
  $self->assert($result == $expected_result,"23:59:59 Saturday, no (two)");
}

1;
