#!/usr/bin/perl


use Frontier::Client;
use Data::Dumper;
use CGI;
#use DateTime::Parse;
use Date::Parse;

#EDITABLE options here:
my $HOST = 'dhcp59-112.rdu.redhat.com';
my $user = 'admin';
my $pass = 'spacewalk';
#END editable options


my $client = new Frontier::Client(url => "http://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);

$systemId = "1000010050";



my $dmi = $client->call('system.getCpu', $session, $systemId);

print $dmi;
print $dmi->{'cache'}."\n";
print $dmi->{'family'}."\n";
print $dmi->{'MHz'}."\n";
print $dmi->{'flags'}."\n";
print $dmi->{'model'}."\n";
print $dmi->{'vendor'}."\n";
print $dmi->{'arch_name'}."\n";
print $dmi->{'stepping'}."\n";
print "\n";










