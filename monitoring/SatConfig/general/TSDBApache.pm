package TSDBApache;
use Apache;
@ISA=qw(Apache);

sub addVsRewriteRules
{
}

sub generateGlobalConfiguration
{
	my $self = shift();
	$self->SUPER::generateGlobalConfiguration;
	my $cluster = Apache->getClassVar('cluster');
	my $apacheConf = Apache->getClassVar('apacheConf');
	$apacheConf->directive('Timeout')->set_value(300);
	$apacheConf->directive('MaxSpareServers')->set_value(40);
	$apacheConf->directive('StartServers')->set_value(5);
	$apacheConf->directive('MaxRequestsPerChild')->set_value(200);
	$apacheConf->directive('User')->set_value('nocpulse');
	$apacheConf->directive('Group')->set_value('nocpulse');
	$apacheConf->directive('ErrorLog')->delete;
	$apacheConf->directive('PidFile')->set_value($self->configValue('logDir').'/'.ref($self).'pid');
	$apacheConf->directive('LogFormat')->set_value('"%h %l %u %t \"%r\" %>s %b" common');
	$apacheConf->directive('LogLevel')->set_value('info');
	$apacheConf->directive('CustomLog')->delete;
	$self->addLog($apacheConf,'CustomLog',ref($self).'_access_log','common');
	$self->addLog($apacheConf,'ErrorLog',ref($self).'_error_log');
	$apacheConf->add_directive(DefaultType => 'text/plain');
	$apacheConf->add_directive(ScoreBoardFile => $self->configValue('logDir').'/'.ref($self).'.scoreboard');
	$apacheConf->directive('MaxClients')->set_value(100);
}

1;
