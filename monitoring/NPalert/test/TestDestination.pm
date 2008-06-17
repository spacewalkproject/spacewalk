package test::TestDestination;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::Destination;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::AlertDB;

my $MODULE = 'NOCpulse::Notif::Destination';

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';

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

############
sub set_up {
############
  my $self = shift;
  # This method is called before each test.

  $self->{'destination'} = NOCpulse::Notif::EmailContactMethod->new (
    customer_id => 1,
    name => 'my_destination',
    recid => '29');
}

# INSERT INTERESTING TESTS HERE

######################
sub test_printString {
######################
  my $self = shift;
  my $dest = $self->{'destination'};

  my $string = $dest->printString;

  $self->assert($string =~ /1/, "customer id");
  $self->assert($string =~ /29/, "recid");
  $self->assert($string =~ /my_destination/, "name");
}

