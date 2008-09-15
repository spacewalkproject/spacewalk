#!/usr/bin/perl -w

use lib './t','../t','./blib/lib','../blib/lib';
	# can run from here or distribution base

use Device::SerialPort 0.06;
require "DefaultPort.pm";
use Carp;
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

my $ob;
my $pass;
my @wanted;
my $before;
my $did_match;
my $stty_onlcr;

sub nextline {
    my $delay = 0;
    my $prompt;
    $delay = shift if (@_);
    if (@_)	{ $prompt = shift; }
    else	{ $prompt = ""; }
    my $timeout=$ob->get_tick_count + (1000 * $delay);
    my $gotit = "";
    my $fmatch = "";
    my @junk;
	# this count wraps every 49 days or so

##    $ob->is_prompt($prompt);
    $prompt =~ s/\n/\r\n/ogs if ($ob->stty_opost && $stty_onlcr);
    $ob->write($prompt);

    for (;;) {
        return unless (defined ($gotit = $ob->lookfor));
        if ($gotit ne "") {
	    ($fmatch, @junk) = $ob->lastlook;
            return ($gotit, $fmatch);
	}
	$fmatch = $ob->matchclear;
	return ("", $fmatch) if ($fmatch);
        return if ($ob->reset_error);
	select undef, undef, undef, 0.05; # 20/sec.
	return if ($ob->get_tick_count > $timeout);
    }
}

sub waitfor {
    croak "parameter problem" unless (@_ == 1);
    $ob->lookclear;
    nextline ( shift );
}

sub stty_char {
    my $pos = shift;
    return '%%%%' unless ($pos);
##    return $pos if (2 >= length($pos));
    my $n_char = chr $pos;
    if ($pos < 32) {
        $n_char = "^".chr($pos + 64);
    }
    if ($pos == 127) {
        $n_char = "DEL";
    }
    return $n_char;
}

# starts configuration created by test1.pl

# =============== execution begins here =======================

# 2: Constructor

$ob = Device::SerialPort->start ($cfgfile) or die "Can't start $cfgfile\n";
    # next test will die at runtime unless $ob

### setup for dumb terminal, your mileage may vary
$ob->stty_echo(1);
$ob->stty_icrnl(1);
$stty_onlcr = 1;
$ob->stty_opost(1);
###

my $intr = stty_char($ob->is_stty_intr);
my $quit = stty_char($ob->is_stty_quit);
my $eof = stty_char($ob->is_stty_eof);
my $eol = stty_char($ob->is_stty_eol);
my $erase = stty_char($ob->is_stty_erase);
my $kill = stty_char($ob->is_stty_kill);
my $echo = ($ob->stty_echo ? "" : "-")."echo";
my $echoe = ($ob->stty_echoe ? "" : "-")."echoe";
my $echok = ($ob->stty_echok ? "" : "-")."echok";
my $echonl = ($ob->stty_echonl ? "" : "-")."echonl";
## my $echoke = ($ob->stty_echoke ? "" : "-")."echoke";
## my $echoctl = ($ob->stty_echoctl ? "" : "-")."echoctl";
my $istrip = ($ob->stty_istrip ? "" : "-")."istrip";
my $icrnl = ($ob->stty_icrnl ? "" : "-")."icrnl";
## my $ocrnl = ($ob->stty_ocrnl ? "" : "-")."ocrnl";
my $igncr = ($ob->stty_igncr ? "" : "-")."igncr";
my $inlcr = ($ob->stty_inlcr ? "" : "-")."inlcr";
my $onlcr = ($stty_onlcr ? "" : "-")."onlcr";
my $opost = ($ob->stty_opost ? "" : "-")."opost";
my $isig = $ob->stty_isig ? "enabled" : "disabled";
my $icanon = $ob->stty_icanon ? "enabled" : "disabled";


# 3: Prints Prompts to Port and Main Screen

my $head	= "\r\n\r\n++++++++++++++++++++++++++++++++++++++++++\r\n";
my $e="\r\n....Bye\r\n";

my $tock	= <<TOCK_END;
Simple Serial Terminal with lookfor

Terminal CONTROL Keys Supported:
    quit = $quit;  intr = $intr;  $isig
    erase = $erase;  kill = $kill;  $icanon
    eol = $eol;  eof = $eof;

Terminal FUNCTIONS Supported:
    $istrip  $igncr  $echok  $echonl
    $echo  $echoe

Terminal Character Conversions Supported:
    $icrnl  $inlcr  $onlcr  $opost

TOCK_END
#

print $head, $tock;
$tock =~ s/\n/\r\n/ogs if ($ob->stty_opost && $stty_onlcr);
$pass=$ob->write($head);
$pass=$ob->write($tock);

$ob->error_msg(1);		# use built-in error messages
$ob->user_msg(1);

my $match1 = "YES";
my $match2 = "NO";
my $prompt1 = "Type $match1 or $match2 or <ENTER> exactly to continue\r\n";

$pass=$ob->write($prompt1) if ($ob->stty_echo);

$ob->are_match($match1, $match2, "\n");
($before, $did_match) = waitfor (30);
my ($found, $end, $patt, $instead) = $ob->lastlook;
if (defined $before) {
    if ("\n" eq $did_match) { $did_match = "newline"; }
    print "\ngot: $before...followed by: $did_match...\n";
}
else {
    print "\r\nAborted or Timed Out\r\n";
    print "actually received: $instead...\n";
}

print $head;
$pass=$ob->write($head);

$ob->lookclear;
($before, $did_match) = nextline (60, "\nPROMPT:");
if (defined $before) {
    if ("\n" eq $did_match) { $did_match = "newline"; }
    print "\ngot: $before...followed by: $did_match...\n";
}
else {
    ($found, $end, $patt, $instead) = $ob->lastlook;
    print "\r\nAborted or Timed Out\r\n";
    print "actually received: $instead...\n";
}

sleep 2;
($before, $did_match) = nextline (60, "\nPROMPT2:");
if (defined $before) {
    if ("\n" eq $did_match) { $did_match = "newline"; }
    print "\ngot2: $before...followed by: $did_match...\n";
}
else {
    ($found, $end, $patt, $instead) = $ob->lastlook;
    print "\r\nAborted or Timed Out\r\n";
    print "actually received: $instead...\n";
}

sleep 2;
@wanted = ("BYE");
$ob->are_match(@wanted);
($before, $did_match) = nextline (60, "\ntype 'BYE' to quit:");
if (defined $before) {
    print "\ngot3: $before...followed by: $did_match...\n";
}
else {
    ($found, $end, $patt, $instead) = $ob->lastlook;
    print "\r\nAborted or Timed Out\r\n";
    print "actually received: $instead...\n";
}

### example from the docs

  $ob->are_match("text", "\n");	# possible end strings
  $ob->lookclear;		# empty buffers
  $ob->write("\r\nFeed Me:");	# initial prompt
##  $ob->is_prompt("More Food:");	# new prompt after "kill" char

  my $gotit = "";
  $match1 = "";
  until ("" ne $gotit) {
      $gotit = $ob->lookfor;	# poll until data ready
      die "Aborted without match\n" unless (defined $gotit);
      last if ($gotit);
      $match1 = $ob->matchclear;   # match is first thing received
      last if ($match1);
      sleep 1;				# polling sample time
  }

  printf "gotit = %s...\n", $gotit;		# input BEFORE the match
  ($found, $end, $patt, $instead) = $ob->lastlook;
      # input that MATCHED, input AFTER the match, PATTERN that matched
      # input received INSTEAD when timeout without match

  if ($match1) {
      $found = $match1;
  }
  print "lastlook-match = $found...\n" if ($found);
  print "lastlook-after = $end...\n" if ($end);
  print "lastlook-pattern = $patt...\n" if ($patt);
  print "lastlook-instead = $instead...\n" if ($instead);

###
print $e;
$pass=$ob->write($e);

sleep 1;

undef $ob;
