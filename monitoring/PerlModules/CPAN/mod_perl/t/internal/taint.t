#!/usr/local/bin/perl -w

my(@tests) = qw{
    args env header_in
};

my $num_tests = scalar @tests;
print "1..$num_tests\n";

use Apache::test;

my $ua = new LWP::UserAgent;    # create a useragent to test

my($request,$response,$str,$i);

foreach $q (@tests) {
    $netloc = $net::httpserver;
    $script = $net::perldir . "/taint.pl";

    $url = new URI::URL("http://$netloc$script?$q");

    $request = new HTTP::Request('GET', $url);

    print "GET $url\n\n";

    $response = $ua->request($request, undef, undef);

    $str = $response->as_string;
    print "$str\n";
    die "$1\n" if $str =~ /(Internal Server Error)/;


    test ++$i, ($response->is_success);
}

# avoid -w warning
$dummy = $net::httpserver;
$dummy = $net::perldir;
