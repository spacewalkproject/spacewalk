#!/usr/bin/perl

use strict;
use FileHandle;
use GDBM_File;
use NOCpulse::Config;
use NOCpulse::Debug;
use NOCpulse::Log::Logger;

umask(022);

my $CFG              = new NOCpulse::Config;                           # Config object
my $tmp_dir          = $CFG->get('notification','tmp_dir');
my $SEND_GDBM        = "$tmp_dir/sendhistory.gdbm";

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__,3);

$Log->log(1,"Starting up $0\n");

# shutdown gracefully
my $bailout = 0;
$SIG{'INT'} = $SIG{'TERM'} = sub { $bailout = 1; };

# Send id database
my %send_history;
tie(%send_history, 'GDBM_File', $SEND_GDBM, O_RDONLY, 0644) || die "Unable to find send history $!";

my (@ids,@operations);

while (!$bailout) {
 unless(@ids) {
   @ids=keys(%send_history);
 } 
 unless(@operations) {
   @operations=qw(ack nak suspend metoo autoack redir);
 }
 my $id=pop(@ids) || 'xxxxxx';
 $id="01$id";
 my $oper=pop(@operations);

 my $cmd;
 if (($oper eq 'ack') || ($oper eq 'nak')) {
   $cmd="$oper $id";
 } elsif (($oper eq 'autoack') || ($oper eq 'suspend')) {
   $cmd="ack $id $oper 10m"
 } else {
   $cmd="ack $id $oper 10m nobody\@nocpulse.com"
 } 
 print "$cmd\n";
 my $full_text = <<EOX;
From: test <nobody\@nocpulse.com>
To: <rogerthatdev01\@localhost>
Subject: $cmd

This is a test message from $0
EOX

 `echo "$full_text" | /usr/bin/ack_enqueuer.pl`;
 sleep(1);
}
