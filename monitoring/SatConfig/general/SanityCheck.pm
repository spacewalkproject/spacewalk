package SanityCheck;
use SysVStep;
@ISA=qw(SysVStep);
use PhysCluster;


sub startActions
{
	my $self = shift();
	my $cluster = PhysCluster->newInitialized;
	$self->dprint(0,"Validating configuration....");
	if ( ! $cluster->isValid ) {
		my $message = 'ERROR: Configuration fails validity checks - see '.SysVStep->ConfigValue('logFileName').' for details';
		$self->dprint(0,$message);
		$self->addError("SYSTEM CONFIGURATION INVALID");
		sleep(10);
	} else {
		$self->dprint(0,'System passes sanity check');
	}
}

1;
