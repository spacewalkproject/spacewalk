package test::TestEscalatorInterface;

use strict;
use base qw(Test::Unit::TestCase);

use NOCpulse::Notif::EscalatorInterface;
use NOCpulse::Notif::EscalatorOperation;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,9);

my $MODULE = 'NOCpulse::Notif::EscalatorInterface';

#my $SOCKET_FILENAME='/tmp/testEscalatorInterface_$$.tmp';
my $SOCKET_FILENAME='/tmp/blah';

######################
sub test_constructor {
######################
  my $self = shift;
  my $obj = $MODULE->new(socket_filename => $SOCKET_FILENAME);

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

    # Create an interface object
    $self->{'item'}=$MODULE->new(socket_filename => $SOCKET_FILENAME);

    # Start a dummy test server to stand in for the escalator
    my $pid;
    if ($pid = fork) {
        # parent here
        # child process pid is available in $pid
        $self->{'child_pid'}=$pid;
        print "Parent here .... child pid is $pid\n";
        sleep(1);
        
    } elsif (defined $pid) { # $pid is zero here if defined
        # child here
        print "Child here....\n";
        exec './scripts/test_server' , $SOCKET_FILENAME || die "Unable to exec test server: $!";

    } else {
        die "Fork error"
   }
}

###############
sub tear_down {
###############
    my $self = shift;
    # This method is called after each test.

    kill('INT',$self->{'child_pid'});
    unlink $SOCKET_FILENAME;
}

#################
sub get_message {
#################
}


# INSERT INTERESTING TESTS HERE



###############
sub test_init {
###############
    my $self=shift;
    my $item=$self->{'item'};

    eval {
        $self->init();
    };

    my $error=$@;

    $self->assert($error =~ /Please specify socket filename/, "test_init (missing socket filename)");
}

#########################
sub test_register_alert {
#########################
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_register_alert (dummy, see test_do_operation)");
}

######################
sub test_update_send {
######################
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_update_send (dummy, see test_do_operation)");
}

######################
sub test_start_sends {
######################
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_start_sends (dummy, see test_do_operation)");
}

#######################
sub test_do_operation {
#######################
    my $self=shift;
    my $item=$self->{'item'};
    my $op=NOCpulse::Notif::EscalatorOperation->new(operation => 'addition');

    my @results=$item->do_operation($op);
    my $result=shift(@results);

    $self->assert($result =~ /result here/,"test_do_operation 1");
    $self->assert($result =~ /addition/,"test_do_operation 2");
}

##############
sub test_ack {
##############
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_ack (dummy, see test_do_operation)");
}

#########################
sub test_clear_alert_id {
#########################
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_clear_alert_id (dummy, see test_do_operation)");
}

#####################
sub test_delay_send {
#####################
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_delay_send (dummy, see test_do_operation)");
}

################################
sub test_filename_for_alert_id {
################################
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_filename_for_alert_id (dummy, see test_do_operation)");
}

###############################
sub test_filename_for_send_id {
###############################
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_filename_for_send_id (dummy, see test_do_operation)");
}

#####################
sub test_next_sends {
#####################
    my $self=shift;
    my $item=$self->{'item'};

    # We don't want to have to launch a full blown escalator for unit testing.
    # Assume that the TestEscalator and TestEscalatorOperation cover all the
    # relevant test cases.
    $self->assert(1, "test_next_sends (dummy, see test_do_operation)");
}

1;
