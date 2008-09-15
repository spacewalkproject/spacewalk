#!/usr/bin/perl -w

use lib '.','./t','./blib/lib','../blib/lib';
# can run from here or distribution base

# Before installation is performed this script should be runnable with
# `perl test1.t time' which pauses `time' seconds (1..5) between pages

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..174\n"; }
END {print "not ok 1\n" unless $loaded;}

use POSIX qw(uname);
# can't drain ports without modems on them under POSIX in Solaris 2.6
my ($sysname, $nodename, $release, $version, $machine) = POSIX::uname();
my $SKIPDRAIN=0;
if ($sysname eq "SunOS" && $machine =~ /^sun/) {
	$SKIPDRAIN=1;
}

use Device::SerialPort qw( :STAT 0.10 );
require "DefaultPort.pm";
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict;

## verifies the (0, 1) list returned by binary functions
sub test_bin_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (1 == shift);
    return 1;
}

my $tc = 2;		# next test number

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

# assume a "vanilla" port on "/dev/ttyS0"

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

my $cfgfile = "$file"."_test.cfg";
my $tstlock = "$file"."_lock.cfg";
$cfgfile =~ s/.*\///;
$tstlock =~ s/.*\///;

my $fault = 0;
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $err;
my $blk;
my $e;
my $tick;
my $tock;
my %required_param;
my @necessary_param = Device::SerialPort->set_test_mode_active(1);

unlink $cfgfile;
foreach $e (@necessary_param) { $required_param{$e} = 0; }

## 2 - 5 SerialPort Global variable ($Babble);

is_bad(scalar Device::SerialPort->debug);	# 2: start out false
is_ok(scalar Device::SerialPort->debug(1));	# 3: set it
is_bad(scalar Device::SerialPort->debug(2));	# 4: invalid binary=false

# 5: yes_true subroutine, no need to SHOUT if it works

$e="not ok $tc:";
unless (Device::SerialPort->debug("T"))   { print "$e \"T\"\n"; $fault++; }
if     (Device::SerialPort->debug("F"))   { print "$e \"F\"\n"; $fault++; }

no strict 'subs';
unless (Device::SerialPort->debug(T))     { print "$e T\n";     $fault++; }
if     (Device::SerialPort->debug(F))     { print "$e F\n";     $fault++; }
unless (Device::SerialPort->debug(Y))     { print "$e Y\n";     $fault++; }
if     (Device::SerialPort->debug(N))     { print "$e N\n";     $fault++; }
unless (Device::SerialPort->debug(ON))    { print "$e ON\n";    $fault++; }
if     (Device::SerialPort->debug(OFF))   { print "$e OFF\n";   $fault++; }
unless (Device::SerialPort->debug(TRUE))  { print "$e TRUE\n";  $fault++; }
if     (Device::SerialPort->debug(FALSE)) { print "$e FALSE\n"; $fault++; }
unless (Device::SerialPort->debug(Yes))   { print "$e Yes\n";   $fault++; }
if     (Device::SerialPort->debug(No))    { print "$e No\n";    $fault++; }
unless (Device::SerialPort->debug("yes")) { print "$e \"yes\"\n"; $fault++; }
if     (Device::SerialPort->debug("f"))   { print "$e \"f\"\n";   $fault++; }
use strict 'subs';

print "ok $tc\n" unless ($fault);
$tc++;

@opts = Device::SerialPort->debug;		# 6: binary_opt array
is_ok(test_bin_list(@opts));

# 7: Constructor

unless (is_ok ($ob = Device::SerialPort->new ($file))) {
    die "\n7: could not open port '$file'.  Are permissions correct?\n";
    # next test would die at runtime without $ob
}

#### 8 - 64: Check Port Capabilities 

## 8 - 21: Binary Capabilities

is_ok($ob->can_baud);				# 8
is_ok($ob->can_databits);			# 9
is_ok($ob->can_stopbits);			# 10
is_ok($ob->can_dtrdsr);				# 11
is_ok($ob->can_handshake);			# 12
is_ok($ob->can_parity_check);			# 13
is_ok($ob->can_parity_config);			# 14
is_ok($ob->can_parity_enable);			# 15
is_zero($ob->can_rlsd);				# 16
is_ok($ob->can_rtscts);				# 17
is_ok($ob->can_xonxoff);			# 18
is_zero($ob->can_interval_timeout);		# 19
is_ok($ob->can_total_timeout);			# 20
is_ok($ob->can_xon_char);			# 21
if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero($ob->can_spec_char);			# 22
is_zero($ob->can_16bitmode);			# 23
is_ok($ob->is_rs232);				# 24
is_zero($ob->is_modem);				# 25

#### 26 - xx: Set Basic Port Parameters 

## 26 - 31: Baud (Valid/Invalid/Current)

@opts=$ob->baudrate;		# list of allowed values
is_ok(1 == grep(/^9600$/, @opts));		# 26
is_zero(scalar grep(/^9601/, @opts));		# 27

is_ok($in = $ob->baudrate);			# 28
is_ok(1 == grep(/^$in$/, @opts));		# 29

is_bad(scalar $ob->baudrate(9601));		# 30
is_ok($in == $ob->baudrate(9600));		# 31
    # leaves 9600 pending

## 32 - xx: Parity (Valid/Invalid/Current)

@opts=$ob->parity;		# list of allowed values
is_ok(1 == grep(/none/, @opts));		# 32
is_zero(scalar grep(/any/, @opts));		# 33

is_ok($in = $ob->parity);			# 34
is_ok(1 == grep(/^$in$/, @opts));		# 35

is_bad(scalar $ob->parity("any"));		# 36
is_ok($in eq $ob->parity("none"));		# 37
    # leaves "none" pending

## 38 - 43: Databits (Valid/Invalid/Current)

@opts=$ob->databits;		# list of allowed values
is_ok(1 == grep(/8/, @opts));			# 38
is_zero(scalar grep(/4/, @opts));		# 39

is_ok($in = $ob->databits);			# 40
is_ok(1 == grep(/^$in$/, @opts));		# 41

is_bad(scalar $ob->databits(3));		# 42
is_ok($in == $ob->databits(8));			# 43
    # leaves 8 pending

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 44 - 49: Stopbits (Valid/Invalid/Current)

@opts=$ob->stopbits;		# list of allowed values
is_ok(1 == grep(/2/, @opts));			# 44
is_zero(scalar grep(/1.5/, @opts));		# 45

is_ok($in = $ob->stopbits);			# 46
is_ok(1 == grep(/^$in$/, @opts));		# 47

is_bad(scalar $ob->stopbits(3));		# 48
is_ok($in == $ob->stopbits(1));			# 49
    # leaves 1 pending

## 50 - 55: Handshake (Valid/Invalid/Current)

@opts=$ob->handshake;		# list of allowed values
is_ok(1 == grep(/none/, @opts));		# 50
is_zero(scalar grep(/moo/, @opts));		# 51

is_ok($in = $ob->handshake);			# 52
is_ok(1 == grep(/^$in$/, @opts));		# 53

is_bad(scalar $ob->handshake("moo"));		# 54
is_ok($in = $ob->handshake("rts"));		# 55

## 56 - 61: Buffer Size

($in, $out) = $ob->buffer_max(512);
is_bad(defined $in);				# 56
($in, $out) = $ob->buffer_max;
is_ok(defined $in);				# 57

if (($in > 0) and ($in < 4096))		{ $in2 = $in; } 
else					{ $in2 = 4096; }

if (($out > 0) and ($out < 4096))	{ $err = $out; } 
else					{ $err = 4096; }

is_ok(scalar $ob->buffers($in2, $err));		# 58

@opts = $ob->buffers(4096, 4096, 4096);
is_bad(defined $opts[0]);			# 59
($in, $out)= $ob->buffers;
is_ok($in2 == $in);				# 60
is_ok($out == $err);				# 61

## 62 - 64: Other Parameters (Defaults)

is_ok("TestPort" eq $ob->alias("TestPort"));	# 62
is_zero(scalar $ob->parity_enable(0));		# 63
is_ok($ob->write_settings);			# 64
is_ok($ob->binary);				# 65

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 66 - 67: Read Timeout Initialization

is_zero($ob->read_const_time);			# 66
is_zero($ob->read_char_time);			# 67

## 68 - 74: No Handshake, Polled Write

is_ok("none" eq $ob->handshake("none"));	# 68

$e="testing is a wonderful thing - this is a 60 byte long string";
#   123456789012345678901234567890123456789012345678901234567890
my $line = "\r\n$e\r\n$e\r\n$e\r\n";	# about 195 MS at 9600 baud

$tick=$ob->get_tick_count;
$pass=$ob->write($line);
if ($SKIPDRAIN) {
	is_zero(0);				# 69
	select(undef,undef,undef,0.195);
} else {
	is_ok(1 == $ob->write_drain);		# 69
}
$tock=$ob->get_tick_count;

is_ok($pass == 188);				# 70
$err=$tock - $tick;
is_bad (($err < 100) or ($err > 300));		# 71
print "<195> elapsed time=$err\n";

is_ok(scalar $ob->purge_tx);			# 72
is_ok(scalar $ob->purge_rx);			# 73
is_ok(scalar $ob->purge_all);			# 74

## 75 - 80: Optional Messages

@opts = $ob->user_msg;
is_ok(test_bin_list(@opts));			# 75
is_zero(scalar $ob->user_msg);			# 76
is_ok(1 == $ob->user_msg(1));			# 77

@opts = $ob->error_msg;
is_ok(test_bin_list(@opts));			# 78
is_zero(scalar $ob->error_msg);			# 79
is_ok(1 == $ob->error_msg(1));			# 80

## 81 - 164: Save and Check Configuration

is_ok(scalar $ob->save($cfgfile));		# 81

is_ok(9600 == $ob->baudrate);			# 82
is_ok("none" eq $ob->parity);			# 83

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(8 == $ob->databits);			# 84
is_ok(1 == $ob->stopbits);			# 85
is_ok(1 == $ob->close);				# 86
undef $ob;

## 87 - 89: Check File Headers

is_ok(open CF, "$cfgfile");			# 87
my ($signature, $name, $lockfile, @values) = <CF>;
close CF;

is_ok(1 == grep(/SerialPort_Configuration_File/, $signature));	# 88

chomp $name;
is_ok($name eq $file);				# 89

chomp $lockfile;
is_ok($lockfile eq "");				# 90

## 91 - 92: Check that Values listed exactly once

$fault = 0;
foreach $e (@values) {
    chomp $e;
    ($in, $out) = split(',',$e);
    $fault++ if ($out eq "");
    $required_param{$in}++;
    }
is_zero($fault);				# 91

$fault = 0;
foreach $e (@necessary_param) {
    $fault++ unless ($required_param{$e} ==1);
    }
is_zero($fault);				# 92


## 93 - 110: Reopen as (mostly 5.003 Compatible) Tie

    # constructor = TIEHANDLE method		# 93
unless (is_ok ($ob = tie(*PORT,'Device::SerialPort', $cfgfile))) {
    die "\n93: could not reopen port from $cfgfile\n";
    # next test would die at runtime without $ob
}

    # tie to PRINT method
$tick=$ob->get_tick_count;
$pass=print PORT $line;
is_ok(1 == $ob->write_drain);			# 94
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 95

$err=$tock - $tick;
is_bad (($err < 160) or ($err > 245));		# 96
print "<195> elapsed time=$err\n";

    # tie to PRINTF method
$tick=$ob->get_tick_count;
if ( $] < 5.004 ) {
    $out=sprintf "123456789_%s_987654321", $line;
    $pass=print PORT $out;
}
else {
    $pass=printf PORT "123456789_%s_987654321", $line;
}
is_ok(1 == $ob->write_drain);			# 97
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 98
$err=$tock - $tick;
is_bad (($err < 180) or ($err > 265));		# 99
print "<215> elapsed time=$err\n";

is_ok (300 == $ob->read_const_time(300));	# 100
is_ok (20 == $ob->read_char_time(20));		# 101
$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(10);
$tock=$ob->get_tick_count;

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

unless (is_zero ($in)) {			# 102
    die "\n102: Looks like you have a modem on the serial port!\n".
        "Please turn it off, or remove it and restart the tests.\n";
    # many tests following here will fail if there is modem attached
}
is_ok ($in2 eq "");				# 103


$err=$tock - $tick;
is_bad (($err < 475) or ($err > 585));		# 104
print "<500> elapsed time=$err\n";

is_ok (0 == $ob->read_char_time(0));		# 105
$tick=$ob->get_tick_count;
$in2= getc PORT;
$tock=$ob->get_tick_count;

is_bad (defined $in2);				# 106
$err=$tock - $tick;
is_bad (($err < 275) or ($err > 365));		# 107
print "<300> elapsed time=$err\n";

is_ok (0 == $ob->read_const_time(0));		# 108
$tick=$ob->get_tick_count;
$in2= getc PORT;
$tock=$ob->get_tick_count;

is_bad (defined $in2);				# 109
$err=$tock - $tick;
is_bad ($err > 50);				# 110
print "<0> elapsed time=$err\n";

## 111 - 115: Bad Port (new + quiet)

my $file2 = "/dev/badport";
my $ob2;
is_bad ($ob2 = Device::SerialPort->new ($file2));	# 111
is_bad (defined $ob2);					# 112
is_zero ($ob2 = Device::SerialPort->new ($file2, 1));	# 113
is_bad ($ob2 = Device::SerialPort->new ($file2, 0));	# 114
is_bad (defined $ob2);					# 115

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 116 - 131: Output bits and pulses

if ($ob->can_ioctl) {
    is_ok ($ob->dtr_active(0));			# 116
    $tick=$ob->get_tick_count;
    is_ok ($ob->pulse_dtr_on(100));		# 117
    $tock=$ob->get_tick_count;
    $err=$tock - $tick;
    is_bad (($err < 180) or ($err > 265));	# 118
    print "<200> elapsed time=$err\n";
    
    is_ok ($ob->dtr_active(1));			# 119
    $tick=$ob->get_tick_count;
    is_ok ($ob->pulse_dtr_off(200));		# 120
    $tock=$ob->get_tick_count;
    $err=$tock - $tick;
    is_bad (($err < 370) or ($err > 485));	# 121
    print "<400> elapsed time=$err\n";
    
    if ($ob->can_rts()) {
	is_ok ($ob->rts_active(0));		# 122
    	$tick=$ob->get_tick_count;
	is_ok ($ob->pulse_rts_on(150));		# 123
	$tock=$ob->get_tick_count;
	$err=$tock - $tick;
	is_bad (($err < 275) or ($err > 365));	# 124
	print "<300> elapsed time=$err\n";
    
	is_ok ($ob->rts_active(1));		# 125
	$tick=$ob->get_tick_count;
	is_ok ($ob->pulse_rts_off(50));		# 126
	$tock=$ob->get_tick_count;
	$err=$tock - $tick;
	is_bad (($err < 80) or ($err > 145));	# 127
	print "<100> elapsed time=$err\n";

	is_ok ($ob->rts_active(0));		# 128
    }
    else {
	# skip RTS setting tests
    	while ($tc < 128.1) { is_ok (1); }	# 122-128
    }
    
    is_ok ($ob->dtr_active(0));			# 129
    is_ok("rts" eq $ob->handshake("rts"));	# 130

        # for an unconnected port, should be $in=0, $out=0, $blk=0, $err=0
    if ($ob->can_status()) {
	    ($blk, $in, $out, $err) = $ob->status;
    }
    else {
	$out=0;
    }
    is_zero($out);				# 131
    is_ok(188 == $ob->write($line));		# 132
    print "<0 or 1> can_status=".$ob->can_status()."\n";
    if ($ob->can_status()) {
    	($blk, $in, $out, $err) = $ob->status;
    }
    else {
	$out=188;
	$in=0;
	$err=0;
	$blk=0;
    }
    is_zero($blk);				# 133

    if ($naptime) {
        print "++++ page break\n";
        sleep $naptime;
    }

    is_zero($in);				# 134
    is_ok(188 == $out);				# 135
    is_zero($err);				# 136
    if ($ob->can_write_done()) {
    	($out, $err) = $ob->write_done(0);
    }
    else {
	$out=0;
    }
    is_zero($out);				# 137

    $tick=$ob->get_tick_count;
    is_ok("none" eq $ob->handshake("none"));	# 138
    if ($ob->can_write_done()) {
    	($out, $err) = $ob->write_done(0);
    }
    else {
	$out=0;
    }
    is_zero($out);				# 139
    if ($ob->can_write_done()) {
    	($out, $err) = $ob->write_done(1);
    }
    else {
	$out=1;
	select(undef,undef,undef,0.200);
    }
    $tock=$ob->get_tick_count;

    is_ok(1 == $out);				# 140
    $err=$tock - $tick;
    is_bad (($err < 170) or ($err > 255));	# 141
    print "<200> elapsed time=$err\n";
    if ($ob->can_status()) {
    	($blk, $in, $out, $err) = $ob->status;
    }
    else {
	$out=0;
    }
    is_zero($out);				# 142
    is_ok(MS_CTS_ON);				# 143
    is_ok(MS_DSR_ON);				# 144
    is_ok(MS_RING_ON);				# 145
    is_ok(MS_RLSD_ON);				# 146
    $blk = MS_CTS_ON | MS_DSR_ON | MS_RING_ON | MS_RLSD_ON;
    is_ok(defined($ob->modemlines));		# 147
    is_zero($blk & $ob->modemlines);		# 148
}
else {
    print "bypassing ioctl tests\n";
    while ($tc < 133.1) { is_ok (1); }		# 116-133

    if ($naptime) {
        print "++++ page break\n";
        sleep $naptime;
    }

	# test number must change to match preceeding loop
    while ($tc < 148.1) { is_ok (1); }		# 134-148
}

is_zero(ST_BLOCK);				# 149
is_ok(1 == ST_INPUT);				# 150
is_ok(2 == ST_OUTPUT);				# 151
is_ok(3 == ST_ERROR);				# 152

$tick=$ob->get_tick_count;
# on Sun, break waits to be flushed, but we're on an empty serial port...
if ($SKIPDRAIN) {
	is_zero(0);				# 153
	select(undef,undef,undef,0.250);
} else {
	is_ok ($ob->pulse_break_on(250));	# 153
}
$tock=$ob->get_tick_count;
$err=$tock - $tick;
is_bad (($err < 235) or ($err > 900));		# 154
print "<500> elapsed time=$err\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

    # destructor = CLOSE method
if ($SKIPDRAIN) {
	is_zero(0);				# 155
} else {
	if ( $] < 5.005 ) {
	    is_ok($ob->close);			# 155
	}
	else {
	    is_ok(close PORT);			# 155
	}
}

    # destructor = DESTROY method
undef $ob;					# Don't forget this one!!
untie *PORT;

#### 156 - 163: Lock File Tests

unlink $tstlock;
is_bad (-e $tstlock);				# 156

is_ok ($ob = Device::SerialPort->new ($file, 1, $tstlock));	# 157
is_ok (-e $tstlock);				# 158
is_ok (-s $tstlock);				# 159

is_ok ($ob->restart($cfgfile));			# 160
sleep 1;
my $cfg2 = "tmp.$cfgfile";
is_ok(scalar $ob->save($cfg2));			# 161
is_ok($ob->close);				# 162
sleep 1;
is_bad (-e $tstlock);				# 163

#### 164 - 167: Lock from Configuration File with DESTROY

is_ok ($ob = Device::SerialPort->start ($cfg2));	# 164
is_ok (-e $tstlock);				# 165
is_ok (-s $tstlock);				# 166
undef $ob;

sleep 1;
is_bad (-e $tstlock);				# 167

## 168 - 170: Repeat with Lock SET

is_ok(open LF, ">$tstlock");			# 168
print LF "$$\n";
close LF;

is_zero ($ob = Device::SerialPort->start ($cfg2));		# 169
is_zero ($ob = Device::SerialPort->new ($file, 1, $tstlock));	# 170
unlink $tstlock;

## 171 - 174: Check File Headers with Lock

is_ok(open CF, "$cfg2");			# 171
($signature, $name, $lockfile, @values) = <CF>;
close CF;

is_ok(1 == grep(/SerialPort_Configuration_File/, $signature));	# 172

chomp $name;
is_ok($name eq $file);				# 173

chomp $lockfile;
is_ok($lockfile eq $tstlock);			# 174
unlink $cfg2;
