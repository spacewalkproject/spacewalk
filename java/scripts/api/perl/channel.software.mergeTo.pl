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





my @dmi = $client->call('channel.software.mergePackages', $session, "rhel-i386-as-4", "test-channel-label-5" );




foreach  $pack (@dmi) {

print $pack;
print "\n";

}






