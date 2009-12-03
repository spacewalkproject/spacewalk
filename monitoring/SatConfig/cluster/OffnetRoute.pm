package OffnetRoute;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);

sub instVarDefinitions
{
	my $self = shift();	
	$self->addInstVar('net',undef);
	$self->addInstVar('mask',undef);
	$self->addInstVar('dev',undef);
	$self->addInstVar('gate',undef);
	$self->addInstVar('vip',undef);
	$self->SUPER::instVarDefinitions;
}

sub initialize
{
	my ($self,@params) = @_;
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'net',
			description=>'A network address',
			required=>1,
			optional=>0,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'mask',
			description=>'A CIDR mask (e.g. 24)',
			required=>0,
			optional=>0,
			format=>'cidrMask'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'dev',
			description=>'A device name (e.g. eth0)',
			required=>1,
			optional=>0,
			format=>'deviceName'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'gate',
			description=>'IP address of a gateway',
			required=>1,
			optional=>0,
			format=>'ipAddress'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'vip',
			description=>'Virtual IP address',
			required=>0,
			optional=>1,
			format=>'ipAddress'
		),
	);
	return $self->SUPER::initialize(@params);
}

1;
