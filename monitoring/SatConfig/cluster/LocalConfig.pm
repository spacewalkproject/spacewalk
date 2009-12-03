package LocalConfig;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->addInstVar('dbd');
	$self->addInstVar('dbname');
	$self->addInstVar('orahome');
	$self->addInstVar('username');
	$self->addInstVar('password');
	$self->SUPER::instVarDefinitions;
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'dbd',
			description=>'Database driver (usually Oracle)',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'dbname',
			description=>'Database name (usually licensed01)',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'orahome',
			description=>'Path to Oracle home (/home/oracle/OraHome1)',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'username',
			description=>'User to log in to database as (web)',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'username',
			description=>'Passwod to log into database with',
			required=>1,
			optional=>0,
			format=>'string'
		)
	);
	return $self;
}

1;
