#!/usr/bin/perl
#
# For use in a satellite. 
# Assumes a single modem card is installed in the PCI bus.
# Will find the modem card, glean it's IRQ and port number
# and run the "setserial" command so we can use "/dev/modem".
#
#

undef $/;

open(F, "/proc/pci") or die "Opening: $!";

my @pcis  = split(/^\s+Bus\s+/m, <F>);

my @match = grep { /Communication controller:/ } @pcis;

my $irq = $match[0];
$irq =~ s/.*IRQ ([0-9A-Fa-fx]+).*/$1/s;

my $port  = $match[0];
$port  =~ s/.*?I\/O at ([0-9A-Fa-fx]+).*/$1/s;

system "setserial /dev/modem uart 16550A port $port irq $irq\n";

#######
# Make sure the modem doesn't answer
#  Note that order is important.
#   S0=0 (don't answer)
#   &F   (initialize to factory burned-in defaults, can take up to 1.5 seconds)
#   L0   (lowest volume)
#   M0   (disable speaker)
#   &W0  (store in NVRAM location 0)
#   &Y0  (power on using NVRAM location 0 configuration)
#
open(MODEM, ">/dev/modem");
print MODEM "AT&F L0 M0 S0=0 &W0 &Y0\r";
close(MODEM);

