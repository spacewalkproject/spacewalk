package NotifEscalator;
use GogoSysVStep;
@ISA=qw(GogoSysVStep);
use PhysCluster;
use NOCpulse::Config;

sub startActions
{
	my ($self) = @_;
	my $cluster = PhysCluster->newInitialized;
	my $CONFIG     = NOCpulse::Config->new;
	my $confFile = $CONFIG->get('notification','config_dir') . '/static/notif.ini';;
	open(FILE,">$confFile");
	print FILE "[server]\n";
	print FILE "serverid=".$cluster->get_satNumber."\n";

	# Note of explanation:
	# Only need the first ip.  Used for the retry url only.
        #my $ips = $cluster->thisNode->get_IpAddr;
        #my ($ipid,$ip);
        #while (($ipid,$ip) = each(%$ips)) {
	#	print FILE "serverip=".$ip->get_addr."\n";
	#	last;
        #}
	my $hostname = `/bin/hostname`;
	chomp($hostname);
	print FILE "serverip=$hostname";
	close(FILE);
	#$self->addStopAction("unlink('$confFile')");

  `rm -rf /var/lock/subsys/notification/*.lock`;   ## Clear stale locks

	return $self->SUPER::startActions;
}

1;
