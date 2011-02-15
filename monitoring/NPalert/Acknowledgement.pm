package NOCpulse::Notif::Acknowledgement;

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw (from subject date body filename 
                        ack_result redirect_result
                        _bounce_addressee _destination _duration
                        _is_bounce _is_redirect _operation 
                        _redirect_type _redirect_scope 
                        _send_id _server_id _contents)],
  list          => '_headers';

use Mail::Internet;

use NOCpulse::Notif::NotifMailer;
use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

#Global variables

my $SEND_ID_LEN = 6;
my $MAX_DURATION = 60 * 60 * 24 * 7;  #7 days

my @bounces=('^\s*Returned mail','^\s*Failed mail','^\s*Waiting mail',
    '\s*Undeliverable','\sOut of Office AutoReply', 'Out of the Office',
     'The mailbox is full.');

my @bounce_origins=('mailer-daemon@','postmaster@','admin@airmessage.net');

my @origheaders = qw(From: Subject: Date: Subject:);
my $ohpat = '^' . join("|^", @origheaders);

my @VALID_ACKS = qw (ack nak clear);

################
# CONSTRUCTORS #
################

###############
sub from_file {
###############

  my $class=shift();
  my $filename=shift();

  $Log->dump(9,"class is ", $class, ", filename is $filename\n"); 

  my $ack=$class->new('filename' => $filename);

  # Create a Mail::Internet object from the email file
  $Log->log(9,"opening $filename\n");
  unless (open(FILE,"< $filename")) {
    $Log->log(1,"unable to open '$filename'\n");
    return undef
  }
  $Log->log(9,"creating new Mail::Internet object\n");
  my $msg = new Mail::Internet([<FILE>]);
  $Log->log(9,"closing $filename\n");
  close(FILE) || $Log->log(1,"Unable to close '$filename' $!"); 

  # Parse the mail message's headers for information
  $ack->_contents($msg->as_string);
  $Log->log(9,"parsing header\n");
  my $header=$msg->head();      
  $ack->_headers(@{$header->header});
  $ack->subject($header->get('subject'));
  $ack->body(join('', @{$msg->body()}));
  $ack->from($header->get('from')); 
  $ack->date($header->get('date')); 
  $Log->dump(9,"ack is ",$ack,"\n");
  
  return $ack
}

##################
# ACCESS METHODS #
##################

######################
sub bounce_addressee {
######################
# Using lazy initialization, parse only if this method is ever called
  my ($self,@rest)=@_;
  return $self->_bounce_addressee(@rest) if @rest;
  my $id = $self->_bounce_addressee;

  unless (defined($id)) { 
    #Call is_bounce to do the parsing
    $self->is_bounce;
    $id = $self->_bounce_addressee;
  }

  if ($id) { 
    return $id
  } else {
    return undef
  }
}

#################
sub destination {
#################
  my ($self,@rest)=@_;
  return $self->_destination(@rest) if @rest;
  my $dest = $self->_destination;

  unless (defined($dest)) { 
    #Call is_redirect to do the parsing
    $self->is_redirect;
    $dest = $self->_destination;
  }

  if ($dest) { 
    return $dest
  } else {
    return undef
  }
}

##############
sub duration {
##############
  my ($self,@rest)=@_;
  return $self->_duration(@rest) if @rest;
  my $dur = $self->_duration;

  unless (defined($dur)) { 
    #Call is_redirect to do the parsing
    $self->is_redirect;
    $dur = $self->_duration;
  }

  if ($dur) { 
    return $dur
  } else {
    return undef
  }
}

#########################
sub duration_in_seconds {
#########################
  my $self=shift();
  $_=$self->duration;
  my $value;

  if (/(\d+)m/) {
    $value= $1 * 60;
  } elsif (/(\d+)h/) {
    $value= $1 * 60 * 60;
  } elsif (/(\d+)d/) {
    $value= $1 * 60 * 60 * 24;
  }
  if ($value > $MAX_DURATION) {
    return $MAX_DURATION
  } else {
    return $value
  }
}

###############
sub is_bounce {
###############
# Using lazy initialization, parse only if this method is ever called
  my ($self,@rest)=@_;
  return $self->_is_bounce(@rest) if @rest;
  my $id = $self->_is_bounce;
  return $id if defined($id);

#Determine whether it's a bounced message
  if (( grep { $self->subject =~ /$_/i } @bounces ) || 
           ( grep { $self->from    =~ /$_/i } @bounce_origins )) {
    $Log->log(9,"we're dealing with a bounce\n");
    $self->_is_bounce(1);
        my $addressee = $1;

    # Remove non-printable characters
    $addressee =~ s{([\'\\\x00-\x09\x11-\x1D\x7F-\xFF])}{''}eg;

    $self->_bounce_addressee($addressee);
    $self->_operation('nak');
  } else {
    $self->_is_bounce(0);
    $self->_bounce_addressee(0);
  }
  return $self->_is_bounce;
}

#################
sub is_redirect {
#################
# Using lazy initialization, parse only if this method is ever called
  my ($self,@rest)=@_;
  return $self->_is_redirect(@rest) if @rest;
  my $id = $self->_is_redirect;
  return $id if defined($id);

  my $whole_message=join(" ",$self->subject(),$self->body()); 
  $whole_message =~ s/\n/ /g;
  if ($whole_message =~ /(autoack|metoo|redir|suspend)\s+(host|check)/i) {
    $self->_is_redirect(1);
    $whole_message =~ /(autoack|metoo|redir|suspend)\s+(host|check)\s+(\d+[hmd])(\s+(\S*))?/i;
    $self->_redirect_type(lc($1));
    $self->_redirect_scope(lc($2));
    $self->_duration(lc($3));
    my $dest=$5;
    if ($self->_redirect_type =~ /^(metoo|redir)$/) {
      $self->_destination($dest);
    } 
  } else {
    $self->_is_redirect(0);
    $self->_redirect_type(0);
    $self->_redirect_scope(0);
    $self->_duration(0);
    $self->_destination(0);
  }

  return $self->_is_redirect();
}
###############
sub operation {
###############
# Using lazy initialization, parse only if this method is ever called
  my ($self,@rest)=@_;
  return $self->_operation(@rest) if @rest;
  my $op = $self->_operation;
  return $op if $op;
  return undef if defined ($op);  # i.e. return undef if 0

#Determine whether it's an ack or nack
#This gets wierd.  Since customers don't want to ack or nack explicitly
#in the subject line, we get to play a counting game.   The idea being
#we have 'ACK' and 'NACK' each in our message once.  If a customer acks
#then we'll have two 'ACK' and one 'NACK,' etc.  Ignore quoted lines 
#beginning with >.

  $Log->log(9,"assuming regular ack or nak\n");
  my ($nak_count,$ack_count);

  my $whole_message=join("\n",$self->subject,$self->body); 
  foreach my $line (split(/\n/,$whole_message)) {
    next if $line =~ /^\>/;  #skip quoted lines from previous message
    next unless $line =~ /ac?k/i;

    foreach(split(/\s+/,$line)) {
      #ugly word by word checking
      if (/^nac?k$/ig) {
        $nak_count++;
      } else {
        $ack_count++ if (/^ack$/ig)
      }
    } #/foreach word
  } #/foreach line

  if ($ack_count > $nak_count) {
    $Log->log(3,"ack identified.\n");
    $self->_operation('ack');
    return $self->_operation
  } elsif ($nak_count > $ack_count) {
    $Log->log(3,"nak identified.\n");
    $self->_operation('nak');
    return $self->_operation
  } else {
    $Log->log(3,"ack or nak not determined.  ack_count: $ack_count nak_count $nak_count\n");
    $self->_operation(0);
    return undef
  }
}

###################
sub redirect_type {
###################
  my ($self,@rest)=@_;
  return $self->_redirect_type(@rest) if @rest;
  my $type = $self->_redirect_type;

  unless (defined($type)) { 
    #Call is_redirect to do the parsing
    $self->is_redirect;
    $type = $self->_redirect_type;
  }

  if ($type) { 
    return $type
  } else {
    return undef
  }
}

####################
sub redirect_scope {
####################
  my ($self,@rest)=@_;
  return $self->_redirect_scope(@rest) if @rest;
  my $scope = $self->_redirect_scope;

  unless (defined($scope)) { 
    #Call is_redirect to do the parsing
    $self->is_redirect;
    $scope = $self->_redirect_scope;
  }

  if ($scope) { 
    return $scope
  } else {
    return undef
  }
}

#############
sub send_id {
#############
# Using lazy initialization, parse only if this method is ever called
  my ($self,@rest)=@_;
  return $self->_send_id(@rest) if @rest;
  my $id = $self->_send_id;
  return $id if $id;
  return undef if defined ($id);  # i.e. return undef if 0

  my ($op, $serverid, $sendid, $cooked_op, $bounce);

  #Determine send id, if possible
  my $whole_message=join(" ",$self->subject,$self->body); 
  if ($whole_message =~ /(notification|[Nn][Aa][cc]?[Kk]|[Aa][Cc][Kk])\s+(0\d[A-Za-z0-9]{$SEND_ID_LEN})/g) {
    $sendid = lc($2); 
    #Parse 2-digit notification server number
    $Log->log(3,"parsing sendid >>$sendid<<\n");
    $sendid =~ /^(..)(.*)$/;  
    ($serverid,$sendid)=($1, $2); 
    $serverid =0 + $serverid;
    $self->_server_id($serverid);
    $self->_send_id($sendid);
    $Log->log(3,"serverid: $serverid, sendid: $sendid\n");
  } else {
    $Log->log(3,"no sendid to parse\n");
    $self->_send_id(0);
    $self->_server_id(0);
  }
  return $self->_send_id;
}

###############
sub server_id {
###############
# Using lazy initialization, parse only if this method is ever called
  my ($self,@rest)=@_;
  return $self->_server_id(@rest) if @rest;
  my $id = $self->_server_id;

  unless (defined($id)) { 
    #Call send_id to do the parsing
    $self->send_id;
    $id = $self->_server_id;
  }

  if ($id) { 
    return $id
  } else {
    return undef
  }
}

##################
# ACTION METHODS #
##################

###########
sub reply {
###########
  my ($self,$smtp)=@_;

  if ($self->is_bounce) {
    $Log->log(1,"bounce to ", $self->bounce_addressee, ": ", $self->ack_result, "\n");
    return 
  }
  
  my $msg;

### Assume everything is a redirect for now -- all groups are Broadcast-NoAck

#  if ($self->redirect_result) {
    $msg .= sprintf("'%s %s %s %s': ",$self->redirect_type, $self->redirect_scope, $self->duration, $self->destination); 
    if ($self->redirect_result =~ /Success/) {
      $msg .= "Your notification filter creation was sucessful.\n\n"
    } else {
      $msg .= sprintf("Notification filter creation failed (%s).\n\n",$self->redirect_result)
    }
#  }

### Skip this for now -- all groups are Broadcast-NoAck

#  $Log->log(1,sprintf("[%s] %s by %s \@ %s", $self->send_id, $self->operation, $self->from, $self->date));
#  if ($self->ack_result =~ /Success/) {
#    $Log->log(1," succeeded.");
#  } else {
#    $Log->log(1," failed: ",$self->ack_result,"\n");
#    $msg .= sprintf("'%s %02d%s': ",$self->operation,$self->server_id,$self->send_id);
#    if ($self->operation) {
#      $msg .=sprintf("SendID invalid or not found.\nThis usually happens when the alert has been completed,\ni.e. somebody already acknowledged a send in this\nescalation or the system ran out of escalation destinations\nIn either case, SendID %02d%s is no longer with us.\n\n",$self->server_id, $self->send_id);
#    } else {
#      $msg .= "Ack or nak not clearly specified.  Acknowledgement failed.\n\n" 
#    }
# } 

  return unless $msg;

  my $replybody = $msg;
  $replybody .= "\n\nOriginal message:\n";
  $replybody .=     "-----------------\n";
  $replybody .= join ("",grep { /$ohpat/ } $self->_headers());
  $replybody .= "\n" . $self->body;         

  my $mailer = NOCpulse::Notif::NotifMailer->new('subject' => 'Re: ' . $self->subject,
                                            'body'    => $replybody);
  $mailer->addressees_push($self->from);
  $mailer->send_via($smtp);
}

#########
sub log {
#########
  my ($self,$log)=@_;
  foreach (qw (from subject date body server_id 
               send_id operation bounce_addressee)) {
    $log->log(4,"$_: ",$self->$_(),"\n")
  }
}

########################
sub not_valid_redirect {
########################
  my $self=shift();

  return "Doesn't contain a redirect"  unless $self->is_redirect;

  return "Invalid type"      unless $self->redirect_type  =~ /^(autoack|metoo|redir|suspend)$/;
  return "Invalid scope"     unless $self->redirect_scope =~ /^(host|check)$/;
  return "Invalid duration"  unless $self->duration       =~ /^\d+[mhd]$/;

  if ($self->redirect_type  =~ /(metoo|redir)/) {
    return "Invalid email destination" unless $self->destination =~ /^([a-zA-Z0-9_\-\.\+]+)@(\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.\]|[a-zA-Z0-9\-\.]+)$/;
  }

  return 0
}

###############
sub as_string {
###############
  my $self=shift;
  return $self->_contents;
}

1;

__END__

=head1 NAME

NOCpulse::Notif::Acknowledgement - Response to a NOCpulse notification.

=head1 SYNOPSIS

 # Parses an email acknowledgement from a file, but doesn't apply it to the
 # notification system
 my $ack = NOCpulse::Notification::Acknowledgement->from_file($filename);

=head1 DESCRIPTION

The C<Acknowledgement> object represents a single response to a notification. Its purpose is to
parse an email ack or nak, post it to the notification system and log the results of the post.

The email acknowledgement must have have 'ack' or 'nak' in the subject line, followed by
the send id.  Without this information, the acknowledgement will be considered invalid and
rejected by the system.

Bounced email notifications are also processed by this object.  A bounced notification is
automatically naked when it is applied.

=head1 CLASS METHODS

=over 4

=item from_file ( [$filename] )

Creates a new email acknowldegement from a file.

=item new ( [%args] )

Create a new Acknowledgement with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item ack_result ( [$string] )

Get or set the result of applying this acknowledgement to the notification system.

=item as_string ( )

Returns the original email acknowledgement as a string.

=item body ( [$string] )

Gets or sets the original message body of the email acknowledgement.

=item bounce_addressee ( [$string] )

Gets or sets the email addresss of the sender of a bounced message.

=item date ( [$string] )

Gets or sets the original message date of the email acknowledgement.

=item destination ( [$email_address] )

Gets or sets the destination for a METOO or REDIRECT redirect.

=item duration ( [$string] )

Gets or sets the duration \d+[mhd] (m=minutes,h=hours,d=days) of the redirect.

=item duration_in_seconds ( )

Parse the duration and return its value in seconds.

=item filename ( [$filename] )

Get or set the name of the file containing this alert.

=item from ( [$string] )

Gets or sets the email address of the person sending the acknowledgement.

=item is_bounce ( [0|1] )

Get or set a boolean flag denoting whether this is a bounced message.

=item is_redirect ( [0|1] )

Get or set a boolean flag denoting whether this acknowledgement contains a redirect.

=item log ( [$string] )

Write a line to the acknowledgemnt handler log.

=item operation ( [$string] )

Gets or sets the acknowledgement type, ack or nack.

=item not_valid_redirect ( )

Returns true if the Acknowledgement does not contain a valid redirect.

=item redirect_result ( [$string] )

Get or set the result of applying this redirect via acknowledgement, if exists, to the notification system.

=item redirect_scope ( [('host'|'check')] )

Gets or sets the scope of the redirect.

=item redirect_type ( [('autoack'|'metoo'|'redir'|'suspend')] )

Gets or sets the type of the redirect.

=item reply ( $msg )

Notify the user with the specified message.

=item send_id ( [$number] )

Gets or sets the notification send id parsed from email acknowledgement.

=item server_id ( [$number] )

Gets or sets the notification server id parsed from email acknowledgement.

=item subject ( [$string] )

Gets or sets the original subject of the email acknowledgement.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Escalator>
B<NOCpulse::Notif::FileQueue>
B<notifserver.pl>
B<ack_enqueuer.pl>

=cut
