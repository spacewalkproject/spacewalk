#!/usr/bin/perl


use Frontier::Client;
use Data::Dumper;
use CGI;


#EDITABLE options here:
my $HOST = 'dhcp59-112.rdu.redhat.com';
my $user = 'admin';
my $pass = 'redhat';
#END editable options


my $client = new Frontier::Client(url => "http://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);

my $system = 1000232075;


@empty;


$package1->{'release'} = "2-3";
$package1->{'version'} = "1.5a";
$package1->{'name'} = "firefox";
$package1->{'arch_label'} = "i386";
$package1->{'epoch'} = "a";



my @packages = [$package1];
my $channels = $client->call('system.createPackageProfile', $session, $system, "ORANGES", "ARE GOOOOOD");

$test = $packages[0];
print $test->{'release'};





