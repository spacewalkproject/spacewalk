package NOCpulse::Notif::Alert;             

use strict;
use Class::MethodMaker
  new_hash_init      =>   'new',
  grouped_fields     =>   [ all_methods => [qw (alert_id checkCommand 
                              clusterDesc clusterId commandLongName current_time
                              customerId debug email fmt_message fmt_subject 
                              groupId groupName hostAddress hostName hostProbeId
                              hoststate mac message notrouble osName 
                              physicalLocationName probeDescription 
                              probeGroupName probeId probeType replyaddr 
                              requires_ack
                              satcluster send_id server_id servicestate snmp 
                              snmpPort state subject ticket_id time type 
                              version) ] 
                           ],
  get_set            =>    [ qw (_is_completed ack_wait )],
  boolean            =>    [ qw (auto_ack)],
  list               =>    [ qw( originalDestinations newDestinations strategies)];


use Storable;
use NOCpulse::Config;
use NOCpulse::Log::Logger;
use NOCpulse::Notif::ContactGroup;
use NOCpulse::Notif::Customer;
use NOCpulse::Notif::EscalateStrategy;
use NOCpulse::Notif::SimpleEmailContactMethod;

my $np_cfg  = new NOCpulse::Config;
my $log_dir = $np_cfg->get('notification','log_dir') . '/ticketlog';

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);
$Log->show_method(0);


use constant AGED_MINS => 240;

## CLASS METHODS

###############
sub from_file {
###############

  my $class=shift();
  my $filename=shift();

  my $alert;
  
  my ($package, $file, $line) = caller;
  eval {
    $alert=retrieve($filename);
  };

  if ($@) {
    warn "Unable to retrieve alert from_file $filename at $package :: $file :: $line $@"
  }

  return $alert;
}

################
sub from_query {
################
  my $class=shift;
  my $query=shift;

  my $instance=$class->new();
  my @methods=$instance->all_methods;

  my @params=$query->all_parameters;
  my $key;
  foreach $key (@params) {
    if (grep { /^$key$/ } @methods) {
      $instance->$key($query->param($key));
    } else {
      $Log->log(3,"Deleting $key\n") if $key;
    }
  }
 
  return $instance;
}

## INSTANCE METHODS

#########
sub ack {
#########
  my ($self,$escalator,$operation,$send_id)=@_;

  my ($send, $strategy) = $self->send_named($send_id);
  
  unless ($send) {
    $@ = "Send $send_id not found for alert " . $self->printString;
    $Log->log(9,"Send $send_id not found for alert ", $self->printString, "\n");
    return 1;
  }

  $send->ack($operation);
  $escalator->update_send($send);

  unless ($strategy) {
    $@ = "Strategy for send $send_id not found for alert " . $self->printString;
    $Log->log(9,"Strategy for send $send_id not found for alert ", $self->printString, "\n");
    return 1;
  }

  $strategy->ack($send, $self, $escalator);
  return 0
}

##########################
sub create_initial_sends {
##########################
  my $self=shift;
  unless ($self->destinations) {
    $Log->log(3,"create_initial_sends: no destinations detected\n");
  }
  my @sends;
  foreach my $dest (@{$self->destinations}) {
    my $strategy=$dest->new_strategy_for_alert($self);
    $self->strategies_push($strategy);
    push(@sends,$strategy->start_sends);
  }
  foreach my $send (@sends) {
    $send->server_id($self->server_id);
    $send->auto_ack($self->auto_ack);
    $send->alert_id($self->alert_id);
  }
  return @sends;
}

##################
sub destinations {
##################
  my $self=shift;
  my @returnval;
  push(@returnval,@{$self->originalDestinations},@{$self->newDestinations});
  return \@returnval;
}

#############
sub is_aged {
#############
  my $self=shift;
  my $time=shift;

  #Note: don't set time=time() here.  There's some odd namespace issue occuring.
  #$self->time is required as a field name from the cgi protocol and must be 
  #conflicting with the standard perl function time();

  my $expired_time=$time - $self->time;
  $Log->log(9, "current time is $time, \$self->time is ", $self->time, ", expired time is: $expired_time\n");
  return $expired_time > (AGED_MINS * 60);  
}

##################
sub is_completed {
##################
  my $self=shift;

  return 1 if ($self->_is_completed);
  my $completed=1;

  foreach (@{$self->strategies}) {
    $completed = $completed && $_->is_completed
  }
  $self->_is_completed($completed);
  return $completed
}

##########
sub null {
##########
  return undef
}

#######################
sub process_redirects {
#######################
  my $self=shift;

  if ($self->groupId) {
    my $group=NOCpulse::Notif::ContactGroup->find_recid($self->groupId);
    if ($group) {
      $self->originalDestinations_push($group);
    } else {
      return("contact group " . $self->groupId . " not found");
    }
  } elsif ($self->email) {
    my $method=NOCpulse::Notif::SimpleEmailContactMethod->new('email' => $self->email);
    $self->originalDestinations_push($method);
  } else {
      return("undefined destination");
  }
  
  my @dest=map { $_->printString } @{$self->destinations};
  $Log->log(1,$self->printString," before redirects: ", join(', ',@dest), "\n");
 
  my $customer=NOCpulse::Notif::Customer->find_recid($self->customerId);

  if ($customer) {
    $customer->redirect($self);
  }  

  @dest=map { $_->printString } @{$self->destinations};
  $Log->log(1,$self->printString, " after redirects: ", join(', ',@dest), "\n");

}

#################
sub printString {
#################
  my $self=shift;
  return "Alert [" . $self->alert_id . "] " . $self->ticket_id . ' ';
}

################
sub send_named {
################
  my ($self, $send_id) = @_;

  my ($send,$strategy);
  my @strategies = $self->strategies;
  
  foreach my $strat (@strategies) {
    $send = $strat->send_named($send_id);
    if ($send) {
      $strategy = $strat;
      last;
    }
  }
  return wantarray ? ($send, $strategy) : $send;
}

###########
sub sends {
###########
  my $self=shift;

  my @sends;
  foreach my $strat (@{$self->strategies}) {
    push(@sends,@{$strat->sends});
  }
  return @sends;
}

##########
sub show {
##########
  my $self=shift;
  my @array;
  push(@array,$self->printString);  
  my @dest_names= map { $_->printString } @{$self->destinations} ;
  push(@array,'destination(s): ' . join(', ',@dest_names));
  push(@array,'completed: ' . ($self->_is_completed ? 'yes' : 'no'));  
   foreach (@{$self->strategies}) {
     push(@array,$_->show);
   }
  return join("\n\t",@array);
}

#############
sub to_file {
#############
  my ($self,$filename)=@_;

  my ($package, $file, $line) = caller;
  eval {
    $self->store($filename);
  };
  if ($@) {
    warn "Can't create '$filename' at $package\:\:$file:$line, $@"
  }
   
}

1;


__END__

=head1 NAME

NOCpulse::Notif::Alert - Alert generated by a monitoring scout.

=head1 SYNOPSIS

 # Parses an alert stored in Storable format from file
 my $alert = NOCpulse::Notification::Alert->from_file($filename);

 # Parses an alert from a CGI query.
 my $alert2 = NOCpulse::Notification::Alert->from_query($query);

 # Create the first wave of sends for an alert.
 my @sends = $alert->create_initial_sends();

=head1 DESCRIPTION

The C<Alert> object represents a single alert generated by a monitoring scout 
that needs to be delivered to the appropriate contact methods and/or groups via the notification system.

=head1 CLASS METHODS

=over 4

=item from_file ( $filename )

Creates a new alert from a file.

=item from_query ( $query )

Create a new alert from information in a cgi query.

=item new ( [%args] )

Create a new alert with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item ack ( $escalator, $operation, $send_id )

Apply the specified acknowledgement this alert, using the escalator.

=item ack_wait ( [$number] )

Get or set the acknowledgement wait time for the current send, i.e. the number of minutes to wait for an acknowledgement to the current send.

=item alert_id ( [$number] )

Gets or sets the alert's identification number, used for tracking and clearing the alert.

=item all_methods ( )

Return a list of all the methods providing encapsulation for data contained in this object.

=item auto_ack ( [$boolean] )

Get or set whether the current send is to be automatically acknowledged when sent.

=item checkCommand ( [$string] )

Get or set the checkCommand field.

=item clusterDesc ( [$string] )

Gets or sets the string describing the satellite cluster that generated the alert.

=item clusterId ( [$number] )

Gets or sets the unique numeric identifier denoting the satellite cluster that generated the alert.

=item commandLongName ( [$string] )

Get or set the commandLongName field.

=item create_initial_sends ( )

Create the first sends to be launched for this alert.  This would include all
broadcast sends and the first wave of any escalations.

=item current_time ( [$timestamp] )

Get or sets the time the alert initially is touched by the notification system.

=item customerId ( [$number] )

Get or sets the unique numeric identifier denoting the customer id of the contact group receiving the alert.

=item debug ( [$level] )

Get or set the numeric value denoting what level of detail should be logged to the log files.

=item destinations ( )

Return a list of destinations for this alert.

=item email ( [$emailAddress] )

Get or set the email address of the recipient of the alert.  This is generally used when a contact group
is not specified.

=item fmt_message ( [$string] )

Get or set the formatted message body of a notification generated from this alert according to some formatting
specification.

=item fmt_subject ( [$string] )

Get or set the formatted subject of a notification generated from this alert according to some formatting
specification.

=item groupId ( [$number] )

Get or set the unique identifier denoting the contact group receiving the alert.

=item groupName ( [$string] )

Get or set the name of contact group receiving the alert.

=item hostAddress ( [$string] )

Get or set the ip address of the host about which the alert is concerned.

=item hostName ( [$string] )

Get or set the name of the host about which the alert is concerned.

=item hostProbeId ( [$number] )

Get or set the unique identifier denoting the id of the host probe which generated this alert.

=item hoststate ( ['UP'|'DOWN'|'UNKNOWN'] )

Get or set the state the host being monitored was in when the alert was generated.

=item is_completed ( ) 

Return true if this alert is considered complete.  All sends have been either sent and expired, cleared, or acknowledged.

=item is_aged ( $timestamp )

Return true if this alert is considered old according to the the given timestamp.

=item mac ( [$mac_address] )

Get or set the mac address of the satellite which generated this alert.

=item message ( [$string] )

Get or set the alert's message, typically a string of output that resulted from running a probe.

=item newDestinations

Return the list of new destinations (contact groups and methods) to which the notification will be delivered as determined by redirects.  (Treat as Class::MethodMaker type list)

=item notrouble

Get or set the notrouble field.

=item null ( [$string] )

Get or set the null field.  Used by parsing logic when a field is passed that doesn't have a corresponding method in this object.

=item originalDestinations

Return the list of destinations (contact groups and methods) to which the notification were originally destined.  Note that certain types of redirects clear out this list.  (Treat as Class::MethodMaker type list)

=item osName ( [$string] )

Get or set the name of the operating system upon which the probe was run.

=item physicalLocationName ( [$string] )

Get or set the physicalLocationName field.

=item printString ( )

Represent this object as a string in a format suitable to present to the user.

=item probeDescription ( [$string] )

Get or set the description of the probe that which was executed and generated this alert.

=item probeGroupName ( [$string] )

Get or set the name of the group to which belongs the probe that which was executed and generated this alert.

=item probeId ( [$number] )

Get or set the unique numeric identifier of the probe that which was executed and generated this alert.

=item probeType ( ['HostProbe','LongLegs','None','ServiceProbe'] )

Get or set the type of probe which was executed and generated this alert.

=item process_redirects ( ) 

Apply all the redirects appropriate to this alert.  This changes the newDestinations and originalDestinations.

=item replyaddr ( [$string] )

Get or set the "from" address used by the notification for email destinations.

=item requires_ack ( [0|1] )

Get or set whether this alert requires an ack.

=item satcluster

Get or set the scout cluster id that generated this alert.

=item show ( )

Return a string describing this object and its component objects, suitable for displaying to an end user.

=item send_id ( [$number] )

Gets or sets the send id of the notification currently being issued from this alert.

=item server_id ( [$number] )

Gets or sets the notification server id of the machine handling this alert.

=item servicestate ( ['OK','CRITICAL','WARNINIG'] )

Get or set the state the service being monitored was in when the alert was generated.

=item set_auto_ack ( )

Set the alert so its notifications are indeed to be automatically acknowledged.

=item send_named ( $send_id ) 

Return the send associated with this alert with the given send id in a scalar context.  In an array context it returns the send and associated strategy object.

=item snmp ( [0|1] )

OBSOLETE.  Now part of SNMPContactMethod.

=item snmpPort [ [$string] )

OBSOLETE.  Now part of SNMPContactMethod.

=item state ( [$string] )

Get or set the overall state of the probe when the alert was generated.

=item strategies ( )

Return the list of strategies created for this alert's final destination.  
(Treat as Class::MethodMaker type list.)

=item subject ( [$string] )

Get or set the subject of an alert, ad-hoc alert only.

=item sends ( )

Return all the sends associated with this alert.

=item ticket_id ( [$string] )

Get or set the unique identifier for this alert.

=item time ( [$timestamp] )

Get or set the time the alert was generated on the satellite.

=item to_file ( $filename )

Store a representation of this object in a file, suitable for later instantiation.

=item type ( ['adhoc'|'host'|'longlegs'|'service'] )

Get or set the type of probe which was executed and generated this alert.

=item version ( [$string] )

Get or set the version field.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-12-15 23:09:26 $

=head1 SEE ALSO

B<enqueue.cgi>
B<notif-launcher>
B<notif-escalator>
B<notifier>

=cut
