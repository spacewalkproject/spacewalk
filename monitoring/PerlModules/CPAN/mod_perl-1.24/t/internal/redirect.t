use Apache::test;
use Config;

{
    package NoRedirect::UA;

    @ISA = qw(LWP::UserAgent);
    
    sub redirect_ok {0}
}

if(not $net::Is_Win32 and $Config{usesfio} eq "true") {
    print "1..1\n";
    print "ok 1\n";
    exit;
}

my $ua = NoRedirect::UA->new;

my $url = "http://$net::httpserver$net::perldir/io/redir.pl";
my $qredirect = "";

my($request,$response);

my $tests = 3;

$CGI::VERSION ||= 0;

if(have_module("CGI") && ($CGI::VERSION >= 2.37)) {
    $qredirect = "http://$net::httpserver$net::perldir/qredirect.pl";
    $tests += 2;
}

print "1..$tests\n";

$request = HTTP::Request->new(GET => "$url?internal");
$response = $ua->request($request, undef, undef);

unless (($response->code == 200) && ($response->content =~ /camel/)) {
    print "not ";
}

print "ok 1\n";


$request = HTTP::Request->new(GET => "$url?remote");
$response = $ua->request($request, undef, undef);

unless ($response->is_redirect && ($response->header("Location") =~ /perl.apache.org/)) {
    print "not ";
}
print "ok 2\n";

#print $response->as_string;

$request = HTTP::Request->new(GET => "$url?content");
$response = $ua->request($request, undef, undef);

unless ($response->content eq "OK") {
    print "not ";
}

print "ok 3\n";

print "content=`", $response->content, "'\n";

if ($qredirect) {

    $request = HTTP::Request->new(GET => $qredirect);
    $response = $ua->request($request, undef, undef);

    if ($response->content =~ /Location: http/) {
        print "not ";
    }

    print "ok 4\n";

    print "content=`", $response->content, "'\n";

    $ua = LWP::UserAgent->new;
    $request = HTTP::Request->new(GET => $qredirect);
    $response = $ua->request($request, undef, undef);

    unless ($response->content eq "OK") {
        print "not ";
    }

    print "ok 5\n";

    print "content=`", $response->content, "'\n";


}
