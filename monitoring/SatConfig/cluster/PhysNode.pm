package PhysNode;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
use IpAddr;
use PrivateIpAddr;
use HostsAccess;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->addInstVar('IpAddr',{});
	$self->addInstVar('PrivateIpAddr',{});
	$self->addInstVar('HostsAccess',{});
	$self->addInstVar('hostname');
	$self->SUPER::instVarDefinitions;
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'IpAddr',
			description=>'An IP Address definition',
			required=>1,
			optional=>-1,
			format=>'IpAddr'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'PrivateIpAddr',
			description=>'A private IP Address definition',
			required=>1,
			optional=>0,
			format=>'PrivateIpAddr'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'HostsAccess',
			description=>'Hosts allowed to access a daemons services',
			required=>0,
			optional=>-1,
			format=>'HostsAccess'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'hostname',
			description=>'Host Name',
			required=>0,
			optional=>1,
			format=>'string'
		)
	);
	
	return $self;
}

sub defaultRouteIp
{
	my $self = shift();
	my $ips = $self->get_IpAddr;
	my ($ipid,$ip);
	while (($ipid,$ip) = each(%$ips)) {
		if ($ip->get_gate) {
			return $ip
		}
	}
	return undef;
}

sub isLeading
{
	my $self = shift();
	if ($self->get_parent->get_haFailoverEnabled) {
		return (-f $self->configValue('leaderFlag'));
	} else {
		return 1;
	}
}

sub setLeading
{
	my ($self,$state) = @_;
	if ($self->get_parent->get_haFailoverEnabled) {
		if ($state) {
			open(FILE,'>'.$self->configValue('leaderFlag'));
			print FILE "KNEEL, KNAVE!\n";
			close(FILE);
		} else {
			unlink($self->configValue('leaderFlag'));
		}
	}
}

sub privateIp
{
	my $self = shift();
	return $self->get_PrivateIpAddr->{0};
}


1;
