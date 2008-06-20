#!/usr/bin/perl

use strict;

use LWP;
use NOCpulse::Config;
use Getopt::Long;
use NOCpulse::Gritch;
use NOCpulse::SatQueue::Enqueuer;
use NOCpulse::Scheduler::CurrentState;
use NOCpulse::SatCluster;
use URI::Escape;
use FileHandle;


my $dbg_level;
GetOptions("debug=i" => \$dbg_level);

my $debug = NOCpulse::Debug->new();
my $debugstream = $debug->addstream(LEVEL => $dbg_level);
my $cfg = NOCpulse::Config->new();
my $cluster = SatCluster->newInitialized($cfg);
my $gritcher = new NOCpulse::Gritch("/opt/home/nocpulse/var/push_errors.db");
$gritcher->recipient(NOCpulse::SatQueue::Enqueuer->new());
my $id = $cluster->get_id();


print "this script is obsolete\n";
