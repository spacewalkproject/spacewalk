#!/usr/bin/perl
use strict;
use threads;
require LWP::UserAgent;
require HTTP::Cookies;
require HTTP::Headers;

my $server = $ARGV[0];
my $cookie = $ARGV[1];
my $threads = $ARGV[2];

#set std out to host
$| = 1; 

if ($server eq "" || $cookie eq "" || $threads eq "") {
    print "Usage: ./lwload.pl  [servername] [cookie value from logged in browser] [threads]\n";
    print "eg:    ./lwload.pl rhn.stage.redhat.com \"JSESSIONID=8E06C063B0B1A25C6E0594D621E36ED5; rh_auth_token=2266493:1124143235x72b4231c4290dadf520dde0795f13879; pxt-session-cookie=1519348590x86563cb35a96b3b8c1ac5eb7fd56434e\" [5]\n";
    print "\nMultithreaded load test for rhn.  Specify a server hostname and a cookie\n";
    print "value and the script will fire up 10 threads to hit the server as fast as it can\n";
    print "\n";
    print "    To get cookie header value you can use:\n\n";
    print "    LiveHTTPHeaders: http://livehttpheaders.mozdev.org/\n\n";
    print "    Then open your browser, and login to the box\n";
    print "    you want to run load script against.  Then \n";
    print "    open the LiveHTTPHeaders sidebar and snag the \n";
    print "    Cookie header value and look for the cookie \n";
    print "    value for the site you logged into\n";
    exit 1;
}

my @tarray;

my $id = hit_page("https://$server/rhn/users/ActiveList.do", $cookie);
print "WebSession.ID for use in this script: $id\n";

for (my $i = 0; $i < $threads; $i++) {
    print "Launching thread $i\n";
    my $child = threads->new(\&loop_pages);
    $child -> detach;
}

while (1 == 1) {
    sleep;
}

sub loop_pages {
    my $cnt = 0;
    while ($cnt < 100) {
        my $output = hit_page("https://$server/rhn/errata/RelevantErrata.do", $cookie);
        $output = hit_page("https://$server/rhn/errata/AllErrata.do", $cookie);
        $output = hit_page("https://$server/rhn/schedule/PendingActions.do", $cookie);
        $output = hit_page("https://$server/rhn/systems/Unentitled.do", $cookie);
        #$output = hit_page("https://$server/rhn/users/ActiveList.do", $cookie);
        #$output = hit_page("https://$server/rhn/systems/Overview.do", $cookie);
        #if ($output ne $id) {
        #    die "expected id:\n$id\n$output\n";
        #}
        #$output = hit_page("https://$server/rhn/errata/details/Details.do?eid=2790", $cookie);
        $cnt++;        
    }
}

sub hit_page {
    my $url = shift;
    my $cookie = shift;
    my $header = HTTP::Headers->new;
    $header->header("Cookie" => $cookie); 
    my $ua = LWP::UserAgent->new;
    $ua->timeout(100);
    my $response = $ua->get($url, "Cookie" => $cookie);
    my @cookies = $response->header('Set-Cookie');
    my $session_id = get_sessionid_from_cookies(@cookies);
    if ($response->is_success) {
        if (index($response->content, "Please Sign In") > 0) {
            print "NOT LOGGED IN! : $url\n";
            #exit 1;
        } else {
            print ".";
        }
    }
    else {
        print $response->status_line . "\n";
    }
    return $session_id;
}


sub get_sessionid_from_cookies {
  my @cookies = @_;

  # At least two digits in auth token b/c the first one has a '0' for
  # user id
  my $session_id = "";
  foreach my $cookie (@cookies) {
    if ($cookie =~ /pxt-session-cookie/g) {

        my @temp = split("x", $cookie);
        @temp = split("=", $temp[1]);
        $session_id = $temp[1];
    }
  }  
  return $session_id;
}
