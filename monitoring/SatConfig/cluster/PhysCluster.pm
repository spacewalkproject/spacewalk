package PhysCluster;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
use IpAddr;
use VIP;
use OffnetRoute;
use PhysNode;
use ApacheServer;
use NetworkFilesystem;
use LocalConfig;
use RemoteConfig;
use TomcatServer;
use ModJK2;
@ISA=qw(ConfigObject);

$hostsFile = '/etc/hosts';
$resolverFile = '/etc/resolv.conf';
$localhostEntry = "127.0.0.1\tlocalhost localhost.localdomain";

sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('satNumber');
	$self->addInstVar('nameservers');
	$self->addInstVar('nssearchpath');
	$self->addInstVar('smonaddr');
	$self->addInstVar('smonfqdn');
	$self->addInstVar('smontestaddr');
	$self->addInstVar('smontestfqdn');
	$self->addInstVar('sshaddr');
	$self->addInstVar('sshmask');
	$self->addInstVar('sshfqdn');
	$self->addInstVar('otherHosts');
	$self->addInstVar('ntpservers');
	$self->addInstVar('superSputEnabled');
	$self->addInstVar('haFailoverEnabled');
	$self->addInstVar('portalAddress');
	$self->addInstVar('VIP',{});
	$self->addInstVar('OffnetRoute',{});
	$self->addInstVar('PhysNode',{});
	$self->addInstVar('ApacheServer',{});
	$self->addInstVar('NetworkFilesystem',{});
	$self->addInstVar('LocalConfig',{});
	$self->addInstVar('RemoteConfig',{});
	$self->addInstVar('TomcatServer',{});
	$self->addInstVar('ModJK2',{});
}

sub initialize
{
	my ($self,$filename) = @_;
	$self->SUPER::initialize();
	$self->readFromFile($filename);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'satNumber',
			description=>'Node number within the cluster (e.g. 1,2)',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'nameservers',
			description=>'List of nameserver ip addresses separated by spaces',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'nssearchpath',
			description=>'List of domain names to search separated by spaces',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'smonaddr',
			description=>'IP address of smon',
			required=>1,
			optional=>0,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'smonfqdn',
			description=>'Fully qualified domain name of smon',
			required=>1,
			optional=>0,
			format=>'fqdn'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'smontestaddr',
			description=>'IP address of smon-test',
			required=>1,
			optional=>0,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'smontestfqdn',
			description=>'Fully qualified domain name of smon-test',
			required=>1,
			optional=>0,
			format=>'fqdn'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'sshaddr',
			description=>'IP Address of host from which SSH connects will come',
			required=>1,
			optional=>0,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'sshmask',
			description=>'Dotted-quad mask for sshaddr',
			required=>1,
			optional=>0,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'sshfqdn',
			description=>'Fully qualified domain name of host from which ssh connects will com',
			required=>1,
			optional=>0,
			format=>'fqdn'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'otherHosts',
			description=>'List of static host entries separated by spaces',
			required=>0,
			optional=>1,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'ntpservers',
			description=>'List of ntp server IP addresses separated by spaces',
			required=>0,
			optional=>1,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'superSputEnabled',
			description=>'1 or 0, depending on whether SuperSput should be enabled or not',
			required=>1,
			optional=>0,
			format=>'boolean'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'haFailoverEnabled',
			description=>'1 or 0, depending on whether HA should be enabled or not',
			required=>1,
			optional=>0,
			format=>'boolean'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'portalAddress',
			description=>'IP address of the portal/DB machine',
			required=>0,
			optional=>1,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'VIP',
			description=>'Virtual IP Address definition',
			required=>0,
			optional=>1,
			format=>'VIP'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'OffnetRoute',
			description=>'Off net route definition',
			required=>0,
			optional=>0,
			format=>'OffnetRoute'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'PhysNode',
			description=>'Node definition',
			required=>1,
			optional=>0,
			format=>'PhysNode'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'ApacheServer',
			description=>'Apache server definition',
			required=>0,
			optional=>-1,
			format=>'ApacheServer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'NetworkFilesystem',
			description=>'An NFS mounted filesystem',
			required=>0,
			optional=>-1,
			format=>'NetworkFilesystem'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'LocalConfig',
			description=>'Local configuration server access info',
			required=>0,
			optional=>1,
			format=>'LocalConfig'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'RemoteConfig',
			description=>'Remote configuration server access info',
			required=>0,
			optional=>1,
			format=>'RemoteConfig'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'TomcatServer',
			description=>'System wide parameters for a Tomcat app server',
			required=>0,
			optional=>1,
			format=>'TomcatServer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'ModJK2',
			description=>'Parameters for JK2 clients under Apache',
			required=>0,
			optional=>1,
			format=>'ModJK2'
		)
	);
	return $self;
}

sub nosave
{
	return {'parent'=>1,'satNumber'=>1};
}

sub thisNode
{
	my ($self) = @_;
	if (exists($self->get_PhysNode->{$self->get_satNumber})) {
		return $self->get_PhysNode->{$self->get_satNumber};
	} else {
		return undef
	}
}

sub readFromFile
{
	my ($self,$filename) = @_;

        my $satnumber;
        my $satNameFile = $self->configValue('satNameFile');
        if ($satNameFile and open(FILE,$satNameFile)) {
                $satnumber = <FILE>;
                close(FILE);
                chomp($satnumber);
		$self->set_satNumber($satnumber);
        }

	$self->SUPER::readFromFile($filename);
}

sub create
{
	my ($self,$class,$nodeNumber) = @_;
	$self->add($class,$class->newInitialized($nodeNumber));
}

sub nodeCount
{
	my $self = shift();
	return scalar(@{values(%{$self->get_PhysNode})});
}

sub writeBaseHostsFile
{
	my ($self) = @_;
	if (open(FILE,">$hostsFile")) {
		my $success = 1;
		if (! print FILE "$localhostEntry\n") {
			$success = 0;
		};
		close(FILE);
		return $success;
	} else {
		return 0;
	}
}

sub writeHostsFile
{
	my ($self) = @_;
	if (open(FILE,">$hostsFile")) {
		my $success = 1;
		if (! print FILE "$localhostEntry\n") {
			$success = 0
		};
		if (! print FILE $self->get_smonaddr."\t".$self->get_smonfqdn."\n") {
			$success = 0
		};
		if (! print FILE $self->get_smontestaddr."\t".$self->get_smontestfqdn."\n") {
			$success = 0
		};
		if (! print FILE $self->get_sshaddr."\t".$self->get_sshfqdn."\n") {
			$success = 0
		};
		my %otherHosts = split(/ /,$self->get_otherHosts);
		my ($hostname,$ip);
		while (($ip,$hostname) = each(%otherHosts)) {
			$hostname =~ tr/,/ /;
			if (! print FILE "$ip\t$hostname\n") {
				$success = 0;
			}
		}
		my $privateIp = $self->thisNode->privateIp;
		while (($hostname,$ip) = each(%{$privateIp->clusterHosts})) {
			# NOTE: Kludge for ethernet issue
			if ($ip ne '127.0.0.1') {
				if (! print FILE "$ip\t$PrivateIpAddr::clusterHostNamePrefix$hostname\n") {
					$success = 0;
				}
			}
		}
		close(FILE);
		return $success;
	} else {
		return 0;
	}
}

sub writeResolverFile
{
	my ($self) = @_;
	
	if (open(FILE,">$resolverFile")) {
		my $success = 1;
		if (! print FILE "search ".$self->get_nssearchpath."\n") {
			$success = 0;
		}
		my @servers=split(' ',$self->get_nameservers);
		my $server;
		foreach $server (@servers) {
			if (! print FILE "nameserver ".$server."\n") {
				$success = 0;
			}
		}
		close(FILE);
		return $success;
	} else {
		return 0;
	}
}


1;
