package test::TestSNMPContactMethod;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::SNMPContactMethod;
use NOCpulse::Notif::Alert;

my $MODULE = 'NOCpulse::Notif::SNMPContactMethod';

my $CONFIG=NOCpulse::Config->new;

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

  $self->{'one'}=$MODULE->new(  'ip'    => '172.31.0.20', 
                                'port'  => 8081);
  $self->{'alert'}=NOCpulse::Notif::Alert->new( 
  'checkCommand' => '27',
  'clusterDesc' => 'NPops-dev',
  'clusterId' => '36',
  'commandLongName' => 'Load',
  'customerId' => '30',
  'groupId' => '13254',
  'groupName' => 'Karen-3-group',
  'hostAddress' => '172.16.0.106',
  'hostName' => 'Velma.stage',
  'hostProbeId' => '22775',
  'mac' => '00:D0:B7:A9:C7:DE',
  'message' => 'The nocpulsed daemon is not responding: ssh_exchange_identification: Connection closed by remote host. Please make sure the daemon is running and the host is accessible from the satellite. Command was: /usr/bin/ssh -l nocpulse -p 4545 -i /home/nocpulse/.ssh/nocpulse-identity -o BatchMode=yes 172.16.0.10 6 /bin/sh -s',
  'osName' => 'Linux System',
  'physicalLocationName' => 'for testing - don\'t delete me',
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
  $self->{'db'}=NOCpulse::Notif::AlertDB->new;
  $self->{'db'}->connect;
}

###############
sub tear_down {
###############
  my $self = shift;
  $self->{'db'}->disconnect;
}

# INSERT INTERESTING TESTS HERE

##################
sub test_deliver {
##################
  my $self=shift;

  my $value=$self->{'one'}->deliver($self->{'alert'},$self->{'db'},undef);
  $self->assert($value == 0, "test_deliver");
}
