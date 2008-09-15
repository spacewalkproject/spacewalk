package test::TestSendInfo;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::SendInfo;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::SendInfo';

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
}


# INSERT INTERESTING TESTS HERE

######################
sub test_from_string {
######################
  my $self = shift;

  my $send_info = $MODULE->new ( 
    alertId => 55555,
    contactId => 29,
    customerId => 13,
    expiration => time(),
    hostProbeId => 28,
    probeId => 71,
    sendId => 'xxxyyy',
    infoTime => time());

  my $string = $send_info->store_string;

  my $result = $MODULE->from_string($string);

  $self->assert($send_info->alertId     == $result->alertId,      "alert id");
  $self->assert($send_info->contactId   == $result->contactId,    "contact id");
  $self->assert($send_info->customerId  == $result->customerId,   "customer id");
  $self->assert($send_info->expiration  == $result->expiration,   "expiration");
  $self->assert($send_info->hostProbeId == $result->hostProbeId,  "host probe id");
  $self->assert($send_info->probeId     == $result->probeId,      "probe id");
  $self->assert($send_info->sendId      eq $result->sendId,       "send id");
  $self->assert($send_info->infoTime    eq $result->infoTime,     "info time");
}

#######################
sub test_store_string {
#######################
  my $self = shift;

  my $send_info = $MODULE->new ( 
    alertId => 55555,
    contactId => 29,
    customerId => 13,
    expiration => time(),
    hostProbeId => 28,
    probeId => 71,
    sendId => 'xxxyyy',
    infoTime => time());

  my $string = $send_info->store_string;

  my $result = $MODULE->from_string($string);

  $self->assert($send_info->alertId     == $result->alertId,      "alert id");
  $self->assert($send_info->contactId   == $result->contactId,    "contact id");
  $self->assert($send_info->customerId  == $result->customerId,   "customer id");
  $self->assert($send_info->expiration  == $result->expiration,   "expiration");
  $self->assert($send_info->hostProbeId == $result->hostProbeId,  "host probe id");
  $self->assert($send_info->probeId     == $result->probeId,      "probe id");
  $self->assert($send_info->sendId      eq $result->sendId,       "send id");
  $self->assert($send_info->infoTime    eq $result->infoTime,     "info time");
}

1;
