package NetworkFilesystem;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->addInstVar('source');
	$self->SUPER::instVarDefinitions;
}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'source',
			description=>'<servername>:</path/to/mount>',
			required=>1,
			optional=>0,
			format=>'string'
		)
	);
	return $self;
}

1;
