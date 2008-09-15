#!/usr/bin/perl

use strict;
use NOCpulse::Scheduler::Message;
use NOCpulse::Scheduler::Event;
use NOCpulse::Scheduler;
use NOCpulse::Debug;

my $debug = new NOCpulse::Debug();
my $stream = $debug->addstream(CONTEXT => 'literal',
			       LEVEL   => 5);

my $now = time();

my $s = new NOCpulse::Scheduler(Debug => $debug);

my $foo = new NOCpulse::Scheduler::Event("foo");
$foo->debugobject($debug);
$foo->time_to_execute($now);
$foo->subscribe_to("fox");

my $bar = new NOCpulse::Scheduler::Event("bar");
$bar->debugobject($debug);
$bar->time_to_execute($now + 5);
$bar->subscribe_to("fox");

my $i = 0;

while(1)
{
    $debug->dprint(1, "i = $i\n");

    if(( $i % 20) == 0)
    {
	$debug->dprint(1, "calling reset\n");
	$s->reset([$foo, $bar]);
    }

    $debug->dprint(1, "sleeping...\n");
    sleep 1;
    my $e = $s->next_event();
    if( defined $e )
    {
	$debug->dprint(1, "next_event() returned ".$e->id()."\n");
	$e = $e->run();
	$s->event_done($e);
    }
    else
    {
	$debug->dprint(1, "next_event() didn't return an event\n");
    }
    $i++;

}







