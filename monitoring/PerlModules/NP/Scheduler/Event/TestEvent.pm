package NOCpulse::Scheduler::Event::TestEvent;

use NOCpulse::Scheduler::Event;
use NOCpulse::Scheduler::Message;
use Data::Dumper;

@ISA=qw(NOCpulse::Scheduler::Event);


##########################################################
# Accessor methods
#
sub peers      { shift->_elem('peers',      @_); }
sub sleeptime  { shift->_elem('sleeptime',  @_); }

sub run
{
  my $self = shift();
  my $id = $self->id;

  # Produce some output
  my $timestamp = localtime(time);
  print "Event $id executing at $timestamp\n";

  # Show my messages
  my $message;
  my $i = 0;
  print "Messages:\n";
  foreach $message (@{$self->read_in_msgs()}) {
    $i++;
    printf "\t%3d.  %s\n", $i, $message->content;
  }
  
  # Send a message to my peers
  my $peerref = $self->peers;
  if ($peerref) {
    my $msg = new NOCpulse::Scheduler::Message(
	       $peerref, 
	       "Message from $id at $timestamp");
    $self->write_out_msgs([$msg]);
  }

  # Set next execution time
  $self->time_to_execute(time + $self->execution_interval);

  my $sleep = $self->sleeptime;
  if ($sleep) {
    print "Sleeping $sleep seconds\n";
    sleep $sleep;
  }

  print "End of event $id execution\n";

  return $self;
}


# Accessor implementation (stolen from LWP::MemberMixin,
# by Martijn Koster and Gisle Aas)
###########
sub _elem {
###########
  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}

1;

