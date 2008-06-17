package test::TestMeTooRedirect;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::MeTooRedirect;
use NOCpulse::Notif::RedirectCriterion;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use Data::Dumper;

my $MODULE = 'NOCpulse::Notif::MeTooRedirect';

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

  my $criterion_1 = NOCpulse::Notif::RedirectCriterion->new( 'match_param' => 'CUSTOMER_ID',
                                            'match_value' => 30,
                                            'inverted'    => 0);                                           
  $self->{'redirect'}->add_criterion($criterion_1);
  $self->{'redirect'}->start_date(time() - 3600);
  $self->{'redirect'}->expiration(time() + 3600);

  $self->{'alert'}    = NOCpulse::Notif::Alert->new( 'message'   => 'The rain in Spain stays mainly on the plain',
                                    'groupName' => 'Karen_Group',
                                    'clusterId' => 29,
                                    'state'     => 'WARNING',
                                    'groupId'   => 11991,
                                    'probeId'   => 3000,
                                    'customerId'=> 30,
                                    'current_time' => time() );
}

# INSERT INTERESTING TESTS HERE

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

  $self->{'alert'}->originalDestinations_push($group1);
  $self->{'alert'}->originalDestinations_push($group2);
  $self->{'alert'}->newDestinations_push($group5);
  $self->{'alert'}->customerId(30);   # Create a match

  my $size=$self->{'alert'}->originalDestinations_count;
  die "original destination configuration incorrect" unless $size == 2;
  $size=$self->{'alert'}->newDestinations_count;
  die "new destination configuration incorrect" unless $size == 1;

  $self->{'redirect'}->add_target($group3);  
  $self->{'redirect'}->add_target($group4);  

  print "original destinations (pre redirect)", 
    &Dumper($self->{'alert'}->originalDestinations()), "\n";

  my $val = $self->{'redirect'}->redirect($self->{'alert'});
  print "redirect successful = $val\n";

  print "original destinations (post redirect)", 
    &Dumper($self->{'alert'}->originalDestinations()), "\n";

  $size=$self->{'alert'}->originalDestinations_count;
  $self->assert($size == 2,'original destinations has two entries');

  print "new destinations (post redirect)", 
    &Dumper($self->{'alert'}->newDestinations()), "\n";

  my @group    = grep { $_->recid() == 5} @{$self->{'alert'}->newDestinations()};
  $self->assert(scalar(@group) == 1,'new destinations contains groupId 5');

  @group = grep { $_->recid() == 3} @{$self->{'alert'}->newDestinations()};
  $self->assert(scalar(@group) == 1,'new destinations contains groupId 3');

  @group    = grep { $_->recid() == 4} @{$self->{'alert'}->newDestinations()};
  $self->assert(scalar(@group) == 1,'new destinations contains groupId 4');

  $size=$self->{'alert'}->newDestinations_count;
  $self->assert($size == 3,"new destinations has three entries ($size)");
}

1;
