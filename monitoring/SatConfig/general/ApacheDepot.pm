package ApacheDepot;
use Apache;
@ISA=qw(Apache);

sub addGlobalDirectives
{
	my $self = shift();
	my $apacheConf = Apache->getClassVar('apacheConf'); 
	$apacheConf->add_directive(Port=>'81');
	$apacheConf->add_directive(DocumentRoot => '"/opt/apache_depot/htdocs/depot"');
	my $linksdir = $apacheConf->add_section(Directory => '/opt/apache_depot/htdocs/depot/RPMS/links');
        $linksdir->add_directive(Options => '+SymLinksIfOwnerMatch');
	my $depotdir = $apacheConf->add_section(Directory => '/opt/apache_depot/htdocs/depot');
        $depotdir->add_directive(Allow => 'from      all');
        $depotdir->add_directive(Options => 'Indexes');
        my $serverStatus = $apacheConf->add('section','Location','/server-status');
	$serverStatus->add('directive',SetHandler => 'server-status' );
}

1;
