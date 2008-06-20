#!/usr/bin/perl

use strict;
use NOCpulse::Config;
use NOCpulse::Debug;
use NOCpulse::NotificationQueue;
use NOCpulse::NPRecords;
use NOCpulse::ProcessPool;
use NOCpulse::Scheduler::Event::TimeoutEvent;
use NOCpulse::Scheduler::Event::StatePushEvent;
use NOCpulse::Scheduler;
use NOCpulse::Scheduler::Statistics;
use NOCpulse::Module;
use NOCpulse::Gritch;
use NOCpulse::Probe::Config::Command;
use Getopt::Long;
use Storable;

use NOCpulse::Utils::XML;
use FreezeThaw qw(thaw);


# Debugging options
my $debuglevel = 0;
my $loglevel   = 1;
&GetOptions('debug=i'    => \$debuglevel,
            'loglevel=i' => \$loglevel);


# Global variables
my $CONCURRENCY   = 5;
my $MAXLIFE       = 300;
my $DINTERVAL     = 300;  # Default interval for probes that can't 
                          # re-schedule themselves.
my $OUTPUTDIR     = '/opt/home/nocpulse/var/rw/NPkernel.out';  # Output directory

# Set up for debugging and log output
my $cfg           = new NOCpulse::Config;
my $debug         = new NOCpulse::Debug();
my $errlog        = new NOCpulse::Debug();

NOCpulse::Scheduler::Statistics::setDebug($debug);

# For printing to STDERR, which is redirected to kernel-error.log
my $errstream = $errlog->addstream(FILE => \*STDERR);
$errstream->timestamps(1);
$errstream->autoflush(1);

# Print to STDOUT if --debug
$debug->addstream(LEVEL => $debuglevel) if ($debuglevel);

# Always add the log file
my $logfile = $cfg->get('satellite', 'schedulerLogFile');
my $log     = $debug->addstream(LEVEL  => $loglevel,
				FILE   => $logfile,
				APPEND => 1);

# Is there a better way to report this?
$errlog->print("Problem opening kernel log: $@\n") if ($@);

if ($log) {
   $log->timestamps(1);
}

# Set up for gritching about probe code errors. These should go out
# as notifications, so we need to instantiate the notification queue first.
my $queueGritcher = new NOCpulse::Gritch($cfg->get('queues', 'gritchdb'));
my $notificationQueue = NotificationQueue->new(Config => $cfg, Gritcher => $queueGritcher);
# Now do the event gritcher.
my $eventGritcher = new NOCpulse::Gritch($cfg->get('satellite', 'gritchdb'));
$eventGritcher->timeinterval(24 * 60 * 60);    # Once every 24 hours
$eventGritcher->recipient($notificationQueue);


# Clean up the environment
delete $ENV{'SSH_AUTH_SOCK'};
delete $ENV{'SSH_AGENT_PID'};


# Set up for graceful exit
my $SCHEDULER_PID = $$;
my $bailout       = 0;
$SIG{'INT'} = $SIG{'TERM'} = sub { $bailout = 1; };

# Set up to test the config
my $CFGCHECKINTERVAL = 30;
my $lastcfgcheck;

my $LIB_DIR = $cfg->get('ProbeFramework', 'probeClassLibraryDirectory');

# Here we go ...
$log->autoflush(1);
$debug->dprint(1, "Starting kernel\n"); $debug->flush;
$errlog->print("Starting kernel\n");


# First, start a new scheduler and populate it with events
my $sched = new NOCpulse::Scheduler(Debug => $debug);

# Emergency measure to dump and resort the scheduler ready queue
$SIG{'HUP'} = sub { 
   $errlog->print("Received HUP\n");
   $sched->dump_internal_state(); $sched->sort_ready_queue;
};


# Clean up the old $OUTPUTDIR ...
system("/bin/rm -rf $OUTPUTDIR");

# Then start a process pool
my $procpool = new NOCpulse::ProcessPool(Size      => $CONCURRENCY,
                                         Maxlife   => $MAXLIFE, 
			                 Debug     => $debug,
					 Outputdir => $OUTPUTDIR)
	       or die "Couldn't create process pool: $@\n";

# Set up the cache of preloaded probes, off by default
# because it slows things down a lot
ProbeCache::init(0);

# Load up the initial config
&load_initial_config($sched, $procpool);

# Turn off log flushing in the daemon loop
$log->autoflush(0);


my $idleMessage     = "Scheduler says we're up-to-date\n";
my $fullPoolMessage = "Waiting for probes to finish\n";
my $printedIdle     = 0;
my $printedFullPool = 0;


# Daemon loop
while (1) {
  
  # Kill any children older than $MAXLIFE
  $procpool->euthanize();

  # Reap any completed children
  &reap_children($procpool, $sched, $debug);

  # If a shutdown was requested, kill any remaining active procs and exit
  &bail_out($procpool, $debug) if ($bailout);

  # Check for a new config file
  if (time - $lastcfgcheck > $CFGCHECKINTERVAL) {
    # Also a good time to print actual latency
    my $lat = NOCpulse::Scheduler::Statistics::averageLatency();
    $debug->dprint(1, 'Average probe latency is ', sprintf("%.3f", $lat), " seconds\n")
      unless $lat == -1;     # -1 shows up on the first run
    $lastcfgcheck = time;
    &check_config($sched, $procpool);
  }

  # Fill the process pool
  my $numSpawned = &spawn_children($procpool, $debug);

  # Print some diagnostics about what's happening.
  if ($numSpawned > 0) {
     $printedIdle = 0;
     $printedFullPool = 0;
  }
  if ($procpool->availableSlots()) {
     $debug->dprint(1, $idleMessage) unless $printedIdle;
     $printedIdle = 1;
     $printedFullPool = 0;
  } else {
     $debug->dprint(1, $fullPoolMessage) unless $printedFullPool;
     $printedIdle = 0;
     $printedFullPool = 1;
  }

  # Mark the log file so that gogo sees activity
  my $now = time();
  utime($now, $now, $logfile);

  $debug->flush();

  # Throttle requests to scheduler
  sleep(1) unless ($numSpawned);

}





sub spawn_children {
  my ($procpool, $debug) = @_;

  my @spawnedIds = ();

  while ($procpool->availableSlots() and my $event = $sched->next_event()) {
    push(@spawnedIds, $event->id);
    $debug->dump(5, '', $event, "\n");
    $debug->flush;  # So that child doesn't also flush

    my $now = time();

    NOCpulse::Scheduler::Statistics::calculateLatency($event, $now);

    ProbeCache::preloadProbe($event->id);

    unless ($procpool->spawn($event)) {
      # Oops!  Couldnt' spawn the event for some reason.
      my $msg = "ERROR:  Couldn't spawn event: $@\n";
      $debug->dprint(1, $msg);
      $errlog->print($msg);
      $debug->dprint(1, "Rescheduling at $DINTERVAL-second interval\n");
      $event->time_to_execute($now + $DINTERVAL);
      $sched->event_done($event);
    }
  }
  if (@spawnedIds) {
     $debug->dprint(1, 'Spawned ', join(', ', @spawnedIds), "\n");

  }
  return scalar @spawnedIds;
}




sub reap_children {
  my ($procpool, $sched, $debug) = @_;

  my @reapedIds = ();

  while (my $reaped = $procpool->reap()) {
    # Print results and post returned event back to the scheduler
    my $event  = $reaped->exec;
    my $id     = $event->id;
    my $rv     = $reaped->retval;
    my $stderr = $reaped->have_stderr ? $reaped->stderr : undef;

    push(@reapedIds, $id);

    if ($reaped->status != 0 || $reaped->errno != 0) {
       $debug->dprint(1, "Reaped '$id' (pid ", $reaped->pid,
		      ") with status ", $reaped->status, ", ERRNO ", $reaped->errno, "\n");
       $errlog->print("Probe $id exited with status ", $reaped->status,
		      ', ERRNO ', $reaped->errno, "\n");

       undef($rv);  # ... so handle_failure will be called below.
    }
       
    my $stderr_log_msg = "\tSTDERR:\n\t>>>$stderr<<\n";

    if ($stderr) {
       # Log probe stderr to both kernel.log and kernel-error.log
       my $msg = "Probe $id produced error output:\n$stderr_log_msg";
       $debug->dprint(1, $msg);
       $errlog->print($msg);
    }
       
    if ($debug->willprint(2)) {
       $debug->dprint(2, "\tSTDOUT:\n\t>>>".$reaped->stdout."<<<\n");
       $debug->dprint(2, $stderr_log_msg);
       $debug->dprint(2, "\tRETVAL: $rv\n");
       $debug->dump(5, "\t>>>", $rv, "<<<\n");
    }       

    if (defined($rv)) {
      $debug->dprint(2, "Next execution scheduled for ",
			scalar(localtime($rv->time_to_execute)), "\n");
      $sched->event_done($rv);

    } elsif ($reaped->errno =~ /Timed out/) {

      # The event timed out.  Run the timeout handler.
      my $toid = $event->id . ".TIMEOUT";
      my $toe  = new NOCpulse::Scheduler::Event::TimeoutEvent($toid);
      $toe->event($event);

      $debug->dprint(1, "Spawning event '", $toe->id, "'\n");
      $debug->dump(5, '', $toe, "\n");
      $debug->flush;  # So that child doesn't also flush
      unless ($procpool->spawn($toe)) {
	my $msg = "ERROR: Couldn't spawn child: $@\n";
        $debug->dprint(1, $msg);
        $errlog->print($msg);
        $debug->dprint(1, "Rescheduling at $DINTERVAL-second interval\n");
	$event->time_to_execute(time + $DINTERVAL);
	$sched->event_done($event);
      }

    } else {

      # The event terminated abnormally.  Schedule the next execution
      # based on its execution interval and have the event gritch about
      # the problem.
      my $msg = "Event terminated abnormally\n";
      $debug->dprint(1, $msg);
      $errlog->print($msg);
      $debug->dprint(1, "Rescheduling at $DINTERVAL-second interval\n");
      $event->handle_failure($stderr, $eventGritcher);
      $event->time_to_execute(time + $DINTERVAL);
      $sched->event_done($event);

    }

    # Clean up the temp files.
    $reaped->cleanup();
  }

  if (@reapedIds) {
     $debug->dprint(1, "Reaped ", join(', ', @reapedIds), "\n");
  }
}




sub bail_out {
    my ($procpool, $debug) = @_;

    # Only clean up if I'm the parent.
    if ($$ == $SCHEDULER_PID) {

        $log->autoflush(1);
        $debug->dprint(0, "Exiting at user request\n");

        $debug->dprint(1, "\tKilling remaining children ...\n");
        my($pid, $child, @doomed);
        while (($pid, $child) = each %{$procpool->active()}) {
            $debug->dprint(2, "\t\tChild $child (pid $pid)\n");
            $child->die();
            push(@doomed, $child);
        }

        # Make sure they're really dead
        foreach $child (@doomed) {
            $child->die_die_die();
        }

        $debug->dprint(1, "\tCleaning up scratch dir ...\n");
        $procpool->cleanup();

        $debug->dprint(1, "\tDone.\n");
        $debug->flush;
        $errlog->print("Exiting kernel\n");

    }

    exit 0;
}





sub load_config {

  # Load the config files
  my $sched = shift;
  my $pool  = shift;
  my($eventsfile, $cfgfile) = @_;
  $debug->dprint(1, "Loading config\n");

  # Step 1:  Load up the config file
  open(CONFIG, $cfgfile);
  my $xml = join('', <CONFIG>);
  close(CONFIG);

  my $dumped = NOCpulse::Utils::XML->unserialize($xml);
  my $hash   = $dumped->[0];

  # Interesting parameters:
  #   MAX_CONCURRENT_CHECKS
  #   SCHED_LOG_LEVEL
  if ($hash->{'MAX_CONCURRENT_CHECKS'}) {
    $pool->poolsize($hash->{'MAX_CONCURRENT_CHECKS'});
  }

  if ($hash->{'SCHED_LOG_LEVEL'}) {
    $log->level($hash->{'SCHED_LOG_LEVEL'});
  }



  # Step 2:  Load up the events
  open(EVENTS, $eventsfile);
  my $eventstring = join('', <EVENTS>);
  close(EVENTS);
  my @events;
  eval {
    @events = thaw($eventstring);
  };

  if ($@) {
    $debug->dprint(1, "Couldn't thaw events: $@\n");
    $debug->dprint(3, "Eventstring: '$eventstring'\n");
  } else {

    # Add a StatePushEvent as event 0 to the list for current state
    push(@events, NOCpulse::Scheduler::Event::StatePushEvent->new(0));

    my $nevents = scalar(@events);
    $debug->dprint(1, "Passing $nevents events to the scheduler\n");
    $sched->reset(\@events);
  }

  # Step 3: Blitz the cached probes
  ProbeCache::clear();

  # Step 4: Load the probe and command records from their separate Storable database
  $debug->dprint(1, "Loading probe records\n");
  my $hashRef = Storable::retrieve($cfg->get('netsaint', 'probeRecordDatabase'));
  ProbeRecord->Absorb([values %{$hashRef}], 'RECID');

  $debug->dprint(1, "Loading command records\n");
  NOCpulse::Probe::Config::Command->load($cfg->get('netsaint', 'commandParameterDatabase'));

  $debug->dprint(1, "Done\n");

  # That's all, folks.
  $debug->dprint(1, "Finished loading config\n");
  $debug->flush;
}





sub check_config {
  my $sched = shift;
  my $pool  = shift;
  my $force = shift;

  my $flagfile   = $cfg->get('satellite', 'schedulerReloadFlagFile');

  if ($force) {
    $debug->dprint(1, "Force-loading config\n");
  } else {
    if (! -f $flagfile) {
      $debug->dprint(1, "Config is up-to-date\n");
      $debug->flush;
      return undef;
    }
  }

  # The config needs to be loaded.  Nuke the flag file and
  # load the config.
  my $eventsfile = $cfg->get('satellite', 'eventsFile');
  $debug->dprint(2, "\tEvents file: $eventsfile\n");

  my $configfile = $cfg->get('satellite', 'schedulerConfigFile');
  $debug->dprint(2, "\tConfig file: $configfile\n");

  if (-f $flagfile) { 
    unlink($flagfile) or
       $debug->dprint(1, "\tCouldn't unlink $flagfile: $!");
  }

  &load_config($sched, $pool, $eventsfile, $configfile);

}


sub load_initial_config {
  &check_config(@_, 1);
}





#
# Probe preloading logic
#
package ProbeCache;

my $enabled = 0;

sub init {
   $enabled = shift();
   if ($enabled) {
      # Avoid deadlocks if we're not caching
      DBMObjectRepository->CacheHandles(1);
   }
}

sub clear {
   if ($enabled) {
      Probe->ReleaseInstances();
      # scheduleEvents creates a new Probe.db, so we need to close
      # the old one when loading a new config. The handle caching
      # set up in init means the regular open/close are no-ops.
      Probe->database->closeCachedHandle();
   }
}

sub preloadProbe {
   if ($enabled) {
      my $probeId = shift();

      my $probe = Probe->loadFromDatabase($probeId, 'try-cache');

      if (! $probe) {
	 $debug->dprint(1, "Probe $probeId not loaded\n");
      } else {
	 # Load its code.
	 my $className = ref($probe);
	 my $error = Module::load($className, $LIB_DIR);
	 if ($error) {
	    $debug->dprint(1, "Cannot load probe class $className: $error");
	 }
      }
   }
}
