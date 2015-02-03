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



my $dmi = $client->call('system.getDmi', $session, $systemId);

print $dmi;
print $dmi->{'vendor'}."\n";
print $dmi->{'system'}."\n";
print $dmi->{'product'}."\n";
print $dmi->{'asset'}."\n";
print $dmi->{'board'}."\n";
print $dmi->{'bios_release'}."\n";
print $dmi->{'bios_version'}."\n";
print $dmi->{'bios_vendor'}."\n";
print "\n";










