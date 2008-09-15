package MacroSysVStep;
use SysVStep;
@ISA=qw(SysVStep);

sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('statusModules',[]);
	$self->addInstVar('exceptions',[]);
}

sub registerSwitches
{
	my $self = shift();
	$self->SUPER::registerSwitches;
	$self->addSwitch('except','=s',undef,undef,"Exclude the listed steps (comma separated) from the operation in question");
}

sub run
{
	my ($self,$action,@params) = @_;
	if ($self->get_except) {
		$self->dprint(2,'Got exceptions: '.$self->get_except);
		my @exceptions = split(',',$self->get_except);
		$self->set_exceptions(\@exceptions);
	} else {
		$self->dprint(2,'No exceptions specified, operation applies to all steps');
	}
	$self->SUPER::run($action,@params);
}

sub persist
{
	my $self = shift();
	$self->set_exceptions([]);
	return $self->SUPER::persist;
}

sub initialize
{
	my ($self,@params) = @_;
	$self = $self->SUPER::initialize(@params);
	$SysVStep::LibMode=1;
	return $self;
}

sub printStatus
{
	my ($self,$avoidRedundancy) = @_;
	$self->SUPER::printStatus($avoidRedundancy);
	if (! $avoidRedundancy) {
		my $module;
		foreach $module (@{$self->get_statusModules}) {
			$self->dprint(0,"----------- $module STATUS ---------------");
			$module->newInitialized->printStatus($avoidRedundancy);
		}
	}
}

sub addStatusModule
{
	my ($self,$moduleName) = @_;
	push(@{$self->get_statusModules},$moduleName);
}

sub excludingModuleNamed
{
	my ($self,$moduleName) = @_;
	return scalar(grep(/^$moduleName$/,@{$self->get_exceptions}));
}

sub startModule
{
	my ($self,$moduleName) = @_;
	my $exceptions = $self->get_exceptions;
	my $startedOk;
	my $moduleInstance;
	if (! $self->excludingModuleNamed($moduleName)) {
		$self->dprint(3,"Macro: Starting $moduleName");
		$moduleInstance = eval("$moduleName->newInitialized");
		if ($@) {
			$self->addError("Error instantiating substep $moduleName");
			$self->addError("$moduleName: $@");
		} else {
			eval { $moduleInstance->run('start') };
			if ($@) {
				$self->addError("Error starting substep $moduleName");
				$self->addError("$moduleName: $@");
			}
		}
	} else {
		$self->dprint(0,"NOTICE!!:  Skipping start of step $moduleName");
	}
	$self->addStopAction("$moduleName->newInitialized->run('stop')");
	$self->addStatusModule($moduleName);
	return $moduleInstance->isRunning;
}

sub okToCallStopAction
{
	# Override of SysVStep::okToCallStopAction
	my ($self,$code) = @_;
	my @parts = split(/->/,$code,2);
	my $moduleName = shift(@parts);
	$self->dprint(2,"Parsed $moduleName from stop action code $code");
	return (! $self->excludingModuleNamed($moduleName));
}

sub stopStep
{
	my ($self,@params) = @_;
	my $result = $self->SUPER::stopStep;
	$self->set_statusModules([]);
	return $result;
}

1;

