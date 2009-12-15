package RemoteConfig;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->addInstVar('protocol');
	$self->addInstVar('host');
	$self->addInstVar('path');
	$self->SUPER::instVarDefinitions;
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'protocol',
			description=>'Protocol to access configuration server with (http/https)',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'host',
			description=>'Host to connect to (defaults to smon address)',
			required=>0,
			optional=>1,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'path',
			description=>'Path to configuration program (/cgi-bin/fetch_nocpulse_ini.cgi)',
			required=>1,
			optional=>0,
			format=>'string'
		)
	);
	return $self;
}

1;
