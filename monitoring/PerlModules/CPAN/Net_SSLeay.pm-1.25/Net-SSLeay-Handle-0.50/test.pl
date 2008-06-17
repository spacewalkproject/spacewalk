# Original by Jim Bowlin <jbowlin@linklint.org>
# Maintenance fixes by Sampo Kellomaki <sampo@iki.fi>
# $Id: test.pl,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use Net::SSLeay::Handle qw/shutdown/;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.
$ENV{RND_SEED} = '1234567890123456789012345678901234567890';

#    app.iplanet.com
my @sites = qw {
    www.cdw.com
    banking.wellsfargo.com
    secure.worldgaming.net
    www.ubs.com       
};
#    www.openssl.org
#    www.engelschall.com

test_2();
test_3();

#== Test 2 ====================================================================
#
# Read home pages from @sites (taken from Net::SSLeay)
#

sub test_2 {
    print "    About to test the following external sites:\n\n";
    print map("    $_\n", @sites), "\n";
    print "    You have 5 seconds of time to hit Ctrl-C if you do not like this.\n";
    print "    So far there were no errors in tests.\n" unless $errors;
    print "*** $errors tests failed already.\n" if $errors;
    print "    Following tests _will_ fail if you do not have network\n"
        . "    connectivity (or if the servers are down or have changed).\n\n";
    sleep 5;                        

    my ($total, $success, $failure);
    for my $site (@sites) {
        $total++;
        $success += test_site_2($site);
    }

    $failed = $total - $success;
    unless ($failed) {
        print "  All sites were successful!\n";
    }
    else {
        print "  $failed out of $total sites failed.\n";
    }
    $success and print "ok 2\n";
}

sub test_site_2 {
    my ($host, $port) = @_;
    print "  testing https://$host/ ...\n";
    $port ||= 443;

    tie(*SSL, "Net::SSLeay::Handle", $host, $port);
    return read_home_page(\*SSL, "close");
}

sub read_home_page {
    my ($socket, $close) = @_;
    print $socket "GET / HTTP/1.0\r\n\r\n";
    #shutdown($socket, 1);
    my $head_cnt = 0;
    my $resp = <$socket>;
    #print $resp;
    while (<$socket>) {
        /\S/ or last;
        $head_cnt++;
    }
    printf "  %d header and ", $head_cnt;
    my $doc_cnt = 0;
    $doc_cnt++ while (<$socket>);
    printf "%d document lines\n", $doc_cnt;
    $close and close $socket;
    return ($resp =~ m|^HTTP/1|) ? 1 : 0;
}                                                  

#== Test 3 ====================================================================
#
# Open 3 sockets, read from each, then close all 3.
#

sub test_3 {
    $port = 443;
    print "creating 3 SSL sockets ...\n";
    tie(*SSL0, "Net::SSLeay::Handle", $sites[0], $port);
    tie(*SSL1, "Net::SSLeay::Handle", $sites[1], $port);
    tie(*SSL2, "Net::SSLeay::Handle", $sites[2], $port);

    $sock[0] = \*SSL0;
    $sock[1] = \*SSL1;
    $sock[2] = \*SSL2;

    my @range = (0..2);
    my ($total, $success, $failure);

    for my $i (@range) { 
        my $sock = $sock[$i];
        $total++;
        print "  reading from $sites[$i] with socket @{[fileno($sock)]}\n";
        $success +=  read_home_page($sock);
    }

    for my $i (@range) { 
        my $sock = $sock[$i];
        print "  closing socket @{[fileno($sock)]}\n";
        close($sock);
    }

    $failed = $total - $success;
    unless ($failed) {
        print "  All sites were successful!\n";
    }
    else {
        print "  $failed out of $total sites failed.\n";
    }
    $success and print "ok 3\n";
}










