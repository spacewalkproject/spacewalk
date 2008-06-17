#!/usr/local/bin/perl -w
#
# Check POST via HTTP.
#

use Config;

my $num_tests = 5;
my(@test_scripts) = qw(test);

#if($Config{usesfio} eq "true" or $] >= 5.003_93) {
if($] >= 5.003_93) {
    $num_tests += 2;
    push @test_scripts, qw(io/perlio.pl);
}

print "1..$num_tests\n";

use Apache::test;
require LWP::UserAgent;

my $ua = new LWP::UserAgent;    # create a useragent to test

my($request,$response,$str,$form);

foreach $script (@test_scripts) {
    $netloc = $net::httpserver;
    $script = $PERL_DIR . "/$script";

    $ua = new LWP::UserAgent;    # create a useragent to test

    $url = new URI::URL("http://$netloc$script");

    $form = 'searchtype=Substring';

    $request = new HTTP::Request('POST', $url, undef, $form);
    $request->header('Content-Type', 'application/x-www-form-urlencoded');

    $response = $ua->request($request, undef, undef);

    $str = $response->as_string;
    print "$str\n";

    die "$1\n" if $str =~ /(Internal Server Error)/;

    test ++$i, ($response->is_success and $str =~ /^REQUEST_METHOD=POST$/m);
    test ++$i, ($str =~ /^CONTENT_LENGTH=(\d+)$/m && $1 == length($form));
}

print "pounding a bit...\n";
for (1..3) {
    test ++$i, ($ua->request($request, undef, undef)->is_success);
}


# avoid -w warning
$dummy = $net::httpserver;
$dummy = $net::perldir;
