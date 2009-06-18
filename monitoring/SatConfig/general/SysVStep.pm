package SysVStep;
use NOCpulse::CommandLineApplicationComponent;
@ISA=qw(NOCpulse::CommandLineApplicationComponent);
use NOCpulse::LocalCommandShell;
use NOCpulse::SetID;
use NOCpulse::Object;
use Data::Dumper;

$NOCpulse::Object::CACHEACCESSORS = 0;
$LibMode = 0; # If true, initialization won't try to parse command line switches.

# Force Getopt::Long to accept options that aren't prefixed with anything at all.
Getopt::Long::Configure('prefix_pattern=--|-|\+|');

sub overview
{
	my $self = shift();
	return "This is a System V init step that starts/stops the ".ref($self)." system/service";
}

sub instVarDefinitions
{
	my $self = shift();
	### NOTE!! If you do NOT want anything defined here saved between executions,
	###        be sure to undef it in persist()!!!
	$self->addInstVar('stopActions',[]);
	$self->addInstVar('lastAction','');
	$self->addInstVar('lastShell');
	$self->addInstVar('hbResourceMode');
	$self->addInstVar('lastActionErrors',[]);
	return $self->SUPER::instVarDefinitions();
}

sub initialize
{
	my ($self,$switches,@params) = @_;
	$self->SUPER::initialize(@params);
	if (! $SysVStep::LibMode ) {
		my $stream = $self->debugObject->addstream(LEVEL=>SysVStep->ConfigValue('logFileLevel'),
						FILE=>SysVStep->ConfigValue('logFileName'),
						APPEND=>1);
		$stream->timestamps(1);
		if ($self->commandLineIsValid) {
			if (! $switches->{'hbResourceMode'}) {
				$stream = $self->debugObject->addstream(LEVEL=>$self->get_debug);
				$stream->timestamps(1);
				$self->dprint(1,'Debug level = ',$self->get_debug);
				$self->dprint(2,'Switches: ',join(',',@ARGV));
			} else {
				$self->debugObject->addstream(LEVEL=>-1);
			}
			$self->dprint(3,'Non-LibMode reincarnation');
			eval 'require NOCpulse::'.$self->databaseType;
			return $self->reincarnated($switches);
		} else {
			$self->dprint(3,'Not in LibMode, and invalid command line');
			$self->printUsage;
		}
	} else {
		$self->dprint(3,'Lib mode reincarnation');
		return $self->reincarnated($switches);
	}
	return $self;
}

sub reincarnated
{
	my ($self,$switches) = @_;
	my $pastLife = ref($self)->loadFromDatabase($self->get_name);
	my ($key,$value);
	if ($pastLife) {
		$self->dprint(3,'Loading self from database');
		$pastLife->set_switches($self->get_switches);
		while (($key,$value) = each(%$switches)) {
			if ($pastLife->hasSwitch($key)) {
				$pastLife->switch($key)->set_value($value);
			} else {
				$pastLife->set($key,$value);
			}
		}
		return $pastLife;
	} else {
		while (($key,$value) = each(%$switches)) {
			$self->dprint(3,"Setting ghost's $key to $value");
			$self->set($key,$value);
		}
		return $self;
	}
}

sub registerSwitches
{
	my $self = shift();
	$self->addSwitch('start',	undef,	0,	0,	'Start this step');
	$self->addSwitch('stop',	undef,	0,	0,	'Stop this step');
	$self->addSwitch('force',	undef,	0,	0,	'Force start/stop');
	$self->addSwitch('restart',	undef,	0,	0,	'Restart this step');
	$self->addSwitch('status',	undef,	0,	0,	'Print status');
	$self->addSwitch('install',	undef,	0,	0,	'Install SYSV symlinks');
	$self->addSwitch('uninstall',	undef,	0,	0,	'Uninstall SYSV symlinks');
	$self->addSwitch('help',	undef,	0,	0,	'Print usage');
	$self->addSwitch('debug',	'=i',	0,	0,	'Debug level');
	$self->addSwitch('simshells',	undef,	0,	0,	"Simulate (don't run) shell commands");
}

sub run
{
	my ($self,$action,@params) = @_;
	if ($action) {
		$self->dprint(3,"Got action: $action");
	}

	if (($action eq 'help') or $self->get_help) {
		$self->dprint(3,'RUN: help');
		$self->printUsage;
	} elsif (($action eq 'start') or $self->get_start) {
		$self->dprint(3,'RUN: start');
		$self->startStep;
		$self->persist;
		$self->_printStatus(1);
		return (! $self->isRunning);
	} elsif (($action eq 'stop') or $self->get_stop) {
		$self->dprint(3,'RUN: stop');
		$self->stopStep;
		$self->persist;
		$self->_printStatus(1);
		return ($self->isRunning);
	} elsif (($action eq 'restart') or $self->get_restart) {
		$self->dprint(3,'RUN: restart');
		$self->restartStep;
		$self->persist;
		return (! $self->isRunning);
	} elsif (($action eq 'status') or $self->get_status) {
		$self->dprint(3,'RUN: status');
		$self->_printStatus(0);
		return (! $self->isRunning);
	} elsif (($action eq 'install') or $self->get_install) {
		$self->dprint(3,'RUN: install');
		$self->installSysVLinks;
		$self->persist;
		return 0;
	} elsif (($action eq 'uninstall') or $self->get_uninstall) {
		$self->dprint(3,'RUN: uninstall');
		$self->uninstallSysVLinks;
		$self->persist;
		return 0;
	} else {
		$self->dprint(3,'RUN: no valid action');
		$self->printUsage;
		$self->_printStatus(0);
	}
}


##########################################
# SysV symlink maintenance

sub installSysVLinks
{
	my $self = shift();
	if ($self->configValue('runLevels')) {
		symlink(SysVStep->ConfigValue('sysvStarter'),'/etc/rc.d/init.d/'.ref($self));
		my @levels = split(',',$self->configValue('runLevels'));
		my $startSeq = $self->configValue('startSeq');
		my $stopSeq = $self->configValue('stopSeq');
		$self->dprint(1,'Installing '.ref($self).' for SysV startup in runlevels '.join(',',@levels).", start=$startSeq, stop=$stopSeq");
		my $level;
		foreach $level (@levels) {
			symlink('/etc/rc.d/init.d/'.ref($self),'/etc/rc.d/rc'.$level.'.d/S'.$startSeq.ref($self));
		}
		my @klevels = (0,1,6);
		foreach $level (@klevels) {
			symlink('/etc/rc.d/init.d/'.ref($self),'/etc/rc.d/rc'.$level.'.d/K'.$stopSeq.ref($self));
		}
		open(FILE,">".SysVStep->ConfigValue('installed').'/'.ref($self));
		print FILE join(',',@levels)."\n";
		close(FILE);
	}
}

sub uninstallSysVLinks
{
	my $self = shift();
	unlink('/etc/rc.d/init.d/'.ref($self));
	$self->dprint(1,'Uninstalling '.ref($self).' from SysV startup');
	my $level;
	foreach $level (0,1,2,3,4,5,6) {
		$self->shell('rm /etc/rc.d/rc'.$level.'.d/S*'.ref($self));
		$self->shell('rm /etc/rc.d/rc'.$level.'.d/K*'.ref($self));
	}
	$self->clearLastActionErrors; 
	my $filename = SysVStep->ConfigValue('installed').'/'.ref($self);
	if ( -f $filename ) {
		unlink($filename)
	}
}

##########################################
# Persistence

sub databaseType
{
	return SysVStep->ConfigValue('databaseType');
}

sub databaseDirectory
{
	return SysVStep->ConfigValue('databaseDirectory');
}

sub databaseFilename
{
	my $class = shift();
	return $class->databaseDirectory.'/SysVStep'.$class->databaseType->fileExtension;
}

sub get_name
{
	return ref(shift());
}

sub persist
{
	my $self = shift();
	my $switches = $self->get_switches;
	$self->set_switches({});
	$self->set_hbResourceMode(undef);
	my $result =  $self->SUPER::persist;
	$self->set_switches($switches);
	return $result;
}



#####################################
# Start/stop logic

sub addError
{
	my ($self,@errors) = @_;
	my $error;
	foreach $error (@errors) {
		push(@{$self->get_lastActionErrors},$error);
	}
}


sub isTrulyRunning
{
	# Subclasses can override to add additional logic
	return 1;
}

sub isStarted
{
	my $self = shift();
	# Indicates simply that the step is known to have been started. Does not
	# indicate whether there were errors in that process.
	return ($self->get_lastAction eq 'start');
}

sub isRunning
{
	my $self = shift();
	# The return value of this function is intended not only to indicate whether or not
	# the step has been started, but also the fact that it appeared to start without
	# errors.  The difference is important:  It is possible to have started something
	# that is in fact running, but that is running *incorrectly* due to some problem.
	# We still want to be able to *stop* a step that is in this state.  Ergo the
	# difference.
	return ( $self->isStarted && (! $self->hasErrors) && $self->isTrulyRunning);
}

sub startStep
{
	my $self = shift();
	if ((! $self->isStarted) || $self->get_force) {
		print "Starting ", $self->get_name, " ...  ";
		if ($self->get_force) {
			$self->clearStopActions;
		}
		$self->clearLastActionErrors;
		$self->startActions;
		$self->set_lastAction('start');
		if ($self->hasErrors) {
			$self->listErrors;
			print "[ FAIL ]\n";
		} else {
			print "[ OK ]\n";
		}
		if (-f '/etc/rc.d/init.d/'.ref($self))  {
			# This is for RH "rc" script - won't kill if this isn't here
			open(FILE,'>/var/lock/subsys/'.ref($self));
			print FILE 'running';
			close(FILE);
		}
		return $self->hasErrors;
	} else {
		print "Starting ", $self->get_name, " ...  [ ALREADY RUNNING ]\n" if ($self->get_name != 'InstallSoftwareConfig');
		$self->dprint(1,'ALREADY RUNNING');
		return 1;
	}
}

sub stopStep
{
	my $self = shift();
	if ($self->isStarted || $self->get_force) {
		print 'Stopping ', $self->get_name, " ...  ";
		$self->clearLastActionErrors;
		$self->stopActions;
		$self->set_lastAction('stop');
		if ($self->hasErrors) {
			$self->listErrors;
			print "[ FAIL ]\n";
		} else {
			print "[ OK ]\n";
		}
		if ( -f '/var/lock/subsys/'.ref($self)) {
			# This is for RH "rc" script - won't kill if this isn't here
			unlink('/var/lock/subsys/'.ref($self));
		}
		return $self->hasErrors;
	} else {
		print "Stopping ", $self->get_name, " ...  [ ALREADY STOPPED ]\n" if ($self->get_name != 'InstallSoftwareConfig');
		$self->dprint(1,'ALREADY STOPPED');
		return 1;
	}
}

sub restartStep
{
	my $self = shift();
	$self->dprint(3,'restartStep: calling stopStep');
	$self->stopStep;
	$self->dprint(3,'restartStep: calling startStep');
	$self->startStep;
}

sub startActions
{
	my $self = shift();
	$self->dprint(2,'Called abstract startActions');
}

sub clearStopActions
{
	my $self = shift();
	$self->dprint(1,'Clearing stop actions');
	$self->set_stopActions([]);
}

sub clearLastActionErrors
{
	my $self = shift();
	$self->dprint(1,'Clearing last action errors list');
	$self->set_lastActionErrors([]);
}

sub addShellStopAction
{
	my ($self,$action,$message) = @_;
	$shell = 'shell("'.$action.'")';
	$self->addSelfStopAction($shell,$message);
}

sub addSelfStopAction
{
	my ($self,$action,$message) = @_;
	my $selfaction = "\$self->$action";
	$self->addStopAction($selfaction,$message);
}

sub addStopAction
{
	my ($self,$action,$message) = @_;
	unshift(@{$self->get_stopActions},[$action,$message]);
	$self->dprint(3,"Added stop action: '$action'");
}

sub okToCallStopAction
{
	# Override if you want to be selective about executing a stop step
	# e.g. MacroSysVStep does this...
	return 1;
}

sub stopActions
{
	my $self = shift();
	my $action;
	foreach $action (@{$self->get_stopActions}) {
		my ($code,$message) = @$action;
		if ($self->okToCallStopAction($code)) {
			$self->dprint(3,"Executing stop action: '$code'");
			if ($message) {
				$code = "$code || die('$message')";
			} 
			eval($code);
			if ($@) {
				$self->addError($@);
			}
		} else {
			$self->dprint(0,"NOTICE: Not executing stop action $code");
		}
	}
	$self->clearStopActions;
}

##################################################
# General utility
sub shell
{
	my ($self,@command) = @_;
	my $command = join(' ',@command);
	my $shell = NOCpulse::LocalCommandShell->newInitialized;
	$self->dprint(1,"shell: '$command'");
	$shell->set_probeCommands($command);
	if ($self->configValue('shellTimeout')) {
		$shell->set_timeout($self->configValue('shellTimeout'));
	}
	$self->dprint(1,'shell timeout: ',$shell->get_timeout);
	if (! $self->get_simshells)  {
		$shell->execute;
		if ($shell->get_exit) {
			$self->addError("ERROR FROM SHELL COMMAND: ");
			$self->addError("STDOUT: ".$shell->get_stdout);
			$self->addError("STDERR: ".$shell->get_stderr);
			$self->addError("EXIT: ".$shell->get_exit);
		}
	}
	$self->set_lastShell($shell);
	return (! $shell->get_exit);
}


sub asUserDo
{
	my ($self,$username,$doMe) = @_;
	$self->dprint(9,"asUserDo($username,$doMe)");

	my $identity = NOCpulse::SetID->new( user => $username );
	$identity->su();
	my $result;
	$self->dprint(9,"EXECUTING with: ".`id`." $doMe *** USED: uid: $uid ");
	$result = eval $doMe;
	$identity->revert();
	$self->dprint(9,"RESET to: ".`id`);
	if ($@) {
		$self->addError("asUserDo($username,$doMe) failed to eval: $@");
	}
	return $result;
}


##################################################
# Console/log output
sub _printStatus
{
	my ($self,$avoidRedundancy) = @_;
	if ($self->get_hbResourceMode) {
		# NOTE!!! This EXACT TEXT is EXTREMELY IMPORTANT
		# to the heartbeat daemon! DO NOT ALTER IT!!
		# Heartbeat relies on this text, not an exit level!!!
		# By giving hearbeat the "isRunning" perspective versus
		# the "isStarted" perspective (see comment in isRunning()),
		# we make the hearbeat cluster more resillient in the face
		# of the misconfiguration of a backup node, etc.
		if ($self->isRunning) {
			print "running\n"
		} else {
			print "stopped\n"
		}
	} else {
		$self->dprint(1,'============ STATUS ===============');
		$self->printStatus($avoidRedundancy);
		$self->dprint(1,'===================================');
	}
}

sub printStatus
{
	my ($self,$avoidRedundancy) = @_;
	$self->dprint(1,'Last action: ',$self->get_lastAction);
	if (-f '/etc/rc.d/init.d/'.ref($self)) {
		$self->dprint(1,'** Installed for SysV startup **');
	} elsif ($self->configValue(runLevels)) {
		$self->dprint(1,'** Can be installed for SysV startup **');
		$self->dprint(1,'Run levels: ',$self->configValue('runLevels'));
		$self->dprint(1,'Start sequence: ',$self->configValue('startSeq'));
		$self->dprint(1,'Stop sequence: ',$self->configValue('stopSeq'));
	}
	if ($self->isStarted) {
		if ($self->isRunning) {
			$self->dprint(1,'STARTED and RUNNING');
		} else {
			$self->dprint(0,'WARNING: STARTED BUT *NOT* RUNNING');
		}
		$self->dprint(1,'Stop actions: ');
		my $action;
		foreach $action (@{$self->get_stopActions}) {
			$self->dprint(1,"\t",$action->[0]);
		}
	} else {
		$self->dprint(1,'STOPPED');
	}
	if ($self->hasErrors) {
		$self->dprint(0,'ERRORS ENCOUNTERED DURING LAST ACTION:');
		$self->listErrors;
	}
}

sub dprint
{
	my ($self,$level,@message) = @_;
	$self->SUPER::dprint($level,ref($self),': ',@message,"\n");
}

sub hasErrors
{
	return (scalar(@{shift()->get_lastActionErrors}))
}

sub listErrors
{
	my $self = shift();
	my $error;
	if ($self->hasErrors) {
		foreach $error (@{$self->get_lastActionErrors}) {
			$self->dprint(0,"\t!! $error");
		}
	}
}

######### Registry related stuff #############

sub registerForInstall
{
	my ($self,$registrant,$traversal) = @_;
	if ( ! defined($traversal)) {
		$traversal = {};
	}
	if ($registrant) {
		my $regdir = SysVStep->ConfigValue('registry');
		my $filename = $regdir.'/'.ref($self);
		if ( ! -f $filename ) {
			open(FILE,">$filename");
			print FILE $registrant."\n";
			close(FILE);
		} else {
			open(FILE, $filename);
			chomp(my @keys = <FILE>);
			close(FILE);
			my %ary;
			@ary{@keys} = (1 .. scalar(@keys));
			print ref($self)." keys = ".join(',',keys(%ary))."\n";
			if ( ! defined($ary{$registrant})) {
				open(FILE,">>$filename");
				print FILE $registrant."\n";
				close(FILE);
			}
		}
	}
	if (defined($traversal->{ref($self)})) {
		return;
	} else {
		$traversal->{ref($self)} = 1;
	}
}

sub registrationList
{
	my $self = shift();
	my @result;
	my $regdir = SysVStep->ConfigValue('registry');
	my $filename = $regdir.'/'.ref($self);
	if ( -f $filename ) {
		open(FILE,$filename);
		my $item;
		foreach  $item (<FILE>) {
			chomp($item);
			push(@result,$item);
		}
		close(FILE);
	}
	return \@result;
}


1;
