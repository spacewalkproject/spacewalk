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


$label = "test-channel-label-14";
$name = "test-channel-name-14";

$org_label = "rhel-i386-as-4";



$map->{'name'} = $name;
$map->{'label'} = $label;
$map->{'summary'} = "SUMMARY";


my $dmi = $client->call('channel.software.clone', $session, $org_label, $map, $client->boolean(1) );











