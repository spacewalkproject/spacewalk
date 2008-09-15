package test::TestEscalateStrategy;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::EscalateStrategy;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::Escalator;

my $MODULE = 'NOCpulse::Notif::EscalateStrategy';

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';

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

  $self->{'internal_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_INTERNAL_EMAIL);
  $self->{'external_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_EXTERNAL_EMAIL);
  $self->{'nowhere_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $NOWHERE_EMAIL);

  $self->{'group'}=NOCpulse::Notif::ContactGroup->new();

  $self->{'group'}->add_destination($self->{'internal_dest'});
  $self->{'group'}->add_destination($self->{'external_dest'});
  $self->{'group'}->add_destination($self->{'nowhere_dest'});

  $self->{'alert'}    = NOCpulse::Notif::Alert->new( 'message'   => 'The rain in Spain stays mainly on the plain',
                                    'groupName' => 'Karen_Group',
                                    'clusterId' => 29,
                                    'state'     => 'WARNING',
                                    'groupId'   => 11991,
                                    'probeId'   => 3000,
                                    'customerId'=> 30 );

  $self->{'strategy'}=$MODULE->new_for_group($self->{'group'},$self->{'alert'});
  $self->{'strategy'}->ack_wait(5);

  $self->{'escalator'}=NOCpulse::Notif::Escalator->new();
}

# INSERT INTERESTING TESTS HERE

##############
sub test_ack {
##############
  my $self=shift;
  my $alert  = $self->{'alert'};
  my $strategy  = $self->{'strategy'};
  my $esc = $self->{'escalator'};
  my $send = $strategy->_next_send;

  my $filename="/tmp/TestEscalateStrategy.test_next_sends.$$.tmp";
  $alert->to_file($filename);
  my $alert_id=$esc->register_alert($filename);
  $send->alert_id($alert_id);
  $esc->start_sends($send);
  $esc->_work_queue_clear();
  $send->acknowledgement('nak');

  $strategy->ack($send,$alert,$esc);

  my $value = $esc->_work_queue_pop();
  $self->assert(defined($value),"send id exists");
  $self->assert(defined($esc->_sends($value)),"test_ack");
}

#####################
sub test__next_send {
#####################
  my $self=shift;
  my $strategy = $self->{'strategy'};

  my $send = $strategy->_next_send;
  my $dest = $send->destination;
  $self->assert($dest->email eq $MY_INTERNAL_EMAIL,'test__next_send 1');
  $send = $strategy->_next_send;
  $dest = $send->destination;
  $self->assert($dest->email eq $MY_EXTERNAL_EMAIL,'test__next_send 2');
  $send = $strategy->_next_send;
  $dest = $send->destination;
  $self->assert($dest->email eq $NOWHERE_EMAIL,'test__next_send 3');
  $send = $strategy->_next_send;
  $self->assert(!defined($send),'test__next_send 4');
}

######################
sub test_start_sends {
######################
  my $self=shift;
  my $strategy = $self->{'strategy'};

  my @sends = $strategy->start_sends();
  my $send = shift(@sends);
  my $dest = $send->destination;
  $self->assert($dest->email eq $MY_INTERNAL_EMAIL,'test_start_sends');
}

######################
sub test_printString {
######################
  my $self=shift;
  my $strategy = $self->{'strategy'};
  $strategy->ack_method('AllAck');

  my $string = $strategy->printString;
  $self->assert($string =~ /Escalate/,"escalate");
}

1;
