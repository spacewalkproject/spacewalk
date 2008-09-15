#!/usr/bin/perl

use NOCpulse::ProcessPool;


# Global variables
my $CONCURRENCY = 5;
my $MAXLIFE     = 30;
my $debug       = new NOCpulse::Debug();
$debug->addstream(CONTEXT => 'literal',
                  LEVEL   => 9);


# Start a process pool
my $procpool = new NOCpulse::ProcessPool(Size    => $CONCURRENCY,
			                 Maxlife => $MAXLIFE, 
			                 Debug   => $debug);

open(WORDS, "/usr/dict/words") or die;
while (<WORDS>) {

  chomp;

  $debug->dprint(1, "Doing '$_'\n");

  $debug->dprint(1, "Euthanizing old processes\n");
  my $killed = $procpool->euthanize();
  $debug->dprint(1, "\tKilled $killed processes\n");

  $debug->dprint(1, "Reaping dead processes\n");
  my $reaped;
  while ($reaped = $procpool->reap()) {
    $debug->dprint(1, "\tChild ", $reaped->pid, " exited with ", 
                                  $reaped->status, " status\n");
    $debug->dprint(1, "\tSTDOUT:  ", $reaped->stdout, "\n");
    $debug->dprint(1, "\tSTDERR:  ", $reaped->stderr, "\n");
  }

  $debug->dprint(1, "\tWaiting up to 10 secs for available slot\n");
  $procpool->wait_for_slot(10);

  if ($procpool->availableSlots) {
    my $randomsleep = int(rand(60));
    my $new = $procpool->spawn("echo $_; sleep $randomsleep");
    $debug->dprint(1, "\tChild ", $new->pid, 
		      " spawned with $randomsleep sleep\n");
  }


}
close(WORDS);

