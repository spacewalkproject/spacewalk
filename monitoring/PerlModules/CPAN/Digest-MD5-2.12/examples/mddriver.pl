#!/usr/local/bin/perl
# SCCS ID @(#)mddriver.pl	1.3 95/05/01

require 'getopts.pl';
use MD5;
sub DoTest;

&Getopts('s:x');

$md5 = new MD5;

if (defined($opt_s))
{
    $md5->add($opt_s);
    $digest = $md5->digest();
    print("MD5(\"$opt_s\") = " . unpack("H*", $digest) . "\n");
}
elsif ($opt_x)
{
    DoTest("", "d41d8cd98f00b204e9800998ecf8427e");
    DoTest("a", "0cc175b9c0f1b6a831c399e269772661");
    DoTest("abc", "900150983cd24fb0d6963f7d28e17f72");
    DoTest("message digest", "f96b697d7cb7938d525a2f31aaf161d0");
    DoTest("abcdefghijklmnopqrstuvwxyz", "c3fcd3d76192e4007dfb496cca67e13b");
    DoTest("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
	   "d174ab98d277d9f5a5611c2c9f419d9f");
    DoTest("12345678901234567890123456789012345678901234567890123456789012345678901234567890",
	   "57edf4a22be3c955ac49da2e2107b67a");
}
else
{
    if ($#ARGV >= 0)
    {
	foreach $ARGV (@ARGV)
	{
	    die "Can't open file '$ARGV' ($!)\n" unless open(ARGV, $ARGV);

	    $md5->reset();
	    $md5->addfile(ARGV);
	    $hex = $md5->hexdigest();
	    print "MD5($ARGV) = $hex\n";

	    close(ARGV);
	}
    }
    else
    {
	$md5->reset();
	$md5->addfile(STDIN);
	$hex = $md5->hexdigest();

	print "$hex\n";
    }
}

exit 0;

sub DoTest
{
    my ($str, $expect) = @_;
    my ($digest, $hex);
    my $md5 = new MD5;

    $md5->add($str);
    $digest = $md5->digest();
    $hex = unpack("H*", $digest);

    print "MD5(\"$str\") =>\nEXPECT: $expect\nRESULT: $hex\n"
}
