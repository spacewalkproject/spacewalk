package NOCpulse::Notif::Escalator;             

use strict;
use Class::MethodMaker
  new_with_init => 'new',
  new_hash_init => '_hash_init',
  get_set       => [ qw( alert_id ) ],
  list          => '_work_queue',
  hash          => [ qw( _sends _alerts ) ]; 

use Config::IniFiles;
use Crypt::GeneratePassword qw(chars);
use FileHandle;
use GDBM_File;
use base 'Storable';
use NOCpulse::Config;
use NOCpulse::Notif::Alert;
use NOCpulse::Notif::AlertDB;
use NOCpulse::Notif::AlertFile;
use NOCpulse::Notif::Send;

use Data::Dumper;

my $np_cfg       = new NOCpulse::Config;
my $tmp_dir      = $np_cfg->get('notification','tmp_dir');
my $STATE_FILE   = "$tmp_dir/escalator.state";
my $SEND_GDBM   = "$tmp_dir/sendhistory.gdbm";
my $cfg_dir      = $np_cfg->get('notification','config_dir');
my $cfg_file     = "$cfg_dir/static/notif.ini";
my $notify_cfg   = new Config::IniFiles(-file    => $cfg_file,
                                        -nocase  => 1);

die "tmp_dir undefined $!"    unless $tmp_dir;
die "cfg_dir undefined $!"    unless $cfg_dir;
die "notify_cfg undefined $!" unless $notify_cfg;
die "cfg_file undefined $!" unless (-e $cfg_file);

my $SERVER_ID    = $notify_cfg->val('server','serverid'); # $server_recid is the recid of the notification server


my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);
$Log->show_method(0);

my @SEND_ID_CHARS = (0..9,'b','c','d','f'..'h','j','k','m','n','p'..'t','v'..'x','z');  #no vowels means no offensive words

my $SEND_ID_LEN          = 6;             # Char length of a send id
my $ALERT_ID_LEN         = 5;             # Char length of an alert id
use constant START_ALERT => 1;            # Min alert id to use
use constant END_ALERT   => 999999;       # Max alert id to use before returning to START_ALERT

use constant KEEP_SENDS_FOR_ACK => 6;     # Hours to keep a send for possible acknowledgement 

#Forgive the file handles
$Storable::forgive_me = 1;

#Patch the old probe schema to the new
my %probe_type_map = (
  'host'     => 'host',
  'service'  => 'check',
  'longlegs' => 'url'
);

#Keep sendid history
my %send_history;
tie(%send_history, 'GDBM_File', $SEND_GDBM, O_CREAT|O_RDWR,0644);


################################################################
# IMPORTANT NOTE: Escalator MUST save state after every change #
################################################################

### CLASS METHODS

###############
sub from_file {
###############
  my ($class,$filename)=@_;

  my $string;
  my ($escalator) = Storable::retrieve($filename);

  my $debug=NOCpulse::Log::LogManager->instance->output_handler;
  $Log->log(2,"escalator initialized\n");
  return $escalator;
}

### INSTANCE METHODS

#############
sub is_okay {
#############
  my $self = shift;
  return 1;
}

##########
sub init {
##########
  my ($self,%args)=@_;
 
  $self->alert_id(START_ALERT);
  my $debug=NOCpulse::Log::LogManager->instance->output_handler;
  $self->_hash_init(%args);
  $Log->log(2,"escalator initialized\n");
}

#########
sub ack {
#########
  my ($self,$operation,$send_id) = @_;

  $Log->log(9,"@_\n");

  my $send_info = $self->_sends($send_id);
  unless ($send_info) {
    $Log->log(1,"Ack Error Send [", $send_id, "] Alert [?]: ", 
      "$operation: Send info not found\n");
    return 1;
  }

  my $alert_file = $self->lock_alert_by_id($send_info->alertId);
  unless ($alert_file) {
    $Log->log(1,"Ack Error Send [", $send_id, "] Alert [", $send_info->alertId,
       "] $operation: Alert not found\n");
    return 1;
  }

  my $alert = $alert_file->alert;
  my $send = $alert->send_named($send_id);
  unless ($send) {
    $Log->log(1,"Ack Error Send [", $send_id, "] Alert [?]: ", 
      "$operation: Send not found\n");
    $alert_file->release_lock;
    return 1;
  }

  my $result;
  if ($operation eq 'clear') {
    $alert->_is_completed(1);
  } else { 
    $result = $alert->ack($self,$operation,$send_id);
    $alert_file->close_file;
    $Log->log(5,"remove_send_id($send_id) for ack\n");
    $self->_remove_send_id($send_id);
  }

  $Log->log(1,"Completed ", $send->printString, ": $operation\n");

  if ($alert->is_completed) {
    $self->clear_alert($alert_file);
    $Log->log(1,"Completed ", $alert_file->alert->printString, "\n");
  }
  $self->save_state;
  return 0;
}

###########
sub clear {
###########
  my $self=shift;

  $Log->log(5,"Clearing all sends\n");
  $self->_sends_clear;
  $self->_alerts_clear;
  %send_history = ();
  $self->save_state;
}


#################
sub clear_alert {
#################
  my ($self,$alert_file) = @_;
  $Log->log(9,"\n");
  
  my $alert=$alert_file->alert;
  # clear all the associated sends
  foreach my $send ($alert->sends) {
    $Log->log(5,"remove_send_id(",$send->send_id,") for clear_alert\n");
    $self->_remove_send_id($send->send_id);
  }

  # clear the alert itself
  $self->_remove_alert_id($alert->alert_id);
  $alert->_is_completed(1);

  $alert_file->delete;
  $self->save_state;
  return 0;
}

####################
sub clear_alert_id {
####################
  my ($self, $alert_id) = @_;

  my $alert_file = $self->lock_alert_by_id($alert_id);
  unless ($alert_file) {
    $Log->log(1,"Clear Error Alert [$alert_id]: Alert not found\n");
    return 1;
  }
  my $result = $self->clear_alert($alert_file);
  if ($result) {
    $Log->log(1,"Clear Error Alert [$alert_id]\n");
  } else {
    $Log->log(1,"Completed ", $alert_file->alert->printString, ": clear\n");
  }
  return $result;
}

################
sub delay_send {
################
  my $self = shift;
  my $send_id = shift;

  $self->_work_queue_push($send_id);
  $self->save_state;
  return 1;
}

##############
sub escalate {
##############
  my $self=shift;
  $Log->log(9,"\n");
  my $state_change;
  my $send;
#  while( my ($send_id, $info_ref) = each(%{$self->_sends}) ) {
  foreach my $send_id ($self->_sends_keys) {
    my $info_ref = $self->_sends($send_id);
    $Log->log(5,"checking send_id: $send_id\n");
    if ($info_ref->{'expiration'} && ($info_ref->{'expiration'} <= time())) {
      # the send's ack wait period has expired -- deal with it
      $Log->log(5,"acking (expiring) $send_id\n");
      $self->ack('expired',$send_id);
    }
  }
#  $Log->log(9,"(post) _sends: ", &Dumper($self->_sends),"\n");
}

##########################
sub filename_for_send_id {
##########################
  my ($self,$send_id) = @_;

  my $info_ref=$self->_sends($send_id);
  return undef unless $info_ref;
  my $alert_id=$info_ref->alertId;
  my $filename=$self->_alerts($alert_id);
  return $filename;
}


######################
sub lock_alert_by_id {
######################
  my ($self,$alert_id) = @_;
  $Log->log(9,"\n");
  my $filename = $self->_alerts($alert_id);
  return undef unless $filename;
  my $alert_file =  NOCpulse::Notif::AlertFile->open_file($filename);
  return $alert_file;
}

####################
sub _next_alert_id {
####################
  my ($self) = @_;
  $Log->log(9,"\n");

  my $tmp=$self->alert_id;
  if ($tmp > END_ALERT) {
    $self->alert_id(START_ALERT);
    $tmp=START_ALERT
  }
  $self->alert_id($self->alert_id + 1);
  return $tmp
}

################
sub next_sends {
################
  my $self = shift;
  $Log->log(9,"\n");
  my $ref=$self->_work_queue_shift;
  return () unless $ref;
  my @send_ids = @$ref;
  
  my $send_id = shift(@send_ids);
  if ($send_id) {
    my $sendinfo = $self->_sends($send_id);
    unless ($sendinfo) {
      warn "no send info for send ($send_id)";
      $Log->log(1,"no send info for send ($send_id)\n");
      return ()
    }
    my $alert_id=$sendinfo->alertId;
    unless ($alert_id) {
      warn "no alert id for send ($send_id)\n";
      $Log->log(1,"no alert id for send ($send_id)\n");
      return ()
    }
    my $alert_filename = $self->_alerts($alert_id);
    unless ($alert_filename) {
      $Log->log(1,"no alert file for alert $alert_id ($send_id)\n");
      warn "no alert file for alert $alert_id ($send_id)";
      return () 
    }
    $self->save_state;
    $Log->log(1,"Dispensing sends ", join(", ",$send_id,@send_ids), " $alert_filename\n"); 
    return ($alert_filename,$send_id,@send_ids);
  }
  return ()
}

###################
sub _next_send_id {
###################
  my ($self) = @_;
  $Log->log(9,"\n");

  my $new_id;
  my $found = 1;  #Is this send id already in use?

  do {
    $new_id=&chars($SEND_ID_LEN,$SEND_ID_LEN,\@SEND_ID_CHARS);
    $found=$self->_sends_exists($new_id);
  } while ($found);

  $Log->log(9,"_next_send_id is $new_id\n");
  return $new_id
}

####################
sub register_alert {
####################
  my ($self, $filename) = @_;
  my $alert_id=$self->_next_alert_id;
  $alert_id=sprintf("%0${ALERT_ID_LEN}i",$alert_id);
  $self->_alerts($alert_id,$filename);
  $self->save_state;
  $Log->log(1,"Registered Alert [$alert_id] $filename\n");
  return $alert_id;
}

####################
sub _register_send {
####################
  my ($self, $send,$alert) = @_;
  $Log->log(9,"\n");

  # Create information to be stored in the send data store
  unless ($alert) {
    die "alert not found for send " . $send->send_id . " " . &Dumper($send);
  }
  my $info=$send->as_send_info($alert);
  $self->_sends($send->send_id => $info);
  $send_history{$send->send_id}=$info->store_string;
  $Log->log(1,"Registered ", $send->printString, "\n");

  $self->save_state;
}

#####################
sub _remove_send_id {
#####################
  my ($self,$send_id) = @_;
  $Log->log(9,"$send_id\n");
  $self->_sends_delete($send_id);
}

######################
sub _remove_alert_id {
######################
  my ($self,$alert_id) = @_;
  $Log->log(9,"$alert_id\n");
  $self->_alerts_delete($alert_id);
}

################
sub save_state {
################
  my $self=shift;
  $Log->log(9,"\n");

  my $new_state_file="$STATE_FILE.$$";
  $self->store($new_state_file);
  rename($new_state_file,$STATE_FILE);
}

###############
sub shut_down {
###############
  my $self=shift;
  $Log->log(9,"\n");
  $self->save_state;
}

####################
sub register_sends {
####################
  my ($self,$alert,@sends) = @_;
  $Log->log(9,"\n");
  $Log->log(1,"Registering sends for ", $alert->printString, "send count = ", scalar(@sends), "\n");
  my @send_ids;
  foreach my $send (@sends) {
    $send->send_id($self->_next_send_id);
    $self->_register_send($send,$alert);
    $send->scheduled_time(time());
    push (@send_ids,$send->send_id);
    $Log->log(1,"Registered ", $send->printString, "\n");
  }
  $self->save_state;
  return @send_ids;
}

##################
sub launch_sends {
##################
  my ($self,$alert,@send_ids) = @_;
  $Log->log(9,"\n");
  $Log->log(1,"Queuing sends for ", $alert->printString, "send count = ", scalar(@send_ids), "\n");
  $self->_work_queue_push(\@send_ids);
  $self->save_state;
  return @send_ids;
}

#################
sub start_sends {
#################
  my ($self,$alert,@sends) = @_;
  $Log->log(9,"\n");
  my @send_ids = $self->register_sends($alert,@sends);
  $self->launch_sends($alert,@send_ids);
  return @send_ids;
}

#################
sub update_send {
#################
  my ($self,$send)=@_;
  $Log->log(9,$send->send_id, "\n");
  my $send_id=$send->send_id;
  die "No send id" unless $send_id;
  my $info=$self->_sends($send_id);
  if ($info) {
    $send->update_send_info($info);
    $self->_sends($send_id,$info);
  } else {
    # Can't find it -- create a new one
    die "Registering $send_id instead of updating";
    $self->_register_send($send);
  }
  $Log->log(1,"Updated ", $send->printString, "\n");
  return 1;
}

#######################
sub weed_send_history {
#######################
  my $self=shift();
  $Log->log(9,"\n");
  my $current_time=time();
  my $expired_time=$current_time - (60* 60 * KEEP_SENDS_FOR_ACK); 
    $Log->log(5,"expired time: $expired_time\n");
  my @expired_list;

  foreach(values(%send_history)) {
     $Log->log(5,"$_\n");
     my $info=NOCpulse::Notif::SendInfo->from_string($_);
      $Log->log(5,"checking ", $info->send_id, ":" , $info->infoTime, "\n");
     if ($info->infoTime < $expired_time) {
       push(@expired_list, $info->send_id)
     }
  }
  foreach(@expired_list) {
    $Log->log(5,"deleting $_\n");
    delete($send_history{$_});
  }
}

1;

__END__

=head1 NAME

NOCpulse::Notif::Escalator - The central dispatcher for the notification system.

=head1 SYNOPSIS

  # Create a new escalator
  $escalator=NOCpulse::Notif::Escalator->new();

  # Create an escalator using a state file left by a previous Escalator instance.
  $escalator=NOCpulse::Notif::Escalator->from_file($filename);

  # Do any escalations for outstanding sends
  $escalator->escalate();

  # Save state and shutdown the escalator
  $escalator->shutdown();

=head1 DESCRIPTION

The C<Escalator> object is responsible for launching all alerts and sends in the notification system.  It tracks sends and does escalations.  It processes send acknowledgements and handles requests for status and clearing sends and alerts.

=head1 CLASS METHODS

=over 4

=item from_file ( $filename )

Create an escalator using a state file left by a previous escalator instance.

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item ack ( $operation, $send_id )

Apply the operation, 'ack' | 'nak' |  'clear' |  'expire', to the send specified by I<$send_id>.

=item alert_id ( $number )

Get or set the number issued to the next alert to be started.

=item clear ( )

Clear all in progress sends and alerts.

=item clear_alert ( $alert_filename )

Clears the alert specified by I<$alert_filename> and all its sends from the system without allowing them to complete.

=item clear_alert_id ( $alert_id )

Clears the alert specified by I<$alert_id> and all its sends from the system without allowing them to complete.

=item delay_send ( $send_id )

Move the send_id specified to the back of the queue.  Usually called when there is an issue with the send.

=item escalate ( )

Do any escalations for outstanding sends:  Check to see if any sends have reached beyond their ack wait period and if so, launch the next send in the escalation chain if applicable.

=item filename_for_send_id ( $send_id )

Return the filename of the alert associated with the given send id.

=item init ( %args )

Initialize this object to a beginning state, using the arguments provided.

=item is_okay ( )

Returns 1.  Used to test IPC.

=item lock_alert_by_id ( $alert_id ) 

Lock the file associated with the given alert id for writing and return that alet file as a B<NOCpulse::Notif::AlertFile> object.

=item next_sends ( ) 

Return a list containing the next group of sends, related by alert id, that are queued to be sent.

=item register_alert ( $filename )

Register the alert represented by the given filename for tending.

=item save_state ( )

Write the current state of all outstanding work, sends, and alerts to disk, in case of system failure or shutdown.

=item shut_down ( )

Prepare for program shutdown, complete in progress jobs and save state.

=item start_sends ( $alert, @sends ) 

Schedule the specified sends for immediate launch.

=item update_send ( $send )

Update the given send's current state with the escalator for tending.


=item weed_send_history (  )

Delete any old sends no longer necessary for email ack redirects.


=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Acknowledgement>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::AlertDB>
B<NOCpulse::Notif::Request>
B<NOCpulse::Notif::Send>
B<NOCpulse::Notif::Strategy>
B<notifserver.pl>

=cut
