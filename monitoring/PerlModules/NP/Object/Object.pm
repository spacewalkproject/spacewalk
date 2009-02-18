package NOCpulse::Object;
#
# Copyright (c) 2009 Red Hat, Inc.
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
$VERSION = (split(/\s+/, q$Id: Object.pm,v 1.26 2003-07-18 02:28:17 cvs Exp $, 4))[2];

use strict;
use vars qw(@ISA $AUTOLOAD $DEBUGOBJECT %classvars $config);
use Carp;
use Config::IniFiles;
use FreezeThaw qw(freeze safeFreeze thaw);
use NOCpulse::Debug;



# MODULE (NON-CLASS) METHODS

# By default when NOCpulse::Object loads up it
# looks to see if there's an environment
# variable called SYSTEM_INI - if it finds
# it it loads an iniconf instance based
# on the file specified.  Programs can
# explicitly force a load by calling
# NOCpulse::Object::SystemIni from wherever 
# they want.  Useful if the program wants
# a command line switch to get the path to
# the ini file, etc.

$DEBUGOBJECT = NOCpulse::Debug->new; # default debug object
#$DEBUGOBJECT->addstream(LEVEL=>1);

SystemIni($ENV{'SYSTEM_INI'});

sub SystemIni
{
	my $inifile = shift();
	if ( ($inifile) && (-e $inifile) ) {
		$config = Config::IniFiles->new( -file=>$inifile);
	}
}

# CLASS METHODS AND VARIABLES


sub ClassBasename
{
	my $class = shift();
	$class = ref($class) || $class;
        my @parts = split("::",$class);
        return pop(@parts);
}

sub Config
{
        my ($class) = @_;
        $class = ref($class) || $class;
	return $config;
}

sub ConfigValue
{
        my ($class,$name,$item) = @_;
        $class = ref($class) || $class;
	if ( defined($config) ) {
		if (defined($item)) { # We're going for a per-class ini file item
			if ($class->ClassConfig) {
				return $class->ClassConfig->val($name,$item);
			} else {
				$class->doesNotUnderstand($class,'ConfigValue',$name,$item);
			}
		} else {
			if (defined($config->val($class,$name))) {
        			return $config->val($class,$name);
			}
		}
	} 
	return undef;
}

sub ClassConfig
{
        my $class = shift();
	if ( defined($config->val($class,'ini'))) {
		# There's an individual INI file for this class
		if (! defined($class->getClassVar('config'))) {
			# Need to initialize this class' Config::IniFiles instance
			my $config = Config::IniFiles->new( -file=>$config->val($class,'ini'));
			$class->setClassVar('config',$config);
		} 
	}
	return $class->getClassVar('config');
}

sub Superclass
{
	my $class = shift();
	$class = ref($class) || $class;
	my @SC    = eval "\@${class}::ISA";
	return shift(@SC);
}


# This bit of hackery gives us something like class instance variables.  It's
# not pretty at all, but it's useful.

# This dictionary holds a dictionary for each class that makes use of it.
# The value for each of these is in turn a dictionary which contains
# named variables.

%classvars = ();

# These should be called as <class>->xxxClassVar so we can know what
# class you're coming from.

sub getClassInstVar
{
	my ($class,$varname) = @_;
	$class = ref($class) || $class;
	my $classInstance = $classvars{$class};
	if (exists($classInstance->{$varname})) {
		return $classInstance->{$varname}
	} else {
		if ($class->Superclass) {
			my $super = $class->Superclass;
			return $super->getClassInstVar($varname);
		} else {
			return undef
		}
	}
}

sub getClassVar
{
        my $class = shift();
        my $varname = shift();
        $class = ref($class) || $class;
        my $classInstance = $classvars{$class};
        return $classInstance->{$varname};
}


sub setClassVar

{
	my $class = shift();
	my $varname = shift();
	my $value = shift();
	$class = ref($class) || $class;
	if (! defined($classvars{$class})) {
		$classvars{$class} = {};
	}
	my $classInstance = $classvars{$class};
	$classInstance->{$varname} = $value;
}


############ debugging support ##########################


sub setDebugObject
{
	my ($selfishness,$debug) = @_;
	if (ref($selfishness)) {
		# I am an instance, so.....
		$selfishness->addInstVar('debugObject',$debug);
	} else {
		# I am a class, so....
		$selfishness->setClassVar('debugObject',$debug);
	}
}

sub defaultDebugObject
{
	return $DEBUGOBJECT;
}

sub debugObject
{
	my $selfishness = shift();
	if (ref($selfishness)) {
		# I am an instance that might have it's own debugObject
		if ($selfishness->has('debugObject') and defined($selfishness->get('debugObject'))) {
			return $selfishness->get('debugObject');
		}
	}
	# I am a class or an instance that has no private debugObject
	my $debug = $selfishness->getClassInstVar('debugObject');
	if (! $debug) {
		return $selfishness->defaultDebugObject;
	} else {
		return $debug;
	}
}

sub dprint
{
	my ($selfishness,$level,@msgs) = @_;
	if (my $debug = $selfishness->debugObject) {
		$debug->dprint($level,@msgs);
	}
}

############ end debugging support ##########################

sub new
{ 	
	my $self = shift();
	my $class = ref($self) || $self;
	$self = {};
	bless $self,$class;
	$self->_initialize;
	return $self;
}

sub newInitialized
{
        my ($class,@params) = @_;
	$class = ref($class) || $class;
	my $self = $class->new;
	my $thing = $self->initialize(@params);
	# DAP Late change on this, may break MUCH STUFF!!!  Beware!!!
	if (defined($thing)) {
		#print ref($self)." Returning a ".ref($thing)."(".$thing.")\n";
		return $thing;
	} else {
		#print "Returning self ".ref($self)."\n";
		return $self;
	}
}

sub fromStoreString
{
	my $class = shift();
	$class = ref($class) || $class;
	my $frozenSelf = shift();
	my ($self) = thaw $frozenSelf;
	return $self;
}


# INSTANCE METHODS

sub _initialize
{
	my $self = shift();
	$self->instVarDefinitions;
	return $self;
}

sub instVarDefinitions
{
	my $self = shift();
	# subclasses should override to add inst vars but should be sure
	# to use SUPER::instVarDefinitions so that superclass variables get built too
	return $self;
}

sub addInstVar
{
	my ($self, $varname, $value) = @_;
	return $self->{$varname} = $value; #could be undefined - that's ok.
}

sub initialize
{
	my $self = shift();  #the new and newInitialized allow the caller to pass additional
					# parameters to the constructor - subclasses can 
					# access these in the initialize method and use them
					# as they see fit.  Use a line like this to get them.
	return $self;
}

sub printIndents
{
	my $indents = shift()||0;
	my $tabs="";
	$tabs  .= "\t" x $indents;
	return $tabs;
}

sub printHash
{
	# This isn't part of the object - it's a utility for recursively printing hash contents
	# (the recursive part isn't in here yet)
	my $hashptr = shift();
	my $indents = shift();
	my $traversal = shift();
	my %hash = %$hashptr;
	my $hashkey;
	my $value;
	my $result = "";
	foreach $hashkey ( keys(%hash)) {
		$value = $hash{$hashkey};
		$result .= printIndents($indents)."Key: ".$hashkey."\tValue: |$value|\n";
		$result .= printThing($value,$indents + 2,$traversal);
	}
	return $result;
}

sub printArray
{
	# This isn't part of the object - it's a utility for recursively printing array contents
	# (the recursive part isn't in here yet)
	my $arrayptr = shift();
	my $indents = shift();
	my $traversal = shift();
	my $result = "";
	my $value;
	foreach $value ( @$arrayptr ) {
		if ( ref($value) eq "" ) {
			$result .= printIndents($indents)."|".$value."|\n";
		} else {
			$result .= printThing($value,$indents + 2,$traversal);
		}
	}
	return $result;
}

sub printThing
{
	# This isn't part of the object - it's a utility for recursively printing array contents
	# (the recursive part isn't in here yet)
	my $value = shift();
	my $indents = shift();
	my $traversal = shift();
	my $result = "";
	#print "PRINTING A THING ".ref($value)." = ".$value."\n";
	if ( ! ref($value) eq "" ) {
		if ( ref($value) eq "HASH" ) {
			$result .= printHash($value,$indents ++,$traversal);
		} elsif ( ref($value) eq "ARRAY" ) {
			$result .= printArray($value,$indents ++,$traversal);
		} elsif ( ref($value) eq "GLOB" ) {
			$result .= $value;
		} else {
			# Assume it's an object of some kind...
			if ($value->can('printString')) {
				$result .= $value->printString($indents ++,$traversal);
			} else {
				$result .= $value;
			}
		}
	}
}

sub printString
{
	my ($self,$indents,$traversal) = @_;
	if (!defined($indents)) {
		$indents = 0; #optional - used by the other printers...
	}
	my $result = "";
	if (! $traversal) {
		$traversal = {};
	}
	$result .= printIndents($indents).$self."\n";
	while (my ($key,$value) = each (%$self)) {
		if ($value && ref($value) eq "") {
			#if (! exists($traversal->{scalar($self)})) {
				$result .= printIndents($indents)."\t$key\t=\t|$value|\n";
			#}
		}
	}
	while (my ($key,$value) = each (%$self)) {
		if (ref($value) ne "") {
			if (! exists($traversal->{scalar($value)})) {
				$result .= printIndents($indents)."\t$key\t= ".ref($value)."(\n";
				$traversal->{scalar($value)}=1;
				$result .= printThing($value,$indents + 2,$traversal);
				$result .= printIndents($indents + 1).")\n";
			}
		}
	}
	return $result;
}

sub asString
{
	return shift()->printString;
}

sub storeString
{
	my $self = shift();
	return freeze $self;	
}

sub configValue
{
        my ($self, $name, $item) = @_;
        return ref($self)->ConfigValue($name,$item);
}

sub has {
   return exists($_[0]->{$_[1]})
}

sub get {
   return $_[0]->{$_[1]};
}

sub set {
   my ($self,$varname,$value) = @_;
   $self->{$varname} = $value;
}

sub delete {
   return delete $_[0]->{$_[1]};
}


sub doesNotUnderstand
{
	my ($self,$class,$message,@params) = @_;
	my ($op,$var) = split("_",$message,2);
	if ( $op =~ /get|getPtr|set|has|delete/ ) {
                if ($op eq 'has') {
                   return $self->has($var);
                }
		if ( $self->has($var) )  {
                        if ($op eq 'delete') {
                           return $self->delete($var);
                        }
			if ( $op eq "set" ) {
				$self->set($var,@params);
			}
			# This will always return a reference
			return $self->get($var);
		}
	}
	Carp::confess("Message $class\:\:$message(".join(',',@params).
		      ") not understood\n\nTRACEBACK:\n");
}

sub DESTROY 
{ # Don't need this, but if it's defined apparently we then won't try to 
  # autoload it.
	#my $self = shift();
	#print "DESTROY: $self\n";
	1;
}

sub AUTOLOAD
{

	# Defines accessor methods set_<varname> and get_<varname> for all 
	# instance variables in the object
	my $self = shift();
	# Next line: Thanks Jay and Bob!
	my ($class,$method) = ($AUTOLOAD =~ /(.*)::(.*)$/);
	return $self->doesNotUnderstand($class,$method,@_);
}


=head1 DIAGNOSTICS

none

=head1 AUTHOR

David A. Parker, dparker@nocpulse.com

=head1 SEE ALSO

FreezeThaw, Config::IniFiles, perlobj, perltoot

=cut

1;


=head1 NAME

NOCpulse:: Object - an abstract PERL class that tries and fails to cover up the ugliness that is OO in Perl, amongst other things.

=head1 SYNOPSIS

	package MyClass;
	use NOCpulse::Object;
	@ISA qw(NOCpulse::Object);
	...


=head1 DESCRIPTION

NOCpulse::Object is an attempt to simplify the task of
building class hierarchies under Perl.  It has a few "extras" that make
writing applications a bit easier as well.  Specifically, NOCpulse::Object...

	...defines a protocol for instance creation
	...defines a protocol for instance variable creation
	...defines a protocol for accessing instance variables
	...defines a protocol for "dumping" the contents of an object
	...defines a protocol for "Class Instance" variables
	...wraps the FreezeThaw mechanism to help facilitate very primitive persistence
	...provides global class-side access to a user-specified .INI file a la Config::IniFiles


=head1 REQUIRES

Perl 5.004, Carp, Config::IniFiles, FreezeThaw

=head1 EXPORTS

nothing

=head1 MODULE VARIABLES

$config - holds an Config::IniFiles instance if one was created with SystemIni()
$DEBUGOBJECT - holds the default debug instance

=head1 CLASS VARIABLES

$classvars - holds hashes of "class instance" variables

=head1 MODULE METHODS

=over 4

=cut


=item SystemIni($inifile)

This method accepts the name of an .ini file (a la Config::IniFiles) and initializes
the module $config variable with an instance of Config::IniFiles based on that file. Note
that this is a global change - it applies to all subclasses and their instances for the execution
of the current program.

=cut


=head1 CLASS METHODS

=over 4

=cut

=item ClassBasename()
	
        Class or object method to return just the last part of a
	PERL class name (i.e. gets rid of leading path parts (e.g. Something::Basename)

=cut


=item Config()

Returns a pointer to the Config::IniFiles instance that was created when
SystemIni() was called.

=cut


=item ConfigValue($name[,$item])

Retrieves the value of the item $name in the section ref($class) of the
.ini file specified when SystemIni() was called.  This is analogous to
putting your class variables in an .ini file (and is B<very> handy).

This method includes a mechanism for dealing with individual per-class
.ini files as well as follows:

* you must include an entry in the SystemIni (above) within the section
  for this class called "ini" (e.g. ini=MyOther.ini).

* when you call ConfigValue, you must pass both a section name and an item
  name ($item) as opposed to just an item name.

If you do these things, an Config::IniFiles instance will be created and stored as
a class instance variable for the class in question whose name is "config",
and this method will defer any section,item requests to that instance rather
than to the instance created for the file specified with SystemIni.

=cut


=item getClassInstVar($name)

Returns the value of the "class instance" variable whose name is $name (if any).  Walks up
the inheritance tree to find the value in question.

=cut


=item getClassVar($name)

Returns the value of the class variable whose name is $name (if any).

=cut


=item setClassVar($name,$value)

Sets the value of the class variable whose name is $name to the
value $value.  You can retrieve the value of $name via either
getClassVar or getClassInstVar (see above).

=cut


=item setDebugObject(<NOCpulse::Debug instance>)

Set the debug object for the entity in question.
NOTE that how this is called has tremendous bearing on
what it does.  If you call it from the perspective of
an instance, a private debug instance will be stored for
the instance in question.  If you call it from the 
perspective of a class, a class variable will be stored
which will be retrieved via the class instance variable
mechanism (meaning that 'inheritance' will occur).

=cut


=item defaultDebugObject()

Returns the default debug object.  You can override this.  By default
it returns an instance that was built when the NOCpulse::Object module was loaded.
The module in question will have a single level 1 literal stream in it.

=cut


=item debugObject()

Returns the debug object (if any) for the entity in question.  This can 
be called from either a class or an instance perspective.  If called in
an instance perspective, a check is performed to see if the instance
in question has its own debug object (and returns it if true).  Otherwise
or if the calling context is from that of a class, attempts to retrieve
a class instance version of a debug object (see setDebugObject and getClassInstVar).
Failing all of that it returns defaultDebugObject().

=cut


=item dprint(<$level>,<@msgs>);

Prints @msgs via $self->debugObject (regardless of whether $self
is an instance or a class) at level $level.

=cut


=item new()

Creates a new instance of the class, ensuring that all instance variables are built
via the instVarDefinitions() method (below).

=cut


=item newInitialized(@parameters)

Creates a new instance of the class via a call to new(), then calls its
initialize() method, passing anything that you passed as a parameter on to it.

Your override B<must return whatever you want the result of the call to the constructor
to be - THIS IS VERY IMPORTANT!! Default behavior is to return the instance, and
usually that is what you will want to do as well>

=cut
	

=item fromStoreString()

Re-creates an instance of an arbitrary class from a string created by the storeString()
method.  Uses the FreezeThaw thaw() method.

=cut


=head1 INSTANCE METHODS

=over 4

=item instVarDefinitions()

Subclasses that wish to define instance variables should override this method.  The
override implementation should contain a call to $self->SUPER::instVarDefinitions 
followed by one or more calls to $self->addInstVar().

NOTE: it is possible to bypass this step and make calls to addInstVar() or even just
make calls to set_xxx or set() methods (described below) in an ad-hoc fashion.  The
reasoning behind the instVarDefinitions()  mechanism is that explicit definitions
of instance variables adds substantially to code clarity.

=cut


=item addInstVar($name[,$value])

Defines an instance variable for the instance whose name is $name and whose (optional)
value is $value.  Variables defined in this manner can be accessed via the get_ and set_
methods that get "AUTOLOADed" as described below.

=cut


=item initialize(@parameters)

Subclasses who wish to have an initialization sequence beyond what happens in
instVarDefinitions() should override this.  This method will recieve any parameters
that might have been passed to ref($self)->newInitialized(), so your override can
use that information as necessary.  B<Your override should return whatever you want
the result of the constructor call to be if you're calling this via newInitialized()!!
Usually you'll want this to be the instance, which is what the default behavior is here>

=cut


=item printString()

Returns a string that expresses the contents of the object.  This method does
a dump of every instance variable in a given instance, and and in addition
will descend into any other classes that it finds along the way. The abstract
implementation is useful as a diagnostic.  Smalltalk fans may wish to override
this in class-specific ways.


=cut


=item asString()

Calls printString() (above)

=cut


=item storeString()

Returns a "frozen" version of the current instance in the form of a string via 
the FreezeThaw freeze() method.  The string can be stored in a file for later "thawing"
via a call to NOCpulse::Object->fromStoreString() (above).  

B<NOTE:> No clamping is performed - if you have self-referential instances you will get
EVERYTHING when you call this.  If you are planning on doing object persistence with this
mechanism, do some sort of hash table lookup reference instead.

=cut


=item configValue($name[,$item])

Calls the class side ConfigValue() method (above) and returns its result.

=cut


=item has($name)

Returns true if an instance variable called $name exists for the instance in question.
Calls to this method can be constructed as "$self->has_name()"; see AUTOLOAD below

=cut


=item get($name)

Returns the value of the instance variable called $name.  Calls to this method can be
constructed as "$self->get_name()" see AUTOLOAD below

=cut

=item set($name,$value)

Sets the value of the instance variable called $name to $value.  Calls to this method can be
constructed as "$self->set_name($value)" see AUTOLOAD below

=cut


=item delete($name)

Removes the the instance variable called $name from the instance in question.  
Calls to this method can be constructed as "$self->delete_name()" see AUTOLOAD below

=cut


=item doesNotUnderstand($class,$message,@params)

Called by AUTOLOAD (see below) if the message sent to the object
cannot be resolved.  This method gives you a chance to catch these things and
provide AUTOLOAD like behavior, but with inheritance.  The fallthrough behavior
is to croak with an informative message.

One of the really nice things about NOCpulse::Object is that you will not have to worry about
goofy hash dereferencing to get at your variables. NOCpulse::Object uses the doesNotUnderstand
mechanism to generate has_, get_, set_, and delete_ methods for you.

As an example, if you defined instance variables thusly...

	sub instVarDefinitions
	{
		my $self = shift();
		$self->addInstVar('foo');
		$self->addInstVar('bar');
	}

..., your instance will (from that point on) behave as if a number of accessor methods
had been defined for it as well, so...

	my $object = MyClass->newInitialized;
	$object->set_foo('a value');
	$object->set_bar('another value');
	print $object->get_foo." ".$object->get_bar."\n";

...will work nicely.


=cut

