package test::TestMessageFormat;

use strict;
use base qw(Test::Unit::TestCase);
use base 'Storable';
use NOCpulse::Notif::MessageFormat;
use NOCpulse::Notif::Alert;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__, 9);

my $MODULE = 'NOCpulse::Notif::MessageFormat';

my $directory = "/tmp/$$";
$ENV{TZ} = 'GMT';

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj  = $MODULE->new();

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");

} ## end sub test_constructor

############
sub set_up {
############
  my $self = shift;

  # This method is called before each test.

  my $alert_contents = <<EOX;
checkCommand=27
clusterDesc=NPops-dev
clusterId=10702
commandLongName=Load
customerId=30
groupId=13254
groupName=Karen-3-group
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

  my @pairs = split('\n', $alert_contents);
  my %alert = map { my ($a, $b) = split(/=/); $a => $b } @pairs;

  $self->{'alert'} = NOCpulse::Notif::Alert->new(%alert);
  $self->{'alert'}->send_id(29);
  $self->{'alert'}->alert_id(13);
  $self->{'format'} = $MODULE->default;
} ## end sub set_up

###############
sub tear_down {
###############
  my $self = shift;

  # Run after each test

  `rm -rf $directory`;
}

# INSERT INTERESTING TESTS HERE

##################
sub test_default {
##################
  my $self = shift;

  my $format = $MODULE->default();

  # Make sure creation succeeded
  $self->assert(defined($format), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$format");

  # Make sure the subject and body are correct
  $self->assert(qr/^..probe state/, $format->subject_format);
  $self->assert(qr/Z\"\]$/,         $format->subject_format);

  $self->assert(qr/^This is Red Hat Command Center/, $format->body_format);

  #  $self->assert(qr/NACK \^\[alert id\]$/,$format->body_format);
} ## end sub test_default

#########################
sub test_format_message {
#########################
  my $self = shift;
  $self->{'format'}->format_message($self->{'alert'});

  $Log->log(9, "subject", $self->{'alert'}->fmt_subject, "\n");
  $Log->log(9, "body",    $self->{'alert'}->fmt_message, "\n");

}

########################
sub test__format_times {
########################
## _GMT
  my $self = shift;

  my $premunge_times = {
                         'timestamp'    => 'time',
                         'current time' => 'current_time'
                       };

  my $zone     = 'GMT';
  my $expected = 'GMT';

  my $alert =
    NOCpulse::Notif::Alert->new(time         => time(),
                                current_time => time());

  my $message = '^[timestamp:"%H:%M %Z"]';

  my $format = $self->{'format'};
  $self->assert($format, "format exists");
  $format->subject_format($message);
  $format->body_format($message);
  $format->format_message($alert, $zone);
  my $value = $alert->fmt_subject();
  print "$value\n";
  $self->assert($value =~ /\:[0-5][0-9] $expected/, "format subject $zone");
  $value = $alert->fmt_message();
  print "$value\n";
  $self->assert($value =~ /\:[0-5][0-9] $expected/, "format message $zone");
} ## end sub test__format_times

############################
sub test__format_times_CST {
############################
  my $self = shift;

  my $premunge_times = {
                         'timestamp'    => 'time',
                         'current time' => 'current_time'
                       };

  my $zone     = 'America/Chicago';
  my $expected = 'CST';

  my $alert =
    NOCpulse::Notif::Alert->new(time         => time(),
                                current_time => time());
  my $message = '^[timestamp:"%H:%M %Z"]';

  my $format = $self->{'format'};
  $self->assert(defined($format), "format exists");
  $format->subject_format($message);
  $format->body_format($message);
  $format->format_message($alert, $zone);
  my $value = $alert->fmt_subject();
  print "$value\n";
  $self->assert($value =~ /\:[0-5][0-9] $expected/, "format subject $zone");
  $value = $alert->fmt_message();
  print "$value\n";
  $self->assert($value =~ /\:[0-5][0-9] $expected/, "format message $zone");
} ## end sub test__format_times_CST

############################
sub test__format_times_PST {
############################
  my $self = shift;

  my $premunge_times = {
                         'timestamp'    => 'time',
                         'current time' => 'current_time'
                       };

  my $zone     = 'America/Los_Angeles';
  my $expected = 'PST';

  my $alert =
    NOCpulse::Notif::Alert->new(time         => time(),
                                current_time => time());

  my $message = '^[timestamp:"%H:%M %Z"]';

  $self->assert(exists($self->{'format'}), "format exists");
  $self->{'format'}->subject_format($message);
  $self->{'format'}->body_format($message);
  $self->{'format'}->format_message($alert, $zone);
  my $value = $alert->fmt_subject();
  $self->assert($value =~ /\:[0-5][0-9] $expected/, "format subject $zone");
  print "$value\n";
  $value = $alert->fmt_message();
  print "$value\n";
  $self->assert($value =~ /\:[0-5][0-9] $expected/, "format message $zone");
} ## end sub test__format_times_PST

########################
sub test_new_with_init {
########################
  my $self = shift;
  my $obj  =
    $MODULE->new(
                 customer_id        => 1,
                 description        => 'test',
                 max_subject_length => 72,
                 subject_format     => '',
                 body_format        => '',
                 reply_format       => ''
                );

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");
} ## end sub test_new_with_init

#########################
sub test_new_with_init2 {
#########################
  my $self = shift;
  my $hash = {
                 customer_id        => 1,
                 description        => 'test',
                 max_subject_length => 72,
                 subject_format     => '',
                 body_format        => '',
                 reply_format       => ''
                };
  my $obj  = $MODULE->new(%$hash);

  # Make sure creation succeeded
  $self->assert(defined($obj), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$obj");
} ## end sub test_new_with_init

1;
