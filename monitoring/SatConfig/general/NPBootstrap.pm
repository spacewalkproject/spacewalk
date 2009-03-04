package NPBootstrap;
use SysVStep;
@ISA=qw(SysVStep);
use NOCpulse::SatCluster;
use NOCpulse::Config;

sub isTrulyRunning
{
	my $self = shift();
	return (! $self->get_lastShell->get_exit);
}

sub printStatus
{
	my ($self,@params) = @_;
	$self->SUPER::printStatus(@params);
	if ($self->isRunning) {
		my $satCluster = NOCpulse::SatCluster->newInitialized(NOCpulse::Config->new);
		$self->dprint(2,'Cluster Description: '.$satCluster->get_description);
		$self->dprint(2,'Cluster ID: '.$satCluster->get_id);
		$self->dprint(2,'Node ID: '.$satCluster->get_nodeId);
	} else {
		$self->dprint(2,'Cluster and node are undefined at this time');
	}
}


sub startActions
{
	my $self = shift();
	$self->shell($self->configValue('command'));
	if (! $self->get_lastShell->get_exit) {
		my $scheduleEvents = $self->configValue('scheduleEvents');
		my $config = NOCpulse::Config->new;
		my $satCluster = NOCpulse::SatCluster->newInitialized($config);
		my $cfgfile = $config->get('satellite', 'schedulerConfigFile');
		if (! -f $cfgfile) {
			$self->dprint(2,'No scheduler configuration found, getting it');
			# scheduleEvents has logic to switch to the
			# appropriate user so long as we're root, so
			# this is ok.
			if (! $self->shell($scheduleEvents)) {
				$self->dprint(1,'WARNING: scheduleEvents returned non-zero exit level');
			}
		} else {
			$self->dprint(1,'Found scheduler configuration file - not requesting one');
		}
		$self->addShellStopAction('rm '.$satCluster->get_configFilename);
	}
}

1;
