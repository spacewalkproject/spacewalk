#!perl -w
#
# Simple command-line terminal emulator
# by Andrej Mikus
# with small modifications by Bill Birthisel
# no local echo at either end
#

use lib './blib/lib','../blib/lib'; # can run from here or distribution base
use Device::SerialPort 0.05;
use Term::ReadKey;

use strict;

my $file = "/dev/ttyS0";
my $ob = Device::SerialPort->new ($file) or die "Can't start $file\n";
    # next test will die at runtime unless $ob

my $c;
my $p1 = "Simple Terminal Emulator\n";
$p1 .= "Type CAPITAL Q to quit\n\n";
print $p1;
$p1 =~ s/\n/\r\n/ogs;
$ob->write ($p1);

for ( ;; ) {
    if ( $c = $ob -> input ) {
	$c =~ s/\r/\n/ogs;
	print $c;
	last if $c =~ /Q/;
	$c =~ s/\n/\r\n/ogs;
        $ob -> write ( $c );
    }
        
    if ( defined ( $c = ReadKey ( -1 ) ) ) {
	$c =~ s/\r/\n/ogs;
	$c =~ s/\n/\r\n/ogs;
        $ob -> write ( $c );
	last if $c eq 'Q';
    }
    select undef, undef, undef, 0.04; # 25/sec.
}

$ob -> close or die "Close failed: $!\n";
undef $ob;  # closes port AND frees memory in perl
