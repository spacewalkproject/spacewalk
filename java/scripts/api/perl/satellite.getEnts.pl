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


my $return = $client->call('satellite.listEntitlements', $session);

$systems = $return->{'system'};
$channels = $return->{'channel'};

foreach $channel (@$channels) {
        print $channel->{'name'}." ";
        print $channel->{'used_slots'}." ";
        print $channel->{'free_slots'}." ";
        print $channel->{'total_slots'};
        print "\n";
}

print "\n\n";

foreach $channel (@$systems) {

        print $channel->{'name'}." ";
        print $channel->{'used_slots'}." ";
        print $channel->{'free_slots'}." ";
        print $channel->{'total_slots'};
        print "\n";
}








