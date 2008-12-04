package Apache;
use GogoSysVStep;
@ISA=qw(GogoSysVStep);
use PhysCluster;
use Apache::Admin::Config;

sub startActions
{
      my $self = shift();

      my $cluster = PhysCluster->newInitialized;
      Apache->setClassVar('cluster',$cluster);
      my $apacheConf = Apache::Admin::Config->new;
      $apacheConf->{'tree'}->{'indent'} = -1; 
      # Stuff in class var b/c of wierd eval context +
      # to simplify registry syntax
      Apache->setClassVar('apacheConf',$apacheConf);

      $self->generateGlobalConfiguration;

      ### Eval everything in the registry that's for us
      my $regdir = Apache->ConfigValue('registryDir');
      $self->dprint(0,"Looking for registry files in $regdir");
      my $filename;
      foreach $filename (glob($regdir.'/'.ref($self).'.*')) {
              $self->dprint(0,"Loading requirements for $filename");
              open(FILE,$filename);
              eval('print "HERE: $apacheConf\n"',join('',<FILE>));
              if ($@) {
                      $self->dprint(0,"ERROR loading $filename: $@");
              }
              close(FILE);
      }
      my $configFile = $self->configValue('configFile');
      $self->dprint(0,"Writing configuration to $configFile");
      $apacheConf->save($configFile);
      $self->addStopAction("unlink('$configFile')");

      return $self->SUPER::startActions;
}

sub generateGlobalConfiguration
{
      my $self = shift();
      my $cluster = Apache->getClassVar('cluster');
      my $apacheConf = Apache->getClassVar('apacheConf');
      $apacheConf->add_directive(LoadModule => 'cgi_module modules/mod_cgi.so');
      $apacheConf->add_directive(LoadModule => 'access_module modules/mod_access.so');
      $apacheConf->add_directive(LoadModule => 'proxy_module modules/libproxy.so');
      $apacheConf->add_directive(LoadModule => 'perl_module modules/libperl.so');
      $apacheConf->add_directive(LoadModule => 'mime_module modules/mod_mime.so');
      $apacheConf->add_directive(TypesConfig => '/etc/mime.types');
      $apacheConf->add_directive(LoadModule => 'alias_module modules/mod_alias.so');
      $apacheConf->add_directive(LoadModule => 'rewrite_module modules/mod_rewrite.so');
      $apacheConf->add_directive(LoadModule => 'ssl_module modules/libssl.so');
      $apacheConf->add_directive(LoadModule => 'status_module modules/mod_status.so');
      $apacheConf->add_directive(LoadModule => 'config_log_module modules/mod_log_config.so');
      $apacheConf->add_directive(ServerType => 'standalone');
      $apacheConf->add_directive(ServerTokens => 'ProductOnly');
      $apacheConf->add_directive(ServerRoot => '"/etc/httpd"');
      $apacheConf->add_directive(ExtendedStatus => 'On');
      $apacheConf->add_directive(ServerAdmin => 'webmaster@nocpulse.com');
      $apacheConf->add_directive(DocumentRoot => '"/opt/apache/htdocs"');
      $apacheConf->add_directive(ResourceConfig => '/dev/null');
      $apacheConf->add_directive(AccessConfig => '/dev/null');
      $apacheConf->add_directive(PidFile => $self->configValue('logDir').'/'.ref($self).'.pid');
      $apacheConf->add_directive(User => 'apache');
      $apacheConf->add_directive(Group => 'apache');
      $apacheConf->add_directive(UseCanonicalName => 'On');
      $apacheConf->add_directive(HostnameLookups => 'Off');
      $apacheConf->add_directive(IdentityCheck => 'Off');
      $apacheConf->add_directive(ServerSignature => 'Off');
      $apacheConf->add_directive(LogLevel => 'crit');
      $self->addLog($apacheConf,'ErrorLog',ref($self).'_error_log');
      $apacheConf->add_directive(LogFormat => '"%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined');
      $apacheConf->add_directive(LogFormat => '"%h %l %u %t \"%r\" %>s %b" common');
      $apacheConf->add_directive(LogFormat => '"%{Referer}i -> %U" referer');
      $apacheConf->add_directive(LogFormat => '"%{User-agent}i" agent');
      $self->addLog($apacheConf,'CustomLog',ref($self).'_access_log','common');
      $apacheConf->add_directive(Timeout => 600);
      $apacheConf->add_directive(KeepAlive => 'On');
      $apacheConf->add_directive(MaxKeepAliveRequests => 400);
      $apacheConf->add_directive(KeepAliveTimeout => 15);
      $apacheConf->add_directive(MinSpareServers => 10);
      $apacheConf->add_directive(MaxSpareServers => 30);
      $apacheConf->add_directive(StartServers => 20);
      $apacheConf->add_directive(MaxClients => 150);
      $apacheConf->add_directive(MaxRequestsPerChild => 400);
      my $rootdir = $apacheConf->add_section(Directory => '/');
      $rootdir->add_directive(Options => 'None');
      $rootdir->add_directive(AllowOverride => 'None');
      $self->addGlobalDirectives;
}

sub addGlobalDirectives
{
      my $self = shift();
      # Overridden by ApacheSSL
}


sub restrictLocationAccess
{
      my ($self,$location) = @_;
      # NOTE: This assumes that $location is a Location, and that the Location
      # is the direct child of a VirtualServer section!!  This relationship
      # is entirely and blindly assumed - should you try passing any other
      # sort of thing in here you'll likely get non-sense.
      my $vsName = $location->parent->value;
      my $vsConfig = Apache->getClassVar('cluster')->objectNamed('ApacheServer',$vsName);
      if ($vsConfig) {
              my $securitay = $vsConfig->get_allowedClients;
      }
      if ($securitay) {
              $location->add('directive',Order=>'deny,allow');
              $location->add('directive',Deny=>'from all');
              $location->add('directive',AllowFrom=>$securitay);
      }
}

sub addProxy
{
      my ($self,$vs,$source,$destination) = @_;
      my $rrstart = $vs->directive('RewriteRule',-which=>0);
      $vs->add('directive','RewriteRule',"$source $destination [P,L]",-before=>$rrstart);
}

sub allowLocation
{
      my ($self,$vs,$source) = @_;
      my $rrstart = $vs->directive('RewriteRule',-which=>0);
      $vs->add('directive','RewriteRule',"$source - [L]",-before=>$rrstart);
}

sub addLog
{
      my ($self,$vs,$type,$filename,$format) = @_;
      my $dir = $self->configValue('logDir');
      $vs->add('directive',$type => '"'.$dir.'/'.$filename.'" '.$format);
      #NOTE: Theoretically these could conflict. Probably won't happen, but could.
      my $lrConfig = "$type-$filename";
      open(FILE,">/etc/logrotate.d/$lrConfig");
      print FILE "$dir/$filename {\n";
      print FILE "        daily\n";
      print FILE "        rotate 7\n";
      print FILE "        missingok\n";
      print FILE "        copytruncate\n";
      print FILE "        compress\n";
      print FILE "}\n";
      close(FILE);
      $self->addStopAction("unlink('/etc/logrotate.d/$lrConfig')");
}

sub addHandler
{
      my ($self,$vs,$location,$class,$sendHeader) = @_;
      my $handler = $vs->add('section','Location',$location,-onbottom);
      $handler->add('directive','SetHandler','perl-script');
      $handler->add('directive','PerlHandler',$class);
      $handler->add('directive',Options => 'ExecCGI' );
      if ($sendHeader) {
              $handler->add('directive','PerlSendHeader','on');
      }
      $self->restrictLocationAccess($handler);
      return $handler;
}

sub addVsRewriteRules
{
      my ($self,$vs) = @_;
      $vs->add('directive',RewriteEngine=>'on');
      $vs->add('directive',RewriteRule=>'^/server-status$        -       [L]');
      $vs->add('directive',RewriteRule=>'^/cgi-bin/ -    [PT]');
      $vs->add('directive',RewriteRule=>'^/cgi-mod-perl/ -       [PT]');
      $vs->add('directive',RewriteRule=>'^/depot/ -      [PT]');
      $vs->add('directive',RewriteRule=>'.*      -       [F]');
}

sub addVirtualDirectives
{
      my ($self,$vs) = @_;
      # overridden by ApacheSSL
}

sub virtualServer
{
      my ($self,$nameAndPort) = @_;
      my @vs = Apache->getClassVar('apacheConf')->section('VirtualHost',$nameAndPort);
      if  (! $vs[0]) {
              my $clusterConfigData = Apache->getClassVar('cluster')->objectNamed('ApacheServer',$nameAndPort);
              $vs[0] = Apache->getClassVar('apacheConf')->add('section','VirtualHost',$nameAndPort,'-onbottom');
              if ($clusterConfigData) {
                      if ($clusterConfigData->get_serverName) {
                              $vs[0]->add('directive','ServerName',$clusterConfigData->get_serverName);
                      }
                      if ($clusterConfigData->get_serverAlias) {
                              $vs[0]->add('directive','ServerAlias',$clusterConfigData->get_serverAlias);
                      }
              }
              $self->addVirtualDirectives($vs[0]);
              $self->addVsRewriteRules($vs[0]);
       
              $vs[0]->add('directive',ScriptAlias=>'/cgi-bin/ /usr/share/nocpulse/cgi-bin');
              $vs[0]->add('directive',AddHandler => 'cgi-script .cgi');
              $vs[0]->add('directive',Alias=>'/depot/ /opt/apache/htdocs/depot/');
              $vs[0]->add('directive',Alias=>'/cgi-mod-perl/ /usr/share/nocpulse/cgi-mod-perl/');

              my $serverStatus = $vs[0]->add('section','Location','/server-status');
              $serverStatus->add('directive',SetHandler => 'server-status' );
              $self->restrictLocationAccess($serverStatus);

              my $cgiBin = $vs[0]->add('section','Location','/cgi-bin');
              $cgiBin->add('directive',Options => 'ExecCGI' );
              $self->restrictLocationAccess($cgiBin);

              my $cgiModPerl = $vs[0]->add('section','Location','/cgi-mod-perl');
              $cgiModPerl->add('directive',SetHandler =>'perl-script' );
              $cgiModPerl->add('directive',PerlHandler => 'Apache::Registry' );
              $cgiModPerl->add('directive',PerlSendHeader => 'on');
              $cgiModPerl->add('directive',Options =>'ExecCGI' );
              $self->restrictLocationAccess($cgiModPerl);

      }
      return $vs[0];
}

1;
