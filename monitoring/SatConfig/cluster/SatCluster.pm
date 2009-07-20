package NOCpulse::SatCluster;
use NOCpulse::Object;
use NOCpulse::Config;
use Config::IniFiles;
use lib qw(/etc/rc.d/np.d);
use PhysCluster;
@ISA=qw(NOCpulse::Object);

$section = 'Cluster';

sub instVarDefinitions
{
	my ($self,@params) = @_;
	$self->SUPER::instVarDefinitions(@params);
	$self->addInstVar('physCluster');
	$self->addInstVar('configFilename');
	$self->addInstVar('npConfig');
	$self->addInstVar('sysvConfig');
	$self->addInstVar('config');
	$self->addInstVar('id');
	$self->addInstVar('nodeId');
	$self->addInstVar('description');
	$self->addInstVar('customerId');
	$self->addInstVar('npIP');
	$self->addInstVar('currentNode');
	$self->addInstVar('isHA',0);
}

sub initialize
{
	my ($self,$npconfig) = @_;
	my $saveconfig = $NOCpulse::Object::config;
	# This package REALLY needs cleaning up.  Most of its functionality
	# has been moved to PhysCluster in the SysV system - otherwise its just
	# a frontend for an ini file.
	my $sysvconfig= NOCpulse::Config->new('/etc/rc.d/np.d/SysV.ini');
	$self->set_sysvConfig($sysvconfig);
	$NOCpulse::Object::config = $sysvconfig;
	$self->set_physCluster(PhysCluster->newInitialized);
	$NOCpulse::Object::config = $saveconfig;
	$self->set_isHA($self->get_physCluster->get_haFailoverEnabled);
	$self->set_currentNode(SatNode->newInitialized($self));
	$self->set_npConfig($npconfig);
	$self->set_configFilename($npconfig->get('netsaint','configDir').'/SatCluster.ini');
	my $config;
	if ( ! -f $self->get_configFilename) {
		open(FILE,">".$self->get_configFilename);
		print FILE "[garbage]\n";
		close(FILE);
	}
    # notice that FILE must not exist
    # (nocpulse user has no write access in /etc/nocpulse)
    if ( -f $self->get_configFilename) {
        $config = Config::IniFiles->new(-file=>$self->get_configFilename);
        $self->set_config($config);
        $self->set_id($self->configValueOf('id'));
        $self->set_nodeId($self->configValueOf('nodeId'));
        $self->set_description($self->configValueOf('description'));
        $self->set_customerId($self->configValueOf('customerId'));
        $self->set_npIP($self->configValueOf('npIP'));
    }
	return $self;
}

sub refreshHAView
{
	return 1;
}

sub configValueOf
{
	my  ($self,$name) = @_;
    if (defined($self->get_config)) {
        return $self->get_config->val($section,$name);
    } else {
        return undef;
    }
}

sub setConfigValueOf
{
	my  ($self,$name,$value) = @_;
	if (! $self->get_config->setval($section,$name,$value)) {
		return $self->get_config->newval($section,$name,$value)
	} else {
		return 1;
	}
}

sub persist
{
	my ($self) = @_;
	$self->setConfigValueOf('id',$self->get_id);
	$self->setConfigValueOf('nodeId',$self->get_nodeId);
	$self->setConfigValueOf('description',$self->get_description);
	$self->setConfigValueOf('customerId',$self->get_customerId);
	$self->setConfigValueOf('npIP',$self->get_npIP);
	if ($self->get_config->WriteConfig($self->get_configFilename)) {
		chmod(0644, $self->get_configFilename);
		return 1;
	} else {
		return 0;
	}
}

sub distributeFile
{
	my ($self,$filename) = @_;
	$filename =~ /^([-\w\/\.]+)$/ and $filename=$1;
	my @messages;
	my $hadProblem = 0;
	my $result= `/etc/rc.d/np.d/cluster --action MirrorFile --file $filename`;
 	if ($? >> 8) { 
		$hadProblem = 1;
	}
	push(@messages,MirrorResult->newInitialized('Cluster',$filename,$result,$hadProblem));
	return @messages;
}

sub runCommand
{
	my ($self,$command) = @_;
	$command =~ /(.*)/ and $command=$1;
	my @messages;
	my $hadProblem = 0;
	my $result = `/etc/rc.d/np.d/cluster --action RunCommand --command $command`;
 	if ($? >> 8) { 
		$hadProblem = 1;
	}
	push(@messages,CommandResult->newInitialized('Cluster',$command,$result,$hadProblem));
	return @messages;
}

package SatNode;
use NOCpulse::PersistentObject;
@ISA=qw(NOCpulse::PersistentObject);

sub instVarDefinitions
{
	my ($self,@params) = @_;
	$self->SUPER::instVarDefinitions($params);
	$self->addInstVar('cluster');
	return $self;
}

sub initialize
{
	my ($self,$cluster,@params) = @_;
	$self->SUPER::initialize(@params);
	$self->set_cluster($cluster);
	return $self;
}

sub get_isLead
{
	# NOTE: At this point this class is kruft - the only reason
	# it exists is so that this method can be called via the
	# SatCluster protocol.  The call(s) in question are somewhere
	# in dequeueing.
	my ($self) = @_;
	my $saveconfig = $NOCpulse::Object::config;
	$NOCpulse::Object::config = $self->get_cluster->get_sysvConfig;
	my $result = $self->get_cluster->get_physCluster->thisNode->isLeading;
	$NOCpulse::Object::config = $saveconfig;
	return $result;
}

package MirrorResult;
use NOCpulse::Object;
@ISA=qw(NOCpulse::Object);

sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('destination');
	$self->addInstVar('filename');
	$self->addInstVar('message');
	$self->addInstVar('hadProblem');
	return $self;
}

sub initialize
{
	my ($self,$destination,$filename,$message,$hadProblem) = @_;
	$self->set_destination($destination);
	$self->set_filename($filename);
	$self->set_message($message);
	$self->set_hadProblem($hadProblem);
	return $self;
}

sub asString
{
	my $self = shift();
	return $self->get_filename."-->".$self->get_destination.": ".$self->get_message;

}
package CommandResult;
use NOCpulse::Object;
@ISA=qw(NOCpulse::Object);

sub instVarDefinitions
{
	my $self = shift();
	$self->addInstVar('destination');
	$self->addInstVar('command');
	$self->addInstVar('message');
	$self->addInstVar('hadProblem');
	return $self;
}

sub initialize
{
	my ($self,$destination,$command,$message,$hadProblem) = @_;
	$self->set_destination($destination);
	$self->set_command($command);
	$self->set_message($message);
	$self->set_hadProblem($hadProblem);
	return $self;
}

sub asString
{
	my $self = shift();
	return $self->get_command." on ".$self->get_destination.": ".$self->get_message;

}


1
