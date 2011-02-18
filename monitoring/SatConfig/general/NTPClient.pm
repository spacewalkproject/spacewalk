package NTPClient;
use GogoSysVStep;
@ISA=qw(GogoSysVStep);
use PhysCluster;

sub startActions
{
	my $self = shift();
	my $cluster = PhysCluster->newInitialized;
	my $ntpdateprog = $self->configValue('ntpdate');
	my $driftfile = $self->configValue('driftFile');
	my $configfile = $self->configValue('configFile');
	my $serverlist =  $cluster->get_ntpservers;
	if (! $serverlist) {
		$self->addError("No ntpservers defined!");
		$self->addError("Can't ntpdate/ntpd without servers!");
	} else {
		$self->dprint(0,"Using servers: $serverlist");
		my @servers = split(' ',$serverlist);
		$self->dprint(0,'Syncing time for ntp');
		$self->shell("/usr/sbin/ntpdate -s -b -p 8 $serverlist");
		local * FILE;
		open(FILE, '>', $configfile);
		print FILE "restrict default ignore\n";
		print FILE "restrict 128.0.0.1\n";
		print FILE "driftfile $driftfile\n";
		print FILE "disable bclient\n";
		print FILE "authenticate no\n";
		my $server;
		foreach $server (@servers) {
			print FILE "server $server\n";
			print FILE "restrict $server\n";
		}
		close(FILE);
		$self->addShellStopAction('rm '.$configfile);
	}
	return $self->SUPER::startActions;
}

1;
