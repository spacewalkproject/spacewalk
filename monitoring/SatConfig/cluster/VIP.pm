package VIP;
use lib qw(/etc/rc.d/np.d);
use IpAddr;
@ISA=qw(IpAddr);

sub instVarDefinitions
{
	my $self = shift();	
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('network');
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'network',
			description=>'A network address',
			required=>1,
			optional=>0,
			format=>'ipAddress'
		)
	);
	return $self;
}
