package Tomcat;

use strict;
use vars qw(@ISA);

use File::Copy;
use XML::Generator;
use PhysCluster;
use GogoSysVStep;
use Data::Dumper;

@ISA=qw(GogoSysVStep);


sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	# DAP NOTE: NEED UPGRADE STEP TO *DELETE* OLD STATE FILE, ELSE ABEND!!
	$self->addInstVar('cluster');
	$self->addInstVar('serverVariables');
	$self->addInstVar('bindings');
}


sub initialize
{
	my ($self,@params) = @_;
	my $self = $self->SUPER::initialize(@params);
	my @bindings;
	$self->set_cluster(PhysCluster->newInitialized);
	my $node = $self->get_cluster->thisNode;
	my ($number,$addr,$ip,$fqdn,$bnumber,$binding);
	my $ipAddrs = $node->get_IpAddr;
	while (($number,$addr) = each(%$ipAddrs)) {
		while (($bnumber,$binding) = each(%{$addr->get_TomcatBinding})) {
			push(@bindings,$binding);
		}
	}
	$self->set_bindings(\@bindings);
	$self->set_serverVariables($self->get_cluster->get_TomcatServer->{0});
	return $self;
}

sub persist
{
	# If we don't do this we'll end up persisting the bindings (which 
	# are quite large as they actually contain all of the cluster definition).
	# This hook lets us do things like ensure that something will not persist.
	#
	my $self = shift();
	my $bindings = $self->get_bindings;
	my $serverVariables= $self->get_serverVariables;
	my $cluster = $self->get_cluster;
	$self->set_bindings(undef);
	$self->set_cluster(undef);
	$self->set_serverVariables(undef);
	my $result = $self->SUPER::persist;
	$self->set_bindings($bindings);
	$self->set_serverVariables($serverVariables);
	$self->set_cluster($cluster);
	return $result;
}



sub startActions
{
    my $self = shift();

    my $catalinaBase = $self->configValue('catalinaBase');
    my $logDir = "$catalinaBase/logs";
    my $tempDir = $self->configValue('catalinaTempDir');

    # The log directory and the temporary directory must exist.
    if (!-d $logDir) {
        mkdir $logDir, 0755 || $self->addError('Error creating logs directory: $logDir');
    }
    if (!-d $tempDir) {
        mkdir $tempDir, 0775 || $self->addError('Error creating temp directory: $tempDir');
        my ($username,$password,$uid,$gid) = getpwnam($self->configValue('user'));
        chown $uid, $gid, $tempDir;
    }

    $self->generateServerConfFile || $self->addError('Error generating config file');
    $self->addShellStopAction($self->configValue('stopCommand'));
    
    # Leave the config file, since to stop action is launched in a seperate thread,
    # there is the potential that the config file could get removed too soon.
    #$self->addShellStopAction('rm '.$self->configValue('configFile'));
    
    $self->SUPER::startActions;
}



######################################################
# now we get into the meat of the xml file generation.
######################################################

sub generateServerConfFile
{
    my $self = shift();
    my $configFile = $self->configValue('catalinaBase') . '/conf/server.xml',

    my $dg = XML::Generator->new( escape => 'always',
                                  pretty => 2,
                                  conformance => 'strict');
    my $success = 1;

    # Get the config values that we need from NOCpulse.ini
    local * SERVER_XML;
    open(SERVER_XML, '>', $configFile) || ($success = 0);
    if ($success) {
	my $content = $self->createServer($dg);
	$self->dprint(9,"SERVER XML FOLLOWS:\n\n\n$content\n\n");
        print SERVER_XML $content || ($success = 0);
        close(SERVER_XML) || ($success = 0);
    }
    return $success;
}


# Define the resources that will  be used for database connectivity.
# The resources are hardcoded in this version, though they don't
# have to be.
sub getResourceDefinitions
{
    my $self = shift();
    my $cfg = new NOCpulse::Config;

    my $configDbDef = {
        attributes => { 'name' => 'jdbc/ConfigDB',
                        'auth' => 'Container',
                        'type' => 'oracle.jdbc.pool.OracleOCIConnectionPool',
                        'description' => 'Connection to the configuration database' },

        parameters => { 'factory'                 => 'oracle.jdbc.pool.OracleDataSourceFactory',
                        'user'                    => $cfg->get('cf_db', 'username'),
                        'password'                => $cfg->get('cf_db', 'password'),
                        'url'                     => 'jdbc:oracle:oci8:@' . $cfg->get('cf_db', 'name'),
                        'connpool_min_limit'      => $self->get_serverVariables->get_cfdb_connpool_min_limit,
                        'connpool_max_limit'      => $self->get_serverVariables->get_cfdb_connpool_max_limit,
                        'connpool_increment'      => $self->get_serverVariables->get_cfdb_connpool_increment,
                        'connpool_active_size'    => $self->get_serverVariables->get_cfdb_connpool_active_size,
                        'connpool_pool_size'      => $self->get_serverVariables->get_cfdb_connpool_pool_size,
                        'connpool_timeout'        => $self->get_serverVariables->get_cfdb_connpool_timeout,
                        'connpool_nowait'         => $self->get_serverVariables->javabool('cfdb_connpool_nowait'),
                        'connpool_is_poolcreated' => 'false'}
    };
    
    my $stateDbDef = {
        attributes => { 'name' => 'jdbc/StateDB',
                        'auth' => 'Container',
                        'type' => 'oracle.jdbc.pool.OracleOCIConnectionPool',
                        'description' => 'Connection to the current state database' },

        parameters => { 'factory'                 => 'oracle.jdbc.pool.OracleDataSourceFactory',
                        'user'                    => $cfg->get('cs_db', 'username'),
                        'password'                => $cfg->get('cs_db', 'password'),
                        'url'                     => 'jdbc:oracle:oci8:@' . $cfg->get('cf_db', 'name'),
                        'connpool_min_limit'      => $self->get_serverVariables->get_csdb_connpool_min_limit,
                        'connpool_max_limit'      => $self->get_serverVariables->get_csdb_connpool_max_limit,
                        'connpool_increment'      => $self->get_serverVariables->get_csdb_connpool_increment,
                        'connpool_active_size'    => $self->get_serverVariables->get_csdb_connpool_active_size,
                        'connpool_pool_size'      => $self->get_serverVariables->get_csdb_connpool_pool_size,
                        'connpool_timeout'        => $self->get_serverVariables->get_csdb_connpool_timeout,
                        'connpool_nowait'         => $self->get_serverVariables->javabool('csdb_connpool_nowait'),
                        'connpool_is_poolcreated' => 'false'}
    };
    return ($configDbDef, $stateDbDef);
}


# Define a list of hashes where each entry in the list represenst
# a hash of attributes for a connection.
sub getConnectorDefinitions
{
    my $self = shift();
    
    #define the http connector (required for waron)
    my $httpConnector = {
        'className'         => 'org.apache.coyote.tomcat4.CoyoteConnector',
        'port'              => $self->get_bindings->[0]->get_httpPort,
        'minProcessors'     => $self->get_serverVariables->get_http_minProcessors,
        'maxProcessors'     => $self->get_serverVariables->get_http_maxProcessors,
        'enableLookups'     => $self->get_serverVariables->javabool('http_enableLookups'),
        'redirectPort'      => $self->get_serverVariables->get_http_redirectPort,
        'acceptCount'       => $self->get_serverVariables->get_http_acceptCount,
        'connectionTimeout' => $self->get_serverVariables->get_http_connectionTimeout,
        'debug'             => $self->get_serverVariables->get_debugLevel
    };
    
    #define the ajp13 connector
    (my $ajpHost = $self->get_bindings->[0]->get_parent->get_fqdn) || $self->addError('IpAddr '.$self->get_bindings->[0]->get_parent->get_id.' FQDN required for ajpHost but not defined');
    my $ajpPort = $self->get_bindings->[0]->get_ajpPort;
    my $ajpConnector = {
        'className'     => 'org.apache.ajp.tomcat4.Ajp13Connector',
        'port'          => $ajpPort,
        'minProcessors'     => $self->get_serverVariables->get_ajp_minProcessors,
        'maxProcessors'     => $self->get_serverVariables->get_ajp_maxProcessors,
        'acceptCount'       => $self->get_serverVariables->get_ajp_acceptCount,
        'debug'         => $self->get_serverVariables->get_debugLevel
    };

    my @connectors = ($httpConnector, $ajpConnector);
    return @connectors;
}


# Define a list of hashes where each entry in the list represenst
# a hash of attributes for a Listener.
sub getServerListenerDefs
{
    my $self = shift();
    my @listenerDefs = (
        {'className' => 'org.apache.catalina.mbeans.ServerLifecycleListener',
         'debug'     => $self->get_serverVariables->get_debugLevel},
        {'className' => 'org.apache.catalina.mbeans.GlobalResourcesLifecycleListener',
         'debug'     => $self->get_serverVariables->get_debugLevel}
    );
    return @listenerDefs;
}


sub createServer
{
    my ($self, $dg) = @_;
    
    my $server = $dg->Server({'port'     => $self->get_bindings->[0]->get_shutdownPort,
                              'shutdown' => $self->configValue('shutdownCommand'),
                              'debug'    => $self->get_serverVariables->get_debugLevel},
                             $self->createServerListeners($dg),
                             $self->createServices($dg),
                             $self->createGlobalNamingResources($dg));
    return $server;
}


sub createServerListeners
{
    my ($self, $dg) = @_;
    my @serverListeners;

    foreach my $listenerDef ($self->getServerListenerDefs) {
        push (@serverListeners, $dg->Listener($listenerDef));
    }
    return @serverListeners;
}


sub createServices
{
    my ($self, $dg) = @_;
    my @services;
 
    push @services, $dg->Service({ 'name' => 'RHN-Web' },
                                 $self->createConnectors($dg),
                                 $self->createEngine($dg));
    return @services;
}


sub createConnectors
{
    my ($self, $dg) = @_;
    my @connectors;

    foreach my $connectorDef ($self->getConnectorDefinitions) {
        push (@connectors, $dg->Connector($connectorDef));
    }
    return @connectors;
}


sub createEngine
{
    my ($self, $dg) = @_;

    (my $ajpHost = $self->get_bindings->[0]->get_parent->get_fqdn) || $self->addError('IpAddr '.$self->get_bindings->[0]->get_parent->get_id.' FQDN required for ajpHost but not defined');
    my $ajpPort = $self->get_bindings->[0]->get_ajpPort;

    my $logger = $dg->Logger({'className' => 'org.apache.catalina.logger.FileLogger',
                              'prefix'    => 'command_log.',
                              'suffix'    => '.txt',
                              'timestamp' => 'true',
                              'verbosity' => '2'});
                              
    my $realm = $dg->Realm({'className'      => 'org.apache.catalina.realm.DataSourceRealm',
                            'dataSourceName' => 'jdbc/ConfigDB',
                            'userTable'      => 'contact',
                            'userNameColumn' => 'username',
                            'userCredCol'    => 'password',
                            'digest'         => 'MD5',
                            'userRoleTable'  => 'contact',
                            'roleNameCol'    => 'privilege_type_name'});
                            
    my $engine = $dg->Engine({'name'        => 'Command',
                              'defaultHost' => 'command',
                              'jvmRoute'    => $ajpHost,
                              'debug'       => $self->get_serverVariables->get_debugLevel},
                             $logger,
                             $realm,
                             $self->createHost($dg));
    return $engine;
}


sub createHost
{
    my ($self, $dg) = @_;
    my @valves;
    my $sso = $dg->Valve({'className' => 'org.apache.catalina.authenticator.SingleSignOn',
                          'debug'     => $self->get_serverVariables->get_debugLevel});
    push (@valves, $sso);
    
    my $host = $dg->Host({'name'                  => 'command',
                          'appBase'               => 'webapps',
                          'unpackWARs'            => 'false',
                          'autoDeploy'            => 'true',
                          'liveDeploy'            => 'false',
                          'errorReportValveClass' => 'org.apache.catalina.valves.ErrorReportValve',
                          'workDir'               => $self->configValue('catalinaTempDir') . '/work/Command/command',
                          'debug'                 => $self->get_serverVariables->get_debugLevel},
                         @valves,
                         $self->createDefaultContext($dg));
    return $host;
}


sub createDefaultContext
{
    my ($self, $dg) = @_;
    my $configRL = $dg->ResourceLink({'name' => 'jdbc/configDB',
                                      'global' => 'jdbc/ConfigDB',
                                      'type' => 'java.sql.DataSource'});

    my $stateRL = $dg->ResourceLink({'name' => 'jdbc/stateDB',
                                     'global' => 'jdbc/StateDB',
                                     'type' => 'java.sql.DataSource'});
    
    my $dc = $dg->DefaultContext({'cookies'       => 'true',
                                  'crossContext'  => 'true',
                                  'reloadable'    => 'false',
                                  'swallowOutput' => 'true',
                                  'useNaming'     => 'true'},
                                  $configRL,
                                  $stateRL);
    return $dc;
} 


sub createGlobalNamingResources
{
    my ($self, $dg) = @_;
    my @resources = $self->createResources($dg);
    my @resourceParams = $self->createResourceParams($dg);

    my $namingResources = $dg->GlobalNamingResources(@resources, @resourceParams);
    return $namingResources;
}


sub createResources
{
    my ($self, $dg) = @_;
    my @resources;

    foreach my $resDef ($self->getResourceDefinitions) {
        my $resource = $dg->Resource(%$resDef->{'attributes'});
        push (@resources, $resource);
    }    
    return @resources;
}


sub createResourceParams
{
    my ($self, $dg) = @_;
    my @resourceParams;

    # iterate over the resource definitions, creating "ResourceParams" nodes
    # for each definition
    foreach my $resDef ($self->getResourceDefinitions) {
        my @paramList;
        my $resName = %$resDef->{'attributes'}->{'name'};
        my $resDefParams = %$resDef->{'parameters'};

        # iterate over the parameters creating a child "parameter" node
        # for each parameter.
        foreach my $paramName (keys (%$resDefParams))
        {
            push (@paramList, $self->createParam($dg, $paramName, $resDefParams->{$paramName}));
        }
        my $params = $dg->ResourceParams({'name' => $resName}, @paramList);
        push (@resourceParams, $params);
    }    
    return @resourceParams;
}


# Creates a "parameter" node with the following fragment structure:
# <parameter>
#   <name>$name</name>
#   <value>$value</value>
# </parameter>
#
sub createParam
{
    my ($self, $dg, $name, $value) = @_;
    my $param = $dg->parameter($dg->name($name), $dg->value($value));
    return $param;
}



# The default command should take its path from catalinaHome
sub get_command
{
    my $self = shift();

    my $command = $self->configValue('command');
    if (!defined($command))
    {
        $ENV{'JAVA_HOME'} = $self->configValue('javaHome');
        $ENV{'JAVA_OPTS'} = $self->configValue('javaOpts');

        my $catalinaHome = $self->configValue('catalinaHome');
        $ENV{'CATALINA_HOME'} = $catalinaHome;
        $ENV{'CATALINA_BASE'} = $self->configValue('catalinaBase');
        $ENV{'CATALINA_TMPDIR'} = $self->configValue('catalinaTempDir');
        $ENV{'CATALINA_PID'} = $self->configValue('catalinaBase') . '/logs/catalina.pid';

        my $oracleHome = $self->configValue('oracleHome');
        $ENV{'ORACLE_HOME'} = $oracleHome;
        $ENV{'LD_LIBRARY_PATH'} = $ENV{'LD_LIBRARY_PATH'} . ":$oracleHome/lib";

        # use the version of the jdbc classes distributed with the oracle client
        # unless overridden in the endorsed directory.
        # XXX - eek this should really go somewhere other than get_command, but
        #   we have to be sure ORACLE_HOME is set - KD (12/5/2003)
        if (-r "$oracleHome/jdbc/lib/ocrs12.jar") {
            copy ("$oracleHome/jdbc/lib/ocrs12.jar", "$catalinaHome/common/lib/ocrs12.jar");
        }
        if (-r "$oracleHome/jdbc/lib/ojdbc14.jar") {
            copy ("$oracleHome/jdbc/lib/ojdbc14.jar", "$catalinaHome/common/lib/ojdbc14.jar");
        }
        
        $command = $catalinaHome . '/bin/catalina.sh run';
    }
    return $command;
}


# The default stop command should take its path from catalinaHome
sub get_stopCommand
{
    my $self = shift();

    my $command = $self->configValue('stopCommand');
    if (!defined($command))
    {
        $ENV{'JAVA_HOME'} = $self->configValue('javaHome');
        $ENV{'JAVA_OPTS'} = $self->configValue('javaOpts');
        $ENV{'CATALINA_HOME'} = $self->configValue('catalinaHome');
        $ENV{'CATALINA_BASE'} = $self->configValue('catalinaBase');

        $command = $self->configValue('catalinaHome') . '/bin/catalina.sh stop';
    }
    return $command;
}


1;
