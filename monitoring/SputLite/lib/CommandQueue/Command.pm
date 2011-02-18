########################################
package NOCpulse::CommandQueue::Command;
########################################

use strict;
use vars qw(@ISA);
use Time::HiRes qw(gettimeofday tv_interval);
use POSIX ":sys_wait_h";
use Data::Dumper;
use NOCpulse::Config;
use NOCpulse::CommandOutput;
use NOCpulse::CommandOutputQueue;
use NOCpulse::SetID;

use NOCpulse::CommandQueue;
@ISA = qw(NOCpulse::CommandQueue);

######################################################
# Accessor methods
#
sub command_line       { shift->_elem('command_line',      @_); }
sub effective_group    { shift->_elem('effective_group',   @_); }
sub effective_user     { shift->_elem('effective_user',    @_); }
sub expdate            { shift->_elem('expdate',           @_); }
sub id                 { shift->_elem('id',                @_); }
sub lastcompletedfile  { shift->_elem('lastcompletedfile', @_); }
sub laststartedfile    { shift->_elem('laststartedfile',   @_); }
sub nsid               { shift->_elem('netsaint_id',       @_); }
sub target_type        { shift->_elem('target_type',       @_); }
sub cluster_id         { shift->_elem('cluster_id',        @_); }
sub notify_email       { shift->_elem('notify_email',      @_); }
sub queue              { shift->_elem('queue',             @_); }
sub restartable        { shift->_elem('restartable',       @_); }
sub timeout            { shift->_elem('timeout',           @_); }


#########
sub new {
#########
  my $class     = shift;
  my $self      = {};
  my $cq        = shift;
  bless $self, $class;

  $self->laststartedfile($cq->laststartedfile);
  $self->lastcompletedfile($cq->lastcompletedfile);
  $self->queue($cq->queue);
  $self->heartbeatfile($cq->heartbeatfile);
  $self->heartbeatfreq($cq->heartbeatfreq);

  return $self;
}


#########
sub set {
#########
  my($self) = shift;
  my($key, $value) = @_;

  $self->dprint(4, "\tSetting $key => $value for $self\n");
  $self->{$key} = $value;
}


############
sub append {
############
  my($self) = shift;
  my($key, $value) = @_;

  $self->dprint(4, "\tAppending '$value' to $key for $self\n");
  $self->{$key} .= $value;
}



#########
sub run {
#########
  my $self = shift;

  my $laststarted   = $self->get_last_started; 
  my $lastcompleted = $self->get_last_completed; 
  my $id            = $self->id;

  # Algorothm:
  #  - time < $self->expdate:  expired command; bail out.
  #  - $id < $laststarted:  this is an old command; bail out.
  #  - $id == $laststarted and $id > $lastcompleted:  this command
  #      was interrupted.  Execute iff it's restartable.
  #  - $id >= $laststarted: this is a new command; execute.

  # Exit status:
  #  undef if we elect not to run the command
  #  -1    if we try to run the command, but it fails

  $self->dprint(2, "\tAttempting to run command $id\n");
  $self->dprint(3, "\t\tLast started: $laststarted; Last completed:  $lastcompleted\n");

  if (time > $self->expdate()) {

    # Expired command
    $@ = "$id is not executable (expired)\n";
    $self->dprint(2, "\t$@");
    return undef;

  } elsif ($id < $laststarted or 
           ($id == $laststarted and $id == $lastcompleted)) {

    # Old command
    $@ = "$id is not executable (old, last started $laststarted, last completed $lastcompleted)\n";
    $self->dprint(2, "\t$@");
    return undef;

  } elsif ( $id == $laststarted && $id > $lastcompleted) {

    # Execution was interrupted.  Restart?
    if ($self->restartable) {

      $self->dprint(2, "\t$id is executable (interrupted, restartable)\n");

    } else {

      $@ = "$id is not executable (interrupted, not restartable)\n";
      $self->dprint(2, "\t$@");
      return undef;

    }

  } else {

    # Unseen command
    $self->dprint(2, "\t$id is executable (new)\n");

  }

  return $self->execute;

}


#############
sub execute {
#############

  my $self    = shift;
  my $timeout = $self->timeout;

  # Execute algorithm:
  #    - Write $self->id() to disk as last_started.
  #    - Execute $self->command_line as $self->effective_user / 
  #         $self->effective_group with timeout $self->timeout
  #         (unless you're faking it).
  #    - Enqueue the response data point (unless you're faking it).
  #    - Write $self->id() to disk as last_completed.
  # Exit status:
  #  return -1 on error and set $@

  $self->dprint(2, "\tExecuting command ...\n");

  $self->write_last_started() or return -1;

  my $time = time;
  my $rv = $self->shellcmd();

  my $command_output = NOCpulse::CommandOutput->newInitialized();

  unless ($rv) {
    # Command failed to execute for some reason.
      $command_output->exit_status(-1);
      $command_output->execution_time(0);
      $command_output->date_executed($time);
      $command_output->stdout('');
      $command_output->stderr("<<$@>>");
  }
  else
  {
      $command_output->exit_status($rv->{'exit_status'});
      $command_output->execution_time($rv->{'execution_time'});
      $command_output->date_executed($rv->{'date_executed'});
      $command_output->stdout($rv->{'STDOUT'});
      $command_output->stderr($rv->{'STDERR'});
  }

  $self->dprint(2, "\tShell command exited with ", $rv->{'exit_status'}, 
                   " exit status\n");
  $self->dprint(3, "\t\tSTDOUT:", $rv->{'STDOUT'}, "\n");
  $self->dprint(3, "\t\tSTDERR:", $rv->{'STDERR'}, "\n");

  # Don't forget to pass back the command ID and Netsaint ID
  
  $command_output->instance_id($self->id);
  $command_output->netsaint_id($self->nsid);
  $command_output->target_type($self->target_type);
  $command_output->cluster_id($self->cluster_id);
  
  # Print the return value for heavy debugging
  $self->dprint(4, "\tData Point:  ", &Dumper($rv), "\n");

  my $nq = NOCpulse::CommandOutputQueue->new( Config => NOCpulse::Config->new() );
  $nq->enqueue($command_output);
  
  $self->write_last_completed() or return -1;

  return 1;

}


##############
sub shellcmd {
##############
  my $self = shift;
  my $pid;
  my $start = [gettimeofday];

  if (!defined($pid = fork())) {

    $@ = "Fork failed: $!\n";

  } elsif ($pid == 0) {

    # This is the child.  Execute the command, directing output to files.
    close(STDIN);
    open(STDOUT, ">/tmp/$$.STDOUT");
    open(STDERR, ">/tmp/$$.STDERR");

    # Set real and effective user and group IDs
    my $id = NOCpulse::SetID->new(
           ruid   => $self->effective_user,
           euid   => $self->effective_user,
           rgid   => $self->effective_group,
           egid   => $self->effective_group);

    $id->su(permanent => 1);

    unless ($) == $id->egid) {
      print STDERR "Exec failed:  Couldn't set egid to ".$id->egid."\n";
      exit 1;
    }

    unless ($( == $id->egid) {
      print STDERR "Exec failed:  Couldn't set rgid to ".$id->egid."\n";
      exit 1;
    }

    unless ($> == $id->euid) {
      print STDERR "Exec failed:  Couldn't set euid to ".$id->euid."\n";
      exit 1;
    }

    unless ($< == $id->euid) {
      print STDERR "Exec failed:  Couldn't set ruid to ".$id->euid."\n";
      exit 1;
    }

    exec $self->command_line();
    
    # If we get here, the exec failed.
    print STDERR "Exec failed: $!";

    exit 1;

  } else {

    # This is the parent
    my $timeoutmessage = "Timed out\n";
    my $timeout        = $self->timeout;
    my $expdate        = time + $self->timeout;
    my $hbfreq         = $self->heartbeatfreq;

    # Set up an ALRM signal handler to keep the heartbeat file fresh
    my $ticker = sub {
      my $time = time;
      $self->heartbeat();
      if ($time >= $expdate) {
        die $timeoutmessage;
      } elsif ($expdate - $time > $hbfreq) {
        alarm($hbfreq);
      } else {
        alarm($expdate - $time);
      }
    };

    # Just do it
    &$ticker();  # to set alarm
    local($SIG{'ALRM'}) = $ticker;
    eval { wait };
    alarm(0);

    my $end = [gettimeofday];

    if ($@) {

      # Clean up after the child.  (The joys of parenting ...)
      if ($@ eq $timeoutmessage) {
        kill(15, $pid);
	sleep 1;
        kill(9, $pid);
	waitpid($pid, &WNOHANG);
      }

      $@ = "Exec failed: $@\n";
      return undef;

    } else {

      # Return the required values:  exit status, execution time,
      # STDOUT, and STDERR
      my $dp = {};
      $dp->{'exit_status'}    = $?>>8;
      $dp->{'execution_time'} = tv_interval($start, $end);
      $dp->{'date_executed'}  = $start->[0];

      my $out;
      foreach $out (qw(STDOUT STDERR)) {

        local * FILE;
        open(FILE, '<', "/tmp/$pid.$out");
	my $output = join('', <FILE>);
	close(FILE);

	$dp->{$out} = $output;

	unlink("/tmp/$pid.$out");

      }

      # Check for exec() failure in the child
      if ($dp->{'STDERR'} =~ /^Exec failed/) {
	$@ = $dp->{'STDERR'};
        return undef;
      }

      return $dp;

    }

  }

}




############
sub get_id {
############
  my $self  = shift;
  my $file  = shift;
  my $alt   = shift;
  my $id;

  local * FILE;
  if (-f $file) {

    unless(open(FILE, '<', $file)) {
      $@ = "Couldn't open $file: $!";
      return undef;
    }
    chomp($id = <FILE>);
    close(FILE);

  } elsif (-f $alt) {

    unless(open(FILE, '<', $alt)) {
      $@ = "Couldn't open $alt: $!";
      return undef;
    }
    chomp($id = <FILE>);
    close(FILE);

  } else {

    # No $file, no $old, this must be the first one
    return 0;

  }


  return $id;
}


######################
sub get_last_started {
######################
  my $self = shift;
  my $file = $self->laststartedfile;
  my $alt  = "${file}.old";

  return $self->get_id($file, $alt);
}


########################
sub get_last_completed {
########################
  my $self = shift;
  my $file = $self->lastcompletedfile;
  my $alt  = "${file}.new";

  return $self->get_id($file, $alt);
}


##############
sub write_id {
##############
  my $self  = shift;
  my $file  = shift;
  my $new   = "${file}.new";
  my $old   = "${file}.old";

  local * FILE;
  unless (open(FILE, '>', $new)) {
    $@ = "Couldn't write to $new: $!";
    return undef;
  }

  unless (print FILE $self->id, "\n") {
    $@ = "print to $new failed: $!";
    return undef;
  }
  close(FILE);

  if (! -f $file or rename($file, $old)) {

    if (rename($new, $file)) {

      # Success!  Ditch the old file
      unlink($old);

    } else {

      # Oops!  First rename made it, second one didn't.  Roll back
      # the first if possible.
      $@ = "Couldn't rename $new => $file: $!";
      rename($file, $old);
      unlink($new);
      return undef;

    }

  } else {

    $@ = "Couldn't rename $file => $old: $!";
    return undef;

  }

  return $self->id;

}


########################
sub write_last_started {
########################
  my $self  = shift;

  $self->write_id($self->laststartedfile);
}


##########################
sub write_last_completed {
##########################
  my $self  = shift;

  $self->write_id($self->lastcompletedfile);
}



1;
