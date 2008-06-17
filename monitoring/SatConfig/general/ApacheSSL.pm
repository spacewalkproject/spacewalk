package ApacheSSL;
use Apache;
@ISA=qw(Apache);

sub addGlobalDirectives
{
	my $self = shift();
        my $cluster = Apache->getClassVar('cluster');
        my $apacheConf = Apache->getClassVar('apacheConf');
	$apacheConf->add_directive(SSLPassPhraseDialog=>'builtin');
	$apacheConf->add_directive(SSLSessionCache=>'shm:'.$self->configValue('logDir').'/ssl_scache(512000)');
	$apacheConf->add_directive(SSLMutex=>'sem');
	$apacheConf->add_directive(SSLRandomSeed=>'startup builtin');
	$apacheConf->add_directive(SSLRandomSeed=>'connect builtin');
	$apacheConf->add_directive(SSLRandomSeed=>'startup file:/dev/urandom 512');
	$apacheConf->add_directive(SSLRandomSeed=>'connect file:/dev/urandom 512');
	$apacheConf->add_directive(LogFormat => '"%a %t %T %P %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %>s %b%c" sslspec');
	$self->addLog($apacheConf,'CustomLog',ref($self).'_request_log','sslspec');
	$apacheConf->add_directive(SSLLogLevel => 'info');
	$self->addLog($apacheConf,'SSLLog',ref($self).'_ssl_log');
	$apacheConf->add_directive(Port=>'443');
	$apacheConf->add_directive(SSLEngine => 'on');
	$apacheConf->add_directive(SSLSessionCacheTimeout =>  '600');
	$apacheConf->add_directive(SSLProtocol => '+all');
        $apacheConf->add_directive(SSLCertificateFile => "/opt/apache/conf/ssl.crt/miab.nplab.redhat.com.crt");
        $apacheConf->add_directive(SSLCertificateKeyFile => "/opt/apache/conf/ssl.key/miab.nplab.redhat.com.key");
        $apacheConf->add_directive(SSLCACertificateFile => "/opt/apache/conf/ssl.crt/nocpulse-sys-sat-ca.crt");
        $apacheConf->add_directive(SSLCertificateChainFile => "/opt/apache/conf/ssl.crt/triumph-sys-proxy-chain.crt");
	#$apacheConf->add_directive(SSLCertificateFile => '/opt/apache/conf/ssl.crt/smon.nocpulse.com.crt');
	#$apacheConf->add_directive(SSLCertificateKeyFile => '/opt/apache/conf/ssl.key/smon.nocpulse.com.key');
	#$apacheConf->add_directive(SSLCACertificateFile => '/opt/apache/conf/ssl.crt/nocpulse-prod-sys-satellite-ca.crt');
	#$apacheConf->add_directive(SSLCertificateChainFile => '/opt/apache/conf/ssl.crt/nocpulse-prod-sys-proxy-chain.crt');
	$apacheConf->add_directive(SSLCipherSuite => 'ALL');
}


sub addVirtualDirectives
{
	my ($self,$vs) = @_;

	my $rootdir = $vs->add_section(Location=>'/');
	$rootdir->add_directive(SSLRequireSSL);
	return $vs;
}

1;
