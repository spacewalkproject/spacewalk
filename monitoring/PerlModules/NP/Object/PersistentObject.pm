package NOCpulse::PersistentObject;
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
use strict;
use vars qw(@ISA);
use Carp;
use NOCpulse::Object;
use NOCpulse::DBMObjectRepository;
use NOCpulse::INIObjectRepository;
use NOCpulse::MultiFileObjectRepository;

@ISA = qw(NOCpulse::Object);

sub databaseType
{
	my $class = shift();
	return $class->ConfigValue('databaseType');
}

sub databaseDirectory
{
	my $class = shift();
	my $dir;
	if (! ($dir = $class->getClassVar('databaseDirectory'))) {
		$dir = $class->ConfigValue('databaseDirectory');
	}
	if (! $dir ) {
		$dir = '.';
	}
	return $dir;
}

sub databaseFilename
{
	my $class = shift();
	my $fullPath = $class->databaseDirectory.'/'.$class.$class->databaseType->fileExtension;
}

sub database
{
	my $class = shift();

	if (!defined $class->getClassVar('database')) {
		my $database;
		$database = $class->databaseType->newInitialized($class->databaseFilename);
		$class->setClassVar('database',$database);
		return $database;
	} else {
		return $class->getClassVar('database');
	}
}

sub instances
{
	my $class = shift();

	if (!defined $class->getClassVar('objects')) {
		$class->ReleaseInstances;
	}
	return $class->getClassVar('objects');
}

sub ReleaseInstances
{
	my $class = shift();
	$class = ref($class) || $class;
	$class->setClassVar('objects',{});
}


sub named
{
	my ($class,$name) = @_;
	my $instances = $class->instances;
	if (exists($instances->{$name})) {
		return $instances->{$name};
	}
	return undef;
}

sub saveToDatabase
{	
	my $class = shift();

	my $objectDict = $class->instances;
	my $name;
	my $value;
	my $database;
	$database = $class->database;
	$database->open;
	while 	(($name,$value) = each(%$objectDict)) {
		$database->writeObject($name,$value);
	}
	$database->close;
}

sub loadFromDatabase
{
	my ($class,$instanceName,$useCache) = @_;
	my $value;
	if (defined($instanceName)) {
	   if ($useCache) {
		$value = Probe->named($instanceName);
	   }
	   unless($value) {
		my $database = $class->database;
		$database->open;
		$value = $database->readObject($instanceName);
		$database->close;
		my $instances = $class->instances;
		$instances->{$instanceName} = $value;
	   }

	} else {
		my $name;
		my $value;
		my $objectDict = $class->instances;
		my $database = $class->database;
		$database->open;
		my $keys = $database->keys;
		foreach $name (@$keys) {
			$value = $database->readObject($name);
			if (defined($value)) {
				$objectDict->{$name} = $value;
			}
		}
		$database->close;
		$value = $objectDict;
	}
	return $value;
}

sub newNamed
{
	my $class = shift();
	my $name = shift();
	my $self = $class->new;
	$self->set_name($name);
	$class->instances->{$name} = $self;
	return $self;
}

sub newInitializedNamed
{
	my ($class,$name,@params) = @_;
	my $self = $class->newNamed($name);
	$self->initialize(@params);
	return $self;
}

#INSTANCE METHODS

sub instVarDefinitions
{
	# NOTE: Subclasses MUST call $self->SUPER::instVarDefinitions
	# since this abstract class relies on having an instvar named
	# "name".  BTW - we also assume that you populate it with
	# unique values...
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('name');
}

sub persist
{
	my $self = shift();
	my $database;
	$database = ref($self)->database;
	$database->open;
	$database->writeObject($self->get_name,$self);
	$database->close;
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
        my $configval;
	if ( $op eq "get" ) {
                if ($self->{'name'}) {
         		# Go for instance level value first
                        $configval =  $self->configValue($self->{'name'},$var);
                }
                if (! $configval ) {
                     # if no instance level, try class level
                     $configval =  $self->configValue($var);
                }
                if ($configval) {
                    return $configval;
                }
	}
        Carp::confess("Message $class\:\:$message(".join(',',@params).
		      ") not understood\n\nTRACEBACK:\n");
}


1;

__END__

=head1 NAME

NOCpulse::PersistentObject - an abstract PERL class that provides a primitive persistence mechanism for named objects.

=head1 SYNOPSIS

	package MyClass;
	use NOCpulse::PersistentObject;
	@ISA qw(NOCpulse::PersistentObject);
	...
        my $thing = NOCpulse::PersistentObject->newInitializedNamed('hello');
        $thing->persist;
        $sameThing = NOCpulse::PersistentObject->loadFromDatabase('hello');


=head1 DESCRIPTION

NOCpulse::PersistentObject is a layer above Object that adds primitive object persistence via the
FreezeThaw based serialization mechanism defined in Object.

To set up this mechanism, you must:

* Set up an Object::SystemIni() file for the class hierarchy

And B<for each class> you must:

* Add a section to the SystemIni file whose name is the name of your class

* Add an item to that section called "databaseDirectory" whose value is
  a path to the directory where the instance database is to live

* Add an item to that section called "databaseType" whose value is the
  name of a properly fleshed out subclass of AbstractObjectRepository (for instance
  NOCpulse::DBMObjectRepository).
  
Classes derived from NOCpulse::PersistentObject will have an instance variable called "name"
defined for them.  The name variable is the means by which the persistence
mechanism keeps track of stored objects.  B<You must come up with a scheme that ensures
that each instance of a given class has a name value that is unique among all instances>.

Insofar as the name attribute is crucial to the inner workings of the persistence mechanisms, a number of new constructors are defined:

newNamed(<name>)
newInitializedName(<name>[,@opts])
loadFromDatabase(<name>)

You should use these instead of the Object constructors to ensure that the persistence
mechanism has everything set up properly.

=head1 REQUIRES

Object

=head1 EXPORTS

nothing

=head1 MODULE VARIABLES

$config - holds an Config::IniFiles instance if one was created with SystemIni()

=head1 CLASS VARIABLES

%classvars - holds hashes of "class instance" variables

=head1 MODULE METHODS

none

=over 4

=cut

# CLASS METHODS

=head1 CLASS METHODS

=over 4

=cut


=item databaseType()

Returns the name of the database type used to store objects of this class (as 
currently configured)

=cut


=item databaseDirectory()

Returns the path of the directory in which the databaseType will store objects of 
this class (as currently configured).  Looks first for a class variable called
databaseDirectory, then at the class ini section for an entry called databaseDirectory.

=cut


=item databaseFilename()

Returns the full path name of the file that databaseType will store objects in.

=cut


=item database()

Returns the database instance for this class

=cut


=item instances()

Returns a hash of all the instances of the class B<currently in memory>

=cut


=item named(<name>)

Returns the instance named <name> if it is currently in memory

=cut


=item saveToDatabase()

Saves all objects currently in memory to the repository. Also see persist() (below)

=cut


=item loadFromDatabase([<name> [, <use-cache]])


If called with no parameters, loads all objects from the repository into memory and returns
a pointer to the instances() hash

If called with the <name> parameter, loads the named object from the repository into memory
(adding it to the instances list) and returns the instance.

If called with <name> and <use-cache>, first checks for a cached instances and
returns it if present, otherwise loads as above.
=cut


=item newNamed(<name>)

Creates an instance of the class whose name is <name> in memory and returns it.

=cut


=item newNamed(<name>[,@params])

Creates an instance of the class whos name is <name> in memory, calls its initialize()
method with [@params], and returns the instance.

=cut


=head1 INSTANCE METHODS

=over 4

=cut


=item instVarDefinitions()

Same as that for Object, but B<Subclasses MUST call $self->SUPER::instVarDefinitions> if
they override this.

=cut


=item persist()

Writes the instance in question to the object repository immediately.

=cut


=item doesNotUnderstand(...)

Overrides AUTOLOADed get_xxx in Object behavior such that instances can retrieve values
from its class .ini file on a B<per instance> basis.

Explanation: If you set up a per-class .ini file according to Object::ConfigValue(), you
this extension to the get_xxx protocol allows you to exploit the fact that all instances
of NOCpulse::PersistentObject have a unique name.  Specifically, once you have an instantiated
NOCpulse::PersistentObject, a call to get_xxx (where xxx is any name) that would otherwise fail for
the lack of an instance variable will now first check to see if your class per-class
.ini file has a B<section> whose name is the name of the current instance. If such a
section is found, its namespace will be "added" to that of the instance virtually via
the get_xxx call.

=cut

