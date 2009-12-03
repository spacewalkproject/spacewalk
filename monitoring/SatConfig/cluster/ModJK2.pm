package ModJK2;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('jkshmSize');            # 1048576
	$self->addInstVar('webapps');              # /usr/share/java/webapps/rhn-notification /usr/share/java/webapps/rhn-monitoring
	$self->addInstVar('serverClusterFilename');# /etc/J2KServerCluster.ini
	$self->addInstVar('debugLevel');           # 0
	$self->addInstVar('serverCluster');

}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'jkshmSize',
			description=>'dykeman fix',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'webapps',
			description=>'dykeman fix',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'serverClusterFilename',
			description=>'Configuration filename (on this machine) of the J2K server cluster',
			required=>1,
			optional=>0,
			format=>'string'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'debugLevel',
			description=>'dykeman fix',
			required=>1,
			optional=>0,
			format=>'integer'
		),
	);
	return $self;
}

sub get_serverCluster
{
	my $self = shift();
	if (! $self->get('serverCluster')) {
		$self->set_serverCluster(PhysCluster->newInitialized($self->get_serverClusterFilename));
	}
}

1;
