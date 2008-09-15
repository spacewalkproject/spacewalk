#!/usr/bin/perl

use strict;
use Getopt::Long;
use NOCpulse::Config;
use NOCpulse::Notif::Alert;

# Get command line options
my @groups;
my $c = 1;
my $sleep = 0;
my $help;

my $result= &GetOptions('group=i'   => \@groups,
                        'count=i'   => \$c,
                        'sleep=i'   => \$sleep,
                        'help'      => \$help);
unless($result) {
  print STDERR "Problem processing options\n";
}

if ($help || !@groups) {
  print "$0",' --group=<group id> [... --group=<group id>] [--count=<# notifs to send each batch>] [--sleep=<number of seconds to sleep between batches] [--help]',"\n";
  exit(0)
}

my $server_id = 0;
my $CFG           = new NOCpulse::Config;
my $QUEUE_DIR     = $CFG->get('notification', 'alert_queue_dir'); 
my $NEW_QUEUE_DIR = "$QUEUE_DIR/.new"; 

my $num_groups = scalar(@groups);
my $alert=new NOCpulse::Notif::Alert(                 
          'type'         => 'adhoc',
          'debug'        => 3,
          'groupName'    => 'Unknown',
          'time'         => time(),
          'customerId' => 1 );

my $batch=0;
do {
  $batch++;
  for (my $number = 1; $number <= $c; $number++) {
    
    my $batch_number= $sleep ? "$batch.$number" : $number;
    my $time = time();
    my $time_string = scalar(localtime());
    my $ticket = sprintf ( "%02d_%010d_%06d_%03d", $server_id, $time, $$, $number);
    $alert->current_time($time);
    $alert->ticket_id($ticket);
    $alert->subject("stress test #$batch_number");
    $alert->message("This is a stress test message #$batch_number at $time_string.\n($ticket by $0)\n");
    $alert->groupId($groups[$number % $num_groups]);
  
    my $new_file="$NEW_QUEUE_DIR/$ticket";
    my $file="$QUEUE_DIR/$ticket";
    $alert->store($new_file);
    rename($new_file,$file) || return "Unable to rename $new_file\n";
    print "$batch_number: $file created\n";
  } 
  if ($sleep) {
    print "Zzzzz .... sleep($sleep)\n";
    sleep($sleep);
  }
} while ($sleep > 0);
