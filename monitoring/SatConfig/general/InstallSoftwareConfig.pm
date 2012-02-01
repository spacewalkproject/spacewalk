package InstallSoftwareConfig;
use SysVStep;
use NOCpulse::NOCpulseini;
use PhysCluster;
@ISA=qw(SysVStep);

use strict;

sub startActions
{
	my $self = shift();
	my $cluster = PhysCluster->newInitialized;
	my $localConfig = $cluster->get_LocalConfig;
	my $remoteConfig = $cluster->get_RemoteConfig;
	my $ini = NOCpulse::NOCpulseini->new();

        umask(022);  # Create the file world-readable

	if (%$localConfig) {
		$self->dprint(1,'Grabbing local config info');
		eval {
			$ini->connect();
			$ini->fetch_nocpulseini('INTERNAL');
			$ini->save();
			$ini->disconnect();
		};
		if ($@) {
			$self->addError($@);
		}
	} elsif (%$remoteConfig) {
		$self->dprint(1,'Grabbing remote config info');
		my $config = (values(%$remoteConfig))[0];
		my $protocol = $config->get_protocol;
		my $path = $config->get_path;
		my $host = $config->get_host;
		if (! $host ) {
			$host = $cluster->get_smonfqdn;
		}
		my $url = "$protocol://$host$path";
		eval {
			$ini->download_nocpulseini($url);
		};
		if ($@) {
			$self->addError($@);
		}
	} else {
		$self->addError('No configuration database info in Cluster.ini!');
	}
}

1;
