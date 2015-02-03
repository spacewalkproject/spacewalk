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

$systemId = "1000035093";

my $channels = $client->call('system.listSubscribedChildChannels', $session, $systemId);

foreach my $channel (@$channels) {

 print $channel->{'LABEL'};
 print "\n";
 print $channel->{'NAME'};
 print "\n";
 print $channel->{'GPG_KEY_URL'};
 print "\n";
 print $channel->{'SUMMARY'};
 print "\n";

}










