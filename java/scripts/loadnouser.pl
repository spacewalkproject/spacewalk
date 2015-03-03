#!/usr/bin/perl
use strict;
use threads;
require LWP::UserAgent;
require HTTP::Cookies;
require HTTP::Headers;

my $server = $ARGV[0];
my $threads = $ARGV[1];

#set stdout to hot
$| = 1;

if ($server eq "" || $threads eq "") {
    print "Usage: ./lwload.pl  [servername] [threads]\n";
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

my $id = hit_page("https://$server/rhn/users/ActiveList.do");
print "User.ID for use in this script: $id\n";

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
    while (1 == 1) {

        my $output = hit_page("https://$server/rhn/help/index.do");
        $output = hit_page("https://$server/rhn/Login.do");
        #$output = hit_page("https://$server/rhn/schedule/PendingActions.do");
        #$output = hit_page("https://$server/rhn/systems/Unentitled.do");
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
    my $ua = LWP::UserAgent->new;
    $ua->timeout(100);
    my $response = $ua->get($url);
    my @cookies = $response->header('Set-Cookie');
    my $user_id = get_userid_from_cookies(@cookies);
    if ($response->is_success) {
        if ($user_id ne "0") {
            print "NOT ZERO ID: [$user_id] ";
        }
        else {
            print ".";
        }
    }
    else {
        print $response->status_line . "\n";
    }
    return $user_id;
}

sub get_userid_from_cookies {
  my @cookies = @_;

  # At least two digits in auth token b/c the first one has a '0' for
  # user id
  my $user_id = "";
  foreach my $cookie (@cookies) {
    if ($cookie =~ /rh_auth_token/g) {
        #print "Cookie: $cookie\n";
        my @temp = split(":", $cookie);
        @temp = split("=", $temp[0]);
        $user_id = $temp[1];
        #print "ID: $user_id\n";
    }
  }

  return $user_id;
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
