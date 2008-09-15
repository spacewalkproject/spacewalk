package test::TestNotifMailer;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::NotifMailer;
use NOCpulse::Log::Logger;
use Data::Dumper;

my $MODULE = 'NOCpulse::Notif::NotifMailer';

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';

my $CONFIG  = NOCpulse::Config->new();
my $MX      = $CONFIG->get('mail', 'mx');
my $TIMEOUT = 30;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

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

  $self->{'one'}=$MODULE->new( #'replyaddr' => 'kja@redhat.com',
                               'subject' => 'test message one',
                               'body'    => 'This is the body of message one.' );
  push(@{$self->{'one'}->addressees},$MY_INTERNAL_EMAIL);

  $self->{'smtp'}=test::TestNotifMailer::SMTPStub->new();
}

###############
sub tear_down {
###############
  my $self=shift;

  $self->{'smtp'}->reset();
  $self->{'smtp'}->quit();
}

# INSERT INTERESTING TESTS HERE

###################
sub test_send_via {
###################
  my $self=shift;

  my $value=$self->{'one'}->send_via($self->{'smtp'});
  $self->assert(!$value, 'test_send_via');
}

####################
sub test_replyaddr {
####################
  my $self=shift;

  my $value=$self->{'one'}->replyaddr;
  print "replyaddr is ($value)\n";
  $self->assert($value, "test_replyaddr");
}

#####################
sub test_precedence {
#####################
  my $self=shift;

  my $value=$self->{'one'}->precedence;
  $self->assert($value, "test_precedence");
}

###################
sub test_priority {
###################
  my $self=shift;

  my $value=$self->{'one'}->priority;
  $self->assert($value, "test_priority");
}

##########################
sub test_send_via__twice {
##########################
  my $self=shift;

  my $value=$self->{'one'}->send_via($self->{'smtp'});
  $self->assert(!$value, 'test_send_via_twice (1)');
  $value=$self->{'one'}->send_via($self->{'smtp'});
  $self->assert(!$value, 'test_send_via_twice (2)');
}

###########################
sub test_check_addressees {
###########################
  my $self=shift;
  my $mailer=$self->{'one'};
  $mailer->addressees_clear();
  $mailer->addressees_push('nobody@nocpulse.com','kja@redhat.com','bitbucket@nocpulse.com');

  $mailer->check_addressees();
  my $size=$mailer->addressees;

  $self->assert($mailer->addressees_count == 1,"test_check_addressees");
}


package test::TestNotifMailer::SMTPStub;

use Class::MethodMaker
  get_set       => '_reset',
  new_hash_init => 'new';

sub code { }
sub data      { return 1 }
sub datasend  { return 1 }
sub dataend   { return 1 }
sub mail      { return 1 }
sub quit      { return 1 }
sub reset     { my $self=shift; $self->_reset(1) }
sub recipient { return 1 }

1;
