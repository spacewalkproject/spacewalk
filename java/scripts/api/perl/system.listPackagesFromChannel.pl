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

my $packages = $client->call('system.listPackagesFromChannel', $session, $system, 'rhel-i386-as-4');

foreach my $package (@$packages) {
        print $package->{'package_name'}."-";
        print $package->{'package_version'}."-";
        print $package->{'package_release'};
        print "\n";
}










