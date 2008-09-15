
use Apache::test;

my $ua = LWP::UserAgent->new;    # create a useragent to test

print "1..1\n";

my $module = "/LoadClass.pm";

my $c = fetch($ua, "http://$net::httpserver$module");

print "fetch: `$c'\n";

unless ($c =~ /^OK ${module}$/i) {
    print "not ";
}

print "ok 1\n";

