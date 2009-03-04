package GogoSysVStep;
use SysVStep;
@ISA=qw(SysVStep);

$GOGOPROG = GogoSysVStep->ConfigValue('gogoProgram');

sub printStatus
{
	my ($self,@params) = @_;
	$self->SUPER::printStatus(@params);
	$self->dprint(2,'GoGo options:');
	$self->dprint(2,'--fname='.ref($self));
	$self->dprint(2,'--command='.$self->get_command);
	if ($self->configValue('user')) { $self->dprint(2,'--user='.$self->get_user)}
	if ($self->configValue('hbfile')) { $self->dprint(2,'--hbfile='.$self->get_hbfile)}
	if ($self->configValue('hbfreq')) { $self->dprint(2,'--hbfreq='.$self->get_hbfreq)}
	if ($self->configValue('hbcheck')) { $self->dprint(2,'--hbcheck='.$self->get_hbcheck)}
	if ($self->configValue('notify')) { $self->dprint(2,'--notify='.$self->get_notify)}
	if ($self->configValue('grtchdir')) { $self->dprint(2,'--grtchdir='.$self->get_grtchdir)}
	if ($self->configValue('workingDir')) { $self->dprint(2,'workingDir='.$self->get_workingDir)}
}

sub isTrulyRunning
{
	my $self = shift();
	return (! ($self->gogo('--check '.ref($self))->get_exit));
}

sub gogo
{
	my ($self,$params) = @_;
	my $cmdline = "$GOGOPROG".' '.$params;
	$self->shell($cmdline);
	return $self->get_lastShell;
}

sub startActions
{
	my $self = shift();
	if ($self->configValue('workingDir')) {
		chdir($self->get_workingDir);
		# Doesn't need undo step
	}
	my $opts = ' --fname='.ref($self);
	if ($self->configValue('user')) { $opts .= ' --user='.$self->get_user}
	if ($self->configValue('hbfile')) { $opts .= ' --hbfile='.$self->get_hbfile}
	if ($self->configValue('hbfreq')) { $opts .= ' --hbfreq='.$self->get_hbfreq}
	if ($self->configValue('hbcheck')) { $opts .= ' --hbcheck='.$self->get_hbcheck}
	if ($self->configValue('notify')) { $opts .= ' --notify='.$self->get_notify}
	if ($self->configValue('grtchdir')) { $opts .= ' --grtchdir='.$self->get_grtchdir}
	$opts .= ' -- '.$self->get_command;
	if ($self->configValue('errorLog')) {
		$opts .= ' >> '.$self->get_errorLog.' 2>&1';
	}
	$self->shell('/usr/bin/nohup '.$GOGOPROG.' '.$opts);
	$self->addSelfStopAction("gogo('--kill ".ref($self)."')");
}

1;
