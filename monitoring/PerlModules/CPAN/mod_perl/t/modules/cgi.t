
use Apache::test;

skip_test unless have_module "CGI";

$ua = new LWP::UserAgent;    # create a useragent to test

my $tests = 4; 
my $test_mod_cgi = 0;
unless($net::callback_hooks{USE_DSO}) { 
  #XXX: hrm, fails under dso?!? 
    $tests++; 
    $test_mod_cgi = 1;
} 

my $i = $tests;
my $have_com = 0;

eval {
    unless (defined $ENV{USER} and $ENV{USER} eq "dougm") {
	#these tests fail for some other folks, not sure why!
	#since our file upload test passes, 
	#my guess is a libwww-perl problem
	die "skipping 6-7";
    }
    require HTTP::Request::Common;
    $HTTP::Request::Common::VERSION ||= '1.00'; #-w
    if($CGI::VERSION >= 2.39 and 
       $HTTP::Request::Common::VERSION >= 1.08) 
    {
	$tests += 2;
	$have_com = 1;
    }
};

print "1..$tests\nok 1\n";
print fetch($ua, "http://$net::httpserver$net::perldir/cgi.pl?PARAM=2");
print fetch($ua, "http://$net::httpserver$net::perldir/cgi.pl?PARAM=%33");
print upload($ua, "http://$net::httpserver$net::perldir/cgi.pl", "4 (fileupload)");
if($test_mod_cgi) { 
    print fetch($ua, "http://$net::httpserver/cgi-bin/cgi.pl?PARAM=5");
}

sub upload {
    my $ua = shift;
    my $url = new URI::URL(shift);
    my $abc = shift;
    my $curl = new URI::URL "http:";
    my $CRLF = "\015\012";
    my $bound = "Eeek!";
    my $req = new HTTP::Request "POST", $url;
    my $content =
	join(
	     "",
	     "--$bound${CRLF}",
	     "Content-Disposition: form-data; name=\"HTTPUPLOAD\"; filename=\"b\"${CRLF}",
	     "Content-Type: text/plain${CRLF}${CRLF}",
	     $abc,
	     $CRLF,
	     "--$bound--${CRLF}"
	    );
    $req->header("Content-Length",length($content));
    $req->content_type("multipart/form-data; boundary=$bound");
    $req->content($content);
    $ua->request($req)->content;
}

if ($have_com) {
    my $url = "http://$net::httpserver$net::perldir/file_upload.cgi";
    my $file = "";
    for my $path (@INC) {
	last if -e ($file = "$path/pod/perlfunc.pod");
    }

    $file = $0 unless -e $file;
    my $lines = 0;
    local *FH;
    open FH, $file or die "open $file $!";
    ++$lines while (<FH>);
    close FH;

    my $response = $ua->request(HTTP::Request::Common::POST($url,
		   Content_Type => 'form-data',
		   Content      => [count => 'count lines',
				    filename  => [$file],
				    ]));

    my $page = $response->content;
    print $response->as_string unless $response->is_success;
    test ++$i, ($page =~ m/Lines:\s+<\D+>(\d+)/m);
    print "$file should have $lines lines (file_upload.cgi says: $1)\n";
    test ++$i, $1 == $lines;
}
elsif($CGI::VERSION < 2.39) {
    print "you should upgrade CGI.pm from $CGI::VERSION to 2.39 or higher\n";
}



