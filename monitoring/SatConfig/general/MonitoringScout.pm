package MonitoringScout;
use MacroSysVStep;
@ISA=qw(MacroSysVStep);

use InstallSoftwareConfig;
use NotifEscalator;
use NotifLauncher;
use Notifier;
use AckProcessor;
use SputLite;
use TSDBLocalQueue;
use NPBootstrap;
use Dequeuer;
use Dispatcher;
use TrapReceiver;
use NOCpulse::NOCpulseini;
use PXT::Config;



sub overview
{
	return 'Starts up monitoring functionality.  What it starts depends on web.is_monitoring_backend and web.is_monitoring_scout in /etc/rhn/rhn.conf';
}

sub printStatus
{
        my ($self,@params) = @_;
	my $pxtconf = new PXT::Config("web");
	if ($pxtconf->get("is_monitoring_backend")) {
		$self->dprint(1,"   ++++ Monitoring backend functionality is enabled");
	} else {
		$self->dprint(1,"   ---- Monitoring backend functionality is disabled");
	}
	if ($pxtconf->get("is_monitoring_scout")) {
		$self->dprint(1,"   ++++ Monitoring scout functionality is enabled");
	} else {
		$self->dprint(1,"   ---- Monitoring scout functionality is disabled");
	}
        $self->SUPER::printStatus(@params);
}


sub startActions
{
	my $self = shift();
	my $pxtconf = new PXT::Config("web");
	my $startMIABServices = $pxtconf->get("is_monitoring_backend");
	my $startScoutServices = $pxtconf->get("is_monitoring_scout");
	#my $separateWebserver = 0;
	my $configIsInstalled;

	if ( $startMIABServices or $startScoutServices ) {
		$configIsInstalled = $self->addStatusModule(InstallSoftwareConfig);

		if (! $configIsInstalled) {
			$configIsInstalled = $self->startModule(InstallSoftwareConfig);
		}

		if (! $configIsInstalled ) {
			$self->addError("Monitoring configuration load failed");
		}
	}

	if ( $startScoutServices ) {
		if ( ! $configIsInstalled ) {
			$self->dprint(0,"NOTE: Attempting to start scout without configuration refresh");
		}
		# These should attempt to start regardless of whether InstallSoftwareConfig worked or not - there
		# may be an existing config that's sufficient for monitoring, nothing will break if there isn't,
		# and if there is, we stand a better chance of doing monitoring that the MOC can catch up on when
		# it becomes available again (per Dave F).
		$self->startModule(NPBootstrap);
		# NOTE: SputLite is no longer uber-nanny'd w/ a cron job - per Greg P, we now
		# assume that customers can physically get to their machines. It's still gogo
		# nanny'd w/ heartbeat etc.
		$self->startModule(SputLite);
		$self->startModule(Dequeuer);
		$self->startModule(Dispatcher);
		#$self->startModule(TrapReceiver);
	}
}

1;
