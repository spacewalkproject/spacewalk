package test::TestEmailContactMethod;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::Alert;

my $MODULE = 'NOCpulse::Notif::EmailContactMethod';

my $CONFIG=NOCpulse::Config->new;
my $server  = $CONFIG->get('mail', 'mx');

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

  $self->{'one'}=$MODULE->new( 'email' => $MY_INTERNAL_EMAIL);
  $self->{'alert'}=NOCpulse::Notif::Alert->new( 
    'fmt_subject' => 'test subject one',
    'fmt_message' => 'this is the body of test one',
    'send_id'     => '0101');

  $self->{'smtp'}=test::TestEmailContactMethod::SMTPStub->new;
  $self->{'db'}=test::TestEmailContactMethod::DBStub->new;
  $self->{'db'}->connect;
}

###############
sub tear_down {
###############
  my $self = shift;
  $self->{'smtp'}->quit;
  $self->{'db'}->disconnect;
}

# INSERT INTERESTING TESTS HERE

##################
sub test_deliver {
##################
  my $self=shift;

  my $alert=$self->{'alert'};
  my $smtp=$self->{'smtp'};
  my $db=$self->{'db'};
  my $value=$self->{'one'}->deliver($alert,$db,$smtp);
  $self->assert($value == 0, "test_deliver");
}

######################
sub test_printString {
######################
  my $self=shift;

  my $method=$self->{'one'};
  my $string=$method->printString();
  
  $self->assert($string =~ /$MY_INTERNAL_EMAIL/, "test_printString");
}

package test::TestEmailContactMethod::SMTPStub;

use Class::MethodMaker
  new_hash_init => 'new';

sub code { }
sub data      { return 1 }
sub datasend  { return 1 }
sub dataend   { return 1 }
sub mail      { return 1 }
sub quit      { return 1 }
sub reset     { return 1 }
sub recipient { return 1 }

package test::TestEmailContactMethod::DBStub;

use Class::MethodMaker
  new_hash_init => 'new';

sub connect { } 
sub disconnect { } 

1;

