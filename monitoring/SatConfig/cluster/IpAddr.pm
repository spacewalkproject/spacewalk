package IpAddr;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
use TomcatBinding;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('dev');
	$self->addInstVar('speed');
	$self->addInstVar('mtu');
	$self->addInstVar('mac');
	$self->addInstVar('addr');
	$self->addInstVar('mask');
	$self->addInstVar('gate');
	$self->addInstVar('fqdn');
	$self->addInstVar('TomcatBinding',{});
}

sub initialize
{
	my ($self,@params) = @_;
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'dev',
			description=>'A device name (e.g. eth0)',
			required=>1,
			optional=>0,
			format=>'deviceName'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'speed',
			description=>'Force link speed (100baseT4, 100baseTx, 100baseTx-FD, 100baseTx-HD, 10baseT, 10baseT-FD, 10baseT-HD)',
			required=>0,
			optional=>1,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'mtu',
			description=>'Force link mtu size',
			required=>0,
			optional=>1,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'mac',
			description=>'A MAC address (e.g. 00:D0:11:22:33:44)',
			required=>0,
			optional=>0,
			format=>'macAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'addr',
			description=>'An IP address',
			required=>1,
			optional=>0,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'mask',
			description=>'A CIDR netmask (e.g. 24)',
			required=>1,
			optional=>0,
			format=>'cidrMask'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'gate',
			description=>'IP address of gateway',
			required=>0,
			optional=>1,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'fqdn',
			description=>'Fully qualified domain name for this address',
			required=>0,
			optional=>1,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'TomcatBinding',
			description=>'Tomcat App Server Binding',
			required=>0,
			optional=>1,
			format=>'TomcatBinding'
		),
	);
	return $self->SUPER::initialize(@params);
}


sub macAddress
{
	my $self = shift();
	my $dev = $self->get_dev;
	my $mac = `/sbin/ifconfig $dev`;
	if ($mac =~ /HWaddr (\S+)/) {
		return $1;
	} else {
		# NOTE: Kludge for ethernet issue - should be undef
		return '00:00:00:00:00';
	}
}

1;
