#!/usr/bin/perl


use Frontier::Client;
use Data::Dumper;
use CGI;
#use DateTime::Parse;
use Date::Parse;

#EDITABLE options here:
my $HOST = 'dhcp59-112.rdu.redhat.com';
my $user = 'admin';
my $pass = 'redhat';
#END editable options


my $client = new Frontier::Client(url => "http://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);

$systemId = "1000278688";

#@channels = ["clone-rhn-tools-rhel-4-as-i386", "gold-clone-rhel-i386-as-4"];
#@channels = ["-1","test"];
@channels = ["gold-clone-rhel-i386-as-4","test-channel"];



my $dmi = $client->call('channel.software.subscribeSystem', $session, $systemId, @channels);











