package test::TestAlert;

use strict;

use base qw(Test::Unit::TestCase);

use CGI;
use Storable;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::BroadcastStrategy;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::EscalateStrategy;
use NOCpulse::Notif::Redirect;
use NOCpulse::Log::LogManager;

my $MODULE = 'NOCpulse::Notif::Alert';

my $directory = "/tmp/$$";

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';

my @EMAILS=($MY_INTERNAL_EMAIL, $MY_EXTERNAL_EMAIL, $NOWHERE_EMAIL);

my $Log=NOCpulse::Log::Logger->new($MODULE);

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

  $self->{'alert'} = $MODULE->new();

  my $temp = $MODULE->new(
  'checkCommand' => '27',
  'clusterDesc' => 'NPops-dev',
  'clusterId' => '10702',
  'commandLongName' => 'Load',
  'customerId' => '30',
  'groupId' => '13254',
  'groupName' => 'Karen-3-group',
  'hostAddress' => '172.16.0.106',
  'hostName' => 'Velma.stage',
  'hostProbeId' => '22775',
  'mac' => '00:D0:B7:A9:C7:DE',
  'message' => 'The nocpulsed daemon is not responding: ssh_exchange_identification: Connection closed by remote host. Please make sure the daemon is running and the host is accessible from the satellite. Command was: /usr/bin/ssh -l nocpulse -p 4545 -i /var/lib//nocpulse/.ssh/nocpulse-identity -o BatchMode=yes 172.16.0.10 6 /bin/sh -s',
  'osName' => 'Linux System',
  'physicalLocationName' => 'for testing - don\'t delete me',
  'probeDescription' => 'Unix: Load',
  'probeGroupName' => 'unix',
  'probeId' => '22776',
  'probeType' => 'ServiceProbe',
  'snmp' => '',
  'snmpPort' => '',
  'state' => 'UNKNOWN',
  'subject' => '',
  'time' => '1024643798',
  'type' => 'service'
);

  mkdir ($directory,0777);
  foreach (qw (one two three)) {
    $temp->store("$directory/$_");    
  }
  $self->{'internal_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_INTERNAL_EMAIL);
  $self->{'external_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_EXTERNAL_EMAIL);
  $self->{'nowhere_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $NOWHERE_EMAIL);

  $self->{'group'}=NOCpulse::Notif::ContactGroup->new();

  $self->{'group'}->add_destination($self->{'internal_dest'});
  $self->{'group'}->add_destination($self->{'external_dest'});
  $self->{'group'}->add_destination($self->{'nowhere_dest'});

  $self->{'alert2'} = NOCpulse::Notif::Alert->new( 
    'message'   => 'The rain in Spain stays mainly on the plain',
    'groupName' => 'Karen_Group',
    'clusterId' => 29,
    'state'     => 'WARNING',
    'groupId'   => 11991,
    'probeId'   => 3000,
    'customerId'=> 30 );

  $self->{'alert3'} = NOCpulse::Notif::Alert->new( 
    'message'   => 'The rain in Spain stays mainly on the plain',
    'groupName' => 'Karen_Group',
    'clusterId' => 29,
    'state'     => 'WARNING',
    'groupId'   => 11991,
    'probeId'   => 3000,
    'customerId'=> 30 );

  # Broadcast group
  my $bro_group=NOCpulse::Notif::ContactGroup->new(
    strategy => NOCpulse::Notif::BroadcastStrategy->new( ack_wait => 0));
  foreach (@EMAILS) {
    $bro_group->destinations_push(
      NOCpulse::Notif::EmailContactMethod->new(email => $_));
  }
  $self->{'alert3'}->originalDestinations_push($bro_group);
  
  # Escalation group
  my $esc_group=NOCpulse::Notif::ContactGroup->new(
    strategy => NOCpulse::Notif::EscalateStrategy->new( ack_wait => 0));
  foreach (@EMAILS) {
    $esc_group->destinations_push(
      NOCpulse::Notif::EmailContactMethod->new(email => $_));
  }
  $self->{'alert3'}->originalDestinations_push($esc_group);

  # Simulate a metoo type redirect
  $self->{'alert3'}->newDestinations_push( NOCpulse::Notif::SimpleEmailContactMethod->new(
      email => $MY_INTERNAL_EMAIL));
}

###############
sub tear_down {
###############
  my $self = shift;
  # Run after each test

#  `rm -rf $directory`;
}

# INSERT INTERESTING TESTS HERE

####################
sub test_from_file {
####################
  my $self=shift;

  my $obj = $MODULE->from_file("$directory/one");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");

  print STDERR "checkCommand is >>", $obj->checkCommand(), "<<\n";
  $self->assert($obj->checkCommand() == 27 ,'checkCommand');

  print STDERR "groupId is >>", $obj->groupId(), "<<\n";
  $self->assert($obj->groupId() == 13254 ,'groupId');

  print STDERR "type is >>", $obj->type(), "<<\n";
  $self->assert($obj->type() eq 'service','type');
}

#####################
sub test_from_query {
#####################
  my $self=shift;

  my %fields = (
    'message'   => 'The rain in Spain stays mainly on the plain',
    'groupName' => 'Karen_Group',
    'clusterId' => 29,
    'state'     => 'WARNING',
    'groupId'   => 11991,
    'probeId'   => 3000,
    'customerId'=> 30 );

  my $query=new CGI;

  while ( my ($key,$value) = each(%fields) ) {
    $query->param($key,$value)
  }

  my $alert=NOCpulse::Notif::Alert->from_query($query);


  foreach (keys(%fields)) {
    $self->assert($alert->{$_} eq $fields{$_}, "test_from_query $_");
  }
  
}

###############################
sub test_create_initial_sends {
###############################
  my $self=shift();
  my $alert = $self->{'alert3'};

  my @sends = $alert->create_initial_sends();
  my $send_count=@sends;

  # 3 for the broadcast group, 1 for the escalate group, 1 for the simulated
  # redirect  = 5
  $self->assert($send_count == 5, "test_create_initial_sends send count");
}

#######################
sub test_destinations {
#######################
  my $self=shift();
  my $alert = $self->{'alert3'};

  my $dests=$alert->destinations;
  my $dest_count=@$dests;

  $self->assert($dest_count == 3, "test_destinations dest count $dest_count");
}

##################
sub test_is_aged {
##################
  my $self=shift;
  my $alert=$self->{'alert3'};

  my $now=time();
  my $many_secs= (10 * 60 * 60);  # ten hours
  my $new_time=$now - $many_secs;
  print "time is: $now (", scalar(localtime($now)), "), new time is $new_time (", scalar(localtime($new_time)), ")\n";
  $alert->time($new_time);

  $self->assert($alert->is_aged($now), "test_is_aged old");
  
  my $some_secs= 10 * 60;  #ten minutes
  $new_time=$now - $some_secs;
  print "time is: $now (", scalar(localtime($now)), "), new time is $new_time (", scalar(localtime($new_time)), ")\n";
  $alert->time($new_time);

  $self->assert(!$alert->is_aged, "test_is_aged not too old");
}

#######################
sub test_is_completed {
#######################
  my $self=shift();
  my $alert = $self->{'alert3'};
  $alert-> create_initial_sends;
  $self->assert($alert->is_completed == 0,"test_is_completed not completed");

  foreach my $send ($alert->sends) {
    $send->is_completed(1);
  }
  foreach my $strat ($alert->strategies) {
    $strat->is_completed(1);
  }

  $self->assert($alert->is_completed == 1,"test_is_completed strat completed");
}

###############
sub test_null {
###############
  my $self=shift();
  my $alert=$self->{'alert'};

  $self->assert(!defined($alert->null),"test_null");
}

############################
sub test_process_redirects {
############################
  my $self=shift;
  my $alert=$self->{'alert'};

  my $customer=NOCpulse::Notif::Customer->new( recid => 1);
  $customer->addRedirect(NOCpulse::Notif::Redirect->new());

  $alert->groupId(undef);
  $alert->email('nobody@nocpulse.com');
  $alert->customerId(1);

  $alert->process_redirects();

  my $size=$alert->originalDestinations_count;
  $self->assert($size == 1, "post redirect ($size)");
}

######################
sub test_printString {
######################
  my $self=shift;
  my $alert=$self->{'alert3'};
  $alert->alert_id(13);
  $alert->ticket_id('woohoo');

  my $string=$alert->printString;
  $self->assert($string =~ /13/,"test_printString (alert_id)");
  $self->assert($string =~ /woohoo/,"test_printString (ticket_id)");
}

#####################
sub test_send_named {
#####################
  my $self = shift;

  my $alert=$self->{'alert2'};
  my $strategy=NOCpulse::Notif::BroadcastStrategy->new_for_method($self->{'internal_dest'},$alert);
  $alert->strategies_push($strategy);

  my @sends = $strategy->sends;

  my $count = 0;
  foreach my $send (@sends) {
    $send->send_id(sprintf("%6.6d", $count));
    $count++;
  }

  $count = 0;
  foreach my $send (@sends) {
    my $name = sprintf("%6.6d", $count);
    my $result = $alert->send_named($name);
    $self->assert($result, "test_send_named result exists $count");
    print $send->send_id, " == ", $result->send_id, "\n";
    $self->assert($result == $send, "test_send_named $count");
  }
}

###############
sub test_show {
###############
  my $self  = shift;
  my $alert = $self->{'alert3'};
  $alert->create_initial_sends;

  my $string = $alert->show;

  foreach my $dest (@{$alert->destinations}) {
    my $s = $dest->printString;
    $self->assert($string =~ /$s/m,"test_show $s");
  }
}

##################
sub test_to_file {
##################
  my $self=shift;
  my $alert=$self->{'alert'};

  my $filename='/tmp/'. "TestAlert.test_to_file.$$.tmp";
  $alert->to_file($filename);

  my $result=NOCpulse::Notif::Alert->from_file($filename);

  foreach (NOCpulse::Notif::Alert::ALL_METHODS) {
    $self->assert($result->$_ eq $alert->$_, "test_to_file ($_)");
  }
}

##############
sub test_ack {
##############
  my $self = shift;
  my $alert = $self->{'alert3'};
  $alert->create_initial_sends;
  my $esc=NOCpulse::Notif::Escalator->new();

  my @sends = $alert->sends;
  $esc->start_sends($alert,@sends);

  my $send=shift(@sends);
  my $send_id=$send->send_id;

  $alert->ack($esc,'ack',$send_id);
  
  $self->assert($send->acknowledgement eq 'ack',"test_ack");
}

################
sub test_sends {
################
  my $self = shift;
  my $alert = $self->{'alert3'};
  $alert->create_initial_sends;

  my @sends = $alert->sends;
  my $size=scalar(@sends);

  $self->assert($size == 7, "test_sends size ($size)");
}

1;
