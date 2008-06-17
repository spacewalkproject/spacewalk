#!/usr/local/bin/perl -w
# bio.pl mikem@open.com.au
#
# Test and demonstrate BIO interface

use Net::SSLeay qw(die_now);

$data = '0123456789' x 100;
$len = length($data);

$b = &Net::SSLeay::BIO_new(&Net::SSLeay::BIO_s_mem())
    or die_now("Could not create memory BIO $!");

&Net::SSLeay::BIO_write($b, $data)
    or die_now("Could not write memory BIO $!");

# Should now have 1000 bytes in BIO
$pending =  &Net::SSLeay::BIO_pending($b);
die("Incorrect result from BIO_pending: $pending. Should be $len")
    unless $pending == $len;

# Partial read of 9 bytes
$len = 9;
$part = &Net::SSLeay::BIO_read($b, $len);
$nlen = length($part);
die("Incorrect result from BIO_read: $len. Should be 9")
    unless $nlen == $len;

die("Incorrect data from BIO_read: $len. Should be 012345678")
    unless $part eq '012345678';

# Should be 991 bytes left
$len = 991;
$pending =  &Net::SSLeay::BIO_pending($b);
die("Incorrect result from BIO_pending: $pending. Should be $len")
    unless $pending == $len;

# Read the rest
$part = &Net::SSLeay::BIO_read($b);
$nlen = length($part);
die("Incorrect result from BIO_read: $len. Should be 9")
    unless $len == $nlen;

&Net::SSLeay::BIO_free($b);

print "OK\n";
exit;
