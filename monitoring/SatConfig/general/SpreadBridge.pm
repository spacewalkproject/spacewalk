package SpreadBridge;
use GogoSysVStep;
use PhysCluster;
@ISA=qw(GogoSysVStep);

sub printStatus
{
	my ($self,@params) = @_;
	my $cluster = PhysCluster->newInitialized;
	if ( $cluster->get_superSputEnabled ) {
		return $self->SUPER::printStatus(@params);
	} else {
		$self->dprint(0,"Not configured to run");
	}
}
sub startActions
{
	my ($self,@params) = @_;
	my $cluster = PhysCluster->newInitialized;
	if ( $cluster->get_superSputEnabled ) {
		return $self->SUPER::startActions(@params);
	} else {
		$self->dprint(0,"No superSputEnabled in cluster config - NOT starting");
		return 1;
	}
}
1;
