package PrivateIpAddr;
use lib qw(/etc/rc.d/np.d);
use IpAddr;
@ISA=qw(IpAddr);

$clusterHostNamePrefix = 'satellite-ha';

%clusterHostsLO = (
	1=>'127.0.0.1',
	2=>'127.0.0.1'
);
%clusterHostsETH = (
	1=>'63.121.136.235',
	2=>'63.121.136.236',
	3=>'63.121.136.237',
	4=>'63.121.136.238',
	5=>'63.121.136.239',
	6=>'63.121.136.240',
	7=>'63.121.136.241',
	8=>'63.121.136.242',
	9=>'63.121.136.243',
	10=>'63.121.136.244',
	11=>'63.121.136.245',
	12=>'63.121.136.246',
	13=>'63.121.136.247',
	14=>'63.121.136.248',
	15=>'63.121.136.249',
	16=>'63.121.136.250',
	17=>'63.121.136.251',
	18=>'63.121.136.252',
	19=>'63.121.136.253',
	20=>'63.121.136.254'
);

sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('satId');
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->set_validators([]);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'dev',
			description=>'A device name (e.g. eth0 or lo)',
			required=>1,
			optional=>0,
			format=>'string'
		)
	);
	return $self;
}

sub get_mask
{
	my $self = shift();
	# NOTE: Get rid of PrivateNet--privateNetMask etc in NOCpulse.ini
	if ($self->get_dev eq 'lo') {
		return 32
	} else {
		return 27
	}
}

sub privateNetwork
{
	my $self = shift();
	if ($self->get_dev eq 'lo') {
		return '127.0.0.0';
	} else {
		return '63.121.136.224';
	}
}

sub broadcastAddr
{
	my $self = shift();
	if ($self->get_dev eq 'lo') {
		return '127.0.0.255';
	} else {
		return '63.121.136.255';
	}
}

sub get_addr
{
	my $self = shift();
	return $self->ipForNumber($self->get_parent->get_id);
}

sub nameForNumber
{
	my ($self,$number) = @_;
	# Note:Kludge for spare ethernet card issue
	if ($self->ipForNumber($number) eq '127.0.0.1') {
		return "localhost";
	} else {
		return "$clusterHostNamePrefix$number";
	}
}

sub ipForNumber
{
	my ($self,$number) = @_;
	return $self->clusterHosts->{$number};
}

sub clusterHosts
{
	my ($self) = @_;
	if ($self->get_dev eq 'lo') {
		$self->dprint(3,'Using LOopback clusterHosts table');
		return \%clusterHostsLO;
	} else {
		$self->dprint(3,'Using ETHernet clusterHosts table');
		return \%clusterHostsETH;
	}
}

sub hostname
{
	my ($self,$usersId) = @_;
	if (defined($usersId)) {
		return $self->nameForNumber($usersId);
	} else {
		return $self->nameForNumber($self->get_parent->get_id);
	}
}

sub ipAddr
{
	my $self = shift();
	return $self->ipForNumber($self->get_id);
}


1;

