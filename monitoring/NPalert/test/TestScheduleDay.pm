package test::TestScheduleDay;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::ScheduleDay;
use Data::Dumper;
use Date::Parse;

my $MODULE = 'NOCpulse::Notif::ScheduleDay';

my $timestamp1 = str2time("Sun Jul 14 8:30:00 GMT 2002");
print "timestamp1 is $timestamp1 (" , scalar(localtime($timestamp1)), ")\n";

my $timestamp2 = str2time("Sun Jul 14 9:00:00 GMT 2002");
print "timestamp2 is $timestamp2 (" , scalar(localtime($timestamp2)), ")\n";

my $timestamp3 = str2time("Sun Jul 14 11:30:00 GMT 2002");
print "timestamp3 is $timestamp3 (" , scalar(localtime($timestamp3)), ")\n";

my $timestamp4 = str2time("Sun Jul 14 12:00:00 GMT 2002");
print "timestamp4 is $timestamp4 (" , scalar(localtime($timestamp4)), ")\n";

my $timestamp5 = str2time("Sun Jul 14 12:01:00 GMT 2002");
print "timestamp5 is $timestamp5 (" , scalar(localtime($timestamp5)), ")\n";


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
  $self->{'zero'} = $MODULE->new( 
                                 start1 => undef,
                                 end1   => undef,
                                 start2 => undef,
                                 end2   => undef,
                                 start3 => undef,
                                 end3   => undef,
                                 start4 => undef,
                                 end4   => undef );
  $self->{'one'} = $MODULE->new(
                                 start1 =>  9 * 60 * 60,
                                 end1   => 12 * 60 * 60,
                                 start2 => undef,
                                 end2   => undef,
                                 start3 => undef,
                                 end3   => undef,
                                 start4 => undef,
                                 end4   => undef );
  $self->{'two'} = $MODULE->new(
                                 start1 =>  1 * 60 * 60,
                                 end1   =>  3 * 60 * 60,
                                 start2 =>  9 * 60 * 60 + 1,
                                 end2   => 12 * 60 * 60,
                                 start3 => 13 * 60 * 60,
                                 end3   => 14 * 60 * 60,
                                 start4 => undef,
                                 end4   => undef );
  $self->{'three'} = $MODULE->new(
                                 start1 =>  1 * 60 * 60,
                                 end1   =>  3 * 60 * 60,
                                 start2 =>  5 * 60 * 60,
                                 end2   =>  7 * 60 * 60,
                                 start3 =>  9 * 60 * 60 + 1,
                                 end3   => 12 * 60 * 60,
                                 start4 => undef,
                                 end4   => undef );
  $self->{'four'} = $MODULE->new(
                                 start1 =>  1 * 60 * 60,
                                 end1   =>  3 * 60 * 60,
                                 start2 =>  5 * 60 * 60,
                                 end2   =>  7 * 60 * 60,
                                 start3 =>  8 * 60 * 60,
                                 end3   =>  9 * 60 * 60 - 1,
                                 start4 =>  9 * 60 * 60,
                                 end4   => 12 * 60 * 60);
}

# INSERT INTERESTING TESTS HERE

#######################
sub test_timeIsActive {
#######################
  my $self = shift();
  my $result = $self->{'zero'}->timeIsActive($timestamp1);
  $self->assert(!$result,"empty start/ends, should not match");
}

#############################
sub test_timeIsActive_one_1 {
#############################
  my $self = shift();
  my $result = $self->{'one'}->timeIsActive($timestamp1);
  $self->assert(!$result,"one (1), should not match");
}

#############################
sub test_timeIsActive_one_2 {
#############################
  my $self = shift();
  my $result = $self->{'one'}->timeIsActive($timestamp2);
  $self->assert($result,"one (2), should match");
}

#############################
sub test_timeIsActive_one_3 {
#############################
  my $self = shift();
  my $result = $self->{'one'}->timeIsActive($timestamp3);
  $self->assert($result,"one (3), should match");
}

#############################
sub test_timeIsActive_one_4 {
#############################
  my $self = shift();
  my $result = $self->{'one'}->timeIsActive($timestamp4);
  $self->assert($result,"one (4), should match");
}

#############################
sub test_timeIsActive_one_5 {
#############################
  my $self = shift();
  my $result = $self->{'one'}->timeIsActive($timestamp5);
  $self->assert(!$result,"one (5), should not match");
}

#############################
sub test_timeIsActive_two_1 {
#############################
  my $self = shift();
  my $result = $self->{'two'}->timeIsActive($timestamp1);
  $self->assert(!$result,"two (1), should not match");
}

#############################
sub test_timeIsActive_two_2 {
#############################
  my $self = shift();
  my $result = $self->{'two'}->timeIsActive($timestamp2);
  $self->assert(!$result,"two (2), should not match");
}

#############################
sub test_timeIsActive_two_3 {
#############################
  my $self = shift();
  my $result = $self->{'two'}->timeIsActive($timestamp3);
  $self->assert($result,"two (3), should match");
}

#############################
sub test_timeIsActive_two_4 {
#############################
  my $self = shift();
  my $result = $self->{'two'}->timeIsActive($timestamp4);
  $self->assert($result,"two (4), should match");
}

#############################
sub test_timeIsActive_two_5 {
#############################
  my $self = shift();
  my $result = $self->{'two'}->timeIsActive($timestamp5);
  $self->assert(!$result,"two (5), should not match");
}

###############################
sub test_timeIsActive_three_1 {
###############################
  my $self = shift();
  my $result = $self->{'three'}->timeIsActive($timestamp1);
  $self->assert(!$result,"three (1), should not match");
}

###############################
sub test_timeIsActive_three_2 {
###############################
  my $self = shift();
  my $result = $self->{'three'}->timeIsActive($timestamp2);
  $self->assert(!$result,"three (2), should not match");
}

###############################
sub test_timeIsActive_three_3 {
###############################
  my $self = shift();
  my $result = $self->{'three'}->timeIsActive($timestamp3);
  $self->assert($result,"three (3), should match");
}

###############################
sub test_timeIsActive_three_4 {
###############################
  my $self = shift();
  my $result = $self->{'three'}->timeIsActive($timestamp4);
  $self->assert($result,"three (4), should match");
}

###############################
sub test_timeIsActive_three_5 {
###############################
  my $self = shift();
  my $result = $self->{'three'}->timeIsActive($timestamp5);
  $self->assert(!$result,"three (5), should not match");
}

###############################
sub test_timeIsActive_four_1 {
###############################
  my $self = shift();
  my $result = $self->{'four'}->timeIsActive($timestamp1);
  $self->assert($result,"four (1), should match");
}

###############################
sub test_timeIsActive_four_2 {
###############################
  my $self = shift();
  my $result = $self->{'four'}->timeIsActive($timestamp2);
  $self->assert($result,"four (2), should match");
}

###############################
sub test_timeIsActive_four_3 {
###############################
  my $self = shift();
  my $result = $self->{'four'}->timeIsActive($timestamp3);
  $self->assert($result,"four (3), should match");
}

###############################
sub test_timeIsActive_four_4 {
###############################
  my $self = shift();
  my $result = $self->{'four'}->timeIsActive($timestamp4);
  $self->assert($result,"four (4), should match");
}

###############################
sub test_timeIsActive_four_5 {
###############################
  my $self = shift();
  my $result = $self->{'four'}->timeIsActive($timestamp5);
  $self->assert(!$result,"four (5), should not match");
}

##########################
sub test__midnightForDay {
##########################

  my $self = shift();
  my $i;
  for ($i = 14; $i <= 21; $i++) { 
    my $ts              = str2time("Jul $i 8:30:00 GMT 2002");
    my $result          = $self->{'zero'}->_midnightForDay($ts);
    my $expected_result = str2time("Jul $i 0:00:00 GMT 2002");
    $self->assert($result == $expected_result, "14-Jul 8:30");
    $ts                 = str2time("Jul $i 0:00:00 GMT 2002");
    $self->assert($result == $expected_result, "14-Jul 23:59:59");
    $ts                 = str2time("Jul $i 23:59:59 GMT 2002");
    $self->assert($result == $expected_result, "14-Jul 0:00");
  }
}
1;
