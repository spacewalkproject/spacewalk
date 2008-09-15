#!/usr/bin/perl -w

use lib '.','./t','./blib/lib','../blib/lib';
# can run from here or distribution base

# Before installation is performed this script should be runnable with
# `perl test2.t time' which pauses `time' seconds (1..5) between pages

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..46\n"; }
END {print "not ok 1\n" unless $loaded;}
use Device::SerialPort 0.10;
require "DefaultPort.pm";
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# tests start using file created by test1.t

use strict;

my $file = "/dev/ttyS0";
if ($SerialJunk::Makefile_Test_Port) {
    $file = $SerialJunk::Makefile_Test_Port;
}
if (exists $ENV{Makefile_Test_Port}) {
    $file = $ENV{Makefile_Test_Port};
}

my $naptime = 0;	# pause between output pages
if (@ARGV) {
    $naptime = shift @ARGV;
    unless ($naptime =~ /^[0-5]$/) {
	die "Usage: perl test?.t [ page_delay (0..5) ] [ /dev/ttyxx ]";
    }
}
if (@ARGV) {
    $file = shift @ARGV;
}

my $cfgfile = $file."_test.cfg";
$cfgfile =~ s/.*\///;

my $fault = 0;
my $tc = 2;		# next test number
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $blk;
my $err;
my $e;
my $tick;
my $tock;
my @necessary_param = Device::SerialPort->set_test_mode_active(1);

sub is_ok {
    my $result = shift;
    printf (($result ? "" : "not ")."ok %d\n",$tc++);
    return $result;
}

sub is_zero {
    my $result = shift;
    if (defined $result) {
        return is_ok ($result == 0);
    }
    else {
        printf ("not ok %d\n",$tc++);
    }
}

sub is_bad {
    my $result = shift;
    printf (($result ? "not " : "")."ok %d\n",$tc++);
    return (not $result);
}

# 2: Constructor

unless (is_ok ($ob = Device::SerialPort->start ($cfgfile))) {
    printf "could not open port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

#### 3 - 11: Check Port Capabilities Match Save

is_ok ($ob->baudrate == 9600);			# 3
is_ok ($ob->parity eq "none");			# 4
is_ok ($ob->databits == 8);			# 5
is_ok ($ob->stopbits == 1);			# 6
is_ok ($ob->handshake eq "none");		# 7
is_ok ($ob->read_const_time == 0);		# 8
is_ok ($ob->read_char_time == 0);		# 9
is_ok ($ob->alias eq "TestPort");		# 10
is_ok ($ob->parity_enable == 0);		# 11

#### 12 - 18: Application Parameter Defaults

is_ok ($ob->devicetype eq 'none');		# 12
is_ok ($ob->hostname eq 'localhost');		# 13
is_zero ($ob->hostaddr);			# 14
is_ok ($ob->datatype eq 'raw');			# 15
is_ok ($ob->cfg_param_1 eq 'none');		# 16
is_ok ($ob->cfg_param_2 eq 'none');		# 17
is_ok ($ob->cfg_param_3 eq 'none');		# 18

# 19 - 21: "Instant" return for read_xx_time=0

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 19
is_bad ($in2);					# 20
$out=$tock - $tick;
is_ok ($out < 150);				# 21
print "<0> elapsed time=$out\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

print "Beginning Timed Tests at 2-5 Seconds per Set\n";

# 22 - 25: 2 Second Constant Timeout

is_ok (2000 == $ob->read_const_time(2000));	# 22
$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 23
is_bad ($in2);					# 24
$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 25
print "<2000> elapsed time=$out\n";

# 26 - 29: 4 Second Timeout Constant+Character

is_ok (100 == $ob->read_char_time(100));	# 26

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(20);
$tock=$ob->get_tick_count;

is_zero ($in);					# 27
is_bad ($in2);					# 28
$out=$tock - $tick;
is_bad (($out < 3800) or ($out > 4400));	# 29
print "<4000> elapsed time=$out\n";


# 30 - 34: 3 Second Character Timeout

is_zero ($ob->read_const_time(0));		# 30

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(30);
$tock=$ob->get_tick_count;

is_zero ($in);					# 31
is_bad ($in2);					# 32
$out=$tock - $tick;
is_bad (($out < 2800) or ($out > 3400));	# 33
print "<3000> elapsed time=$out\n";

is_zero ($ob->read_char_time(0));		# 34

is_ok ("rts" eq $ob->handshake("rts"));		# 35
is_ok ($ob->purge_rx);				# 36 
is_ok ($ob->purge_all);				# 37 
is_ok ($ob->purge_tx);				# 38 

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(1 == $ob->user_msg);			# 39
is_zero(scalar $ob->user_msg(0));		# 40
is_ok(1 == $ob->user_msg(1));			# 41
is_ok(1 == $ob->error_msg);			# 42
is_zero(scalar $ob->error_msg(0));		# 43
is_ok(1 == $ob->error_msg(1));			# 44

undef $ob;

# 45 - 46: Reopen tests (unconfirmed) $ob->close via undef

sleep 1;
unless (is_ok ($ob = Device::SerialPort->start ($cfgfile))) {
    printf "could not reopen port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}
is_ok(1 == $ob->close);				# 46
undef $ob;
