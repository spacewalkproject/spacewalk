package ApacheServer;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->addInstVar('serverName');
	$self->addInstVar('serverAlias');
	$self->addInstVar('allowedClients');
	$self->SUPER::instVarDefinitions;
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'serverName',
			description=>'Fully qualified host+domain name of the server in question',
			required=>0,
			optional=>1,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'serverAlias',
			description=>'Short name (i.e. host name) of the server',
			required=>0,
			optional=>1,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'allowedClients',
			description=>'Space separated list of IP addresses that clients can connect from (if none, all are allowed)',
			required=>0,
			optional=>1,
			format=>'string'
		)
	);
	
	return $self;
}

1;
