
use Apache::test;

my $ua = LWP::UserAgent->new;    # create a useragent to test

print fetch($ua, "http://$net::httpserver/rgy-include.shtml");

my $c = fetch($ua, "http://$net::httpserver/content.shtml");

unless ($c eq "OK") {
    print "not ";
}	

print "ok 3\n";

