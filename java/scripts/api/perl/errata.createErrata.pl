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

my $channel = "ChannelLabelgOKw27Ph9hghU";



$synopsis = "apples are ghood";
$advisoryName = "qwerty";
$advisoryRelease = 3;
$advisoryType  = "Bug Fix Advisory";
$product = "oranges";
$topic = "abacadaba";
$description = "boring!";
$solution = "fix it";
$references = "reference this!";
$notes =  "ack";
@bugs = [];
@keywords = [];
@packageIds=[];
@channels=[];
$publish=$client->boolean(0);


@array = [$advisory];

my $errata = $client->call('errata.create', $session, $synopsis, $advisoryName, $advisoryRelease, $advisoryType, $product, $topic, $description, $solution, $references,$notes, @bugs, @keywords, @packageIds, @channels , $publish);

        print "ERRATA: ";
        print "$errata->{'advisory_name'}: ";
        print $errata->{'id'};
        print "\n";
