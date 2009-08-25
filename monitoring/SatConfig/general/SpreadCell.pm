package SpreadCell;
use GogoSysVStep;
@ISA=qw(GogoSysVStep);
use PhysCluster;
use Net::IPv4Addr qw(ipv4_broadcast);

sub generateSpreadConfigFile
{
	my $self = shift();
	my $success = 1;
	my $cluster = PhysCluster->newInitialized;
	my $cellIp = $cluster->thisNode->get_IpAddr->{1}; # ** WARNING-EVIL!!! NEED MECHANISM FOR THIS **
	open(SPCONF,'>'.$self->get_configFile) || ($success = 0);
	print SPCONF "DebugFlags = { PRINT EXIT }\n" || ($success = 0);
	print SPCONF "EventLogFile = /home/spread/event.log\n" || ($success = 0);
	print SPCONF "EventTimeStamp\n" || ($success = 0);
	print SPCONF "DangerousMonitor = true\n" || ($success = 0);
	my $broadcast = ipv4_broadcast($cellIp->get_addr."/".$cellIp->get_mask);
        print SPCONF "Spread_Segment ".$broadcast.":".$self->get_port." {\n" || ($success = 0);
	my ($number,$host,$ip,$name);
	my $hosts = $cluster->get_PhysNode;
	while (($number,$host) = each(%$hosts)) {
		$ip = $host->get_IpAddr->{1}->get_addr; # ** WARNING - SIMILAR EVIL - NEED MECHANISM **
		$name = $host->get_hostname; # ** WARNING - PRESUMES ONE NAME **
		$name = (split(/\./,$name))[0];
        	print SPCONF "        $name $ip  {\n" || ($success = 0);
        	print SPCONF "           D $ip\n" || ($success = 0);
        	print SPCONF "           C 127.0.0.1\n" || ($success = 0);
        	print SPCONF "        }\n" || ($success = 0);
	}
        print SPCONF "}\n" || ($success = 0);
	close(SPCONF) || ($success = 0);
	chmod(0644,$self->get_configFile);
	return $success;
}

sub get_command
{
	my $self = shift();
	my $result = $self->configValue('command');
	my $cluster = PhysCluster->newInitialized;
	my $hostname = $cluster->thisNode->get_hostname; #  ** WARNING - SEE ABOVE - EVIL LURKS **
	if (! $hostname) {
		$self->addError("WARNING: HOST NAME NOT SET - SPREAD WILL PROBABLY FAIL");
		$result .= ' -c '.$self->get_configFile.' >> /var/log/spread.log 2>&1';
	} else {
		$hostname = (split(/\./,$hostname))[0];
		$result .= ' -c '.$self->get_configFile.' -n '.$hostname.' >> /var/log/spread.log 2>&1';
	}
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
