package ClustCfgServices;
use  GogoSysVStep;
@ISA=qw(GogoSysVStep);

sub overview
{
	return 'Starts the cluster configuration services daemon.  This daemon permits cluster reconfiguration and other administrative functions';
}
# Remainder of definition is in .ini file

1;
