package test::TestPhoneContactMethod;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::Alert;

my $MODULE = 'NOCpulse::Notif::EmailContactMethod';

my $CONFIG=NOCpulse::Config->new;
my $server  = $CONFIG->get('mail', 'mx');


$| = 1;

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

1;
