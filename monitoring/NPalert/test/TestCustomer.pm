package test::TestCustomer;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::Customer;
use NOCpulse::Notif::Redirect;
use NOCpulse::Notif::Alert;
use Data::Dumper;

my $MODULE = 'NOCpulse::Notif::Customer';

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

  $self->{'customer'} = $MODULE->new();
  $self->{'redirect'} = NOCpulse::Notif::Redirect->new();

  $self->{'alert'}    = NOCpulse::Notif::Alert->new( 'message'   => 'The rain in Spain stays mainly on the plain',
                                    'groupName' => 'Karen_Group',
                                    'clusterId' => 29,
                                    'state'     => 'WARNING',
                                    'groupId'   => 11991,
                                    'probeId'   => 3000,
                                    'customerId'=> 30 );
}

# INSERT INTERESTING TESTS HERE

###################
sub test_redirect {
###################
  my $self=shift();
  $self->{'customer'}->addRedirect($self->{'redirect'});
  $self->{'customer'}->redirect($self->{'alert'});
}

######################
sub test_addRedirect {
######################
  my $self = shift();
  my $customer = $self->{'customer'}; 
  $customer->addRedirect($self->{'redirect'});

  my $redirect = $customer->redirects_shift;
  $self->assert(qr/NOCpulse::Notif::Redirect/, "$redirect");
}

1;
