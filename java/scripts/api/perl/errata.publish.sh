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

my $channel = "ChannelLabelpJMUdX0ESZ9hM";



$advisoryName = "qwerty";
@channels=[$channel];



my $errata = $client->call('errata.publish', $session, $advisoryName, @channels);

        print "ERRATA: ";
        print "$errata->{'advisory_name'}: ";
        print $errata->{'id'};
        print "\n";
