use strict;
use Apache::test;
use Apache::src ();
 
my $Is_dougm = (defined($ENV{USER}) && ($ENV{USER} eq "dougm"));

skip_test unless have_module "Apache::Cookie";
skip_test unless have_module "CGI::Cookie";

unless (Apache::src->mmn_eq) {
    skip_test if not $Is_dougm;
}

my $ua = LWP::UserAgent->new;

my $cookie = "one=bar-one&a; two=bar-two&b; three=bar-three&c";
my $url = "http://$net::httpserver$net::perldir/request-cookie.pl";
my $request = HTTP::Request->new('GET', $url);
$request->header(Cookie => $cookie);
my $response = $ua->request($request, undef, undef); 
 
print $response->content;
 
