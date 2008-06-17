package NOCpulse::ProcessPool;

use POSIX ":sys_wait_h";
use NOCpulse::Process;

use NOCpulse::Debuggable;
use vars qw(@ISA);
@ISA = qw(NOCpulse::Debuggable);



##########################################################
# Global variables
#

my $POOLSIZE  = 10;                     # Default pool size
my $MAXLIFE   = undef;                  # Max secs a process is allowed to live
my $OUTPUTDIR = "/var/tmp/procpool.$$"; # Output directory



##########################################################
# Accessor methods
#
sub active      { shift->_elem('active',      @_); }
sub maxlife     { shift->_elem('maxlife',     @_); }
sub outputdir   { shift->_elem('outputdir',   @_); }
sub poolsize    { shift->_elem('poolsize',    @_); }
sub reaped      { shift->_elem('reaped',      @_); }
sub surekill    { shift->_elem('surekill',    @_); }



##########################################################
# Class methods
#

#########
sub new {
#########
  my $class = shift;
  my %args  = @_;
  $class    = ref($class) || $class;
  my $self  = {};
  bless $self,$class;
  my $label = "ProcessPool::new";

  # Set up the debug object
  $self->debugobject($args{'Debug'} || $self->defaultDebugObject);

  # Set up empty store for processes
  $self->active({});
  $self->reaped({});

  # Store optional parameters
  $self->poolsize($args{'Size'}       || $POOLSIZE);
  $self->maxlife($args{'Maxlife'}     || $MAXLIFE);
  $self->outputdir($args{'Outputdir'} || $OUTPUTDIR);

  # Make surekill the default (kills with SIGKILL)
  $self->surekill(1);


  # Create output directory
  if (mkdir($self->outputdir, 0700)) {
    $self->dprint(3, "Created output dir " . $self->outputdir . "\n");
  } else {
    $@ = "Couldn't create output dir " . $self->outputdir . ": $!";
    $self->dprint(2, "\t$label: $@\n");
    return undef;
  }

  return $self;
}






##########################################################
# Instance methods
#


####################
sub availableSlots {
####################
  my $self = shift;
 
  my $nactive = scalar(keys(%{$self->active}));
  my $nreaped = scalar(keys(%{$self->reaped}));
 
  $self->dprint(4,"availableSlots sees poolsize = ", $self->poolsize,
                  ", active = $nactive, reaped = $nreaped and is returning ",
                  ($self->poolsize - ($nactive + $nreaped)), "\n");
 
  return $self->poolsize - ($nactive + $nreaped);
}


###############
sub euthanize {
###############
  my $self  = shift;
  my $label = "ProcessPool::euthanize";
  $self->dprint(4, "Entering $label(@_)\n");
  my $nkilled = 0;
  my @killed;

  # Kill all children older than $self->maxlife seconds old
  my $child;
  foreach $child (values %{$self->active}) {
    if (time - $child->starttime > $self->maxlife) {
      $self->dprint(3, "\t$label:  killing ", $child->pid, "\n");
      $self->debugobject->dump(5, "\t$label:  ", $child, "\n");
      $nkilled++;
      $child->die("Timed out");
      push(@killed, $child);
    }
  }

  if ($self->surekill) {
    $self->dprint(3, "\t$label:  Surekilling $nkilled children\n");
    # Make sure stubborn children are dead
    foreach $child (@killed) {
      $child->die_die_die("Timed out");
    }
  }

  $self->dprint(4, "Leaving $label() => $nkilled\n");
  return $nkilled;

}


###########
sub spawn {
###########
  my $self  = shift;
  my $label = "ProcessPool::spawn";
  $self->dprint(4, "Entering $label(@_)\n");
  my $rv;

  # Do we have any available slots?
  if ($self->availableSlots()) {
    my $child = new NOCpulse::Process(Outputdir => $self->outputdir,
                                      Debug     => $self->debugobject);
    if (defined($child)) {
      my $pid   = $child->spawn(@_);
      $rv = $self->active->{$pid} = $child;
    } else {
      my $msg = "Couldn't create child process: $@";
      $self->dprint(2, "\t$label: $msg\n");
      $@ = $msg;
      $rv = undef;
    }
  } else {
    $self->dprint(2, "\t$label: no available slots\n");
    $@ = "No available process slots";
    $rv = undef;
  }

  $self->dprint(4, "Leaving $label() => $rv\n");
  return $rv;

}


##########
sub reap {
##########
  my $self  = shift;
  my $label = "ProcessPool::reap";
  $self->dprint(4, "Entering $label(@_)\n");
  my $rv;

  # Move all the dead children to the reaped structure
  $self->bring_out_your_dead();

  my($pid, $child) = each %{$self->reaped};
  if ($pid) {

    # We have a winner!
    $self->dprint(3, "\t$label: Reaped PID is '$pid'\n");
    delete($self->reaped->{$pid});
    $rv = $child;
    
  } else {

    # No dead children
    $self->dprint(3, "\t$label: No dead children\n");

  }

  $self->dprint(4, "Leaving $label() => $rv\n");
  return $rv;

}



###################
sub wait_for_slot {
###################
  my $self  = shift;
  my $label = "ProcessPool::wait_for_slot";
  $self->dprint(4, "Entering $label(@_)\n");
  my $secs = shift || 0;

  if ($self->availableSlots) {
    # There are slots available;
    return 1;
  }

  # There are no slots available.  Wait up to $secs secs for somebody to die.
  $self->dprint(3, "\t$label: Waiting ", $secs ? "up to $secs seconds " : "",
                   "for available slot\n");
  $SIG{'ALRM'} = sub {die "Timed out!\n"};
  my $pid;
  eval {
    alarm($secs);
    $pid = wait();
    alarm(0);
  };

  if ($@) {
    $self->dprint(3, "\t$label: Timed out\n");
    return undef;
  } else {
    $self->embalm($pid, $?);
  }

  $self->dprint(4, "Leaving $label()\n");
  return 1;

}


#########################
sub bring_out_your_dead {
#########################
  my $self  = shift;
  my $label = "ProcessPool::bring_out_your_dead";
  $self->dprint(4, "Entering $label(@_)\n");

  # Collect all the dead children and put them in the reaped queue
  my $bodycount = 0;
  while (1) {

    my $pid = waitpid(-1, &WNOHANG);
    last if ($pid <= 0);

    # We have a corpse.  Move it from the active queue to the reaped queue
    $self->dprint(3, "\t$label:  reaped pid $pid, rv $?\n");
    if ($self->embalm($pid, $?)) {
      $bodycount++ 
    } else {
      $self->dprint(2, "\t$label: ERROR:  Reaped inactive pid $pid ($?)!\n");
    }

  }

  $self->dprint(4, "Leaving $label() => $bodycount\n");
  return $bodycount;

}


############
sub embalm {
############
  my $self  = shift;
  my $label = "ProcessPool::embalm";
  $self->dprint(4, "Entering $label(@_)\n");

  my $pid    = shift;
  my $status = shift;

  return undef unless ($self->active->{$pid});

  # Move PID from "running queue" to "reaped queue"
  $self->reaped->{$pid} = delete($self->active->{$pid});

  # Use the status in the process object if it exists (i.e. the
  # process was terminated abnormally by the parent)
  if ($self->reaped->{$pid}->status) {
    $status    = $self->reaped->{$pid}->status;
    my $reason = $self->reaped->{$pid}->errno;
    $self->dprint(3, "\t$label: using pre-set status $status ($reason)\n");
  } else {
    $self->reaped->{$pid}->status($status);
  }


  $self->dprint(4, "Leaving $label()\n");
  return 1;

}




############
sub dprint {
############
   my $self = shift;
   my $lvl  = shift;

   # +++ EXPERIMENTAL:  Tab over an amount representing the debug level
   $self->debugobject->dprint($lvl, "   " x $lvl, @_);

#   $self->debugobject->dprint(@_);

}



#############
sub cleanup {
#############
  my $self = shift;

  # Delete the output directory
  my $dir = $self->outputdir;
  opendir(DIR, $dir);
  my @files = map("$dir/$_", grep(!/^\.\.?$/, readdir(DIR)));
  closedir(DIR);
  unlink(@files);
  rmdir($dir);

}


###########
sub _elem {
###########
  my $self = shift;
  my $elem = shift;
  my $old = $self->{$elem};
  $self->{$elem} = shift if (scalar(@_));
  return $old;
}
1;

