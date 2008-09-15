package test::TestAutoAckRedirect;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::AutoAckRedirect;
use NOCpulse::Notif::RedirectCriterion;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use Data::Dumper;

my $MODULE = 'NOCpulse::Notif::AutoAckRedirect';

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
  my $criterion_1 = NOCpulse::Notif::RedirectCriterion->new( 
                                            'match_param' => 'CUSTOMER_ID',
                                            'match_value' => 0,
                                            'inverted'    => 1);                                           
  $self->{'redirect2'}->add_criterion($criterion_1);
  $self->{'redirect2'}->start_date(time() - 3600);
  $self->{'redirect2'}->expiration(time() + 3600);


  $self->{'alert'}    = NOCpulse::Notif::Alert->new( 'message'   => 'The rain in Spain stays mainly on the plain',
                                    'groupName' => 'Karen_Group',
                                    'clusterId' => 29,
                                    'state'     => 'WARNING',
                                    'groupId'   => 11991,
                                    'probeId'   => 3000,
                                    'customerId'=> 30 ,
                                    'current_time' => time ());
  $self->{'alert2'}   = NOCpulse::Notif::Alert->new( 'message'   => 'Don\'t let the sun go down on me',
                                    'groupName' => 'Dave_Group',
                                    'clusterId' => 13,
                                    'state'     => 'UNKNOWN',
                                    'groupId'   => 29292,
                                    'probeId'   => 5000,
                                    'customerId'=> 2,
                                    'current_time' => time () );
}

# INSERT INTERESTING TESTS HERE

###################
sub test_redirect {
###################
  my $self=shift();
  $self->{'redirect2'}->redirect($self->{'alert2'});
  $self->assert($self->{'alert2'}->auto_ack,"auto ack");
}

1;
