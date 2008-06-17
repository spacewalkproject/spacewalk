package ArpWatch;
use SysVStep;
@ISA=qw(SysVStep);
use PhysCluster;

sub startActions
{
	my $self = shift();
	my $privateNetDev = PhysCluster->newInitialized->thisNode->privateIp->get_dev;
	if ( $privateNetDev and ($privateNetDev ne 'lo')) {
		$self->dprint(0,"Starting arpwatch on $privateNetDev");
		my $command = $self->configValue('startArpwatch').' -i '.$privateNetDev;
		$self->shell($command);
		my $stopCommand = $self->configValue('stopArpwatch');
		$self->addShellStopAction($stopCommand,"Running ".$stopCommand);
	} else {
		$self->dprint(0,'NOTE: Not starting arpwatch - no private network or on loopback');
	}
}

1;
