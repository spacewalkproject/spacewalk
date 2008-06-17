
use CGI;
use strict;
my $q = new CGI;

my $loc = $q->url . "/OK";

if ($ENV{'PATH_INFO'}) {
    print $q->header, "OK";
} else {
    print $q->redirect(-url => $loc);
}

