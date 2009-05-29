package Monitoring;
use MacroSysVStep;
@ISA=qw(MacroSysVStep);

use InstallSoftwareConfig;
use AckProcessor;
use GenerateNotifConfig;
use NotifEscalator;
use NotifLauncher;
use Notifier;
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
	my $configIsInstalled;

	if ( $startMIABServices or $startScoutServices ) {

		if (!($configIsInstalled = $self->startModule(InstallSoftwareConfig))) {
			$self->addError("Monitoring configuration load failed");
		}
	}

	if ( $startMIABServices ) {
		if ($configIsInstalled) {
			# REQUIRE that NOCpulse.ini is installed, else bad stuff could happen if 
			# MOC services start.
			$self->startModule(GenerateNotifConfig);
			$self->startModule(NotifEscalator);
			$self->startModule(NotifLauncher);
			$self->startModule(Notifier);
			$self->startModule(AckProcessor);
			$self->startModule(TSDBLocalQueue);
		} else {
			$self->addError('Monitoring configuration not loaded - not starting MOC functions!');
		}
	}
}

1;
