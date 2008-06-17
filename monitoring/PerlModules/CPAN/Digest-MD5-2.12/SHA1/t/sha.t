#!/usr/local/bin/perl -w

print "1..1\n";
my $bad;

use SHA qw(sha_version);
$ver = &sha_version();

sub do_test
{
    my ($label, $str, $expect0, $expect1, $skip_big_test) = @_;
    my ($c, @tmp);
    my $sha = new SHA;
    $sha->add($str);
    $expect = ($ver eq 'SHA-1') ? $expect1 : $expect0;
    print "$label:\nEXPECT:   $expect\n";
    my $hexdigest = $sha->hexdigest();
    my $hexhash   =  $sha->hexhash($str);
    print "RESULT 1: $hexdigest\n";
    print "RESULT 2: $hexhash\n";
    $bad++ if $hexdigest ne $expect || $hexhash ne $expect;
    unless ($skip_big_test) {
	$sha->reset();
	@tmp = split(//, $str);
	foreach $c (@tmp) {
	    $sha->add($c);
	}
	my $hexdigest = $sha->hexdigest();
	print "RESULT 3: $hexdigest\n";
	$bad++ if $hexdigest ne $expect;
    } else {
	print "skipping RESULT 3\n";
    }
}

print "Using digest version $ver, library version $SHA::VERSION\nIf the following results don't match, there's something wrong.\n";
do_test("test1", "abc",
    "0164b8a9 14cd2a5e 74c4f7ff 082c4d97 f1edf880",
    "a9993e36 4706816a ba3e2571 7850c26c 9cd0d89d");
do_test("test2", "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
    "d2516ee1 acfa5baf 33dfc1c4 71e43844 9ef134c8",
    "84983e44 1c3bd26e baae4aa1 f95129e5 e54670f1");
do_test("test3", "a" x 1000000,
    "3232affa 48628a26 653b5aaa 44541fd9 0d690603",
    "34aa973c d4c4daa4 f61eeb2b dbad2731 6534016f", 1);

print "not " if $bad;
print "ok 1\n";
