package ClusterServices;
use MacroSysVStep;
@ISA=qw(MacroSysVStep);

use SpreadBridge;
use Scheduler;
use Transactor;
use Dequeuer;

sub overview
{
	return 'Starts up cluster level services (spread bridge, scheduler, transactor, dequeuer)';
}

sub startActions
{
	my $self = shift();
	$self->startModule(SpreadBridge);
	$self->startModule(Scheduler);
	$self->startModule(Transactor);
	$self->startModule(Dequeuer);
}


1;
