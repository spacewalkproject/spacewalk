#!/usr/bin/perl -w

## use lib './blib/lib','../blib/lib'; # can run from here or distribution base

use strict;
use Device::SerialPort 0.02;

my $file = "/dev/ttyS0";
if (@ARGV) {
    $file = shift @ARGV;
}

my $ob = Device::SerialPort->new ($file) || 
	 die "Usage: perl options.plx port_name (/dev/ttySx) > results";

my @baud_opt = $ob->baudrate;
my @parity_opt = $ob->parity;
my @data_opt = $ob->databits;
my @stop_opt = $ob->stopbits;
my @hshake_opt = $ob->handshake;

print "\nAvailable Options for port $file\n";

print "\nData Bit Options:   ";
foreach $a (@data_opt) { print "  $a"; }

print "\n\nStop Bit Options:   ";
foreach $a (@stop_opt) { print "  $a"; }

print "\n\nHandshake Options:  ";
foreach $a (@hshake_opt) { print "  $a"; }

print "\n\nParity Options:     ";
foreach $a (@parity_opt) { print "  $a"; }

my $c = 8;

print "\n\nBaudrate Options:   ";
foreach $a (@baud_opt) {
    print "  $a";
    unless (--$c > 0) {
        $c = 8;
        print "\n                    ";
    }
}

print "\nBinary Capabilities:\n";

print "    can_baud\n"			if (scalar $ob->can_baud);
print "    can_databits\n"		if (scalar $ob->can_databits);
print "    can_stopbits\n"		if (scalar $ob->can_stopbits);
print "    can_dtrdsr\n"		if (scalar $ob->can_dtrdsr);
print "    can_handshake\n"		if (scalar $ob->can_handshake);
print "    can_parity_check\n"		if (scalar $ob->can_parity_check);
print "    can_parity_config\n"		if (scalar $ob->can_parity_config);
print "    can_parity_enable\n"		if (scalar $ob->can_parity_enable);
print "    can_rlsd\n"			if (scalar $ob->can_rlsd);
print "    can_rtscts\n"		if (scalar $ob->can_rtscts);
print "    can_xonxoff\n"		if (scalar $ob->can_xonxoff);
print "    can_interval_timeout\n"	if (scalar $ob->can_interval_timeout);
print "    can_total_timeout\n"		if (scalar $ob->can_total_timeout);
print "    can_xon_char\n"		if (scalar $ob->can_xon_char);
print "    can_spec_char\n"		if (scalar $ob->can_spec_char);
print "    can_16bitmode\n"		if (scalar $ob->can_16bitmode);
print "    is_rs232\n"			if (scalar $ob->is_rs232);
print "    is_modem\n"			if (scalar $ob->is_modem);
print "    binary\n"			if (scalar $ob->binary);
print "    parity_enable\n"		if (scalar $ob->parity_enable);

print "\nCurrent Settings:\n";

printf "    baud = %d\n", scalar $ob->baudrate;
printf "    parity = %s\n", scalar $ob->parity;
printf "    data = %d\n", scalar $ob->databits;
printf "    stop = %d\n", scalar $ob->stopbits;
printf "    hshake = %s\n", scalar $ob->handshake;

print "\nOther Capabilities:\n";

my ($in, $out) = $ob->buffer_max;
printf "    input buffer max = 0x%x\n", $in;
printf "    output buffer max = 0x%x\n", $out;
($in, $out)= $ob->buffers;
print "    input buffer = $in\n";
print "    output buffer = $out\n";
printf "    alias = %s\n", $ob->alias;

undef $ob;
