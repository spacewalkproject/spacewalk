
use Apache::test;

if($] < 5.003_02) {
    print "1..1\nok 1;\n";
    exit;
}
    
my $ua = new LWP::UserAgent;    # create a useragent to test
my $base = "http://$net::httpserver$net::perldir";
my $s = "$base/io/perlio.pl";

my $tests = 11;
my $cgi;

if(have_module "CGI") {
    (my $v = $CGI::VERSION) =~ s/b\d+$//;
    if($v >= 2.37) {
	$cgi++;
	$tests += 2;
	$v = $CGI::VERSION; #avoid -w arning
    }
}

print "1..$tests\n";
my $i = 0;

for (1..4) {
    test $_, fetch($ua, "$s?$_") == $_;
}

my $str = join "\n", ("A".."D"), "";

test 5, fetch($ua, "$s?5") eq $str;

$i = 5;

my $req = new HTTP::Request('GET', $s);
$r = $ua->request($req, undef, undef);       

test ++$i, $r->header("Server");
test ++$i, $r->header("X-Perl-Script") eq "perlio.pl";

$req = new HTTP::Request('GET', "$base/test");
$r = $ua->request($req, undef, undef);       

test ++$i, $r->header("Server");
test ++$i, $r->header("X-Perl-Script") eq "test";

if($cgi) {
    $req = new HTTP::Request('GET', "$base/cgi.pl?PARAM=1");
    $r = $ua->request($req, undef, undef);       
    test ++$i, $r->header("Server");
    test ++$i, $r->header("X-Perl-Script") eq "cgi.pl";
}

$req = new HTTP::Request('GET', "$base/raw.pl");
$r = $ua->request($req, undef, undef);       

test ++$i, not $r->header("Server");
test ++$i, $r->header("Content-type");





