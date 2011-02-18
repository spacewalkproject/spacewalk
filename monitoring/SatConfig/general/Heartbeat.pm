package Heartbeat;
use SysVStep;
@ISA=qw(SysVStep);
use PhysCluster;


sub startActions
{
	my $self = shift();

	my $cluster = PhysCluster->newInitialized;

	local * FILE;
	open(FILE, '>', $self->get_configFile);
	print FILE "debugfile      ".$self->get_debugfile."\n";
	print FILE "logfile        ".$self->get_logfile."\n";
	print FILE "logfacility    ".$self->get_logfacility."\n";
	print FILE "keepalive      ".$self->get_keepalive."\n";
	print FILE "deadtime       ".$self->get_deadtime."\n";
	print FILE "initdead       ".$self->get_initdead."\n";
	print FILE "serial         ".$self->get_serial."\n";
	print FILE "udp            ".$cluster->thisNode->privateIp->get_dev."\n";
	print FILE "watchdog       ".$self->get_watchdog."\n";
	print FILE "nice_failback  ".$self->get_nice_failback."\n";
	print FILE "node ".$cluster->thisNode->privateIp->nameForNumber(1)."\n";
	print FILE "node ".$cluster->thisNode->privateIp->nameForNumber(2)."\n";
	close(FILE);
	$self->addShellStopAction('rm '.$self->get_configFile);

	open(FILE, '>', $self->get_resourceFile);
	print FILE $cluster->thisNode->privateIp->nameForNumber(1)." ClusterLeader\n";
	close(FILE);
	$self->addShellStopAction('rm '.$self->get_resourceFile);
	my $oldmask = umask(0177);
	open(FILE, '>', $self->get_authFile);
	print FILE "auth 1\n1 ".$self->get_authKey."\n";
	close(FILE);
	umask($oldmask);
	$self->addShellStopAction('rm '.$self->get_resourceFile);
	

	$self->shell($self->get_command);
	$self->addShellStopAction($self->get_command.' -k');
}

1;
