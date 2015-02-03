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

$systemId = "1000232075";

my $date = $client->call('system.getRegistrationDate', $session, $systemId);

my $return = $client->call('system.scheduleReboot', $session, $systemId, $date);

print $return;
print "\n";










