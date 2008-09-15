#!/usr/bin/perl
#---------------------------------------------------------------------------
#  Author:
#      Bruce Winter    brucewinter@home.net  http://members.home.net/winters
#
#  This free software is licensed under the terms of the GNU public license. 
#  Copyright 1998,1999 Bruce Winter
#
#---------------------------------------------------------------------------

use strict;
use vars qw($OS_win);

BEGIN {
        $OS_win = ($^O eq "MSWin32") ? 1 : 0;

        print "Perl version: $]\n";
        print "OS   version: $^O\n";

            # This must be in a BEGIN in order for the 'use' to be conditional
        if ($OS_win) {
            print "Loading Windows modules\n";
            eval "use Win32::SerialPort";
	    die "$@\n" if ($@);

        }
        else {
            print "Loading Unix modules\n";
            eval "use Device::SerialPort";
	    die "$@\n" if ($@);
        }
}                               # End BEGIN

die "\n\nno port specified\n" unless (@ARGV);
my $port = shift @ARGV;

my $serial_port; 

if ($OS_win) {
    $serial_port = new Win32::SerialPort ($port,1);
}
else {
    $serial_port = new Device::SerialPort ($port,1);
}
die "Can't open serial port $port: $^E\n" unless ($serial_port);

my $name = $serial_port->alias;
print "\nopened serial port $port as $name\n";
$serial_port->close || die "\nclose problem with $port\n";
