package test::TestContactMethod;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::AlertDB;

my $MODULE = 'NOCpulse::Notif::EmailContactMethod';

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
  $self->{'alert'}=NOCpulse::Notif::Alert->new( 'fmt_subject' => 'test subject one',
                                                'fmt_message' => 'this is the body of test one',
                                                'send_id'     => '0101');

  $self->{'smtp'}=test::TestContactMethod::SMTPStub->new;
  $self->{'db'}=test::TestContactMethod::DBStub->new;
  $self->{'db'}->connect;
}

###############
sub tear_down {
###############
  my $self=shift;
  $self->{'db'}->disconnect;
  $self->{'smtp'}->quit if $self->{'smtp'};
}

# INSERT INTERESTING TESTS HERE

#################################
sub test_new_strategy_for_alert {
#################################
  my $self=shift;

  my $value=$self->{'one'}->new_strategy_for_alert($self->{'alert'});
  $self->assert(qr/NOCpulse::Notif::BroadcastStrategy/, "$value");
}

###############
sub test_send {
###############
  my $self=shift;

  my $send=NOCpulse::Notif::Send->new();
  my $alert=$self->{'alert'};
  my $db=$self->{'db'};
  my $smtp=$self->{'smtp'};
  my $value=$self->{'one'}->send($send,$alert,$db,$smtp);
  $self->assert($value = ~ /this is the body of test one/,"test_send");
}

######################
sub test_designation {
######################
  my $self=shift;

  my $value=$self->{'one'}->designation;
  $self->assert($value eq 'i','designation is i');
}

package test::TestContactMethod::SMTPStub;

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

package test::TestContactMethod::DBStub;

use Class::MethodMaker
  new_hash_init => 'new';

sub connect { } 
sub disconnect { }
1;
