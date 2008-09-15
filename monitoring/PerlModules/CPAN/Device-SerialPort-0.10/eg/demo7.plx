#!/usr/bin/perl -w
#
# a perl/Tk based simple chat program
# demonstrates use of non-blocking I/O with event loop
# uses same setup as other demo?.plx programs in SerialPort distribution
#
# Send-Button does not add "\n", <Return> = <Enter> does

use lib './t','../t','./blib/lib','../blib/lib';
	# can run from here or distribution base

BEGIN { require 5.004; }
use Tk;
use Tk::ROText;
use Tk::LabEntry;
use Device::SerialPort 0.06;
require "DefaultPort.pm";

## use subs qw/newline sendline/;
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

# =============== execution begins here =======================

    # constructor
my $ob = Device::SerialPort->start ($cfgfile) or die "Can't start $cfgfile\n";
    # next test will die at runtime unless $ob

my $poll = 0;
my $polltime = 200;	# milliseconds
my $maxpoll = 150;	# 30 seconds
my $msg = "";
my $send = "";
my $senttext = "";

my $mw= MainWindow->new('-title' => 'Device::SerialPort Chat Demo7');

my $f = $mw->Frame;
my $s = $f->LabEntry(-label => 'Local: ', -width => 60,
                     -labelPack => [qw/-side left -anchor w/],
                     -textvariable => \$send)->pack(qw/-side left/);
$s->Subwidget('entry')->focus;

my $sendret = sub { $send .= "\n"; &sendline; };
my $sendcmd = \&sendline;
my $b = $f->Button(-text => 'Send');
$b->pack(qw/-side left/);
$b->configure(-command => $sendcmd);
$s->bind('<Return>' => $sendret);

$f->pack(qw/-side bottom -fill x/);

my $t = $mw->Scrolled(qw/ROText -setgrid true -height 20 -scrollbars e/);
$t->pack(qw/-expand yes -fill both/);
$t->tagConfigure(qw/Win32 -foreground black -background white/);
$t->tagConfigure(qw/Serial -foreground white -background red/);
$t->insert('end',"        Welcome to the Tk SerialPort Demo\n", 'Win32');
$t->insert('end',"                REMOTE messages\n", 'Serial');
$t->insert('end',"                LOCAL messages\n\n", 'Win32');

my $stty_onlcr = 1;			# on my terminal, but not POSIX
$ob->stty_opost(1);			# on my terminal
$ob->stty_icrnl(1);			# but you might change
$ob->stty_echo(1);
$ob->stty_icanon(1);
$ob->are_match("\n");			# possible end strings
$ob->lookclear;				# empty buffer
$ob->write("\nSerialPort Demo\n");	# "write" first to init "write_done"
$msg = "\nTalking to Tk\n";		# initial prompt
## $ob->is_prompt("Again?");		# new prompt after "kill" char

&newline;
MainLoop();

sub newline {
    my $gotit = "";		# poll until data ready
##    if ($ob->write_done(0)) {
        $gotit = $ob->lookfor;		# poll until data ready
##    }
    die "Aborted without match\n" unless (defined $gotit);
    my $match = $ob->matchclear;
    if ( ($gotit ne "") || ($match ne "") ) {
        $t->insert('end',"$gotit\n",'Serial');
        $poll = 0;
        $t->see('end');
        $ob->write("\r") if ($stty_onlcr);
    }
    if ($maxpoll < $poll++) {
        $t->insert('end',"\nCOUNTER: long time with no input\n",'Win32');
        $poll = 0;
        $msg = "\nAnybody there?\n";
    }
    if ($senttext) {
        $t->insert('end',"\n$senttext",'Win32');
        $senttext = "";
    }
##     if ($msg && $ob->write_done(0)) {
    if ($msg) {
        if ($stty_onlcr) { $msg =~ s/\n/\r\n/osg; }
##         $ob->write_bg($msg);
        $ob->write($msg);
        $msg = "";
        $t->see('end');
    }
    $mw->after($polltime, \&newline);
}

sub sendline {
    $msg .= "\n$send";
    $senttext = "$send";
    $send = "";
}
