package NOCpulse::Debuggable;
#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#
use NOCpulse::Debug;


##########################################################
# Global variables
#

my $DEBUGOBJECT = new NOCpulse::Debug;  # Default debug object



##########################################################
# Accessor methods
#

#################
sub debugobject {
#################
  my $self = shift;
  my $old = $self->{'debugobject'};
  $self->{'debugobject'} = shift if (scalar(@_));
  return $old;
}


##########################################################
# Class methods
#


####################
sub setDebugObject {
####################
  my $class = shift;
  $DEBUGOBJECT = shift;
}


########################
sub defaultDebugObject {
########################
  return $DEBUGOBJECT;
}



##########################################################
# Instance methods
#



############
sub dprint {
############
   my $self = shift;
   my $obj  = $self->debugobject();

   $obj->dprint(@_) if ($obj);
}

############
sub log_print {
############
   my $self = shift;
   my $obj  = $self->debugobject();

   $obj->print(@_) if ($obj);
}

############
sub dump {
############
   my $self = shift;
   my $obj  = $self->debugobject();

   $obj->dump(@_) if ($obj);
}

############
sub will_dprint {
############
   my $self = shift;
   my $obj  = $self->debugobject();

   return $obj->willprint(@_) if ($obj);
}


1;

__END__

=pod

=head1 NAME

NOCpulse::Debuggable - Plug-in architecture for debugging modules

=head1 SYNOPSIS

 package MyPkg;

 use NOCpulse::Debuggable;
 @ISA=qw(NOCpulse::Debuggable);

  sub new {                         # Accept a 'Debug' argument
    my $class = shift;
    my %args  = @_;
    $class    = ref($class) || $class;
    my $self  = {};
    bless $self,$class;

    # Set up the debug object
    $self->debug($args{'Debug'} || $DEBUGOBJECT);

    # Other initialization ...

    return $self;
  }


  package main;

  my $mp = new MyPkg();
  $mp->debugobject->level(3);
  $mp->dprint(1, 'This is a level 1 debugging statement');

=head1 DESCRIPTION

Recommended debug levels:

  Debug level -1 => Absolute silence
                    No dprint statements should use level -1.

  Debug level  0 => Standard output
                    Use this level where you'd normally use a 'print'
		    statement when debugging is off.  (In general, avoid
		    using 'print' with dprint(), or I/O buffering will get
		    your output all out of order.  Unless you make both
		    unbuffered, of course.)

  Debug level  1 => Verbose output (main only)
                    Use this level in the main program for verbose output
		    (a'la '--verbose').  Library routines should not use 
		    this level.

  Debug level  2 => Verbose & error conditions
                    Use this level for extra verbosity in the main, or
		    broad strokes in libraries (e.g. "I'm connecting to
		    the database", "I spawned process $pid", etc).
		    Use this level for internal errors as well (e.g.
		    when a method which usually returns a value has to
		    return undef, dprint the reason at level 2).

  Debug level  3 => High definition detail
                    Use this level for high-definition detail of actions
		    taken (e.g. "I'm creating a new Process object", etc).

  Debug level  4 => Method calls, return values, and variables
                    At this level, print entrances to and exits from method
		    calls ("Entering Process::reap()"), the contents of
		    key variables ("Object is Process=HASH(0x8264688)",
		    "$stdout is 'booga booga booga'", etc), and significant
		    return values ("Leaving Process::reap() => 12164", 
		    "Process::spawn() returns PID 21314").

  Debug level  5 => Data dumps
                    At this level, print dumps of key variables.  E.g.:
		      Spawning event 'foo'
		      $VAR1 = bless( {
				       'execution_interval' => 10,
				       'in_msgs' => [],
				       'out_msgs' => [],
				       'time_to_execute' => 990829652,
				       'id' => 'foo',
				     }, 'NOCpulse::Scheduler::Event' );


  Debug level 6+ => Unnecessary detail
                    Everything else -- contents of buffers, insignificant
		    return values, environment, timing info, yada yada yada.


