package NOCpulse::CommandLineApplicationComponent;
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
use vars qw($VERSION);
$VERSION = (split(/\s+/, q$Id: CommandLineApplicationComponent.pm,v 1.4 2003-07-18 02:28:15 cvs Exp $, 4))[2];

use strict;
use vars qw(@ISA);
use NOCpulse::PersistentObject;
use NOCpulse::CommandLineSwitch;
use Text::Wrap qw(wrap);
use Carp;
@ISA=qw(NOCpulse::PersistentObject);

use vars qw(@Instances $OutputTarget);

$OutputTarget = \*STDOUT;

sub  FreeAllInstances {
   @NOCpulse::CommandLineApplicationComponent::Instances = ();
}

sub AddInstance {
   my ($instance) = @_;
   push(@NOCpulse::CommandLineApplicationComponent::Instances,$instance);
}

sub commandLineIsValid
{
        my $self = shift();
	my $result = 1;
	foreach my $component (@NOCpulse::CommandLineApplicationComponent::Instances) {
	   	# Validate all switches so that their missing/invalid status is tracked,
	   	# as opposed to stopping with the first error.
		if (! $component->switchesAreValid){
			$result = 0;
		}
	}
	return $result;
}

sub printUsage
{
	my $self = shift();
	my $component;
        $self->print("*"x80,"\n");
        foreach  $component (@NOCpulse::CommandLineApplicationComponent::Instances) {
            my $componentClass = ref($component);
            $self->print("COMPONENT: ".$componentClass."\n");
            if ($component->overview) {
                    $self->print("\n");
                    $self->print(wrap('',"\t\t","OVERVIEW:  ",$component->overview));
                    $self->print("\n");
            } else {
               $self->print("\n(no overview available)\n");
            }
            my $name;
            my $switch;
            my $switchref = $component->get_switches;
            if ($component->hasSwitches) {
               $self->print("\nSWITCHES:\n");
               foreach $name (keys %$switchref) {
                       $switch =  $switchref->{$name};
                       last unless(defined($name));
                       $self->print($switch->usage($component));
               }
            } else {
               $self->print("\n(this component has no switches)\n");
            }
	    $component->printUsageNotes;
            $self->print("*"x80,"\n");
	}
}

sub printUsageNotes
{
	my $self = shift();
}

sub printInvalidSwitches
{
   my $self = shift();

   my @missing = ();
   my @wrongType = ();

   foreach my $component (@NOCpulse::CommandLineApplicationComponent::Instances) {
      my $componentClass = ref($component);
      if ($component->hasSwitches) {
	 my $switchref = $component->get_switches;
	 foreach my $name (keys %$switchref) {
	    last unless(defined($name));

	    my $switch =  $switchref->{$name};

	    if ($switch->hasProblem($component)) {
	       if ($switch->get_isMissing) {
		  push(@missing, $switch);
	       } elsif ($switch->get_isWrongType) {
		  push(@wrongType, $switch);
	       }
	    }
	 }
      }
   }
   if (scalar(@missing) > 0) {
      $self->print("Missing arguments: ");
      foreach my $switch (@missing) {
	 $self->print('--'.$switch->get_name.' ');
      }
      $self->print("\n");
   }

   if (scalar(@wrongType) > 0) {
      $self->print("Wrong datatype:\n");
      foreach my $switch (@wrongType) {
	 $self->print('  --'.$switch->get_name.'='.$switch->get_value." must be ".
		      $switch->specAsType."\n");
      }
   }
  
}

sub printUsageAsXML
{
	my $self = shift();
        foreach my $component (@NOCpulse::CommandLineApplicationComponent::Instances) {
            my $componentClass = ref($component);
            if ($component->hasSwitches) {
	       my $invalidSwitches = '';
	       my $switchref = $component->get_switches;
               foreach my $name (keys %$switchref) {
                       my $switch =  $switchref->{$name};
                       last unless(defined($name));
		       my $switchXML = $switch->invalidSwitchAsXML($component);
		       if ($switchXML) {
			  $invalidSwitches .= $switchXML."\n";
		       }
               }
	       if ($invalidSwitches) {
		 $self->print($invalidSwitches);
	       }
            }
	}
}

sub registerSwitches
{
        my $self = shift();
	# NOTE: Override this and fill it with calls to 
	# $self->registerSwitch(name,spec,required,default,usage)
	# if your module needs switches. 
        return 1;
}

sub overview {
   # Override this with a method that returns a string that describes your
   # component.
   0
}

sub newNamed
{
        my $class = shift();
        my $name = shift();
        my $self = $class->new;
        $self->set_name($name);
        #$class->instances->{$name} = $self;
        return $self;
}

sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('usage');
	$self->addInstVar('switches');
}

sub initialize
{
	my $self = shift();
        $self->SUPER::initialize();
	$self->set_switches({});
	NOCpulse::CommandLineApplicationComponent::AddInstance($self);
	$self->registerSwitches;
	return $self;
}


sub switchesAreValid
{
	my $self = shift();
	my $switchref = $self->get_switches;
	my $result = 1;
	foreach my $name (keys(%$switchref)) {
		my $switch = $switchref->{$name};
		if (! $switch->isValid($self)) {
			$result = 0;
		}
	}
	return $result;
}

sub switchValue
{
        my ($self,$name) = @_;
        my $switch = $self->get_switches->{$name};
	if ($switch->get_required && (!defined($switch->get_value))) {
		return $self->get($name)
	} else {
		return $switch->get_value;
	}
}

sub hasSwitch {
   my ($self,$name) = @_;
   return exists($self->get_switches->{$name});
}

sub switch
{
   my ($self,$name) = @_;
   return $self->get_switches->{$name};
}

sub switchIsValid(<name>) {
   my ($self,$name) = @_;
   if (defined($self->get_switches->{$name})) {
      return $self->get_switches->{$name}->isValid($self);
   } else {
      Carp::cluck(ref($self)." asked for the nonexistent switch '$name'");
      exit(3);
   }
}

sub addSwitch
{
	my ($self,$name,$spec,$required,$defaultValue,$usage) = @_;
	my $switch = NOCpulse::CommandLineSwitch->newInitialized($name,$spec,$required,$defaultValue,$usage);
	$self->get_switches->{$name} = $switch;
}

sub hasSwitches {
   my $self = shift();
   my $switchref = $self->get_switches;
   return (keys(%$switchref));
}

sub print {
        my ($self,@list) = @_;
 
        if (ref($OutputTarget) eq 'SCALAR') {
                $$OutputTarget .= join("", @list);
        } else {
                print $OutputTarget @list;
        }
}

sub usageAsSql
{
	my $self = shift();
	my $switchesPtr = $self->get_switches;
	my $result;
	while (my ($key, $value) = each(%$switchesPtr)) {
		$result .= $value->usageAsSql($self)."\n";
	}
	return $result;
}

sub doesNotUnderstand
{
	my ($self,$class,$method,@parms) = @_;
	my ($op,$var) = split("_",$method,2);
        my $originalCall = $class."::".$method;
	if ( $op eq "get" ) {
		if ($var eq 'switches') {
        		return $self->SUPER::doesNotUnderstand($class,$method,@parms);
		} elsif ($self->has('switches')
			 && defined($self->get('switches'))
			 && exists($self->get('switches')->{$var})
			 && $self->switchIsValid($var)) {
		   return $self->switchValue($var);
        	}
	}
        return $self->SUPER::doesNotUnderstand($class,$method,@parms);
}

1;

__END__


=head1 NAME

NOCpulse::CommandLineApplicationComponent - an abstract superclass for classes that participate in the use of command line switches in an application.

=head1 SYNOPSIS

	package MyClass;
	use NOCpulse::CommandLineApplicationComponent;
	@ISA qw(NOCpulse::CommandLineApplicationComponent);
	
        sub overview {
            my $self = shift();
            return "This component provides access to a shell via ssh";
        }
        
        sub registerSwitches {
            my $self = shift();
            $self->SUPER::registerSwitches; # good practice
            $self->addSwitch('login','=s',1,'root@localhost','SSH login string');
            $self->addSwitch('command','=s',1,'/bin/true','Command to run');
        }
        
        sub doit {
            my $self = shift();
            my $login = $self->get_login;
            my $command = $self->get_command;
            return `ssh $login $command`
        }
        
        package main;
        
        use MyClass;        
        $thing = MyClass->newInitialized;
        if ($thing->commandLineIsValid) {
         print $thing->doit;
        } else {
         $thing->printUsage;
        }

=head1 DESCRIPTION

NOCpulse::CommandLineApplicationComponent helps you write modular command line applications without
having to worry about dealing with command line switch specifications and validation, and
without having to deal with writing help methods.

The typical NOCpulse::CommandLineApplicationComponent based application will have one or more subclasses
of this class, with one of them acting as a "driver" for the rest (e.g. it would be responsible
for dealing with a --help switch).

It is especially handy for doing "polymorphic command line apps", where documentation and
switch requirements change depending on other switches (e.g. you can have a switch in the
mainline that specifies one or more classes that must be used/instantiated dynamically).

=head1 REQUIRES

NOCpulse::PersistentObject, NOCpulse::CommandLineSwitch, Text::Wrap, Carp

=head1 MODULE VARIABLES

@Instances - holds all instances of if this class and its subclasses

=over 4

=cut

=head1 CLASS VARIABLES

=over 4

=item $OutputTarget

==cut

=head1 CLASS METHODS

=over 4

=cut

=item AddInstance()

Register an instance with the NOCpulse::CommandLineApplicationComponent class.  This is done
automatically as part of object construction - you should probably never call this.

=cut


=item commandLineIsValid()

(can also be called as an instance method) Called by the mainline logic in your application only once, this causes all switches in all 
components to calculate their validity.  If everything is valid, this returns true, else false.

=cut


=item printUsage()

(can be called as an instance method) Prints usage for all NOCpulse::CommandLineApplicationComponent instances in the current application.

=cut

=item printUsageNotes()

Callout for subclasses to add extra info to its usage - by default does nothing.

=cut


=item printUsageAsXML()

(can be called as an instance method) Prints usage for any components that have problems
with any command line switch.

=cut


=head1 INSTANCE METHODS

=over 4

=cut

=item registerSwitches()

Abstract method - you must override this in your subclass and make calls to addSwitch() if your
component needs switches.  This method gets called automatically during initialization of
the component.

=cut


=item overview()

Abstract method - you must override this and define it such that it returns a string describing
the component.

=cut

 
=item newNamed(<name>)
 
Overrides NOCpulse::PersistentObject behavior, which would cache the instance
Cpulse::
in a way that is not useful to us here ( NOCpulse::PersistentObject uses 
a hash, we want an array)
 
=cut
 

=item instVarDefinitions()

Defines the following variables:

   usage - (I don't think this is used - it's probably cruft)

   switches - A hash of all the switches this component defines/owns ( name=>value where
   value is an instance of NOCpulse::CommandLineSwitch)

=cut


=item initialize()

Initializes all switches.  If you override this in your subclass(es), be B<SURE> to call
$self->SUPER::initialize !!

=cut


=item switchesAreValid()

Returns true if switches are valid for B<this> component

=cut


=item switchValue(<name>)

Returns the value of the switch whose name is <name>.  You can get here via get_name as well
(see doesNotUnderstand).

=cut


=item hasSwitch(<name>)

Returns true if a switch whose name is <name> exists.

=cut


=item switch(<name>)

Returns the switch object whose name is <name>.

=cut


=item switchIsValid(<name>)

Returns true if a switch whose name is <name> is valid.

=cut


=item addSwitch(<name>,<spec>,<required>,<default>,<usage>)

Adds a NOCpulse::CommandLineSwitch object as described by the parameters to this method to the component.

<name> = the name of the switch
<spec> = the Getopt::Long specification for the switch
<required> = if true, the switch is required
<default> = default value for the switch (use undef if none exists)
<usage> = a string describing the switch

=cut


=item hasSwitches()

Returns a (possibly empty) list of the names of all switches defined for the component.

=cut


=item print()

Printing via this method allows you to redirect output to $NOCpulse::CommandLineApplicationComponent::OutputTarget,
which may be a glob or object or scalar.

=cut

=item usageAsSql()

Returns a string consisting of sql commands that update NOCpulse tables which describe
probes and their switches.

=cut


=item doesNotUnderstand()

Adds to NOCpulse::PersistentObject doesNotUnderstand logic such that calls to get_xxx will also
return the value of a switch whose name is xxx

=cut

=item FreeAllInstances()

Cause all instances of NOCpulse::CommandLineApplicationComponent to be cleared from memory (assuming
nothing else is holding on to them).

=cut
