package TomcatServer;
use lib qw(/etc/rc.d/np.d);
use ConfigObject;
@ISA=qw(ConfigObject);


sub instVarDefinitions
{
	my $self = shift();	
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('csdb_connpool_min_limit');    #  '1'
	$self->addInstVar('csdb_connpool_max_limit');    #  '5'
	$self->addInstVar('csdb_connpool_increment');    #  '2'
	$self->addInstVar('csdb_connpool_active_size');  #  '1'
	$self->addInstVar('csdb_connpool_pool_size');    #  '1'
	$self->addInstVar('csdb_connpool_timeout');      #  '10'
	$self->addInstVar('csdb_connpool_nowait');       #  'false'
	$self->addInstVar('cfdb_connpool_min_limit');    #  '1'
	$self->addInstVar('cfdb_connpool_max_limit');    #  '5'
	$self->addInstVar('cfdb_connpool_increment');    #  '2'
	$self->addInstVar('cfdb_connpool_active_size');  #  '1'
	$self->addInstVar('cfdb_connpool_pool_size');    #  '1'
	$self->addInstVar('cfdb_connpool_timeout');      #  '10'
	$self->addInstVar('cfdb_connpool_nowait');       #  'false'
	$self->addInstVar('http_minProcessors');         # '5'
	$self->addInstVar('http_maxProcessors');         # '75'
	$self->addInstVar('http_enableLookups');         # 'false'
	$self->addInstVar('http_redirectPort');          # '8443'
	$self->addInstVar('http_acceptCount');           # '10'
	$self->addInstVar('http_connectionTimeout');     # '60000'
	$self->addInstVar('ajp_minProcessors');         # '5'
	$self->addInstVar('ajp_maxProcessors');         # '75'
	$self->addInstVar('ajp_acceptCount');           # '10'
	$self->addInstVar('debugLevel');            # 0
	$self->addInstVar('javaOpts');		    # ''

}

sub initialize
{
	my ($self,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->addValidators(
		SatConfig::cluster::Validator->newInitialized(
			name=>'csdb_connpool_min_limit',
			description=>'The Minimum number of physical connections maintained by the current state connection pool',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'csdb_connpool_max_limit',
			description=>'The Maximum number of physical connections maintained by the current state connection pool',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'csdb_connpool_increment',
			description=>'Incremental number of physical current state connections to be opened when all the existing ones are busy and a new connection is requested.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'csdb_connpool_active_size',
			description=>'kdykeman fix',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'csdb_connpool_pool_size',
			description=>'kdykeman fix',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'csdb_connpool_timeout',
			description=>'Specifies how much time must pass before an idle physical current state connection is disconnected',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'csdb_connpool_nowait',
			description=>'Specifies whether to wait or return an error if the maximum number of connections are in the pool and busy.',
			required=>1,
			optional=>0,
			format=>'boolean'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'cfdb_connpool_min_limit',
			description=>'The Minimum number of physical connections maintained by the configuration connection pool',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'cfdb_connpool_max_limit',
			description=>'The Maximum number of physical connections maintained by the configuration connection pool',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'cfdb_connpool_increment',
			description=>'Incremental number of physical current state connections to be opened when all the existing ones are busy and a new connection is requested.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'cfdb_connpool_active_size',
			description=>'kdykeman fix',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'cfdb_connpool_pool_size',
			description=>'kdykeman fix',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'cfdb_connpool_timeout',
			description=>'Specifies how much time must pass before an idle physical current state connection is disconnected',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'cfdb_connpool_nowait',
			description=>'Specifies whether to wait or return an error if the maximum number of connections are in the pool and busy.',
			required=>1,
			optional=>0,
			format=>'boolean'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'http_minProcessors',
			description=>'The number of http request processing threads that will be created on startup. The default value is 5.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'http_maxProcessors',
			description=>'The maximum number of simultaneous requests that can be handled on the http port.  The default value is 20.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'http_enableLookups',
			description=>'Whether or not to perform DNS lookups to return the actual host name of the remote client',
			required=>1,
			optional=>0,
			format=>'boolean'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'http_redirectPort',
			description=>'The ssl port if being used',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'http_acceptCount',
			description=>'The maximum queue length for incoming http connection requests when all possible request processing threads are in use. Any requests received when the queue is full will be refused.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'http_connectionTimeout',
			description=>'The number of milliseconds to wait, after accepting a connection, for the request URI line to be presented.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'ajp_minProcessors',
			description=>'The number of ajp request processing threads that will be created on startup. The default value is 5.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'ajp_maxProcessors',
			description=>'The maximum number of simultaneous requests that can be handled on the ajp port.  The default value is 20.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'ajp_acceptCount',
			description=>'The maximum queue length for incoming ajp connection requests when all possible request processing threads are in use. Any requests received when the queue is full will be refused.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'debugLevel',
			description=>'The debugging detail level of log messages generated, with higher numbers creating more detailed output.',
			required=>1,
			optional=>0,
			format=>'integer'
		),
		SatConfig::cluster::Validator->newInitialized(
			name=>'javaOpts',
			description=>'Java runtime options passed on invocation of the java process',
			required=>0,
			optional=>1,
			format=>'string'
		),
	);
	return $self;
}

sub javabool
{
	my($self,$varname) = @_;
	return ($self->get($varname)?"true":"false");
}

1;
