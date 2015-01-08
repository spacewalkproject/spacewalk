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


my $channels = $client->call('system.listOutOfDateSystems', $session);

foreach my $channel (@$channels) {
        print "$channel->{'system_name'}:";
        print $channel->{'sid'};
        print "\n";
}










