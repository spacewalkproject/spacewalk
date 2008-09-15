package test::TestRedirect;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::Redirect;
use NOCpulse::Notif::RedirectCriterion;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use Data::Dumper;

my $MODULE = 'NOCpulse::Notif::Redirect';

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

  $self->{'redirect'} = $MODULE->new();
  $self->{'redirect'}->start_date(time() - 3600);
  $self->{'redirect'}->expiration(time() + 3600);

  $self->{'redirect2'} = $MODULE->new();
  my $criterion_1 = NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                            'match_value' => 0,
                                            'inverted'    => 1);                                           
  $self->{'redirect2'}->add_criterion($criterion_1);
  $self->{'redirect2'}->start_date(time() - 3600);
  $self->{'redirect2'}->expiration(time() + 3600);


  $self->{'alert'}    = NOCpulse::Notif::Alert->new( 'message'   => 'The rain in Spain stays mainly on the plain',
                                    'groupName'    => 'Karen_Group',
                                    'clusterId'    => 29,
                                    'state'        => 'WARNING',
                                    'groupId'      => 11991,
                                    'probeId'      => 3000,
                                    'customerId'   => 30,
                                    'current_time' => time() );
  $self->{'alert2'}   = NOCpulse::Notif::Alert->new( 'message'   => 'Don\'t let the sun go down on me',
                                    'groupName' => 'Dave_Group',
                                    'clusterId' => 13,
                                    'state'     => 'UNKNOWN',
                                    'groupId'   => 29292,
                                    'probeId'   => 5000,
                                    'customerId'=> 2, 
                                    'current_time' => time() );
}

# INSERT INTERESTING TESTS HERE

########################
sub test_add_criterion {
########################
  my $self = shift;

  my $criterion_1 = NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                            'match_value' => 30,
                                            'inverted'    => 0);                                           
  my $criterion_2 = NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'NETSAINT_ID',
                                            'match_value' => 10,
                                            'inverted'    => 1);                                           

  $self->{'redirect'}->add_criterion($criterion_1);
  $self->{'redirect'}->add_criterion($criterion_2);

  my @items = grep { $_->match_param() eq 'CUSTOMER_ID'} $self->{'redirect'}->criteria();
  $self->assert(@items,'customer_id criterion');
  $self->assert($items[0]->match_value() == 30,'customer_id value');

  @items = grep { $_->match_param() eq 'NETSAINT_ID'} $self->{'redirect'}->criteria();
  $self->assert(@items,'netsaint_id criterion');
  $self->assert($items[0]->match_value() == 10,'netsaint_id value');
}

#####################
sub test_add_target {
#####################

  my $self = shift;

  my $method  = NOCpulse::Notif::EmailContactMethod->new( 'email' => 'nobody@nocpulse.com');
  my $group  =  NOCpulse::Notif::ContactGroup->new();

  $self->{'redirect'}->add_target($method);
  $self->{'redirect'}->add_target($group);

  my @items = grep { qr/EmailContactMethod/,$_ } $self->{'redirect'}->targets();
  $self->assert(@items,'email contact method target');
  $self->assert($items[0]->email() eq 'nobody@nocpulse.com','email contact method value');

  @items = grep { qr/ContactGroup/,$_ } $self->{'redirect'}->targets();
  $self->assert(@items,'contact group target')
}

##################
sub test_matches {
##################

# If there are no fields in the redirect, it should match nothing

   my $self = shift;
   
   my $result          = $self->{'redirect'}->matches($self->{'alert'});
   my $expected_result = 0;
   
   $self->assert($result == $expected_result,"no fields");
}

####################
sub test_matches_2 {
####################

# One Field, single value

   my $self = shift;

   my $criterion = NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                           'match_value' => 30,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion);

   my $result          = $self->{'redirect'}->matches($self->{'alert'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"one field, single value (match)");

   #-------------------------------------------------------------------#

   $criterion->match_value(2);

   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"one field, single value (no match)");
}

####################
sub test_matches_3 {
####################

# One Field, single value, negated

   my $self = shift;

   my $criterion = NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                           'match_value' => 2,
                                           'inverted'    => 1);
   $self->{'redirect'}->add_criterion($criterion);

   my $result          = $self->{'redirect'}->matches($self->{'alert'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"one field, single value, negated");

   #-------------------------------------------------------------------#

   $criterion->match_value(30);

   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"one field, single value, negated (no match)");
}

####################
sub test_matches_4 {
####################

# One Field, multiple values

   my $self = shift;

   for (my $i = 1; $i <= 30; $i++) {
     my $criterion =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                             'match_value' => $i,
                                             'inverted'    => 0);
     $self->{'redirect'}->add_criterion($criterion)
   }

   my $result          = $self->{'redirect'}->matches($self->{'alert'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"one field, last of multiple values");

   #-------------------------------------------------------------------#

   $self->{'alert'}->customerId(1);

   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 1;
   
   $self->assert($result == $expected_result,"one field, first of multiple values");

   #-------------------------------------------------------------------#

   $self->{'alert'}->customerId(15);

   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 1;
   
   $self->assert($result == $expected_result,"one field, mid multiple values");

   #-------------------------------------------------------------------#

   $self->{'alert'}->customerId(100);

   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"one field, none of multiple values");
}

####################
sub test_matches_5 {
####################

# Multiple fields single values

   my $self = shift;

   my $criterion1 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CASE_SEN_MSG_PATTERN',
                                            'match_value' => '\srain',
                                            'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion1);
   my $criterion2 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'DESTINATION_NAME',
                                            'match_value' => 'Karen_Group',
                                            'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion2);
   my $criterion3 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'NETSAINT_ID',
                                            'match_value' => 29,
                                            'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion3);
   my $criterion4 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'PROBE_ID',
                                            'match_value' => 3000,
                                            'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion4);
   my $criterion5 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                            'match_value' => 30,
                                            'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion5);

   my $result          = $self->{'redirect'}->matches($self->{'alert'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"mutiple fields, single values, all match");

   #-------------------------------------------------------------------#

   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, single values, none match");

   #-------------------------------------------------------------------#

   $criterion1->match_value('France');
   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, single values, first doesn't match");

   #-------------------------------------------------------------------#

   $criterion1->match_value('\srain');
   $criterion5->match_value(2);
   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, single values, last doesn't match");

   #-------------------------------------------------------------------#

   $criterion5->match_value(30);
   $criterion3->match_value(13);
   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, single values, mid doesn't match");
}

####################
sub test_matches_6 {
####################

# Multiple fields single values, all negated:

   my $self = shift;

   my $criterion1 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CASE_SEN_MSG_PATTERN',
                                            'match_value' => '\srain',
                                            'inverted'    => 1);
   $self->{'redirect'}->add_criterion($criterion1);
   my $criterion2 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'DESTINATION_NAME',
                                            'match_value' => 'Karen_Group',
                                            'inverted'    => 1);
   $self->{'redirect'}->add_criterion($criterion2);
   my $criterion3 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'NETSAINT_ID',
                                            'match_value' => 29,
                                            'inverted'    => 1);
   $self->{'redirect'}->add_criterion($criterion3);
   my $criterion4 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'PROBE_ID',
                                            'match_value' => 3000,
                                            'inverted'    => 1);
   $self->{'redirect'}->add_criterion($criterion4);
   my $criterion5 =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                            'match_value' => 30,
                                            'inverted'    => 1);
   $self->{'redirect'}->add_criterion($criterion5);

   my $result          = $self->{'redirect'}->matches($self->{'alert'});
   my $expected_result = 0;
   
   $self->assert($result == $expected_result,"mutiple fields negated, single values, none match");

   #-------------------------------------------------------------------#

   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 1;
   
   $self->assert($result == $expected_result,"multiple fields negated, single values, all match");

}

####################
sub test_matches_7 {
####################

# Multiple fields, multiple values on all

   my $self = shift;

   for (my $i = 12; $i <= 30; $i++) {
     my $criterion =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'NETSAINT_ID',
                                             'match_value' => $i,
                                             'inverted'    => 0);
     $self->{'redirect'}->add_criterion($criterion)
   }
   for (my $j = 3000; $j <= 3010; $j++) {
     my $criterion =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'PROBE_ID',
                                             'match_value' => $j,
                                             'inverted'    => 0);
     $self->{'redirect'}->add_criterion($criterion)
   }
   for (my $k = 1; $k <= 35; $k++) {
     my $criterion =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                             'match_value' => $k,
                                             'inverted'    => 0);
     $self->{'redirect'}->add_criterion($criterion)
   }

   $self->{'alert2'}->clusterId(12);
   $self->{'alert2'}->probeId(3000);
   $self->{'alert2'}->customerId(1);
   my $result          = $self->{'redirect'}->matches($self->{'alert2'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values, first of each");

   #-------------------------------------------------------------------#

   $self->{'alert2'}->clusterId(30);
   $self->{'alert2'}->probeId(3010);
   $self->{'alert2'}->customerId(35);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 1;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values, last of each");

   #-------------------------------------------------------------------#

   $self->{'alert2'}->clusterId(16);
   $self->{'alert2'}->probeId(3005);
   $self->{'alert2'}->customerId(18);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 1;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values, mid each");

   #-------------------------------------------------------------------#

   $self->{'alert2'}->clusterId(0);
   $self->{'alert2'}->probeId(5000);
   $self->{'alert2'}->customerId(1012);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values, none each");

   #-------------------------------------------------------------------#

   $self->{'alert2'}->clusterId(0);
   $self->{'alert2'}->probeId(3005);
   $self->{'alert2'}->customerId(18);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values, none first");

   #-------------------------------------------------------------------#

   $self->{'alert2'}->clusterId(16);
   $self->{'alert2'}->probeId(5000);
   $self->{'alert2'}->customerId(18);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values, none mid");

   #-------------------------------------------------------------------#

   $self->{'alert2'}->clusterId(16);
   $self->{'alert2'}->probeId(3005);
   $self->{'alert2'}->customerId(1012);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values, none last");

}

####################
sub test_matches_8 {
####################

# Multiple fields, multiple values on first

   my $self = shift;

   for (my $i = 12; $i <= 30; $i++) {
     my $criterion =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'NETSAINT_ID',
                                             'match_value' => $i,
                                             'inverted'    => 0);
     $self->{'redirect'}->add_criterion($criterion)
   }
   my $criterion2=NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'PROBE_ID',
                                           'match_value' => 3000,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion2);
   my $criterion3=NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                           'match_value' => 1,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion3);

   $self->{'alert2'}->clusterId(18);
   $self->{'alert2'}->probeId(3000);
   $self->{'alert2'}->customerId(1);

   my $result          = $self->{'redirect'}->matches($self->{'alert2'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values on first, match");

   #-------------------------------------------------------------------#

   $criterion2->match_value(1);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values on first, no match");
}

####################
sub test_matches_9 {
####################

# Multiple fields, multiple values on last

   my $self = shift;

   my $criterion2=NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'PROBE_ID',
                                           'match_value' => 3000,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion2);
   my $criterion3=NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                           'match_value' => 1,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion3);

   for (my $i = 12; $i <= 30; $i++) {
     my $criterion =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'NETSAINT_ID',
                                             'match_value' => $i,
                                             'inverted'    => 0);
     $self->{'redirect'}->add_criterion($criterion)
   }

   $self->{'alert2'}->clusterId(18);
   $self->{'alert2'}->probeId(3000);
   $self->{'alert2'}->customerId(1);

   my $result          = $self->{'redirect'}->matches($self->{'alert2'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values on first, match");

   #-------------------------------------------------------------------#

   $criterion2->match_value(1);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values on first, no match");
}

#####################
sub test_matches_10 {
#####################

# Multiple fields, multiple values on middle

   my $self = shift;

   my $criterion2=NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'PROBE_ID',
                                           'match_value' => 3000,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion2);

   for (my $i = 12; $i <= 30; $i++) {
     my $criterion =NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'NETSAINT_ID',
                                             'match_value' => $i,
                                             'inverted'    => 0);
     $self->{'redirect'}->add_criterion($criterion)
   }

   my $criterion3=NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                           'match_value' => 1,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion3);

   $self->{'alert2'}->clusterId(18);
   $self->{'alert2'}->probeId(3000);
   $self->{'alert2'}->customerId(1);

   my $result          = $self->{'redirect'}->matches($self->{'alert2'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values on first, match");

   #-------------------------------------------------------------------#
                                                                              
   $criterion2->match_value(1);
   $result          = $self->{'redirect'}->matches($self->{'alert2'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"multiple fields, multiple values on first, no match");
}

#####################
sub test_matches_11 {
#####################

# start time via one field single value

   my $self = shift;

   my $criterion = NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                           'match_value' => 30,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion);

  # start date before alert current time

   $self->{'redirect'}->start_date($self->{'alert'}->current_time - 1);
   my $result          = $self->{'redirect'}->matches($self->{'alert'});
   my $expected_result = 1;
   
   $self->assert($result == $expected_result,"start date < alert time (match)");

   #-------------------------------------------------------------------#

  # start date equal to alert time

   $self->{'redirect'}->start_date($self->{'alert'}->current_time);
   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 1;
   
   $self->assert($result == $expected_result,"start date = alert time (match)");

   #-------------------------------------------------------------------#
  
  # start date after alert time

   $self->{'redirect'}->start_date($self->{'alert'}->current_time + 1);
   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"start date > alert time (no match)");
}

#####################
sub test_matches_12 {
#####################

# expiration via one field single value

   my $self = shift;

   my $criterion = NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                           'match_value' => 30,
                                           'inverted'    => 0);
   $self->{'redirect'}->add_criterion($criterion);

  # expiration before alert current time

   $self->{'redirect'}->expiration($self->{'alert'}->current_time - 1);
   my $result          = $self->{'redirect'}->matches($self->{'alert'});
   my $expected_result = 0;
   
   $self->assert($result == $expected_result,"expiration < alert time (no match)");

   #-------------------------------------------------------------------#

  # expiration equal to alert time

   $self->{'redirect'}->expiration($self->{'alert'}->current_time);
   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 0;
   
   $self->assert($result == $expected_result,"start date = alert time (no match)");

   #-------------------------------------------------------------------#
  
  # expiration after alert time

   $self->{'redirect'}->expiration($self->{'alert'}->current_time + 1);
   $result          = $self->{'redirect'}->matches($self->{'alert'});
   $expected_result = 1;
   
   $self->assert($result == $expected_result,"expiration > alert time (match)");
}

###################
sub test_redirect {
###################

  # A redirect of type 'Redirect' empties out an alert's originalDestinations and adds to the
  # newDestinations

  my $self=shift;

  my $group1  =  NOCpulse::Notif::ContactGroup->new( recid => '1');
  my $group2  =  NOCpulse::Notif::ContactGroup->new( recid => '2');
  my $group3  =  NOCpulse::Notif::ContactGroup->new( recid => '3');
  my $group4  =  NOCpulse::Notif::ContactGroup->new( recid => '4');
  my $group5  =  NOCpulse::Notif::ContactGroup->new( recid => '5');

  push(@{$self->{'alert'}->originalDestinations()},$group1);
  push(@{$self->{'alert'}->originalDestinations()},$group2);
  push(@{$self->{'alert'}->newDestinations()     },$group5);
  $self->{'alert'}->customerId(30);   # Create a match

  my $size=@{$self->{'alert'}->originalDestinations()};
  die "original destination configuration incorrect" unless $size == 2;
  $size=@{$self->{'alert'}->newDestinations()};
  die "new destination configuration incorrect" unless $size == 1;

  $self->{'redirect2'}->add_target($group3);  
  $self->{'redirect2'}->add_target($group4);  

  print "original destinations (pre redirect):", 
    &Dumper($self->{'alert'}->originalDestinations()), "\n";

  print "new destinations (pre redirect): ", &Dumper($self->{'alert'}->newDestinations()), "\n";  

  my $val = $self->{'redirect2'}->redirect($self->{'alert'});
  print "redirect successful = $val\n";

  print "original destinations (post redirect):", 
    &Dumper($self->{'alert'}->originalDestinations()), "\n";

  $size=@{$self->{'alert'}->originalDestinations()};
  $self->assert($size == 0,'original destinations is empty');
    
  print "new destinations (post redirect):", &Dumper($self->{'alert'}->newDestinations()), "\n";  

  $size=@{$self->{'alert'}->newDestinations()};
  $self->assert($size == 3,'new destinations has three entries');

  my @group = grep { $_->recid() == 3} @{$self->{'alert'}->newDestinations()};
  $self->assert(@group,'new destinations contains groupId 3');

  @group    = grep { $_->recid() == 4} @{$self->{'alert'}->newDestinations()};
  $self->assert(@group,'new destinations contains groupId 4');
}

1;
