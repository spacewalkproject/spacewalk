package Snort;
use SysVStep;
@ISA=qw(SysVStep);
use PhysCluster;

sub startActions
{
	my $self = shift();
	my $privateNetDev = PhysCluster->newInitialized->thisNode->privateIp->get_dev;
	if ( $privateNetDev and ($privateNetDev ne 'lo')) {
                $self->shell($self->configValue('command'));
                $self->addShellStopAction($self->configValue('stopCommand'),'Stopping snort');
	} else {
		$self->dprint(0,'NOTE: Not starting snort - no private network or on loopback');
	}
}

1;
