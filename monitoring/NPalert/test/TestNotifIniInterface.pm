package test::TestNotifIniInterface;

use strict;
use File::Basename;
use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::NotifIniInterface;
use Data::Dumper;

my $MODULE = 'NOCpulse::Notif::NotifIniInterface';

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
  $self->{'blah'} = $MODULE->new();

}

# INSERT INTERESTING TESTS HERE

########################
sub test__convertStart {
########################
  my $self = shift;
  my $if = $self->{'blah'};

  my $string1 = '00:00';
  my $value = $if->_convertStart($string1);
  $self->assert($value == 0, "$string1 ($value)");

  $string1 = '00:01';
  $value = $if->_convertStart($string1);
  $self->assert($value == 60, "$string1 ($value)");

  $string1 = '09:59';
  $value = $if->_convertStart($string1);
  $self->assert($value == 35940, "$string1 ($value)");
}

######################
sub test__convertEnd {
######################
  my $self = shift;
  my $if = $self->{'blah'};

  my $string1 = '00:00';
  my $value = $if->_convertEnd($string1);
  $self->assert($value == 59, "$string1 ($value)");

  $string1 = '00:01';
  $value = $if->_convertEnd($string1);
  $self->assert($value == 119, "$string1 ($value)");

  $string1 = '09:59';
  $value = $if->_convertEnd($string1);
  $self->assert($value == 35999, "$string1 ($value)");
}

sub test_buildContactMethods {
  # See test_everything
}

sub test_buildMessageFormats {
  # See test_everything
}

sub test_buildSchedules {
  # See test_everything
}

sub test_buildCustomers {
  # See test_everything
}

sub test_buildContactGroups {
  # See test_everything
}

sub test_buildRedirects {
  # See test_everything
}

#####################
sub test_everything { 
#####################
  my $self = shift;
  my $if = $self->{'blah'};

  my $schedules = $if->buildSchedules();
  my $formats   = $if->buildMessageFormats();
  my $methods   = $if->buildContactMethods($formats,$schedules);
  my $customers = $if->buildCustomers();
  my $groups    = $if->buildContactGroups($methods,$customers);
  my $redirects = $if->buildRedirects($customers, $groups, $methods);

  my @schedules = values(%$schedules);
  my $schedule  = shift(@schedules);
  $self->assert(qr/NOCpulse::Notif::Schedule/, "$schedule");

  my @formats = values(%$formats);
  my $format  = pop(@formats);
  $self->assert(qr/NOCpulse::Notif::MessageFormat/, "$format");

  my @methods = values(%$methods);
  my $method  = shift(@methods);
  $self->assert(qr/ContactMethod/, "$method");

  my @customers = values(%$customers);
  my $customer  = shift(@customers);
  print &Dumper($customer), "\n";
  $self->assert(qr/NOCpulse::Notif::Customer/, "$customer");

  my @groups = values(%$groups);
  my $group  = shift(@groups);
  $self->assert(qr/NOCpulse::Notif::ContactGroup/, "$group");

  my @array = values(%$redirects);
  my @r = map { @$_ } @array;
  my $redirect = shift(@r);
#  if (defined($redirect)) {
    $self->assert(qr/Redirect/, "$redirect");
#  }
}

1;
