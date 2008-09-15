#! perl -w

use lib './blib/lib','../blib/lib'; # can run from here or distribution base

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "demo2.plx loaded "; }
END {print "not ok 1\n" unless $loaded;}
use Device::SerialPort 0.05;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# starts configuration created by test1.pl

use strict;

my $file = "/dev/ttyS0";
my $tc = 2;		# next test number
my $pass;
my $fail;
my $in;
my $in2;
my @necessary_param = Device::SerialPort->set_test_mode_active;

# 2: Constructor

my $ob = Device::SerialPort->new ($file) || die "Can't open $file: $!";

$ob->baudrate(9600)	|| die "fail setting baudrate";
$ob->parity("none")	|| die "fail setting parity";
$ob->databits(8)	|| die "fail setting databits";
$ob->stopbits(1)	|| die "fail setting stopbits";
$ob->handshake("none")	|| die "fail setting handshake";

$ob->write_settings || die "no settings";

# 3: Prints Prompts to Port and Main Screen

my $out= "\r\n\r\n++++++++++++++++++++++++++++++++++++++++++\r\n";
my $tick= "Very Simple Half-Duplex Chat Demo\r\n\r\n";
my $tock= "type CAPITAL-Q on either terminal to quit\r\n";
my $e="\r\n....Bye\r\n";
my $loc="\r\n";

print $out, $tick, $tock;
$pass=$ob->write($out);
$pass=$ob->write($tick);
$pass=$ob->write($tock);

$out= "Your turn first";
$tick= "\r\nterminal>";
$tock= "\r\n\r\nperl>";

$pass=$ob->write($out);
## $_ = <STDIN>;		# flush it out (shell dependent)

$ob->error_msg(1);		# use built-in error messages
$ob->user_msg(1);

$fail=0;
while (not $fail) {
    $pass=$ob->write($tick);
    $in = 1;
    while ($in) {
        if (($_ = $ob->input) ne "") {
        	$ob->write($_);
        	print $_;
        	if (/\cM/) { $ob->write($loc); $in--; }
        	if (/Q/) { $ob->write($loc); $in--; $fail++; }
        	if ($ob->reset_error) { $ob->write($loc); $in--; $fail++; }
        }
    }
    unless ($fail) {
        print $tock;
        $_ = <STDIN>;
	last unless (defined $_);
	print "\n";
        $fail++ if (/Q/);
        $ob->write($loc);
        $ob->write($_) unless ($_ eq "");
    }
}
print $e;
$pass=$ob->write($e);

sleep 1;

undef $ob;
