package NOCpulse::Process;

use strict;
use POSIX ":sys_wait_h";
use FreezeThaw qw(freeze thaw);
use File::stat;

use NOCpulse::Debuggable;
use vars qw(@ISA);
@ISA = qw(NOCpulse::Debuggable);


##########################################################
# Global variables
#




##########################################################
# Accessor methods
#
sub errno       { shift->_elem('errno',       @_); }
sub exec        { shift->_elem('exec',        @_); }
sub outputdir   { shift->_elem('outputdir',   @_); }
sub pid         { shift->_elem('pid',         @_); }
sub rvfile      { shift->_elem('rvfile',      @_); }
sub starttime   { shift->_elem('starttime',   @_); }
sub status      { shift->_elem('status',      @_); }
sub stderrfile  { shift->_elem('stderrfile',  @_); }
sub stdoutfile  { shift->_elem('stdoutfile',  @_); }



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

  # Set up the debug object
  $self->debugobject($args{'Debug'} || $self->defaultDebugObject);

  # Set up the output directory (required field);
  unless (exists($args{'Outputdir'})) {
    $@ = "Missing required parameter 'Outputdir'";
    return undef;
  }

  if (! -d $args{'Outputdir'}) {
    $@ = "Output directory $args{'Outputdir'} does not exist";
    return undef;
  }

  $self->outputdir($args{'Outputdir'});

  return $self;
}





##########################################################
# Instance methods
#

###########
sub spawn {
###########
  my $self  = shift;
  my $label = "Process::spawn";
  $self->dprint(4, "Entering $label(@_)\n");

  my $exec  = shift;
  my @args  = @_;
  my $rv;
  my $dir    = $self->outputdir();
  my $stdout = "$dir/%s.STDOUT";
  my $stderr = "$dir/%s.STDERR";
  my $retval = "$dir/%s.RETVAL";

  # Save the executed element
  $self->exec($exec);

  # Flush debug output before the fork to prevent duplicate output
  $self->debugobject->flush();

  my $pid = fork();

  if (!defined($pid)) {

    $self->dprint(2, "\t$label: Fork failed: $!");
    $@ = "Fork failed: $!\n";
    $rv = undef;

  } elsif ($pid == 0) {

    # This is the child.  Set up STDOUT & STDERR files.
    my $dir = $self->outputdir();
    my $f;

    $f = sprintf($stdout, $$);
    open(STDOUT, ">$f") or die "Couldn't create $f: $!";

    $f = sprintf($stderr, $$);
    open(STDERR, ">$f") or die "Couldn't create $f: $!";


    # Execute the command
    if (ref($exec)) {

      # This is a Perl object.  First, set $0 to show which event is running
      my $nullpadding = "\0" x 100;
      $0 = sprintf("$0 (event %s)$nullpadding", $exec->id);
      
      # Then just call its run() method.
      my $return = $exec->run(@args);

      # Print the returned object to the rvfile
      my $frozen = freeze($return);
      $f = sprintf($retval, $$);
      open(RV, ">$f") or die "Couldn't create $f: $!";
      print RV $frozen;
      close(RV);

      exit 0;

    } else {

      # We've been passed a string to exec.
      CORE::exec($exec, @args);

      # Shouldn't get here
      print STDERR "Exec failed: $!\n";
      exit 1;

    }


  } else {

    # This is the parent
    $self->starttime(time);
    $self->pid($pid);
    $self->stdoutfile(sprintf($stdout, $pid));
    $self->stderrfile(sprintf($stderr, $pid));
    if (ref($exec)) {
      $self->rvfile(sprintf($retval, $pid));
    }
    $rv = $pid;

  }

  $self->dprint(4, "Leaving $label() => $rv\n");
  return $rv;
}


############
sub file_contents {
############
  my ($self, $file)  = @_;
  my $label = "Process::file_contents";
  $self->dprint(4, "Entering $label(@_)\n");

  my $contents;

  # Read the file if cleanup has not been called yet.
  if (defined($file)) {
     $self->dprint(4, "\t$label: Fetching from ", $file, "\n");
     open(FILE, $file);
     $contents = join('', <FILE>);
     close(FILE);
  }
  $self->dprint(4, "Leaving $label(@_)\n");

  return $contents;
}


############
sub cleanup {
############
  my $self  = shift;
  my $label = "Process::cleanup";
  $self->dprint(4, "Entering $label(@_)\n");

  unlink($self->stdoutfile) if ($self->stdoutfile);
  $self->stdoutfile(undef);

  unlink($self->stderrfile) if ($self->stderrfile);
  $self->stderrfile(undef);

  unlink($self->rvfile) if ($self->rvfile);
  $self->rvfile(undef);

  $self->dprint(4, "Leaving $label()\n");
}


############
sub stdout {
############
  my $self  = shift;
  my $label = "Process::stdout";
  $self->dprint(4, "Entering $label(@_)\n");
  my $stdout = $self->file_contents($self->stdoutfile);
  $self->dprint(4, "Leaving $label() => ", length($stdout), " bytes\n");
  return $stdout;
}


############
sub have_stderr {
############
  my $self  = shift;
  my $stat = stat($self->stderrfile);
  return (defined($stat) && $stat->size > 0);
}


############
sub stderr {
############
  my $self  = shift;
  my $label = "Process::stderr";
  $self->dprint(4, "Entering $label(@_)\n");
  my $stderr = $self->file_contents($self->stderrfile);
  $self->dprint(4, "Leaving $label() => ", length($stderr), " bytes\n");
  return $stderr;
}


############
sub retval {
############
  my $self  = shift;
  my $label = "Process::retval";
  $self->dprint(4, "Entering $label(@_)\n");

  my $rvstring = $self->file_contents($self->rvfile, $label);
  my $rv;

  $self->dprint(4, "\t$label: RV string: '$rvstring'\n");

  if (! length($rvstring)) {
     $self->dprint(2, "\t$label: No return value\n");
     $rv = undef;

  } else {
     eval { ($rv) = thaw($rvstring) };

     if ($@) {
	$self->dprint(2, "\t$label: Thaw failed: $@");
	$rv = undef;
	$self->errno($self->errno . "\n" . $@);
     }

     $self->debugobject->dump(5, "\t$label: RV:  ", $rv, "\n");
  }

  $self->dprint(4, "Leaving $label() => $rv\n");
  return $rv;
}


#########
sub die {
#########
  my $self = shift;
  my $label = "Process::die";
  $self->dprint(4, "Entering $label(@_)\n");
  my $msg  = shift;

  kill 'TERM', $self->pid;
  $self->status(-1);
  $self->errno("Killed" . (length($msg) ? " - $msg" : ""));

  $self->dprint(4, "Leaving $label()\n");

}


#################
sub die_die_die {
#################
  my $self = shift;
  my $label = "Process::die_die_die";
  $self->dprint(4, "Entering $label(@_)\n");
  my $msg  = shift;

  kill 'KILL', $self->pid;
  $self->status(-1);
  $self->errno("Killed" . (length($msg) ? " - $msg" : ""));

  $self->dprint(4, "Leaving $label()\n");

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

