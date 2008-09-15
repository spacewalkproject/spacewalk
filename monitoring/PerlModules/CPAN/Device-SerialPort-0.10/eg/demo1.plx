#!/usr/bin/perl -w

use lib './blib/lib','../blib/lib'; # can run from here or distribution base

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "demo1.plx loaded "; }
END {print "not ok 1\n" unless $loaded;}
use Device::SerialPort 0.05;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use strict;

my $file = "/dev/ttyS0";
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $loc;
my $e;
my $tick;
my $tock;

# 2: Constructor and Basic Values

my $ob = Device::SerialPort->new ($file) || die "Can't open $file: $!";

$ob->baudrate(9600)	|| die "fail setting baudrate";
$ob->parity("none")	|| die "fail setting parity";
$ob->databits(8)	|| die "fail setting databits";
$ob->stopbits(1)	|| die "fail setting stopbits";
$ob->handshake("none")	|| die "fail setting handshake";

$ob->write_settings || die "no settings";

# 3: Prints Prompts to Port and Main Screen

$out= "\r\n\r\n++++++++++++++++++++++++++++++++++++++++++\r\n";
$tick= "Simple Serial Terminal with echo to STDOUT\r\n\r\n";
$tock= "type CONTROL-Z on serial terminal to quit\r\n";
$e="\r\n....Bye\r\n";

print $out, $tick, $tock;
$pass=$ob->write($out);
$pass=$ob->write($tick);
$pass=$ob->write($tock);


$ob->error_msg(1);		# use built-in error messages
$ob->user_msg(1);

$in = 1;
while ($in) {
    if (($loc = $ob->input) ne "") {
	$loc =~ s/\cM/\r\n/;
	$ob->write($loc);
	print $loc;
    }
    if ($loc =~ /\cZ/) { $in--; }
    if ($ob->reset_error) { $in--; }
}
print $e;
$pass=$ob->write($e);

sleep 1;

undef $ob;
