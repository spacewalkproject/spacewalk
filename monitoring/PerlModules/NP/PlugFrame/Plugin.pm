package Plugin;

use strict;
use vars qw(@ISA);

use NOCpulse::CommandLineApplicationComponent;
use NOCpulse::Module;
use NOCpulse::PlugFrame::Probe;
use NOCpulse::NPRecords;
use Getopt::Long;
use NOCpulse::Config;
use Data::Dumper;
use NOCpulse::SatCluster;
use NOCpulse::SetID;

@ISA=qw(CommandLineApplicationComponent);

my %statusMap = ('CRITICAL'=> 2,'WARN'=>1,'OK'=>0,'UNKNOWN'=>-1);

sub overview {
   return "This component drives execution of a probe class that you must specify.";
}

sub classVarDefinitions
{
	my $class = shift();
	my $class = ref($class) || $class;

	if (! $class->getClassVar('NPConfig')) {
		$class->setClassVar('NPConfig',NOCpulse::Config->new);
	}

	if (! $class->getClassVar('Cluster')) {
		$class->setClassVar('Cluster',SatCluster->newInitialized($class->getClassVar('NPConfig')));
	}
}

sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('probeModule');
	$self->addInstVar('shellModule');
        $self->addInstVar('npconfig');
	$self->addInstVar('cluster');
        $self->addInstVar('definition');
	$self->addInstVar('isValid',1);
}

sub loadClass
{
	my ($self,$className) = @_;
	my $libdir = $self->get_libdir;
	unless ($libdir) {
		$libdir = $self->configValue('probeClassLibraryDirectory');
	}

        my ($status,$errors) = Module::load($className, $libdir, ['NOCpulse::PlugFrame','NOCpulse']);
 
        if (! $status) {
                $self->print("Configuration error - unable to load $className:\n");
                my $attempt = 0;
                map { $self->print("Attempt ".($attempt + 1)." = ".$$errors[$attempt]."\n");$attempt ++} @$errors;
                return $self->exit;
        }


}

sub registerSwitches
{
	my $self = shift();
	$self->SUPER::registerSwitches;
	$self->addSwitch('probe','=s',1,undef,'Specify the probe class or instance ID to use');
	$self->addSwitch('shell','=s',0,$self->configValue('defaultCommandShell'),'Specify the type of shell to use (if required)');
        $self->addSwitch('debug','=i',0,0,'Execute with debug level set to this number.  Support varies from module to module.');
        $self->addSwitch('saveid','=i',0,0,'Save configuration (do not run probe) to the object database with ID equal to this value');
        $self->addSwitch('libdir','=s',0,undef,'Use this library directory instead of the one defined in the framework configuration file');
	$self->addSwitch('xmlUsage','',0,'','Print usage as XML');
	$self->addSwitch('help','',0,'','Print this help');

	# This will go away soon...it's been replaced by the catalog script
	$self->addSwitch('catalog','',0,'','Obsolete: use catalog script instead');
}

sub setupDebugging {
	my $self = shift();
	# Note - this can only be called after switchesAreValid is called as
	# CommandLineApplicationComponent doesn't actually claim switch values
	# 'til then.
	if ($self->get_debug) {
		my $debugLevel = $self->get_debug;
		$self->debugObject()->addstream(LEVEL=>$debugLevel);
		$self->dprint($debugLevel,"Debugging set to $debugLevel\n");
	}
}


sub initialize
{
	my ($self,$probeRecord) = @_;

	$self->classVarDefinitions;
        $self->set_npconfig($self->getClassVar('NPConfig'));
	$self->set_cluster($self->getClassVar('Cluster'));

	if (! defined($Object::config)) {
        	Object::SystemIni($self->get_npconfig->get('PlugFrame','configFile'));
	}

	$self->SUPER::initialize;

        if ($self->configValue('requiredUser')) {
		$self->ensureIsRequiredUser;
        }

	if (! $self->switchesAreValid) {
              if ($self->get_catalog) {
		 # Old usage, tell them what to do and bail.
		 $self->print("\nNOTE: Run /home/nocpulse/libexec/catalog to get a catalog of probes.\n\n");
		 exit;

              } else {
                 $self->print("Configuration error\n");
                 $self->printUsage($self->get_xmlUsage);
                 return $self->exit;
              }
	} else {
		$self->setupDebugging;
	}

	my $probeSwitch =  $self->switchValue('probe');
        
        if ($probeSwitch  =~ /^\d*$/) {
		# This is a probe ID
		$self->initFromProbeId($probeSwitch, $probeRecord);

        } else {
                # Not an ID, so it should be the class name
		$self->initFromProbeClass($probeSwitch, $probeRecord);
	}
	if ($self->switchValue('help')) {
               $self->printUsage($self->get_xmlUsage);
               return $self->exit;
               # Does not return

	} elsif ( ! $self->commandLineIsValid ) {
	       $self->set_isValid(0);
               $self->printUsage($self->get_xmlUsage);
	       $self->printInvalidSwitches($self->get_xmlUsage);
               return $self->exit;
               # Does not return
	}

	if ($self->switchValue('saveid')) {
               # Save the probe instance to the object database with the given ID
               $self->get_probeModule->persist; # Magic happens :)
               $self->get_probeModule->set_status('OK');
               #$self->print("Saved probe with id ".$self->switchValue('saveid').' to object database');
               return $self->exit;
       }
       return $self;
}

sub run
{
	my ($self) = @_;
	# Probe object is defined unless it's been deleted
	# from the probe DB while the probe was running.
	my $probe = $self->get_probeModule;
	if ($probe) {
	   $probe->_run(1);
	}
	return $self->exit;
}

sub runAndDump
{
	my ($self) = @_;
	$self->get_probeModule->_run(1);
	$self->dprint(1,$self->printString);
	return $self->exit;
}

sub pluginStatusMessage
{
	my $self = shift();	
	if ($self->get_probeModule) {
		return $self->get_probeModule->get_status.': '.
		  $self->get_probeModule->statusMessage;
	} else {
		return "UNKNOWN: Configuration error: cannot find probe module\n";
	}
}

sub exitLevel
{
	my $self = shift();
	if ($self->get_probeModule) {
		return $statusMap{$self->get_probeModule->get_status()};
	} else {
		return 'UNKNOWN';
	}
}

sub exit
{
	my $self = shift();
	print $self->pluginStatusMessage;
	exit($self->exitLevel);
}

sub printUsage {
   my ($self,$xmlUsage) = @_;
   $self->dprint(1,$self->printString);
   if ($xmlUsage) {
   	$self->printUsageAsXML;
   } else {
   	$self->SUPER::printUsage;
   }
}

sub printInvalidSwitches {
   my ($self,$xmlUsage) = @_;
   if (!$xmlUsage) {
      $self->SUPER::printInvalidSwitches;
   }
}

# Exits if not running as the required user.
sub ensureIsRequiredUser
{
   my ($self, $requiredUser) = @_;
   if ($requiredUser) {
      if ( $< == 0) {                                      
	 if (getpwnam($requiredUser) > 0) {
		NOCpulse::SetID->new( username => $requiredUser)->su(permanent=>1);
	 } else {
	    $self->print("\n!!ERROR!! No $requiredUser user found - ending run\n\n");
	    exit(-1);
	 }
      } elsif (! (getpwuid($<) eq $requiredUser)) {
	 $self->print("\nERROR: Plugins must be run as user ".$requiredUser.', but you are currently '.getpwuid($<)." - ending run.\n\n");
	 exit(-1);
      }
   }
}

# Initializes a probe from its class name.
sub initFromProbeClass
{
	my ($self, $probeClass, $probeRecord) = @_;
	$probeClass =~ s/(.*)\.pm/$1/g;
	$self->loadClass($probeClass);

	if ($self->switchValue('saveid')) {
		# Saving this one in the probe database.
		$probeRecord = $self->getDummyProbeRecord(@ARGV) unless $probeRecord;
		$self->set_probeModule($probeClass->newInitializedNamed($self->switchValue('saveid'),$self,$probeRecord));
	} else {
		# Not saving, so don't try to save state.
		ProbeState->setClassVar('databaseDirectory', '/dev/null');
		$self->set_probeModule($probeClass->newInitialized($self));
	}
	my $shellClass = $self->switchValue('shell');
	if ($self->get_probeModule->needsCommandShell) {
       		$self->loadClass($shellClass);
       		$self->set_shellModule($shellClass->newInitialized());
       	}
	# Assign the shell module directly to the probe, so that it is
	# present in the probe DB for use after thawing.
	$self->get_probeModule->set_shellModule($self->get_shellModule);
}

# Initializes a probe from the probe cache or database.
sub initFromProbeId
{
	my ($self, $probeId, $probeRecord) = @_;

	my $probe = Probe->loadFromDatabase($probeId, 'try-cache');

	if (! $probe) {
		$self->print('Unable to load probe with instance ID='.$probeId."\n");
		return $self->exit;
        }

	$self->loadClass(ref($probe)); # Now load the relevant class definition

	$probe->set_probeRecord(ProbeRecord->Called($probeId));

	# (Next one is sort of kludgy)
	CommandLineApplicationComponent::AddInstance($probe); # Let the framework know about it too
	$self->set_shellModule($probe->get_shellModule); # Re-wire the shell instance
	if ($self->get_shellModule) {
	   $self->loadClass(ref($self->get_shellModule));  # ...and load its class definition
	   CommandLineApplicationComponent::AddInstance($self->get_shellModule); # Let the framework know about it too
	}
	$probe->set_plugin($self); # Tell probe instance it belongs to me now
	$self->set_probeModule($probe); # Tell me I own the probe instance
}


###################################################################
### The status methods are for backward compatibility with probes
### that wanted to converse with their status at the plugin level,
### which is where it used to be.
sub get_status
{
	my $self = shift();
	return $self->get_probeModule->get_status;
}
sub set_status
{
	my ($self,$value) = @_;
	return $self->get_probeModule->set_status($value);
}
###################################################################

# Returns a dummy probe record so that things can more or less run from the command line.
sub getDummyProbeRecord {
   my $self = shift();
   my %rec =
     (
      'RECID' => $self->get_saveid,
      'PROBE_TYPE' => 'ServiceProbe',
      'CUSTOMER_ID' => 0,
      'CHECK_INTERVAL' => 5,
      'RETRY_INTERVAL' => 5,
      'MAX_ATTEMPTS' => 1,
      'parsedCommandLine' => \@ARGV,
      'hostName' => 'None',
      'hostRecid' => 0,
      'DESCRIPTION' => 'None',
      'NOTIFY_WARNING' => '0',
      'NOTIFY_CRITICAL' => '0',
      'NOTIFY_RECOVERY' => '0',
      'NOTIFICATION_PERIOD' => 1,
      'NOTIFICATION_INTERVAL' => 60,
      'contactGroupNames' => [ 'ignoreMe' ],
      'LAST_UPDATE_USER' => 'nobody',
      'LAST_UPDATE_DATE' => 'never',
     );
   ProbeRecord->ReleaseAllInstances;
   return ProbeRecord->newFromHash(\%rec, 'RECID');
}


package MemoryPlugin;

use strict;
use vars qw(@ISA);
@ISA=qw(Plugin);
use NOCpulse::Scheduler::Event::PluginEvent;
use Data::Dumper;

sub initialize {
   my ($self,$probeRecord) = @_;
   $self->SUPER::initialize($probeRecord);
   return $self;
}

sub asInitialEvent
{
	my $self = shift();
	my $event = NOCpulse::Scheduler::Event::PluginEvent->new($self->get_probeModule->get_name);
	my $probeRec = $self->get_probeModule->get_probeRecord($event->id);
	if (! defined($probeRec)) {
	   print STDERR "No probe record found for probe ", $event->id, "\n";
	} else {
	   $event->time_to_execute($self->get_probeModule->nextRunTime);
	   if ($probeRec->get_PARENT_PROBES_ID) {
	      $event->subscribe_to('childOf-'.$probeRec->get_PARENT_PROBES_ID);
	   }
	}
	return $event;
}

sub exit {
   my $self = shift();
   return $self;
}

package ScheduledPlugin;

use strict;
use vars qw(@ISA);
@ISA=qw(Plugin);
use NOCpulse::Scheduler::Message;

sub initialize {
	my ($self,$recid) = @_;
	my $args = ["--probe=$recid"];
	@ARGV=@$args;
	DBMObjectRepository->CacheHandles(0);
	$self->SUPER::initialize();
	return $self;
}

sub run
{
	my $self = shift();
	return $self->SUPER::run();
}

sub handleTimeout
{
	my $self = shift();
	$self->get_probeModule->handleTimeout;
	return $self->exit;
}

sub exit {
	my $self = shift();
	print $self->pluginStatusMessage;
	my $probe = $self->get_probeModule;
	if ($probe) {
		return $probe->nextRunTime, undef;
	} else {
		return undef,undef;
	}
}

sub removeStatusFile
{
	my $self = shift();
	my $filename = $self->get_probeModule->get_probeRecord->get_RECID;
        my $fullPath = "/home/nocpulse/var/status/$filename";
        return unlink($fullPath);
	# Ridiculous - this appears to be the only reason we're using NSStatus.  The code above
	# accomplishes the same thing.
	#return NSStatusFile->newInitialized->remove($self->get_probeModule->get_probeRecord->get_RECID);
}

1;

__END__

=head1 NAME

Plugin - NOCpulse style plugin "driver" class

=head1 SYNOPSIS

   use NOCpulse::PlugFrame::Plugin; 
   Plugin->newInitialized->run;


=head1 DESCRIPTION

Plugin is a "driver" class that implements NOCpulse style plugin probes.  It is a
"driver" in that its intent is to be that of the "mainline" for a probe (it
is not intended to be subclassed).

Plugin provides for dynamic loading of probe classes and support for dynamically loading
shell access classes.

=head1 REQUIRES

Perl 5.004, CommandLineApplicationComponent, Getopt::Long, NOCpulse::Config;

=cut


=head1 CLASS VARIABLES

=over 4

=item %statusMap

A hash that translates a status name to an exit level:

CRITICAL = 2

WARN = 1

OK = 0

UNKNOWN = -1

=cut


=head1 INSTANCE METHODS

=over 4

=item instVarDefinitions()

Defines the following:

probeModule - holds a pointer to an instance of the probe module for the current execution

shellModule - holds a pointer to an instance of a CommandShell subclass (if the probeModule requires one)

npconfig - holds a pointer to a NOCpulse::Config object

cluster - holds a pointer to a NOCpulse::SatCluster object

definition - holds the configuration database record for the current instance - only present when running in scheduler

isValid - true or false depending on whether the command line is valid

=cut


=item registerSwitches()

Defines the following:

probe - the name of the class (module) to load/run

shell - the name of the shell class to use (if required)

debug - sets a debug level available to any module that requests it through the Plugin instance

saveid - number to save instance to object database with

libdir - override for configured library directory

help - prints help

=cut


=item initialize()

Sets up Object::SystemIni(), validates Plugin switches,  loads the
probe class and instantiates it, loads the shell class and instantiates it if the probe
class reports needsCommandShell, validates the probe instance and shell instance switches.

=cut


=item run()

Sends the probe a "run" message, then calls exit()

=cut


=item runAndDump()

Debugging tool.  Sends the probe a "run" message, calls $self->printString for a comprehensive dump of all
instantiated objects for the run to stdout, then calls exit()

=cut


=item pluginStatusMessage()

Constructs a properly formatted status message from the list of messages created
via calls to addStatusString() (above)

=cut


=item exitLevel()

Returns the numeric version of the current named status

=cut


=item exit()

Exits in the way by printing pluginStatusMessage() and exiting with exitLevel()

=cut

