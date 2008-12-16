#!/usr/bin/perl
#
# Example command lines:
#
#  * Host probe:
#     ./enqueue.cgi checkCommand=2 clusterDesc=lab-20 Development Scout clusterId=36
#                       groupId=13053 groupName=NPops_contact_group hostAddress=192.168.0.61
#                       hostName=nexus hostProbeId=22681 mac=00:D0:B7:A9:C7:DE message=booga 
#                       probeDescription=booga probeId=22685 probeType=HostProbe
#                       state=WARNING time=1024617577 type=host
#
#  * Service probe:
#     ./enqueue.cgi checkCommand=230 clusterDesc=NPops-dev clusterId=10702
#                       commandLongName=Process Counts by State customerId=30
#                       groupId=13053 groupName=NPops_contact_group hostAddress=192.168.0.61
#                       hostName=nexus hostProbeId=22681 mac=00:D0:B7:A9:C7:DE message=booga 
#                       probeDescription=booga probeId=22685 probeType=ServiceProbe
#                       state=UNKNOWN time=1024617314 type=service
#  *  LongLegs probe:
#     ./enqueue.cgi checkCommand=2 clusterDesc=lab-20 Development Scout clusterId=36
#                       commandLongName=LongLegs customerId=11
#                       groupId=11414 groupName=Test-Email2_GRP
#                       mac=00:D0:B7:A9:C7:DE message=booga 
#                       probeDescription=booga probeId=16002 probeType=LongLegs
#                       time=1024617577 type=longlegs
#
#  * Ad-hoc alert:
#     ./enqueue.cgi customerId=1 groupId=742 groupName=dfaraldo_email subject=boo 
#                       message=booga time=1024621918 type=adhoc
#
# Interpretation for snmp alerts:
#   groupName     => SNMP

use strict;
use CGI qw/-unique_headers/;
use URI;
use Storable;
use Date::Parse;
use Time::Local;
use NOCpulse::Config;
use NOCpulse::Debug;
use Config::IniFiles;
use NOCpulse::Notif::Alert;

umask(022);

####################
# Global variables #
####################

use vars qw/$debuglevel $output $query $restart $stdout $QUEUE_DIR 
            $NEW_QUEUE_DIR $TICKETCOUNT $SERVER_ID $SERVER_IP/;


##############################################################################
#                               Main Program                                 #
##############################################################################
{    


#Server specific configuration

my $np_cfg       = new NOCpulse::Config;
my $cfg_file     = $np_cfg->get('notification','config_dir') . '/static/notif.ini';
my $notify_cfg   = new Config::IniFiles(-file    => $cfg_file,
                                        -nocase  => 1); 

$SERVER_ID    = $notify_cfg->val('server','serverid'); # $server_recid is the recid of the notification server 
                                                       #  in the "notifservers" DB table
$SERVER_IP    = $notify_cfg->val('server','serverip');

#Common configuration

my $MAX_AGE_IN_HOURS = 24;

my $CFG           = new NOCpulse::Config;             # Config object

my $TEST_URL      = "notifserver-test.cgi";           # URL for the test CGI

my $ENQUEUE_LOG   = $CFG->get('notification', 'enqueue_log'); # File for recording enqueued alerts   
$QUEUE_DIR        = $CFG->get('notification', 'alert_queue_dir'); # Dir for queuing alerts 
$NEW_QUEUE_DIR    = "$QUEUE_DIR/.new";                


$query   = new CGI;             # Basic query object
$restart = new CGI($query);     # Copy of original for creating restart URL

$restart->param('notrouble' => 1); # Don't create a trouble-ticket on a restart
$restart->param('debug'     => 9); # Set high to watch the restart in detail


# If no form input was submitted, bounce the user to the test CGI.
unless ($query->param()) {
  print $query->redirect($TEST_URL);
  exit 0;
}

# Start setting up the output object (added to later)
$output = new NOCpulse::Debug;

# - Standard output
$debuglevel    = $query->param('debug') || 9;

$stdout        = $output->addstream(LEVEL => $debuglevel,
                                    CONTEXT => 'stdout');

# - enqueue event log -- only summary lines
my $enqueuelog = $output->addstream(LEVEL  => 1,
                                    FILE   => $ENQUEUE_LOG,
                                    APPEND => 1);
die ("Failed to create enqueuelog $!") unless $enqueuelog;
$enqueuelog->timestamps(1);

$output->dprint(1,$query->self_url(),"\n");

# Parse the input, if invalid reject the alert
my $alert = &ParseInput($query);
unless(defined($alert)) {

  # Somebody submitted a bad request -- need to open up a trouble ticket.
  my $summary = "Bad request submitted to notification system\n";
  my $details = $@;
  my $restarturl = &restarturl($restart);

  $enqueuelog->dprint(1,"DROPPED $summary: $details, $restarturl\n");

  # Drop this alert (no need to retry)
  chomp($summary); $summary .= ":\n";
  &DropAlert($query, $stdout, $summary, $details);

}

# Check to make sure the alert is not ancient
# If so, drop the alert!
 
   
if (($alert->current_time - $alert->time) > ($MAX_AGE_IN_HOURS * 3600)) {
    my $msg = "Dropping old alert\n";
    &DropAlert($query, $stdout, $msg);
}

# Make sure the satellite id is not zero for non-gritch.  If it is, drop it and notify the satellite.

if (($alert->clusterId == 0) && ($alert->{'type'} ne 'adhoc')) {
  &DropAlert($query, $stdout, "Cluster id is zero\n");
}

$TICKETCOUNT++;
my $result=&Enqueue_Alert($alert);
if ($result) {
  my $str = "\nUnable to enqueue alert $result\n";
  &RejectAlert($query,$stdout,$str)
}

$stdout->dprint(0, $query->header(), 
                   $query->start_html("Alert"), "\n");

# Now that the headers are printed, we can make sure web output is readable
if (exists($ENV{'QUERY_STRING'})) {
  $stdout->prefix("<PRE>");
  $stdout->suffix("</PRE>\n");
}

my $str=&DumpQuery($query) . "Processed Input:\n" . &DumpAlert($alert);
$output->dprint(2,$str);
$output->dprint(1,"Alert ", $alert->ticket_id , " Enqueued\n");

$output->dprint(1, "Thank you for playing the Notification Game!\n");

$stdout->prefix('');
$stdout->suffix('');
$stdout->dprint(0,$query->end_html(), "\n");
$stdout->close();
$enqueuelog->close();


}  ### END MAIN

##############################################################################
#                                Subroutines                                 #
##############################################################################

################
sub ParseInput {
################
  my $query = shift;
 
  my @params=$query->all_parameters;
  my $alert = NOCpulse::Notif::Alert->from_query($query);
  
  my @required=qw(customerId);

  # Messages come in two flavors:  message to a
  # group and message to an email address.
  if ($alert->email) {
    push(@required,qw(email)); 
  } else {
    push(@required,qw(groupId groupName)); 
  }

  if ($alert->snmp == 1)
  {
    push(@required, qw (snmpPort))
  }
  
  if ($alert->type eq 'adhoc') {
    push(@required,'message');
  } else {
    push(@required, qw(clusterDesc clusterId mac state type));
  }
  if ($alert->type eq 'host') {
    push(@required, qw(hostAddress hostName hostProbeId));
  } elsif ($alert->type eq 'service') {
    push(@required, qw(hostAddress hostName hostProbeId message probeDescription probeId));
  } elsif ($alert->type eq 'longlegs') {
    push(@required, qw(message probeDescription probeId mac));
  }

  # Additional parameters that may be passed:
  #   notrouble    - Don't create a trouble ticket if alert submission fails
  #   ticketid     - Pre-generated ticket ID (don't create a new one)
  #   debug        - debug level

  my $param;
  # Options Processing:

  #  - First, make sure all required parameters were provided
  $@='';
  foreach $param (@required) {
    if (! defined($alert->{$param})) {
      $@ .= "Parameter '$param' is required for type " .  $alert->type . " but was not provided\n";
    }
  }
  return undef if (length($@));

  # Don't forget to decode URL-encoding applied by the queueing client.
  my $message=$alert->message;
  $message =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
  $alert->message($message);
  my $subject=$alert->subject;
  $subject =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
  $alert->subject($subject);

  # Stamp the current time on the alert
  my $t=time;
  $alert->current_time($t);

  # Add timestamp if missing
  unless ($alert->time) {
    $alert->time($t);
  }

  # Check for 'WARN' as opposed to 'WARNING', Bug 4100
  if ($alert->state eq 'WARN') {
    $alert->state('WARNING')
  }

  return $alert;
}


###############
sub DumpQuery {
###############
  my($query) = @_;
  my($param, $str);

  $str = "Raw input:\n";
  foreach $param (sort $query->param()) {
    $str .= "\t${param}=" . $query->param($param) . "\n";
  }
  $str .= "\n";

  return $str;
}

###############
sub DumpAlert {
###############
  my($alert) = @_;

  my $str = "";
  foreach my $param (NOCpulse::Notif::Alert::ALL_METHODS) {
       $str .= "$param=$alert->{$param}\n";
  }
  return $str;
}

#################
sub RejectAlert {
#################
  my $query = shift;
  my $stdout = shift;
  my $message = join('', @_);

  # Reject the client with a 503 Service Unavailable status
  $stdout->dprint(0, $query->header(-status=>503),
      $query->start_html('Error'),
      $query->h2('Alert rejected'),
      $query->strong($message),
      $query->end_html(), "\n");
  $stdout->close();
  $output->delstream($stdout);
  $output->dprint(0, "Rejecting alert: $message\n");

  exit 0;
}

###############
sub DropAlert {
###############
  my $query   = shift;
  my $stdout = shift;
  my $message = join('', @_);

  # Return a 202 Accepted status to the client (no retry is necessary)
  $message =~ s/\n/<BR>\n/g;
  $stdout->dprint(0, $query->header(-status=>202), "\n",
      $query->start_html('Alert Dropped'), "\n",
      $query->h2('Alert Dropped'), "\n",
      "<FONT COLOR=red>$message</FONT>", 
      $query->end_html(), "\n");
  $stdout->close();

  $output->dprint(0, "Dropping alert: $message\n");

  exit 0;
}


################
sub restarturl {
################
    my($query) = @_;

    # Return my URL but with host portion (nominally the virtual)
    # replaced with the (real) IP address of this host.
    my $url = new URI($query->self_url());
    $url->host($SERVER_IP);

    return $url;
}

###################
sub Enqueue_Alert {
###################
  my ($alert)=@_;
  $alert->ticket_id(&NewTicketId()) unless $alert->ticket_id;
  my $t=$alert->ticket_id;
  return "ticket id undefined\n" unless $t;
  my ($new_file)="$NEW_QUEUE_DIR/$t" =~ /(.*)/;
  my ($file)="$QUEUE_DIR/$t" =~ /(.*)/;
  $alert->store($new_file);
  rename($new_file,$file) || return "Unable to rename $new_file\n";
  return 0;
}

#################
sub NewTicketId {
#################
  my $ticket = sprintf ( "%02d_%010d_%06d_%03d", $SERVER_ID, time(), $$, $TICKETCOUNT );
  return $ticket;
}
