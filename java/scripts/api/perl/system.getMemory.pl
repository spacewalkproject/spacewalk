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



my $dmi = $client->call('system.getMemory', $session, $systemId);

print $dmi->{'ram'}."\n";
print $dmi->{'swap'}."\n";










