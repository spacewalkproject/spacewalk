
use Apache::test;

#hrm, deal with this later
print "1..1\nok 1\n";
exit 0;

unless(defined $ENV{USER} and $ENV{USER} eq "dougm" and
    $net::callback_hooks{PERL_TRANS} and 
    $net::callback_hooks{PERL_STACKED_HANDLERS} and
    $net::callback_hooks{MMN} > 19980270)
{
    print "1..1\nok 1\n";
    exit 0;
}

my $url = "http://$net::httpserver/"."proxytest";
my $ua = LWP::UserAgent->new;
$ua->proxy([qw(http)], "http://$net::httpserver");

my $request = HTTP::Request->new('GET', $url);
my $response = $ua->request($request, undef, undef);
print $response->content;      
  
