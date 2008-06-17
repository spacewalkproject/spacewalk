package test::TestRedirectCriterion;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::RedirectCriterion;
use NOCpulse::Notif::Alert;
use Data::Dumper;

my $MODULE = 'NOCpulse::Notif::RedirectCriterion';

my $alert=NOCpulse::Notif::Alert->new();

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

# INSERT INTERESTING TESTS HERE

##################
sub test_matches {
##################
#  "CASE_SEN_MSG_PATTERN"   => $alert->message();

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'CASE_SEN_MSG_PATTERN',
                                'match_value' => 'Spain',
                                'inverted'    => 0);
  $alert->message('The rain in Spain stays mainly in the plain.');

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value('France');
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

####################
sub test_matches_2 {
####################
#  "CASE_INSEN_MSG_PATTERN"   => $alert->message();

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'CASE_INSEN_MSG_PATTERN',
                                'match_value' => 'spain',
                                'inverted'    => 0);
  $alert->message('The rain in Spain stays mainly in the plain.');

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value('France');
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

####################
sub test_matches_3 {
####################
#  "DESTINATION_NAME"       => $alert->groupName(),

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'DESTINATION_NAME',
                                'match_value' => 'karen_email',
                                'inverted'    => 0);
  $alert->groupName('karen_email');

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value('karen_email2');
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

####################
sub test_matches_4 {
####################
#  "NETSAINT_ID"            => $alert->clusterId(),

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'NETSAINT_ID',
                                'match_value' => 29,
                                'inverted'    => 0);
  $alert->clusterId(29);

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value(13);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

####################
sub test_matches_5 {
####################
#  "PROBE_TYPE"             => $alert->probeType()

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'PROBE_TYPE',
                                'match_value' => 'ServiceProbe',
                                'inverted'    => 0);
  $alert->probeType('ServiceProbe');

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value('LongLegs');
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

####################
sub test_matches_6 {
####################
#  "SERVICE_STATE"          => $alert->state()

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'SERVICE_STATE',
                                'match_value' => 'UNKNOWN',
                                'inverted'    => 0);
  $alert->state('UNKNOWN');

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value('WARNING');
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

####################
sub test_matches_7 {
####################
#  "HOST_STATE"             => $alert->state()

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'HOST_STATE',
                                'match_value' => 'UNKNOWN',
                                'inverted'    => 0);
  $alert->state('UNKNOWN');

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value('WARNING');
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

####################
sub test_matches_8 {
####################
#  "CONTACT_GROUP_ID"       => $alert->groupId()

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'CONTACT_GROUP_ID',
                                'match_value' => 11991,
                                'inverted'    => 0);
  $alert->groupId(11991);

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value(12337);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

####################
sub test_matches_9 {
####################
#  "CUSTOMER_ID"            => $alert->customerId

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'CUSTOMER_ID',
                                'match_value' => 30,
                                'inverted'    => 0);
  $alert->customerId(30);

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'yes');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'yes inverted');

  $criterion->inverted(0);
  $criterion->match_value(1098);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'no inverted');
}

#####################
sub test_matches_10 {
#####################
#  "PROBE_ID"            => $alert->hostProbeId or $alert->probeId

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'PROBE_ID',
                                'match_value' => 10029,
                                'inverted'    => 0);

  #Service Probe

  $alert->probeType('ServiceProbe');
  $alert->probeId(10029);
  $alert->hostProbeId(10013);

  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'match Service Probe');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'inverted no match Service Probe');

  $criterion->inverted(0);
  $alert->probeId(10000);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no match Service Probe');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'inverted match Service Probe');
}

#####################
sub test_matches_11 {
#####################
#  "PROBE_ID"            => $alert->hostProbeId or $alert->probeId

  my $self = shift();
  my $criterion = $MODULE->new( 'match_param' => 'PROBE_ID',
                                'match_value' => 10013,
                                'inverted'    => 0);
  # Host Probe

  $alert->probeType('HostProbe');
  $alert->probeId(10029);
  $alert->hostProbeId(10013);


  my $result = $criterion->matches($alert);
  my $expected_result = 1;
  $self->assert($result == $expected_result,'match Host Probe');                     

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'inverted no match Host Probe');

  $criterion->inverted(0);
  $alert->hostProbeId(10000);
  $result = $criterion->matches($alert);
  $expected_result = 0;
  $self->assert($result == $expected_result,'no match Host Probe');

  $criterion->inverted(1);
  $result = $criterion->matches($alert);
  $expected_result = 1;
  $self->assert($result == $expected_result,'inverted match Host Probe');
}

1;
