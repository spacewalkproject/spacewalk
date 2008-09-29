package test::TestEscalator;

use strict;

use base qw(Test::Unit::TestCase);

use FileHandle;
use NOCpulse::Notif::Escalator;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::Send;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Log::Logger;

use Data::Dumper;

$|=1;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);
$Log->show_method(0);

my $MODULE = 'NOCpulse::Notif::Escalator';

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $directory = "/tmp/$$";

######################
sub test_constructor {
######################
  my $self = shift;
  `rm -rf /var/tmp/procpool*`;

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

  ### FIXME do not know what should replace this, /opt is obsolete
  ### but since this tests are not used... just comment out
  #`rm -rf /opt/notification/tmp/*`;

  $self->{'escalator'}=$MODULE->new();
  $self->{'escalator'}->save_state;

  my $file_contents = <<EOX;
checkCommand=27
clusterDesc=NPops-dev
clusterId=10702
commandLongName=Load
customerId=30
groupId=13556
groupName=Karen_Esc_OneAck
hostAddress=172.16.0.106
hostName=Velma.stage
hostProbeId=22775
mac=00:D0:B7:A9:C7:DE
message=The nocpulsed daemon is not responding: ssh_exchange_identification: Connection closed by remote host. Please make sure the daemon is running and the host is accessible from the satellite. Command was: /usr/bin/ssh -l nocpulse -p 4545 -i /var/lib/nocpulse/.ssh/nocpulse-identity -o BatchMode=yes 172.16.0.10 6 /bin/sh -s
osName=Linux System
physicalLocationName=for testing - don't delete me
probeDescription=Unix: Load
probeGroupName=unix
probeId=22776
probeType=ServiceProbe
snmp=
snmpPort=
state=UNKNOWN
subject=
time=1024643798
type=service
EOX

  my @array=split(/\n/,$file_contents);
  my %hash=map { split(/=/,$_,2) } @array;

  # Broadcast: One-Ack
  $self->{'bro_alert_oneack'} = NOCpulse::Notif::Alert->new(%hash);

  my $dest=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_INTERNAL_EMAIL);
  my $group=NOCpulse::Notif::ContactGroup->new(  
      'strategy' => 'NOCpulse::Notif::BroadcastStrategy', 
      'ack_wait' => 5,
      'ack_method' => 'OneAck');
  $group->add_destination($dest);
  $group->add_destination($dest);
  $group->add_destination($dest);
  push(@{$self->{'bro_alert_oneack'}->originalDestinations},$group);
  my $strategy=$dest->new_strategy_for_alert($self->{'bro_alert_oneack'});
  $self->{'bro_alert_oneack'}->strategies_push($strategy);
  $self->{'bro_send_oneack'}=${$strategy->sends}[0];
 
  # Escalate: All-Ack
  $self->{'esc_alert_oneack'} = NOCpulse::Notif::Alert->new(%hash);

  $group=NOCpulse::Notif::ContactGroup->new(  
      'strategy' => 'NOCpulse::Notif::BroadcastStrategy', 
      'ack_wait' => 0,
      'ack_method' => 'OneAck');
  $group->add_destination($dest);
  $group->add_destination($dest);
  $group->add_destination($dest);
  push(@{$self->{'esc_alert_oneack'}->originalDestinations},$group);
  $strategy=$dest->new_strategy_for_alert($self->{'esc_alert_oneack'});
  $self->{'esc_alert_oneack'}->strategies_push($strategy);
  $self->{'esc_send_oneack'}=${$strategy->sends}[0];
 
  $self->{'filename'}="/tmp/TestEscalator.$$.tmp";
}

###############
sub tear_down {
###############
  my $self=shift;
  `rm -rf $self->{'filename'}`;
}


# INSERT INTERESTING TESTS HERE

####################
sub test_from_file {
####################
  my $self=shift;
  my $alert=$self->{'bro_alert_oneack'};
  my $esc=$self->{'escalator'};

  
  $Log->log(9,"to_file\n");
  $alert->to_file($self->{'filename'});
  $self->assert(-e $self->{'filename'},"test_register_alert (alert file exists)");
  $Log->log(9,"register_alert\n");
  my $alert_id = $esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  unlink($self->{'filename'});

  $self->{'filename'}="/tmp/TestEscalator.test_from_file_escalator.$$.tmp";
  $Log->log(9,"store\n");
  $esc->store($self->{'filename'});

  $Log->log(9,"from_file\n");
  my $new_esc=NOCpulse::Notif::Escalator->from_file($self->{'filename'});

  $Log->log(9,"assertions\n");
  while (my ($key,$value) = each(%{$esc->_alerts})) {
    $self->assert($new_esc->_alerts($key) eq $value,"test_from_file (_alerts: $key)");
  }
  print "done test_from_file\n";
}
  
######################
sub test_clear_alert {
######################
  my $self=shift;

  my $esc=$self->{'escalator'};
  my $alert=$self->{'bro_alert_oneack'};
  
  #Setup: start the alert and its send in the system
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  my $alert_file=NOCpulse::Notif::AlertFile->new ( 
    file  => $self->{'filename'},
    alert => $alert);
  
  my @sends = $alert->create_initial_sends;
  my $send = shift(@sends);
  my ($send_id) = $esc->start_sends($alert,$send);

  #Ensure proper setup
  $self->assert(defined($esc->_alerts($alert_id)),"test_clear_alert alert exists");
  $self->assert(defined($esc->_sends($send_id)),"test_clear_alert send exists");

  #Clear the alert
  $esc->clear_alert($alert_file);

  #Ensure it worked
  $self->assert(!defined($esc->_alerts($alert_id)),"test_clear_alert alert cleared");
  $self->assert(!defined($esc->_sends($send_id)),"test_clear_alert send cleared");
}

###################
sub test_escalate {
###################
  my $self=shift;
  my $esc=$self->{'escalator'};

  # Test to ensure that expired sends are acked with an 'expire' operation

  #Setup: start the alert and its send in the system
  my $alert=$self->{'bro_alert_oneack'};
  my $send=$self->{'bro_send_oneack'};
  
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  $send->alert_id($alert_id);
  $alert->to_file($self->{'filename'});

#  $Log->log(9,"alert is (post register alert)", &Dumper($alert),"\n");

  # Expired send
  $Log->log(9,"TEST: start send\n");
  $esc->start_sends($alert,$send);
  $Log->log(9,"TEST: alert is (post start send)", &Dumper($alert),"\n");
  $Log->log(9,"TEST: alert to file\n");
  $alert->to_file($self->{'filename'});
  $Log->log(9,"TEST: send time\n");
  $send->send_time(time() - (5 * 60 + 10));   # 5 minutes 10 seconds ago
  $Log->log(9,"TEST: send ack wait\n");
  $send->ack_wait(5);
  $Log->log(9,"TEST: send update send\n");
  $esc->update_send($send);
  $alert->to_file($self->{'filename'});
  my $send_id=$send->send_id;

  $self->assert(defined($esc->_sends($send_id)),"test_escalate (pre) send exists");
  $self->assert(defined($esc->_alerts($alert_id)),"test_escalate (pre) alert exists");

  $Log->log(9,"TEST: escalator escalate\n");
  $esc->escalate();

  $Log->log(9,"TEST: escalator sends\n");
  my $info=$esc->_sends($send_id);
  $self->assert(!defined($info),"test_escalate (post) info exists");
}

###########################
sub test_lock_alert_by_id {
###########################
  my $self=shift;
  my $esc=$self->{'escalator'};
  my $alert=$self->{'bro_alert_oneack'};
  my $send=$self->{'bro_send_oneack'};

  #Setup: start the alert and its send in the system
  
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  $alert->to_file($self->{'filename'});

  $self->assert(defined($esc->_alerts($alert_id)),"test_lock_alert_by_id alert exists");

  my $alert_file=$esc->lock_alert_by_id($alert_id);
  $self->assert(qr/NOCpulse::Notif::AlertFile/,"$alert_file");
}

###############################
sub test_filename_for_send_id {
###############################
  my $self=shift;
  my $esc=$self->{'escalator'};
  my $alert=$self->{'bro_alert_oneack'};

  #Setup: start the alert and its send in the system
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  my @sends = $alert->create_initial_sends;
  $esc->start_sends($alert,@sends);
  my $send=shift(@sends);
  my $send_id=$send->send_id;

  #Ensure proper setup
  $self->assert(defined($esc->_alerts($alert_id)),"filename_for_send_id alert exists");
  $self->assert(defined($esc->_sends($send_id)),"filename_for_send_id send exists");
  $self->assert(defined($send_id),"filename_for_send_id send id exists");

  # Do the test
  my ($name)=$esc->filename_for_send_id($send_id);
  $Log->log(1,"send name ($send_id) is $name");

  $self->assert(defined($name), "filename exists");
  $self->assert($name eq $self->{'filename'}, "filename_for_send_id filename ");
}

#########################
sub test__next_alert_id {
#########################
  my $self=shift;
  my $esc=$self->{'escalator'};
  $esc->alert_id(1);
  for (my $i=1; $i <=10; $i++) {
    my $value = $esc->_next_alert_id;
    $self->assert($value == $i, "alert id $i");
  }
}

#####################
sub test_next_sends {
#####################
  my $self=shift;

  my $esc=$self->{'escalator'};
  my ($send)=$esc->next_sends;
  $self->assert(!defined($send),"next_sends/ (empty work queue)");

  my $alert=$self->{'bro_alert_oneack'};

  #Setup: start the alert and its send in the system
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  my @sends = $alert->create_initial_sends;
  $esc->start_sends($alert,@sends);
  $send=shift(@sends);

  my ($filename,@ids) = $esc->next_sends;
  $self->assert($self->{'filename'} eq $filename, "filename");
  my $id = shift(@ids);
  $self->assert($send->send_id eq $id, "send id");
}

########################
sub test__next_send_id {
########################
  my $self=shift;

  my %list;

  for (my $i=1; $i <=10; $i++) {
    my $value = $self->{'escalator'}->_next_send_id;
    $self->assert(length($value) == 6,'length send_id');
    $self->assert($value =~ /^[a-z0-9]+$/,'content send_id');
    $self->assert($value !~ /[aeiouy]/,'vowel content send_id');
    $self->assert(!exists($list{$value}),'uniqueness send_id');
    $list{$value}++;
  }
}

#########################
sub test_register_alert {
#########################
  my $self=shift;
  my $alert=$self->{'bro_alert_oneack'};
  my $esc=$self->{'escalator'};
  
  print "Escalator: ", &Dumper($esc), "\n";
  $alert->to_file($self->{'filename'});
  $self->assert(-e $self->{'filename'},"test_register_alert (alert file exists)");

  my $alert_id = $esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  unlink($self->{'filename'});
  my $result=$esc->_alerts($alert_id);
  print "alert_id: $alert_id, filename: $self->{'filename'}, result: $result\n";
  $self->assert($self->{'filename'} eq $result,"test_register_alert (alert registered)");
}

#########################
sub test__register_send {
#########################
  my $self=shift;

  my $esc=$self->{'escalator'};
  my $alert=NOCpulse::Notif::Alert->new('customerId'  => 1,
                                        'hostProbeId' => 13,
                                        'probeId'     => 28);
  die ('no alert') unless defined($alert);
  
  $alert->to_file($self->{'filename'});

  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  $alert->to_file($self->{'filename'});

#  my $strategy=NOCpulse::Notif::BroadcastStrategy->new();
#  die ('no strategy') unless defined($strategy);
#  $strategy->alert($alert);

  my $send=NOCpulse::Notif::Send->new(
    'send_id'  => 29,
    'alert_id' => $alert_id);
  die ('no send') unless defined($send);
  
  $esc->_register_send($send,$alert);
  unlink($self->{'filename'});
  $self->assert($esc->_sends_exists(29),"send 29 exists");

  my $info=$esc->_sends(29);
  $self->assert($info->alertId      == $alert_id,"alert id correct");
  $self->assert($info->customerId   == 1,        "customerId correct");
  $self->assert($info->hostProbeId  == 13,       "hostProbeId correct");
  $self->assert($info->sendId       == 29,       "send id correct");
  $self->assert($info->probeId      == 28,       "probeId correct");
}

###########################
sub test__remove_alert_id {
###########################
  my $self=shift;
  my $alert=$self->{'bro_alert_oneack'};
  my $esc=$self->{'escalator'};
  
  print "Escalator: ", &Dumper($esc), "\n";
  $alert->to_file($self->{'filename'});
  $self->assert(-e $self->{'filename'},"test_remove_alert_id (alert file exists)");

  my $alert_id = $esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  my $result=$esc->_alerts($alert_id);
  print "alert_id: $alert_id, filename: $self->{'filename'}, result: $result\n";
  $self->assert($self->{'filename'} eq $result,"test_remove_alert_id (alert registered)");

  $esc->_remove_alert_id($alert_id);
  $self->assert(!defined($esc->_alerts($alert_id)),"test_remove_alert_id");
}


##########################
sub test__remove_send_id {
##########################
  my $self=shift;

  my $alert = $self->{'bro_alert_oneack'};
  my $send=NOCpulse::Notif::Send->new('send_id' => 13);
  my $esc=$self->{'escalator'};
  $esc->_register_send($send,$alert);
  $esc->_remove_send_id($send->send_id);
  $self->assert(!defined($esc->_sends(13)),"send 13 doesn't exist");
}

######################
sub test_start_sends {
######################
  my $self=shift;
  my $send=$self->{'bro_send_oneack'};
  my $alert=$self->{'bro_alert_oneack'};
  my $esc=$self->{'escalator'};

  
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  $send->alert_id($alert_id);

  $esc->start_sends($alert,$send);

  $self->assert(defined($send->send_id),"send assigned id");
  $self->assert($esc->_sends_exists($send->send_id),"send registered");

}


######################
sub test_update_send {
######################
  my $self=shift;

  my $esc=$self->{'escalator'};
  my $alert=NOCpulse::Notif::Alert->new('customerId'  => 1,
                                        'hostProbeId' => 13,
                                        'probeId'     => 28);
  die ('no alert') unless defined($alert);
  
  $alert->to_file($self->{'filename'});

  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  $alert->to_file($self->{'filename'});

#  my $strategy=NOCpulse::Notif::BroadcastStrategy->new();
#  die ('no strategy') unless defined($strategy);
#  $strategy->alert($alert);

  my $send=NOCpulse::Notif::Send->new(
    'send_id'  => 29,
    'alert_id' => $alert_id);
  die ('no send') unless defined($send);
  
  $esc->_register_send($send,$alert);
  $self->assert($esc->_sends_exists(29),"send 29 exists");

  my $info=$esc->_sends(29);

  my $current_time=time();
  $send->destination(NOCpulse::Notif::ContactMethod->new(contact_id => 100));
  $send->send_time($current_time);
  $send->ack_wait(1);
  $send->is_completed(1);

  $esc->update_send($send);
  $info=$esc->_sends(29);
  $self->assert($info->contactId    == 100, "contact id correct");
  $self->assert($info->expiration   == $current_time + 60,   
    "expiration correct");
  $self->assert($info->completed    == 1,   "completed correct");
  
  unlink($self->{'filename'});
}

#####################
sub test_save_state {
#####################
  my $self=shift;
  my $send=$self->{'bro_send_oneack'};
  my $alert=$self->{'bro_alert_oneack'};
  my $esc=$self->{'escalator'};

  
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $send->alert_id($alert_id);

  $esc->start_sends($alert,$send);
  $esc->save_state;

  my $np_cfg       = new NOCpulse::Config;
  my $tmp_dir      = $np_cfg->get('notification','tmp_dir');
  my $STATE_FILE   = "$tmp_dir/escalator.state";
  my $new_esc=NOCpulse::Notif::Escalator->from_file($STATE_FILE);

  my @alerts=$esc->_alerts;
  foreach my $id (@alerts) {
    $self->assert($esc->_alerts($id) eq $new_esc->_alerts($id),"alerts $id");
  }

  my @sends=$esc->_sends_keys;
  foreach my $send_id (@sends) {
    my $info1=$esc->_sends($send_id);
    my $info2=$new_esc->_sends($send_id);

    $self->assert($info1->sendId eq $info2->sendId,"send $send_id");
  }
}

####################
sub test_shut_down {
####################
  my $self=shift;
  my $send=$self->{'bro_send_oneack'};
  my $alert=$self->{'bro_alert_oneack'};
  my $esc=$self->{'escalator'};

  
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $send->alert_id($alert_id);

  $esc->start_sends($alert,$send);
  $esc->shut_down;

  my $np_cfg       = new NOCpulse::Config;
  my $tmp_dir      = $np_cfg->get('notification','tmp_dir');
  my $STATE_FILE   = "$tmp_dir/escalator.state";
  my $new_esc=NOCpulse::Notif::Escalator->from_file($STATE_FILE);

  my @alerts=$esc->_alerts;
  foreach my $id (@alerts) {
    $self->assert($esc->_alerts($id) eq $new_esc->_alerts($id),"alerts $id");
  }

  my @sends=$esc->_sends_keys;
  foreach my $send_id (@sends) {
    my $info1=$esc->_sends($send_id);
    my $info2=$new_esc->_sends($send_id);

    $self->assert($info1,"info1 exists");
    $self->assert($info2,"info2 exists");
    $self->assert($info1->sendId eq $info2->sendId,"send $send_id");
  }
}
  
############################
sub x_test_weed_send_history {
############################
  my $self=shift;
  my $esc=$self->{'escalator'};
  $esc->clear;
  my $send=$self->{'bro_send_oneack'};
  my $alert=$self->{'bro_alert_oneack'};

  my $duration= 7 * 60 * 60;  # 7 hours (as seconds)

  
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $send->alert_id($alert_id);

  my $np_cfg       = new NOCpulse::Config;
  my $tmp_dir      = $np_cfg->get('notification','tmp_dir');
  my $SEND_GDBM   = "$tmp_dir/sendhistory.gdbm";

  $esc->start_sends($alert,$send);
  $send->scheduled_time(time() - $duration);
  $esc->update_send($send);

  my %send_history;
  tie(%send_history, 'GDBM_File', $SEND_GDBM, O_RDWR,0644);
  my $count=scalar(keys(%send_history));

  my %temp;
  $Log->log(1,"(pre) count is $count\n");
  $Log->log(1,"(pre) send history is...\n");
  while (my($key,$value) = each(%send_history)) {
    $Log->log(1,"$key: $value\n");
  }
  untie(%send_history);

  $self->assert($count == 1,"pre weed history");

  $esc->weed_send_history;

  tie(%send_history, 'GDBM_File', $SEND_GDBM, O_RDONLY,0644);
  $count=keys(%send_history);
  $Log->log(1,"(post) count is $count\n");
  $Log->log(1,"(post) send history is...\n");
  while (my($key,$value) = each(%send_history)) {
    $Log->log(1,"$key: $value\n");
  }
  untie(%send_history);

  $self->assert($count == 0, "after weed history");
}

##############
sub test_ack {
##############
  my $self = shift;
  my $esc=$self->{'escalator'};
  $esc->clear;

  my $alert = $self->{'bro_alert_oneack'};
  $alert->to_file($self->{'filename'});
  
  my $alert_id = $esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);

  my @sends = $alert->create_initial_sends;
  $esc->start_sends($alert,@sends);
  $alert->to_file($self->{'filename'});

  my $send=shift(@sends);
  my $send_id=$send->send_id;
  $self->assert(defined($esc->_sends($send_id)), "(pre) send id");

  my $result = $esc->ack('ack',$send_id);

  $self->assert(!$result, "result test_ack");
  $self->assert(!defined($esc->_sends($send_id)), "send id");
}

################
sub test_clear {
################
  my $self=shift;
  my $esc=$self->{'escalator'};
  my $alert=$self->{'bro_alert_oneack'};
  
  #Setup: start the alert and its send in the system
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  my $alert_file=NOCpulse::Notif::AlertFile->new ( 
    file  => $self->{'filename'},
    alert => $alert);
  
  my @sends = $alert->create_initial_sends;
  my $send = shift(@sends);
  my ($send_id) = $esc->start_sends($alert,$send);

  #Ensure proper setup
  $self->assert(defined($esc->_alerts($alert_id)),"test_clear_alert alert exists");
  $self->assert(defined($esc->_sends($send_id)),"test_clear_alert send exists");

  #Clear the escalator
  $esc->clear;

  #Ensure it worked
  $self->assert(scalar($esc->_alerts_values) == 0, "test_clear empty alerts");
  $self->assert(scalar($esc->_sends_values) == 0, "test_clear empty sends");
}

#########################
sub test_clear_alert_id {
#########################
  my $self=shift;

  my $esc=$self->{'escalator'};
  my $alert=$self->{'bro_alert_oneack'};
  
  #Setup: start the alert and its send in the system
  $alert->to_file($self->{'filename'});
  my $alert_id=$esc->register_alert($self->{'filename'});
  $alert->alert_id($alert_id);
  my $alert_file=NOCpulse::Notif::AlertFile->new ( 
    file  => $self->{'filename'},
    alert => $alert);
  
  my @sends = $alert->create_initial_sends;
  my $send = shift(@sends);
  my ($send_id) = $esc->start_sends($alert,$send);
  $alert->to_file($self->{'filename'});

  #Ensure proper setup
  $self->assert(defined($esc->_alerts($alert_id)),"(pre) alert exists");
  $self->assert(defined($esc->_sends($send_id)),"(pre) send exists");

  #Clear the alert
  my $result = $esc->clear_alert_id($alert_id);

  #Ensure it worked
  $self->assert(!$result, "clear_alert_id result");
  $self->assert(!defined($esc->_sends($send_id)),"send cleared");
  $self->assert(!defined($esc->_alerts($alert_id)),"alert cleared");
}

#####################
sub test_delay_send {
#####################
  my $self=shift;
  my $esc=$self->{'escalator'};
  my $send_id_1 = 'xxxyyy';
  my $send_id_2 = 'yyyzzz';
  $esc->delay_send($send_id_1);
  $esc->delay_send($send_id_2);
  $self->assert($esc->_work_queue_shift eq $send_id_1, "send_id_1");
  $self->assert($esc->_work_queue_shift eq $send_id_2, "send_id_2");
}

1;
