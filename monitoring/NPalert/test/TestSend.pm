package test::TestSend;

use strict;

use base qw(Test::Unit::TestCase);

use Date::Parse;
use NOCpulse::Notif::Send;
use NOCpulse::Notif::BroadcastStrategy;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::EmailContactMethod;

use NOCpulse::Log::Logger;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::Send';

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

  my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
  my $alert=NOCpulse::Notif::Alert->new();
  my $dest=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_INTERNAL_EMAIL);
  my $strategy=$dest->new_strategy_for_alert($alert);
  $self->{'send'}=${$strategy->sends}[0];
}


# INSERT INTERESTING TESTS HERE

#######################
sub test_as_send_info {
#######################
  my $self=shift;
  my $now=time();

  my $send=$self->{'send'};
  my $alert=NOCpulse::Notif::Alert->new(alert_id => 5000, 
    customerId => 1,
    hostProbeId => 10,
    probeId => 20);

  $send->send_id('aaaaaa');
  $send->alert_id(5000);
  $send->expire_time($now);
  $send->is_completed(1);
  
  my $info=$send->as_send_info($alert);

  $self->assert($info->customerId == $alert->customerId, "customer id");
  $self->assert($info->hostProbeId == $alert->hostProbeId, "host probe id");
  $self->assert($info->probeId == $alert->probeId, "probe id");
  $self->assert($info->sendId == $send->send_id, "send id");
  $self->assert($info->alertId == $alert->alert_id, "alert id");
  $self->assert($info->expiration == $send->expire_time, "expiration");
  $self->assert($info->completed == $send->is_completed, "completed");
}

##########################
sub test_ack_wait_string {
##########################
  my $self=shift;
  my $send=$self->{'send'};
  $send->send_time(str2time("Sun Jul 14 8:30:00 GMT 2002"));
  $send->ack_wait(5);

  my $string=$send->ack_wait_string;
  $self->assert($string eq 'expired',"test_ack_wait_string");
}

######################
sub test_expire_time {
######################
  my $self=shift;

  $self->{'send'}->send_time(str2time("Sun Jul 14 8:30:00 GMT 2002"));
  $self->{'send'}->ack_wait(5);
  my $result=$self->{'send'}->expire_time;

  my $expected_result=str2time("Sun Jul 14 8:35:00 GMT 2002");

  $self->assert($result == $expected_result);
}

######################
sub test_has_expired {
######################
  my $self=shift;

  my $send=$self->{'send'};
  $send->send_time(time-120);
  $send->ack_wait(1);
  $self->assert($send->has_expired,"expired send");

  $send->send_time(time);
  $send->ack_wait(5);
  $self->assert(!$send->has_expired,"unexpired send");

  $send->send_time(time);
  $send->ack_wait(0);
  $self->assert($send->has_expired,"expired send, no ack");
}

################
#sub test_send {
################

# Currently BOBO

#  my $self=shift;
#  my $send=$self->{'send'};
#
#  $send->send();
#  $self->assert(defined($send->send_time),"send time defined");
#}

##############
sub test_ack {
##############
  my $self=shift;
  my $send=$self->{'send'};
  my $escalator;

  $send->ack('nak',$escalator);

  $self->assert($send->acknowledgement eq 'nak',"operation");
  $self->assert($send->is_completed, "completed");
}


###########################
sub test_update_send_info {
###########################
  my $self=shift;

  my $info=NOCpulse::Notif::SendInfo->new();

  my $send=$self->{'send'};
  my $now=time();
  $send->send_id('aaaaaa');
  $send->alert_id(5000);
  $send->expire_time($now);
  $send->is_completed(1);
  
  $info=$send->update_send_info($info);

  $self->assert($info->sendId == $send->send_id, "send id");
  $self->assert($info->expiration == $send->expire_time, "expiration");
  $self->assert($info->completed == $send->is_completed, "completed");
}

######################
sub test_printString {
######################
  my $self=shift;
  my $send=$self->{'send'};
  $send->send_id('xxxyyy');

  my $string = $send->printString;
  $self->assert($string =~ /xxxyyy/, "print string");
  
}

###############
sub test_show {
###############
  my $self=shift;
  my $send=$self->{'send'};
  $send->send_id('xxxyyy');

  my $string = $send->show;

  $self->assert($string =~ /xxxyyy/, "show");
}

1;
