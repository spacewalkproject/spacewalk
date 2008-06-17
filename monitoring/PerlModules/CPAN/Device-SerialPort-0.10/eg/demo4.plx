#! perl -w

use lib './blib/lib','../blib/lib'; # can run from here or distribution base

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "demo4.plx "; }
END {print "not ok\n" unless $loaded;}
use Device::SerialPort 0.05;
$loaded = 1;
print "ok\n";

######################### End of black magic.

use strict;

my $ob;

# Constructor

unless ($ob = Device::SerialPort->new ('/dev/ttyS0')) {
    printf "could not open port /dev/ttyS0\n";
    exit 1;
    # next test would die at runtime without $ob
}

$ob->baudrate(9600)		|| die "bad baudrate";
$ob->parity('even')		|| die "bad parity";
$ob->databits(7)		|| die "bad databits";
$ob->stopbits(2)		|| die "bad stopbits";

    # you probably want this one, too
    # note "defined" since "0" ("false") is a legal return value
    # returns "undef" on failure
defined $ob->parity_enable('T')	|| die "bad parity_enable";

$ob->write_settings		|| undef $ob;
unless ($ob)			{ die "couldn't write_settings"; }

print "write_settings done\n";
$ob->handshake("rts")		|| die "bad handshake";

print "handshake problem\n" unless ("rts" eq $ob->handshake);
print "baudrate problem\n" unless (9600 == $ob->baudrate);
print "parity problem\n" unless ("even" eq $ob->parity);
print "databits problem\n" unless (7 == $ob->databits);
print "stopbits problem\n" unless (2 == $ob->stopbits);

    # note result comes from bit-mask test (zero/non-zero)
print "parity_enable problem\n" unless (0 != $ob->parity_enable);

undef $ob;
