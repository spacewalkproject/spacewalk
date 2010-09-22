#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

use strict;
package Dobby::CLI::MiscCommands;

use Carp;

use Dobby::DB;
use Dobby::Reporting;

sub register_dobby_commands {
  my $class = shift;
  my $cli = shift;

  $cli->register_mode(-command => "stop",
		      -description => "Stop the RHN Oracle Instance",
		      -handler => \&command_startstop);
  $cli->register_mode(-command => "start",
		      -description => "Start the RHN Oracle Instance",
		      -handler => \&command_startstop);

  $cli->register_mode(-command => "status",
		      -description => "Show database status",
		      -handler => \&command_status);
  $cli->register_mode(-command => "report",
		      -description => "Show database space report",
		      -handler => \&command_report);
  $cli->register_mode(-command => "tablesizes",
		      -description => "Show space report for each table",
		      -handler => \&command_tablesizes);
  $cli->register_mode(-command => "report-stats",
		      -description => "Show tables with stale or empty statistics",
		      -handler => \&command_reportstats);
}

sub command_startstop {
  my $cli = shift;
  my $command = shift;

  my $d = new Dobby::DB;

  if ($command eq 'start') {
    if ($d->instance_state ne 'OFFLINE') {
      print "Database already running.\n";
    }
    else {
      print "Starting database... ";
      $d->database_startup;
      $d->listener_startup;
      print "done.\n";
    }
  }
  elsif ($command eq 'stop') {
    if ($d->instance_state eq 'OFFLINE') {
      print "Database already shut down.\n";
    }
    else {
      print "Shutting down database... ";
      $d->listener_shutdown;
      $d->database_shutdown("immediate");
      print "done.\n";
    }
  }
  else {
    croak "Unknown command '$command' not in (start, stop)";
  }
}

sub command_status {
  my $cli = shift;

  my $d = new Dobby::DB;
  my $state = $d->instance_state;

  my %msgs =
    ( OPEN => "The database is running and accepting connections.",
      OFFLINE => "The database is offline.",
      MOUNTED => "The database is running but not accepting connections.",
      STOPPING => "The database is in the process of shutting down.",
    );

  if (exists $msgs{$state}) {
    print "$msgs{$state}\n";
  }
  else {
    print "Error: unknown database state '$state'\n";
  }

  return ($state eq 'OPEN' ? 0 : 1);
}

# input is a number of bytes
# output is human-readable string
sub size_scale {
  my $class = shift;
  my $n = shift;
  my @prefixes = qw/B K M G T/;

  while ($n > 1024 and @prefixes > 1) {
    shift @prefixes;
    $n = int(10 * $n / 1024)/10;
  }

  return "$n$prefixes[0]";
}

sub command_report {
  my $cli = shift;

  my $d = new Dobby::DB;
  if (not $d->database_started) {
    print "Error: The database must be running to get a space report.\n";
    return 1;
  }

  my $indent = "  ";

  my $fmt = "%-24s %7s %7s %7s %5s%%\n";
  printf $fmt, "Tablespace", "Size", "Used", "Avail", "Use";

  my $class = __PACKAGE__;
  for my $ts (sort { $a->{NAME} cmp $b->{NAME} } Dobby::Reporting->tablespace_overview($d)) {
    $ts->{FREE_BYTES} = $ts->{TOTAL_BYTES} - ($ts->{USED_BYTES} or 0) unless $ts->{FREE_BYTES};
    $ts->{USED_BYTES} = $ts->{TOTAL_BYTES} - ($ts->{FREE_BYTES} or 0) unless $ts->{USED_BYTES};
    printf $fmt,
      $ts->{NAME},
      $class->size_scale($ts->{TOTAL_BYTES}),
      $class->size_scale($ts->{USED_BYTES}),
      $class->size_scale($ts->{FREE_BYTES}),
      sprintf("%.0f", 100 * ($ts->{USED_BYTES} / $ts->{TOTAL_BYTES}));
  }
}

sub command_tablesizes {
  my $cli = shift;

  my $d = new Dobby::DB;
  if (not $d->database_started) {
    print "Error: The database must be running to get a space report.\n";
    return 1;
  }

  my $indent = "  ";

  my $fmt = "%-32s %7s\n";
  printf $fmt, "Tables", "Size";

  my $class = __PACKAGE__;
  my $total = 0;
  for my $ts (sort { $a->{NAME} cmp $b->{NAME} } Dobby::Reporting->table_size_overview($d)) {
    printf $fmt,
      $ts->{NAME}, $class->size_scale($ts->{TOTAL_BYTES});
    $total += $ts->{TOTAL_BYTES};
  }

  printf $fmt, "-" x 32, "-" x 7;
  printf $fmt, "Total", $class->size_scale($total);
}

sub command_reportstats {
  my $cli = shift;

  my $d = new Dobby::DB;
  if (not $d->database_started) {
    print "Error: The database must be running to get a statistics report.\n";
    return 1;
  }

  my $stats = $d->report_database_stats();
  for my $i (sort keys %$stats) {
    print "Tables with $i statistics: $stats->{$i}\n";
    }
}

1;
