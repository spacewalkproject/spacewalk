package PrivateSpreadCell;
use GogoSysVStep;
@ISA=qw(GogoSysVStep);
use PhysCluster;

sub generateSpreadConfigFile
{
	my $self = shift();
	my $success = 1;
	my $cluster = PhysCluster->newInitialized;
	my $privateIp = $cluster->thisNode->privateIp;
	my $clusterHosts = $privateIp->clusterHosts;
	open(SPCONF,'>'.$self->get_configFile) || ($success = 0);
	print SPCONF "DebugFlags = { PRINT EXIT }\n" || ($success = 0);
	print SPCONF "EventLogFile = /home/spread/event.log\n" || ($success = 0);
	print SPCONF "EventTimeStamp\n" || ($success = 0);
	print SPCONF "DangerousMonitor = true\n" || ($success = 0);
        print SPCONF "Spread_Segment ".$privateIp->broadcastAddr.":".$self->get_port." {\n" || ($success = 0);
	my @ips = values(%$clusterHosts);
	my ($number,$ip,$name);
	while (($number,$ip) = each(%$clusterHosts)) {
		$name = $privateIp->nameForNumber($number);
        	print SPCONF "        $name               $ip  {\n" || ($success = 0);
        	print SPCONF "           D $ip\n" || ($success = 0);
        	print SPCONF "           C 127.0.0.1\n" || ($success = 0);
        	print SPCONF "        }\n" || ($success = 0);
	}
        print SPCONF "}\n" || ($success = 0);
	close(SPCONF) || ($success = 0);
	return $success;
}

sub get_command
{
	my $self = shift();
	my $result = $self->configValue('command');
	my $cluster = PhysCluster->newInitialized;
	my $hostname;
	# NOTE: Kludge for ethernet device issue
	if ($cluster->thisNode->privateIp->get_dev eq 'lo') {
		$hostname = 'localhost';
	} else {
		$hostname = `/bin/hostname`;
	}
	chomp($hostname);
	$result .= ' -c '.$self->get_configFile.' -n '.$hostname.' >> /var/log/spread.log 2>&1';
	return $result;
}

sub startActions
{
	my $self = shift();
	if (-f '/tmp/4803') {
		$self->shell('rm /tmp/4803');
	}
	$self->generateSpreadConfigFile || $self->addError('Error generating spread config file');
	$self->addShellStopAction('rm '.$self->get_configFile);
	$self->SUPER::startActions;
}

1;
