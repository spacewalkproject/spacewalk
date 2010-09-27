#!/usr/bin/perl

use strict;
use NOCpulse::Config;
use Pod::Usage;

my $CFG=NOCpulse::Config->new;

  my $queue_name=$ARGV[0];
  my $WARNING_QUEUE_SIZE  = $ARGV[1];
  my $CRITICAL_QUEUE_SIZE = $ARGV[2];

  unless ($queue_name && $WARNING_QUEUE_SIZE && $CRITICAL_QUEUE_SIZE) {
    pod2usage(1)
  }

  my $OK_EXIT = 0;
  my $WARNING_EXIT  = 1;
  my $CRITICAL_EXIT = 2;
  my $UNKNOWN_EXIT  = 3;
  my $exit_value=$OK_EXIT;

  my $queue = { ALERTS   => 'alert_queue_dir',
                ACKS     => 'ack_queue_dir',
                REQUESTS => 'request_queue_dir' };

  if (not $CFG) {
    bailout("Error: /etc/NOCpulse.ini do not exist\n");
  }

# Locate queue directory
  my $QUEUE_DIR = $CFG->get('notification', $queue->{$queue_name});
  chdir $QUEUE_DIR || &bailout("unable to find queue directory\n");
  my @files=glob("*");

  my $queue_size=scalar(@files);

  # output data for time series and setup exit status
  print "<perldata>\n<hash>\n";
  print '<item key="data">';
  print $queue_size;
  print "</item>\n</hash>\n</perldata>";

  if ($queue_size >= $CRITICAL_QUEUE_SIZE) {
    $exit_value=$CRITICAL_EXIT;
  } elsif ($queue_size >= $WARNING_QUEUE_SIZE) {
    $exit_value=$WARNING_EXIT;
  }
  exit $exit_value;

sub bailout {
  print STDERR "@_\n";
  exit($UNKNOWN_EXIT);
}

=pod

=head1 NAME

queue_remote_check.pl - monitor the queues from Spacewalk monitoring.

=head1 SYNOPSIS

queue_remote_check.pl QUEUE WARNING_QUEUE_SIZE CRITICAL_QUEUE_SIZE

=head1 DESCRIPTION

This script is give you content of the alert, acknowledgement, and request queues.
There exist version for running as cronjob: monitor-queue.

=head1 OPTIONS

QUEUE
        Name of notification queue. Should be ALERTS, ACKS or REQUESTS.

WARNING_QUEUE_SIZE
        Size of queue, which should produce warning. In cron we use 50.
        If queue reach this limit. Script exit with code 1.

CRITICAL_QUEUE_SIZE
        Size of queue, which is critical. In cron we use 100.
        If queue reach this limit, script exit with code 2.

=head1 SEE ALSO

monitor-queue(3)

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009--2010 Red Hat, Inc.
Released under GNU General Public License, version 2 (GPLv2).

=cut
