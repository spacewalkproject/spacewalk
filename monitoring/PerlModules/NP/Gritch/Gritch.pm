######################################
package NOCpulse::Gritch;
######################################

use vars qw($VERSION);
$VERSION = 1.27;

use strict;
use NOCpulse::Config;
use NOCpulse::Debug;
use GDBM_File;
use Sys::Hostname;
use LWP::UserAgent;
use URI::Escape;
use Mail::Send;
use Mail::Mailer;

# Class variables
$NOCpulse::Gritch::USE_SENDMAIL = 0;
my $MAX_TIE_TRIES = 5;
my $MODE          = 0644;
my $BADCHARS      = '^-_a-zA-Z0-9';



##########################################################
# Accessor methods
#
sub clusterdesc    { shift->_elem('clusterdesc',    @_); }
sub clusterid      { shift->_elem('clusterid',      @_); }
sub countinterval  { shift->_elem('countinterval',  @_); }
sub dbfile         { shift->_elem('dbfile',         @_); }
sub dbmode         { shift->_elem('dbmode',         @_); }
sub db             { shift->_elem('db',             @_); }
sub debug          { shift->_elem('debug',          @_); }
sub destination    { shift->_elem('destination',    @_); }
sub mac            { shift->_elem('mac',            @_); }
sub mx             { shift->_elem('mx',             @_); }
sub netsaintid     { shift->_elem('clusterid',      @_); } # cruft
sub queue          { shift->_elem('queue',          @_); }
sub recipient      { shift->_elem('recipient',      @_); }
sub timeinterval   { shift->_elem('timeinterval',   @_); }

#########
sub new {
#########
  my $class  = shift;
  my $dbfile = shift;
  my $dbmode = shift || $MODE;
  my $self   = {};

  bless($self, $class);

  # Set DB file
  $self->dbfile($dbfile);

  # Set default hard-coded values
  $self->dbmode($dbmode);

  # Set default config values
  my $cfg = new NOCpulse::Config;
  $self->timeinterval(  $cfg->get('gritch', 'timeInterval')  );
  $self->countinterval( $cfg->get('gritch', 'countInterval') );
  $self->mx(            $cfg->get('gritch', 'targetMX')      );
  $self->recipient(     $cfg->get('gritch', 'targetEmail')   );
  $self->destination(   $cfg->get('gritch', 'targetDest')    );
  $self->queue(         $cfg->get('gritch', 'targetQueue')   );

  # Fetch the netsaint ID if it exists
  my $clid = 0;
  my $cdesc;
  eval {
     require NOCpulse::SatCluster;
     my $cluster = NOCpulse::SatCluster->newInitialized($cfg);
     $clid = $cluster->get_id();
     $cdesc = $cluster->get_description();
  };
  $self->clusterid($clid);
  $self->clusterdesc($cdesc);

  # Set the MAC address (for fallback ID if cluster ID isn't available)
  $self->mac($self->get_mac());

  # Create debug object
  my $debug = new NOCpulse::Debug;
  $self->debug($debug->addstream(LEVEL=>0, AUTOFLUSH=>1));

  return $self;
}


##############
sub setDebug {
##############
  my $self = shift;
  $self->debug->level(shift);
}



############
sub dprint {
############
  my $self = shift;
  $self->debug->dprint(@_);
}



############
sub gritch {
############
  my $self     = shift;
  my $subject  = shift;
  my $message  = join("", @_);
  $message .= "\n" unless ($message =~ /\n$/);

  $self->dprint(1, "Gritching re: '$subject' at ", scalar(localtime(time)), "\n");

  $self->dprint(2, "\tTying DB file\n");
  $self->open_db();

  my($lasttime, $count);
  if ($self->tied) {

    ($lasttime, $count) = $self->get_last($subject);
    $self->dprint(2, "\tLast time is $lasttime (", 
                     scalar(localtime($lasttime)), "); count is $count\n");

  } else {

    $self->dprint(2, "\tFailed to access the DB\n");
    # Oops!  Failed to access the database.  Append the error message
    # and send.
    $message .= "<<Gritch error:  unable to open DB: $@>>";
    $lasttime = time - $self->timeinterval;

  }

  my $its_time = 0;
  my $interval = time - $lasttime;
  my $ti       = $self->timeinterval;
  my $ci       = $self->countinterval;
  $self->dprint(2, "\tSend message? (Time interval $ti, count interval $ci)\n");

  if ($interval >= $ti) {

    $self->dprint(2, "\t\tYES: Last message $interval seconds ago (>$ti)\n");
    $its_time = 1;

  } elsif ($count >= $ci) {

    $self->dprint(2, "\t\tYES: $count messages accrued (>$ci)\n");
    $its_time = 1;

  } else {

    $self->dprint(2, "\t\tNO: only $interval seconds passed and ",
                     "$count messages accrued\n");

  }

  if ($its_time) {

    my $postscript;
    # Add the hostname and caller to the message:  walk up the call stack ...
    my $i; for ($i = 0;  caller($i); $i++) {};

    # .... and then get the immediate caller
    my ($pkg, $file, $line, $sub) = caller(--$i);
    $postscript = "Sent by $file " . ($i ? "$sub() " : "") . "line $line";

    my $hostname = hostname;
    $postscript .= " on host $hostname";

    if ($self->clusterid()) {

      $postscript .= 
        sprintf(" (sat %s, \"%s\").", $self->clusterid,  $self->clusterdesc);

    } elsif ($self->mac) {

      # No cluster ID -- use MAC address instead
      $postscript .= " (MAC " . $self->mac . ").";

    }

    if ($count && $message !~ /Gritch error/) {

      $postscript .= "\n   $count of these messages were filtered since " .
                   scalar(gmtime($lasttime)) . " GMT";
    }

    $self->dprint(2, "\tPostscript:\n<< $postscript >>\n");
    $message .= "\n<< $postscript >>\n";

    my $rv;
    if (ref($self->recipient) eq 'NOCpulse::NotificationQueue') {
      $self->dprint(1, "Enqueueing message to ", $self->destination, "\n");
      $rv = $self->enqueue($subject, $message);

    } elsif (ref($self->recipient) =~ /^NOCpulse::Debug::Stream/) {

      $self->dprint(1, "Printing message to debug object\n");
      $self->recipient($self->recipient->fh);
      $rv = $self->sendmail($subject, $message);

    } else {

      $self->dprint(1, "Sending message to ", $self->recipient, "\n");
      $rv = $self->sendmail($subject, $message);

    }

    if ($rv) {
      $self->dprint(1, "Send succeeded, clearing stats\n");
      $self->clear_last($subject);
    } else {
      $self->dprint(1, "Send FAILED: $@\n");
      $self->dprint(1, "Not clearing stats\n");
    }

  } 

  $self->increment_count($subject);
  $self->close_db();

}


#############
sub open_db {
#############
  my $self     = shift;
  my %db;
  my $tries = 0;
  my $maxtries = $MAX_TIE_TRIES;

  my $filename = $self->dbfile();
  my $oserror;

  while (! tie(%db, 'GDBM_File', $filename, &GDBM_WRCREAT, $self->dbmode())) {
    $oserror = $!;
    $self->dprint(3, "\t\tTie failed: $oserror\n");
    last unless ($oserror =~ /Resource temporarily unavailable/);
    last if ($tries++ >= $maxtries);
    sleep(1);
  }

  $self->dprint(2, "\tDB access was ", tied(%db) ? "" : "NOT ", "successful\n");

  if (tied(%db)) {
    $self->db(\%db);
    return 1;
  } else {
    $@ = "$oserror";
    return undef;
  }

}

##############
sub get_last {
##############
  my $self    = shift;
  my $subject = shift;
  my $db      = $self->db;

  return($db->{"LAST:$subject"}||0, $db->{"COUNT:$subject"}||0);
}



################
sub clear_last {
################
  my $self    = shift;
  my $subject = shift;
  my $db      = $self->db;

  if ($self->tied) {
    $db->{"LAST:$subject"}  = time;
    $db->{"COUNT:$subject"} = 0;
  }
}

#####################
sub increment_count {
#####################
  my $self    = shift;
  my $subject = shift;
  my $db      = $self->db;

  if ($self->tied) {
    $db->{"COUNT:$subject"} = $db->{"COUNT:$subject"} + 1;
  }
}


##############
sub close_db {
##############
  my $self = shift;

  untie(%{$self->db}) if ($self->tied);
}


##########
sub tied {
##########
  my $self = shift;
  my $db   = $self->db || {};

  return tied(%{$db});
}


#############
sub DESTROY {
#############
  my $self = shift;
  $self->close_db();
}


#############
sub enqueue {
#############
  my $self     = shift;
  my $subject  = shift;
  my $message  = join("", @_);

  my $nq       = $self->recipient;
  my $queue    = $self->queue;
  my $dest     = $self->destination;
  my $clid     = $self->clusterid;
  my $cdesc    = $self->clusterdesc;
  my ($cid, $did, $destname) = split(/_/, $dest, 3);

  eval
  {
    require NOCpulse::Notification;

    my $notification = NOCpulse::Notification->newInitialized();

    $notification->type('adhoc');
    $notification->time(time());
    $notification->groupId($did);
    $notification->groupName($destname);
    $notification->clusterId($clid);
    $notification->clusterDesc($cdesc);
    $notification->customerId($cid);
    $notification->subject($subject);
    $notification->message($message);
    
    $nq->enqueue($notification);
  };
  if ($@) {
	die("Attempt to enqueue failed \n\nError:\n$@\n\nProbable illogic in system configuration");
  }

  return 1
}




##############
sub sendmail {
##############
  my $self     = shift;
  my $subject  = shift;
  my $message  = join("", @_);
  my $recip    = $self->recipient;
  my $mx       = $self->mx;

  if (ref($recip)) {
    # Recipient is not a scalar -- must be a filehandle
    print $recip "Subject: $subject\n";
    print $recip "Body:    $message\n";

  } else {
    if (! $NOCpulse::Gritch::USE_SENDMAIL ) {
    	# Gritch now sends mail via HTTPS to the SMON layer.  $mx is the
    	# URL of the HTTPS MX.
    	my $ua = new LWP::UserAgent;
	
    	my $req = new HTTP::Request(POST => $mx);
	
    	my @content;
    	push(@content, 
          	sprintf("to=%s",      uri_escape($recip,   $BADCHARS)),
          	sprintf("subject=%s", uri_escape($subject, $BADCHARS)),
          	sprintf("body=%s",    uri_escape($message, $BADCHARS)),
		);
	
    	$req->content(join('&', @content));
	
    	my $res = $ua->request($req);
	
    	unless ($res->is_success) {
      	$@ = join(' ', $res->code, $res->message);
      	return undef;
    	}
   } else {
	# Use sendmail
	my $sendmail = get_sendmail();
	if (Mail::Mailer::is_exe('sendmail')) {
           my $msg = Mail::Send->new(Subject => $subject, To => $recip, From => $self->recipient);
           my $fh = $msg->open('sendmail');
           print $fh $message;
           $fh->close or $err= "couldn't send whole message: $!";
	} else {
           # Couldn't find sendmail -- fall back to /bin/mail
           $subject =~ tr/'//d;
           open(MAIL, "|/bin/mail -s '$subject' $recip");
           print MAIL "$message\n";
           close(MAIL);
	}
   }
  }

  return 1;

}


#############
sub get_mac {
#############

  my $ifconfig = `/sbin/ifconfig eth0`;
  if ($ifconfig =~ /HWaddr\s+(\S+)/) {
    return $1;
  } else {
    return undef;
  }

}







# Accessor implementation (stolen from LWP::MemberMixin
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

__END__

=pod

=head1 NAME

NOCpulse::Gritch - Throttled email notification for satellites

=head1 SYNOPSIS

  use NOCpulse::Gritch;

  my $soapbox = new NOCpulse::Gritch("/var/adm/gripes.db");

  # ... Something Bad Happens

  $soapbox->gritch($subject, $body);


=head1 DESCRIPTION

This module provides the ability to send time- and count-throttled
email.  

The module uses three parameters to send notifications:  a I<recipient>,
a I<time interval>, and a I<count interval>.  The first instance of a
message is sent immediately, but subsequent instances of the same message
are filtered until (1) the configured time interval passes, or (2) the
number of filtered messages reaches the configured count interval.
(The $subject is used to determine whether a message is "the same";
differences in the body are ignored.)


=head1 SYNTAX

The constructor takes a single argument, the name of a database
file to use for keeping track of message counts and the last
send time.  (The database will be created if it doesn't exist.)

Gritch takes its default configuration parameters from /etc/NOCpulse.ini.
The defaults can be overridden with the following methods:

=over

=item $soapbox->countinterval($count);

Sets the count interval.

=item $soapbox->timeinterval($time);

Sets the time interval.

=item $soapbox->recipient($recipient);

Sets the email recipient.  $recipient may be an email address,
a comma-separated list of email addresses, or an open filehandle.





=head1 ESOTERICA

To select a debug level, use $soapbox->setDebug($level).   You can print
your own debugging statements to the Gritch object's debug stream by using

  $soapbox->dprint($level, $message); 
  
If you want more control, $soapbox->debug() gives you direct access to
the NOCpulse::Debug object.

To inspect the database, use:

  my($lasttime, $count) = $self->get_last($subject);

Use clear_last() and increment_count() to poke the database.


=cut
