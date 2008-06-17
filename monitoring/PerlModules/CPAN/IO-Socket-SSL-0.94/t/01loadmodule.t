# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl t/01loadmodule.t'

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..3\n"; }
END {print "Load failed ... not ok 1\n" unless $loaded;}

use IO::Socket::SSL qw(:debug1);
$loaded = 1;
$test=1;
print "ok $test\n";

$test++;
if ($IO::Socket::SSL::DEBUG == 1) { print "ok $test\n"; }
else { print "not ok $test\n"; }

$test++;
if ($Net::SSLeay::trace == 1) { print "ok $test\n"; }
else { print "not ok $test\n"; }

