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

#$regex = "alaska_1.*";
$regex = 'server(factory)?test.*';

my $channels = $client->call('system.searchForIds', $session, $regex);

foreach my $channel (@$channels) {

        print $channel;
        print "\n";
}










