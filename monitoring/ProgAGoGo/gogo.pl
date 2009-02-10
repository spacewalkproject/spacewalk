#!/usr/bin/perl

use strict;
use Getopt::Long;
use IPC::Open3;
use NOCpulse::Debug;
use NOCpulse::Gritch;
use NOCpulse::Config;
use NOCpulse::SetID;
use Symbol qw(gensym);

# A machine may or may not have the queue system running
# (satellites are currently the only thing that does)
#
my $haveQueues= 0;
eval('use NOCpulse::NotificationQueue');
$haveQueues = !($@);

##################
# Global variables
#
my $PIDDIR   = "/var/run";
my $GR_DBDIR = "/var/lib/nocpulse";
unless (-w $GR_DBDIR) {
  $GR_DBDIR = $ENV{HOME};
}
my $GR_COUNT = 1000; # Notify every 1000 errors ...
my $GR_TIME  = 600;  # ... or every 10 minutes
my $HBSTAT   = "Couldn't stat heartbeat file";
my $HBSTALE  = "Stale heartbeat";
my $THROTTLE_COUNT_INC_THRESH = 60; # seconds a program must have run
				# in order to get it's throttle counter
				# reset.
my $THROTTLE_KICKIN_COUNT=10; # If throttleCount is modulus of this,
my $THROTTLE_SLEEP_TIME=60; # we sleep for this amount of time.



my($user, $command, $fname, $options, @options);
my($notify, $grtchdir, $sendmail, $help, $debug, $kill, $check);
my($hbfile);
my $hbfreq  = 300;  # Expect heartbeat every 5 minutes (default)
my $hbcheck = 60;   # Check heartbeat every minute (default)



# Get command-line options
&GetOptions(
  "user=s"     => \$user,
  "command=s"  => \$command,
  "options=s"  => \$options,
  "fname=s"    => \$fname,
  "notify=s"   => \$notify,
  "grtchdir=s" => \$grtchdir,
  "hbfile=s"   => \$hbfile,
  "hbfreq=i"   => \$hbfreq,
  "hbcheck=i"  => \$hbcheck,
  "kill+"      => \$kill,
  "check+"     => \$check,
  "sendmail+"  => \$sendmail,
  "help+"      => \$help,
  "debug+"     => \$debug,
);

# Use sendmail if the user says so or if we don't have
# the queueing system.
$sendmail = ($sendmail || (! $haveQueues));
$NOCpulse::Gritch::USE_SENDMAIL=$sendmail;



# Take commands and args as command-line switches or @ARGV
if (! defined($command)) {
  $command = shift;
}

if (defined($options)) {
  @options = split(/\s+/, $options);
} else {
  @options = @ARGV;
}


if ($help or ! defined($command)) {
  print <<EOH;
 
  Usage:  gogo.pl [<gogo opts>] -- <command> [<command opts>]
     or:  gogo.pl [<gogo opts>] --command=<command> [--options='<command opts>']
  Options:
    --user=<username>    - effective user (loginid or uid)
    --hbfile=<filename>  - heartbeat file
    --hbfreq=<secs>      - expected heartbeat frequency in seconds
    --hbcheck=<secs>     - check for heartbeat every <secs> seconds
    --grtchdir=<dirname> - directory for gritch database (default /var/lib/nocpulse or \$HOME)
    --notify=<email>     - email address (default NOC via notification system)
    --sendmail		 - use sendmail when sending to the --notify address
    --fname=<fname>      - use <fname> as the daemon name
    --check              - check whether daemon is running
    --kill               - kill running daemon
    --debug              - enable debugging output
    --help               - print this message

EOH
  exit;
}


# Unless an fname is explicitly supplied, the daemon name ($fname)
# is the basename of the daemon command
unless (defined($fname)) {
  $fname = $command;
  $fname =~ s,^.*/,,;
}

my $pidfile = "$PIDDIR/$fname.pid";



if ($kill) {

  # Requested kill -- kill the running daemon and exit.
  my $pid = &pid($pidfile);
  if (defined($pid) && &check_running($pid)) {

    print "killing $fname\n";
    &slaughter($pid);

  } else {

    print "$fname is not running\n";

  }
  unlink($pidfile);
  exit 0;

} elsif ($check) {

  # Requested check -- verify that the daemon is running
  my $pid = &pid($pidfile);
  if (defined($pid) && &check_running($pid)) {

    # Yup -- it's running
    print "$fname is running (pid $pid)\n" if ($debug);
    exit 0;

  } else {

    # Nope -- it's not.
    print "$fname is not running\n" if ($debug);
    unlink($pidfile);
    exit 1;

  }

}





# Daemon start requested

# Make sure the daemon isn't already running ...
my $testpid = &pid($pidfile);
if (defined($testpid) && &check_running($testpid)) {

  print "$fname is already running (pid $testpid)\n";
  exit(1);

}




# ... set up a Gritch object to complain when the child dies ...

# (Find an appropriate directory for the gritch database)
unless ($grtchdir) {
  $grtchdir=$GR_DBDIR
}
my $gritchdb = "$grtchdir/.gritch-$fname.db";
my $soapbox = new NOCpulse::Gritch($gritchdb);
$soapbox->countinterval($GR_COUNT);
$soapbox->timeinterval($GR_TIME);
if ( $notify ) {
  $soapbox->recipient($notify);
} else {
  if (! $sendmail ) {
  	$soapbox->recipient(NOCpulse::NotificationQueue->new( Config => NOCpulse::Config->new(), Gritcher => $soapbox));
  }
}

# (For debugging)
$soapbox->setDebug($debug) if ($debug);
$soapbox->debug->prefix("GOGO: ");



my $respawn = 0;
my $throttleCount = 0;
my $startTime = 0;
my $timeRunning = 0;
my $status  = 0;
my($subject, $err);


# Need to daemonize so gogo.pl can be called in the foreground
# and only returns when the PID file has been wired up.
# Which means:
#   - Fork (initiator / nanny)
#   - Initiator writes to PIDfile
#     * On failure, initiator kills nanny and exits
#     * On success, initiator exits
# The nanny will then fork again (nanny / daemon)

if (my $nannypid = fork()) {
  # I am the initiator.  Write the nanny PID into the PIDfile
  if (&pid($pidfile, $nannypid)) {
    # Write successful!  Initiator is done.
    exit 0;
  } else {
    # Failed to write PID file.  Kill nanny and exit.
    my $errno = "$!";
    &slaughter($nannypid);
    die "Couldn't write PID file $pidfile: $errno\n";
  }
} elsif (! defined($nannypid)) {
  die "Couldn't fork: $!\n";
}

# ... else, I am the nanny.


# Set up the signal handlers for nice clean exits ...
$SIG{'INT'}   = \&sigRelay;
$SIG{'TERM'}  = \&sigRelay;


# Go, man, go!
my $pid;
while (1) {

  $soapbox->gritch($subject, $err) if ($respawn);

  $soapbox->dprint(1, "Spawning $command\n");

  if ($pid = fork()) {
    $startTime = time();

    # Set up the heartbeat check if one was requested
    if (defined($hbfile)) {
      $SIG{'ALRM'} = \&ticker;
      alarm($hbcheck);
    }

    # And we wait.
    eval { 
      wait;
      alarm(0);
    };

    # What happened?
    if ($@ =~ /^$HBSTALE/) {

      # Stale heartbeat -- kill the child, violently if necessary
      $soapbox->dprint(1, "Stale heartbeat file -- killing child\n");
      &slaughter($pid);  # Kill the child
      $subject = "$fname exited -- stale heartbeat";
      $err     = "$fname has stale heartbeat file -- respawning\n";

    } elsif ($@ =~ /^$HBSTAT/) {

      # Missing heartbeat -- kill the child, violently if necessary
      $soapbox->dprint(1, "Missing heartbeat file -- killing child\n");
      &slaughter($pid);  # Kill the child
      $subject = "$fname exited -- no heartbeat";
      $err     = $@;

    } else {

      $status  = $? >> 8;
      $subject = "$fname exited";
      $err     = "$fname (PID $pid) exited with $status status -- respawning\n";
      $soapbox->dprint(1, $err);

    }

    $respawn++;
    $timeRunning = time() - $startTime;
    if ($timeRunning < $THROTTLE_COUNT_INC_THRESH) {
  	$soapbox->dprint(1, "Run time too short, incrementing throttleCount\n");
    	$throttleCount++;
	if (! ($throttleCount % $THROTTLE_KICKIN_COUNT)) {
		$soapbox->dprint(1,"Throttling for $THROTTLE_SLEEP_TIME seconds - throttle count is $throttleCount\n");
    		sleep($THROTTLE_SLEEP_TIME);  # Throttle
	} else {
    		sleep(1);  # Don't kill the box with restarts
	}
    } else {
	$soapbox->dprint(1,"Resetting throttle count\n");
        $throttleCount = 0;
    	sleep(1);  # Don't kill the box with restarts
    }


  } else {

    # This is the child
    if (defined($user)) {
      &set_userinfo($user);
    }
    $| = 1;
    $SIG{'PIPE'} = sub {die("Couldn't exec $command: $!") };
    local *PROCESS_OUT;
    my $pid = open3(gensym, \*PROCESS_OUT, \*PROCESS_OUT, $command, @options);
    while (<PROCESS_OUT>) {
      print NOCpulse::Debug::Stream->timestamp, " $_";
    }
    waitpid($pid, 0);
    exit;
  }

}


##############################################################################
###############################  Subroutines  ################################
##############################################################################

sub sigRelay {
  my($sig) = @_;
  $soapbox->dprint(1, "Sending $sig to child $pid\n");
  kill($sig,$pid);
  unlink($pidfile);
  exit 0;
}


sub check_heartbeat {
  my($file, $freq) = @_;

  # Check heartbeat
  $soapbox->dprint(1, "Checking heartbeat file $file\n");

  my $mtime = (stat($file))[9];
  if (! defined($mtime)) {
    die "$HBSTAT $file: $!\n";
  }

  my $age  = time - $mtime;

  if ($age > $freq) {
    $soapbox->dprint(1, "\tStale heartbeat: $age seconds old\n");
    die $HBSTALE;
  }

  $soapbox->dprint(1, "\tLast heartbeat $age seconds ago\n");

}


sub ticker {
  &check_heartbeat($hbfile, $hbfreq);
  alarm($hbcheck);
}


sub slaughter {
  my($pid) = @_;

  # Kill kill kill
  kill 'TERM', $pid;
  sleep 1;
  kill 'KILL', $pid;

  # Reap reap reap
  waitpid($pid, 0);

}


sub pid {
  my($pidfile, $pid) = @_;

  if (defined($pid)) {

    # Write the PID
    open(PIDFILE,">$pidfile") or return undef;
    print PIDFILE $pid;
    close(PIDFILE);

    return 1;

  } else {

    # Read the PID
    open(PIDFILE, $pidfile);
    chomp(my $pid = <PIDFILE>);
    close(PIDFILE);

    return $pid;

  }

}


sub check_running {
  my $pid = shift;

  if (kill(0, $pid)) {
    return 1;
  } else {
    return 0;
  }
}


sub set_userinfo {
  my $username = shift;
  NOCpulse::SetID->new( user => $username )->su(permanent => 1);
}
