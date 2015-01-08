#!/usr/bin/perl


use Frontier::Client;
use Data::Dumper;
use CGI;


#EDITABLE options here:
my $HOST = 'dhcp59-112.rdu.redhat.com';
my $user = 'admin';
my $pass = 'spacewalk';
#END editable options


my $client = new Frontier::Client(url => "http://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);

$systemName = "Cliff test # 1";



my $systems = $client->call('system.getId', $session, $systemName);

foreach my $system (@$systems) {

 print $system;
 print "\n";

}










