package NOCpulse::Notif::EscalatorInterface;       

use strict;
use Class::MethodMaker
  new_with_init => 'new',
  new_hash_init => '_hash_init',
  get_set     => [qw(socket_filename error)];

use IO::Socket::UNIX;
use Storable qw(nfreeze thaw);
use NOCpulse::Debug;
use NOCpulse::Notif::EscalatorOperation;

use Data::Dumper;

my $TIMEOUT=30;
my $HEADER_BYTES=8;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


##########
sub init {
##########
  my $self=shift;
  my %args=@_;

  unless (exists($args{socket_filename})) {
    die "Please specify socket filename\n";
  }

  return $self->_hash_init(%args);
}

#############
sub is_okay {
#############
  # Check to make sure the escalator is up and reachable 
  my $self = shift;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'is_okay');

  $self->do_operation($op);

  my $status = $op->results_shift;
  return $status == 1;
}

################
sub next_sends {
################
  my $self = shift;

  ## Doesn't need a lock on the alert file -- just detecting the alert file

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'next_sends');

  $self->do_operation($op);

  my $alert_file = $op->results_shift;
  my @send_ids   = @{$op->results};
  return ($alert_file, @send_ids);
}

####################
sub register_alert {
####################
  # Register the given new alert with the escalator and return the assigned 
  # alert id
  my ($self,$filename) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'register_alert');
  $op->parameters_push($filename);

  $self->do_operation($op);

  my $alert_id = $op->results_shift;
  return $alert_id;
}
  
####################
sub register_sends {
####################
# Register the given new sends with the escalator.
# Return the send ids assigned.

  my ($self,$alert,@sends) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'register_sends');
  $op->parameters_push($alert,@sends);

  $self->do_operation($op);

  my @send_ids = $op->results;
  return @send_ids;
}

##################
sub launch_sends {
##################
# Schedule the given new sends for immediate launch.  

  my ($self,$alert,@send_ids) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'launch_sends');
  $op->parameters_push($alert,@send_ids);

  $self->do_operation($op);

  my @ids = $op->results;
  return @ids;
}

#################
sub start_sends {
#################
# Register the given new sends with the escalator and schedule them 
#for immediate launch.  Return the send ids assigned.

  my ($self,$alert,@sends) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'start_sends');
  $op->parameters_push($alert,@sends);

  $self->do_operation($op);

  my @send_ids = $op->results;
  return @send_ids;
}

#################
sub update_send {
#################
  # Register the given send with the escalator, could be an update 
  #or a new entry
  my ($self, $send) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'update_send');
  $op->parameters_push($send);

  $self->do_operation($op);

  my ($result) = $op->results;
  return $result;
}

################
sub delay_send {
################
  # Place the given send with the at the end of the escalator's work queue
  my ($self, $send_id) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'delay_send');
  $op->parameters_push($send_id);

  $self->do_operation($op);

  my ($result) = $op->results;
  return $result;
}

#########
sub ack {
#########
  # Acknowledge a send
  my ($self, $ack, $send_id) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'ack');
  $op->parameters_push($ack,$send_id);

  $self->do_operation($op);

  my ($result) = $op->results;
  return $result;
}

###########################
sub filename_for_alert_id {
###########################
  # Get the alert filename associated with a given alert id
  my ($self, $alert_id) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => '_alerts');
  $op->parameters_push($alert_id);

  $self->do_operation($op);

  my ($result) = $op->results;
  return $result;
}


##########################
sub filename_for_send_id {
##########################
  # Get the alert filename associated with a given send id
  my ($self, $send_id) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'filename_for_send_id');
  $op->parameters_push($send_id);

  $self->do_operation($op);

  my ($result) = $op->results;
  return $result;
}

####################
sub clear_alert_id {
####################
  # Clear the alert associated with the given alert id
  my ($self, $alert_id) = @_;

  my $op=NOCpulse::Notif::EscalatorOperation->new(
    operation => 'clear_alert_id');
  $op->parameters_push($alert_id);

  $self->do_operation($op);

  my ($result) = $op->results;
  return $result;
}
##################
sub do_operation {
##################
  my ($self,$operation) = @_;

  my $filename=$self->socket_filename;
  die "No socket filename specified" unless $filename;

  my $client = IO::Socket::UNIX->new( Peer    => $filename,
                    Type    => SOCK_STREAM,
                    Timeout   => $TIMEOUT );

  die "Unable to create client $!" unless $client;

  $operation->results_clear;

  # Send it across the pipe
  my $item = nfreeze($operation);
  my $length = length($item);
  my $string = sprintf("%${HEADER_BYTES}.${HEADER_BYTES}i%s",$length, $item);
  print $client $string;

  # Get the reply
  # Check how many bytes to read
  my $bytes;
  read ($client, $bytes, $HEADER_BYTES);
  $bytes = $bytes + 0;
  
  # Read those bytes
  my $answer;
  read ($client, $answer, $bytes);
  
  if ($answer) {
    my $result=thaw($answer);
    unless ($result) {
      die "unable to read result from server: $!";
    }
    $operation->results_clear;
    $operation->results_push($result->results);
    $self->error($operation->error);
  } else {
    die "no result from server: $!";
  }
 
  # and terminate the connection when we're done
  $Log->log(9, "Closing the client\n");
  close ($client);
}

1;

__END__

=head1 NAME

NOCpulse::Notif::EscalatorInterface - An object-based interface to the notification system escalator.

=head1 SYNOPSIS

  # Create an empty interface
  $escalator_if = NOCpulse::Notif::EscalatorInterface->new(
    socket_filename => '/tmp/socketfile');

  # Register a new notification 
  my $alert_id = $escalator_if->register_alert($filename);

  # Schedule a send for immediate launch 
  my $alert = NOCpulse::Notif::Alert->from_file($filename);
  my @sends = $alert->create_initial_sends;
  my $send_id = $escalator_if->start_sends($alert,@sends);

=head1 DESCRIPTION

The C<EscalatorInterface> object provides an interface for communicating with
the notification system's escalator via ipc.

=head1 CLASS METHODS

=over 4

=item new ( )

Create a new interface to the escalator.

=back

=head1 METHODS

=over 4

=item init ( %args )
Initialize this object to a beginning state, using the arguments provided.

=item ack ( ['ack','nak',clear'], $send_id )

Apply the operation, ('ack'|'nak'|'clear'|'expire'), to the send specified by $send_id.

=item clear_alert_id ( $alert_id )

Clear the alert with the given id.

=item delay_send ( $send_id )

Move the send_id specified to the back of the queue.  Usually called when there is an issue with the send.

=item do_operation ( $escalator_operation )

Peform the specified escalator operation.  The $escalator_operation->results will be set with the result of performing the operation.

=item filename_for_alert_id ( $alert_id )

Return the filename of the alert associated with the given alert id.

=item filename_for_send_id ( $send_id )

Return the filename of the alert associated with the given send id.

=item next_sends ( )
Return a list containing the next group of sends, related by alert id, that are queued to be sent.

=item register_alert ( $filename )

Register a new notification with the escalator for babysitting.  The escalator
will return the alert id it assigned as a result of the registration process.

=item socket_filename  [ ( $another_filename ) ] 

Get or set the socket filename to be used to communicate with the escalator.

=item start_sends ( $alert, @sends )

Schedule the sends with the escalator for immediate launch.  The escalator will return the send ids it assigned a result of the scheduling process.

=item update_send ( $send )

Update an existing send with the escalator for babysitting.  

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::EscalatorOperation>
B<notif-escalator>

=cut
