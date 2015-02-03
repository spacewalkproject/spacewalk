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

my $channel = "rhel-i386-as-4";
my $advisory = "RHBA-2007:0485";


#@array = [$advisory];
@array = [$advisory];

my $return = $client->call('errata.listByDate', $session, $channel);

foreach my $errata (@$return) {
        print "ERRATA: ";
        print "$errata->{'advisory_name'}:";
        print $errata->{'date'}->value;
        print "\n";
}










