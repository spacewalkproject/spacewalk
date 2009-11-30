package HostsAccess;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->addInstVar('allow');
	$self->SUPER::instVarDefinitions;
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'allow',
			description=>'Comma separated list of hosts (per hosts_access(5)) allowed access to this daemon',
			required=>0,
			optional=>1,
			format=>'string'
		)
	);
	return $self;
}

1;
