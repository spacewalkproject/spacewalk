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

my $system = 1000010050;

my $devices = $client->call('system.getDevices', $session, $system);



print "\n\nDEVICES\n------------------------\n";
@device_fields = ("device", "device_class", "driver", "description", ,"bus", "pcitype");
foreach $device  (@$devices){
        print "\nDevice:\n";
        foreach $field (@device_fields){
                print("$field - $device->{$field}\n");
        }
}


