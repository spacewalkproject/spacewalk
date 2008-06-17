package test::TestMailer;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::Mailer;
use Net::SMTP;

my $MODULE = 'NOCpulse::Notif::Mailer';

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';

my $CONFIG  = NOCpulse::Config->new();
my $MX      = $CONFIG->get('mail', 'mx');
my $TIMEOUT = 30;

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

  $self->{'one'}=$MODULE->new( 'subject' => 'test message one',
                               'body'    => 'This is the body of message one.' );
  push(@{$self->{'one'}->addressees},$MY_INTERNAL_EMAIL);


  $self->{'smtp'}=Net::SMTP->new( $MX,
                                Timeout => $TIMEOUT,
                                Debug   => 0);

  $self->{'faker'}=test::TestMailer::SMTPStub->new;
}

###############
sub tear_down {
###############
  my $self=shift;

  $self->{'smtp'}->reset();
  $self->{'smtp'}->quit();
}

# INSERT INTERESTING TESTS HERE

###########################
sub test_check_addressees {
###########################
  my $self=shift;

  $self->assert(1,"test_check_addressees (no-op)");
}

###################
sub test_send_via {
###################
  my $self=shift;

  my $value=$self->{'one'}->send_via($self->{'smtp'});
  $self->assert(!$value, 'test_send_via');
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

############################
sub test_send_via__failure {
############################
  my $self=shift;
  $self->{'smtp'}->quit;

  my $value=$self->{'one'}->send_via($self->{'smtp'});
  $self->assert($value, 'test_failure');
}

######################
sub test__start_send {
######################
  my $self=shift;
  my $mailer=$self->{'one'};

  $mailer->_start_send;

  my $comments="woohoo";
  print STDERR $comments;

  $mailer->_capture->stop if $mailer->_capture;
  my $output;
  $mailer->_capture->read if $mailer->_capture;

  $self->assert($output eq $comments,"test__start_send") if $mailer->_capture; 
}

####################
sub test__end_send {
####################
  my $self=shift;
  my $mailer=$self->{'one'};

  $mailer->_start_send($self->{'faker'});
  $mailer->_end_send($self->{'faker'});
  $self->assert($self->{'faker'}->_reset, "test__end_send (smtp quit)");
}


package test::TestMailer::SMTPStub;

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
