#!/usr/bin/perl -w

use lib './t','../t','./blib/lib','../blib/lib';
	# can run from here or distribution base

use Device::SerialPort 0.06;
require "DefaultPort.pm";
use strict;

# tests start using file created by test1.t unless overridden

my $file = "/dev/ttyS0";
if ($SerialJunk::Makefile_Test_Port) {
    $file = $SerialJunk::Makefile_Test_Port;
}
if (exists $ENV{Makefile_Test_Port}) {
    $file = $ENV{Makefile_Test_Port};
}
if (@ARGV) {
    $file = shift @ARGV;
}

my $cfgfile = $file."_test.cfg";
$cfgfile =~ s/.*\///;

if (-e "../t/$cfgfile") { $cfgfile = "../t/$cfgfile"; }
elsif (-e "../$cfgfile") { $cfgfile = "../$cfgfile"; }
elsif (-e "t/$cfgfile") { $cfgfile = "t/$cfgfile"; }
else { die "$cfgfile not found" unless (-e $cfgfile); }

# Constructor

my $head	= "\r\n\r\n+++++++++++ Tied FileHandle Demo ++++++++++\r\n";
my $e="\r\n....Bye\r\n";

# =============== execution begins here =======================

    # constructor = TIEHANDLE method
my $tie_ob = tie(*PORT,'Device::SerialPort', $cfgfile)
                 || die "Can't start $cfgfile\n";

    # timeouts
$tie_ob->read_char_time(0);
$tie_ob->read_const_time(10000);
### $tie_ob->read_interval(0);
### $tie_ob->write_char_time(0);
### $tie_ob->write_const_time(3000);
### 
###     # match parameters
### $tie_ob->are_match("\n");
$tie_ob->lookclear;
### $tie_ob->is_prompt("\r\nPrompt! ");

    # other parameters
$tie_ob->error_msg(1);		# use built-in error messages
$tie_ob->user_msg(1);
$tie_ob->handshake("xoff");
### $tie_ob->handshake("rts");   # will cause output timeouts if no connect
### $tie_ob->stty_onlcr(1);		# depends on terminal
### $tie_ob->stty_opost(1);		# depends on terminal
$tie_ob->stty_icrnl(1);		# depends on terminal
$tie_ob->stty_echo(0);		# depends on terminal

    # Print Prompts to Port and Main Screen
print $head;
print PORT $head;

    # tie to PRINT method
print PORT "\r\nEnter one character (10 seconds): "
    or print "PRINT timed out\n\n";

    # tie to GETC method
my $char = getc PORT;
if (!defined $char) {
    print "GETC timed out\n";
    print PORT "...GETC timed_out\r\n";
}
else {
    print PORT "$char\r\n";
}

    # tie to WRITE method
if ( $] < 5.005 ) {
    print "syswrite tie to WRITE not supported in this Perl\n\n";
}
else {
    my $out = "\r\nThis is a 'syswrite' test\r\n\r\n";
    syswrite PORT, $out, length($out), 0
        or print "WRITE timed out\n\n";
}


    # tie to READLINE method
$tie_ob->stty_echo(1);		# depends on terminal
print PORT "enter line: ";
my $line = <PORT>;
if (defined $line) {
    print "READLINE received: $line"; # no chomp
    print PORT "\r\nREADLINE received: $line\r";
}
else {
    print "READLINE timed out\n\n";
    print PORT "...READLINE timed out\r\n";
    my ($patt, $after, $match, $instead) = $tie_ob->lastlook;  ## NEW
    print "got_instead = $instead\n" if ($instead);            ## NEW
}

    # tie to READ method
my $in = "FIRST:12345, SECOND:67890, END";
$tie_ob->stty_echo(0);		# depends on terminal
print PORT "\r\nenter 5 char (no echo): ";
unless (defined sysread (PORT, $in, 5, 6)) {
    print "READ timed out:\n";
    print PORT "...READ timed out\r\n";
}

$tie_ob->stty_echo(1);		# depends on terminal
print PORT "\r\nenter 5 more char (with echo): ";
unless (defined sysread (PORT, $in, 5, 20)) {
    print "READ timed out:\n";
    print PORT "...READ timed out\r\n";
}

    # tie to PRINTF method
printf PORT "\r\nreceived: %s\r\n", $in
    or print "PRINTF timed out\n\n";

    # PORT-specific versions of the $, and $\ variables
my $n1 = ".number1_";
my $n2 = ".number2_";
my $n3 = ".number3_";

print PORT $n1, $n2, $n3;
print PORT "\r\n";

$tie_ob->output_field_separator("COMMA");
print PORT $n1, $n2, $n3;
print PORT "\r\n";

$tie_ob->output_record_separator("RECORD");
print PORT $n1, $n2, $n3;
$tie_ob->output_record_separator("");
print PORT "\r\n";
    # the $, and $\ variables will also work

print PORT $e;

    # destructor = CLOSE method
if ( $] < 5.005 ) {
    print "close tie to CLOSE not supported in this Perl\n\n";
    $tie_ob->close || print "port close failed\n\n";
}
else {
    close PORT || print "CLOSE failed\n\n";
}

    # destructor = DESTROY method
undef $tie_ob;	# Don't forget this one!!
untie *PORT;

print $e;
