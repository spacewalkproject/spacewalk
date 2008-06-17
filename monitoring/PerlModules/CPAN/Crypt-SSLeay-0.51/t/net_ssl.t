#!/usr/bin/perl

use lib qw(../lib ./lib);

use Net::SSL;

my $sock;
eval {
    $sock = Net::SSL->new(
			  PeerAddr => '127.0.0.1',
			  PeerPort => 40000,
			  Timeout => 3,
			  );
};

print "1..1\n";
print $@;
if($@ && ($@ !~ /Connect failed/i)) {
    print "not ok\n";
} else {
    print "ok\n";
}
