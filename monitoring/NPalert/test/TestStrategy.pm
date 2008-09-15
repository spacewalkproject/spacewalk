package test::TestStrategy;

use strict;

use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::Strategy;
use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Notif::Alert;

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::Strategy';

my $MY_INTERNAL_EMAIL = 'kja@redhat.com';
my $MY_EXTERNAL_EMAIL = 'nerkren@yahoo.com';
my $NOWHERE_EMAIL     = 'nobody@nocpulse.com';

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

  $self->{'internal_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_INTERNAL_EMAIL);
  $self->{'external_dest'}=NOCpulse::Notif::EmailContactMethod->new( 'email' => $MY_EXTERNAL_EMAIL);
  $self->{'nowhere_dest'} =NOCpulse::Notif::EmailContactMethod->new( 'email' => $NOWHERE_EMAIL);

  $self->{'group'}=NOCpulse::Notif::ContactGroup->new();

  $self->{'group'}->add_destination($self->{'internal_dest'});
  $self->{'group'}->add_destination($self->{'external_dest'});
  $self->{'group'}->add_destination($self->{'nowhere_dest'});

  $self->{'alert'}=NOCpulse::Notif::Alert->new( 'fmt_subject' => 'test subject one',
                                                'fmt_message' => 'this is the body of test one',
                                                'send_id'     => '0101');

  $self->{'strategy'}=$MODULE->new_for_group($self->{'group'},$self->{'alert'});
  $self->{'strategy'}->ack_method('AllAck');
}

# INSERT INTERESTING TESTS HERE

########################
sub test_new_for_group {
########################
  my $self=shift;
  
  my $alert=$self->{'alert'};
  my $strategy=$MODULE->new_for_group($self->{'group'},$alert);
  my @list=map { $_->destination } @{$strategy->sends};
  my $item=shift(@list);
  $self->assert($item->email eq $MY_INTERNAL_EMAIL,"internal email (1)");
  $item=shift(@list);
  $self->assert($item->email eq $MY_EXTERNAL_EMAIL,"external email (1)");
  $item=shift(@list);
  $self->assert($item->email eq $NOWHERE_EMAIL,"nowhere email (1)");
} 

#########################
sub test_new_for_method {
#########################
  my $self=shift;

  my $alert=$self->{'alert'};
  my $strategy=$MODULE->new_for_method($self->{'internal_dest'},$alert);

  # Make sure creation succeeded
  $self->assert(defined($strategy), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  $self->assert(qr/$MODULE/, "$strategy");
        
  my $send=$strategy->sends_pop;

  # Make sure send creation succeeded
  $self->assert(defined($strategy), "Couldn't create $MODULE object: $@");

  # Make sure we got the right type of object
  my $SEND_MODULE="NOCpulse::Notif::Send";
  $self->assert(qr/$SEND_MODULE/, "$send");
  $Log->dump(9,"send: ",$send,"\n");
}

################
sub test_clear {
################
  my $self=shift;
  my $strategy = $self->{'strategy'};

  $strategy->clear;
  
  $self->assert($strategy->is_completed,"strategy is_completed");

  my $count=0;
  foreach my $send (@{$strategy->sends}) {
    $count++;
    $self->assert($send->is_completed,"send $count is_completed");
  }

  print "count is $count\n";
}

#####################
sub test_send_named {
#####################
  my $self=shift;
  my $strategy = $self->{'strategy'};

  my $count=0;
  foreach my $send (@{$strategy->sends}) {
    $count++;
    $send->send_id($count);
  }

  print "count is $count\n";

  for (my $i=1; $i <= $count; $i++) {
    my $result = $strategy->send_named($i);
    $self->assert(defined($result),"send $i exists");
    $self->assert($result->send_id == $i,"send $i name");
  }
}

###############
sub test_show {
###############
  my $self=shift;
  my $strategy = $self->{'strategy'};


  my $count=1;
  foreach my $send (@{$strategy->sends}) {
    $send->send_id($count++);
  }

  my $string = $strategy->show;

  my $p_string = $strategy->printString;
  $self->assert($string =~ /$p_string/m, "strategy show");

  foreach my $send (@{$strategy->sends}) {
    $p_string = $send->send_id;
    $self->assert($string =~ /Send \[$p_string\]/m, "send show");
  }
}

######################
sub test_printString {
######################
  my $self = shift;
  my $strategy = $self->{'strategy'};

  my $string = $strategy->printString;

  $self->assert($string =~ /AllAck/, "test_printString");
}

1;
