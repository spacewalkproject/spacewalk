#!/usr/bin/perl -w

use lib './blib/lib','../blib/lib'; # can run from here or distribution base

use Device::SerialPort 0.05;
use strict;

sub get_tf {
    my $result = shift;
    if ($result) { return "T"; }
    return "F";
}

my $file = "/dev/ttyS0";
my $ob;
my $full_cfg = 0;

# Constructor

if (@ARGV) {
    $file = $ARGV[0];
    $ob = Device::SerialPort->start ($file) or
        die "could not open port from configuration $file\n";
    # next test would die at runtime without $ob
    $full_cfg++;
}
else {
    $ob = Device::SerialPort->new ($file) or
        die "could not open port from $file\n";
    # next test would die at runtime without $ob
}

my @carp_off_please = Device::SerialPort->set_test_mode_active(1);

#### Check Port Settings

my $baud=$ob->baudrate;
my $par=$ob->parity;
my $data=$ob->databits;
my $stop=$ob->stopbits;
my $hshake=$ob->handshake;
my $rint="Win32";
my $rconst=$ob->read_const_time;
my $rchar=$ob->read_char_time;
my $wconst="Win32";
my $wchar="Win32";
my ($rbuf, $wbuf)= $ob->buffers;
my $alias=$ob->alias;
my $xof_l="Win32";
my $xon_l="Win32";

my $user=get_tf(scalar $ob->user_msg);
my $error=get_tf(scalar $ob->error_msg);
my $debug=get_tf(scalar $ob->debug);
my $bin=get_tf(scalar $ob->binary);
my $par_e=get_tf(scalar $ob->parity_enable);

my $xon_c="Win32";
my $xof_c="Win32";
my $eof_c="Win32";
my $evt_c="Win32";
my $err_c="Win32";

## if ($rint == 0xffffffff) { $rint = "OFF "; }

sub update_menu {
	$baud=$ob->baudrate;
	$par=$ob->parity;
	$data=$ob->databits;
	$stop=$ob->stopbits;
	$hshake=$ob->handshake;
## 	$rint=$ob->read_interval;
	$rconst=$ob->read_const_time;
	$rchar=$ob->read_char_time;
## 	$wconst=$ob->write_const_time;
## 	$wchar=$ob->write_char_time;
	($rbuf, $wbuf)= $ob->buffers;
	$alias=$ob->alias;
## 	$xof_l=$ob->xoff_limit;
## 	$xon_l=$ob->xon_limit;

	$user=get_tf(scalar $ob->user_msg);
	$error=get_tf(scalar $ob->error_msg);
	$debug=get_tf(scalar $ob->debug);
	$bin=get_tf(scalar $ob->binary);
	$par_e=get_tf(scalar $ob->parity_enable);

## 	$xon_c=sprintf("0x%x", scalar $ob->xon_char);
## 	$xof_c=sprintf("0x%x", scalar $ob->xoff_char);
## 	$eof_c=sprintf("0x%x", scalar $ob->eof_char);
## 	$evt_c=sprintf("0x%x", scalar $ob->event_char);
## 	$err_c=sprintf("0x%x", scalar $ob->error_char);

## 	if ($rint == 0xffffffff) { $rint = "OFF "; }

	$-=0;
	write;
}

format STDOUT_TOP =

========================  Serial Port Setup ===========================

.

format STDOUT =
A  Alias:      @<<<<<<<<<<<<      M  Read Interval Time     @>>>>>>> MS
               $alias,                                      $rint
B  Baud:       @<<<<<<            N  Read Char. Time        @>>>>>>> MS
               $baud,                                       $rchar
C  Binary:     @<                 O  Read Constant Time     @>>>>>>> MS
               $bin,                                        $rconst
D  Databits:   @<                 P  Write Char. Time       @>>>>>>> MS
               $data,                                       $wchar
E  Parity_En:  @<                 Q  Write Const. Time      @>>>>>>> MS
               $par_e,                                      $wconst
F  Parity:     @<<<<              R  Read Buffer Size       @>>>>>>>
               $par,                                        $rbuf
G  Error Msg:  @<<                S  Write Buffer Size      @>>>>>>>
               $error,                                      $wbuf
H  Handshake:  @<<<<              T  Buffer Send Xon  (top)   @>>>>>
               $hshake,                                       $xon_l
I  User Msg:   @<<<<              U  Buffer Send Xoff (bot)   @>>>>>
               $user,                                         $xof_l
J  Error Char: @<<<<              V  Xoff Character           @>>>>>
               $err_c,                                        $xof_c
K  Event Char: @<<<<              W  Xon Character            @>>>>>
               $evt_c,                                        $xon_c
L  Debug:      @<<<<              X  Eof Character            @>>>>>
               $debug,                                        $eof_c
.

write;

print "\nWaiting 5 seconds before continuing\n";
sleep 5;

$ob->user_msg(1);
$ob->parity("odd");
$ob->parity_enable(1);

update_menu;

## unless ($full_cfg) {
##     print "\nParity settings will not update until write_settings complete\n";
## }

undef $ob;
