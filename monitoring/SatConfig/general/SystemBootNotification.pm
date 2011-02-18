package SystemBootNotification;
use SysVStep;
@ISA=qw(SysVStep);
use PhysCluster;
use NOCpulse::Gritch;


sub startActions
{
	my $self = shift();

	my $soapbox = new NOCpulse::Gritch("/var/adm/systemboots.db");
	local * FILE;
	open(FILE, '<', '/etc/issue');
	my $buildinfo = join('',<FILE>);
	close(FILE);
	$mac = $soapbox->get_mac;
	$soapbox->gritch('REBOOT ALERT', "This system ($mac) has re-booted\n\n$buildinfo");
}

1;
