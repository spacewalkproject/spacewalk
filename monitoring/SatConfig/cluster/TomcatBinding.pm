package TomcatBinding;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->addInstVar('shutdownPort');
	$self->addInstVar('httpPort');
	$self->addInstVar('ajpPort');
	$self->SUPER::instVarDefinitions;
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'shutdownPort',
			description=>'Port on which Tomcat should listen for a shutdown message',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'httpPort',
			description=>'Server HTTP server port',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'ajpPort',
			description=>'Port on which AJP content is served (a highly-optimized transaction protocol)',
			required=>1,
			optional=>0,
			format=>'integer'
		),
	);
	
	return $self;
}

1;
