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
package Dobby::CLI::MaintCommands;

use Carp;

use Filesys::Df;
use File::Basename;
use Dobby::DB;
use Dobby::CLI::MiscCommands;

sub register_dobby_commands {
  my $class = shift;
  my $cli = shift;

  $cli->register_mode(-command => "extend",
		      -description => "Increase the RHN Oracle Instance tablespace",
		      -handler => \&command_extend);
  $cli->register_mode(-command => "gather-stats",
		      -description => "Gather statistics on RHN Oracle database objects",
		      -handler => \&gather_stats);
  $cli->register_mode(-command => "shrink-segments",
		      -description => "Shrink RHN Oracle database segments",
		      -handler => \&shrink_segments);
}

sub command_extend {
  my $cli = shift;
  my $command = shift;
  my $ts = shift;
  $ts = uc($ts);

  $cli->usage("TABLESPACE") unless $ts;

  my $d = new Dobby::DB;

  if (not $d->database_started) {
    print "Error: The database must be running to extend a tablespace.\n";
    return 1;
  }
    
  my @files = $d->tablespace_datafiles($ts);
  my $f = pop(@files);

  if (!$f) {
    print "Error: Invalid tablespace name '$ts' specified.\n";
    return 1;
  }

  my $file   = $f->{FILENAME};
  my $status = $f->{STATUS};
  my $bytes  = $f->{BYTES};

  #Check here for available space
  my $df = df($d->data_dir, "1024");
  my $available_space = $df->{bavail} * 1024;

  if ($available_space < $bytes) {
    print "Error: Not enough free space to extend tablespace.\n";
    printf "Available: %7s\n", Dobby::CLI::MiscCommands->size_scale($available_space);
    printf "Required : %7s\n", Dobby::CLI::MiscCommands->size_scale($bytes);
    return 1;
  }

  
  print "Extending $ts... ";
  my $fn = next_filename($cli, $file);
  my $size = $bytes / 1024;
  $d->tablespace_extend($ts, $fn, "$size K");
  print "done.\n";

}

sub next_filename {
  my $cli = shift;
  my $fn = shift;
  my $next;

  my $dir  = dirname($fn);
  my $base = basename($fn);
  $base =~ /^(.*)(\.dbf)/;
  my $root = $1;
  my $suffix = $2;
  if ($root =~ /(.*_)(\d+)/) {
    my $seq = $2;
    $seq++;
    $next = sprintf("%s/%s%2.2i%s", $dir, $1, $seq, $suffix);
  }
  else {
    $next = sprintf("%s/%s_%2.2i%s", $dir, $root, 2, $suffix);
  }
  return $next;
}


sub gather_stats {
  my $cli = shift;
  my $command = shift;
  my $pct = shift;

  my $d = new Dobby::DB;

  $pct = 15 if not defined($pct);
  $cli->usage("PERCENT") unless 0 < $pct and $pct <=100;

  if (not $d->database_started) {
    print "Error: The database must be running to gather statistics.\n";
    return 1;
  }
    
  print "Gathering statistics...\n";
  print "WARNING: this may be a very slow process.\n";
  $d->gather_database_stats($pct);
  print "done.\n";

}

sub shrink_segments {
  my $cli = shift;

  my $d = new Dobby::DB;

  if (not $d->database_started) {
    print "Error: The database must be running to shrink segments.\n";
    return 1;
  }

  print "Running segment advisor to find out shrinkable segments...\n";
  print "WARNING: this may be a slow process.\n";
  $d->segadv_runtask();
  my %msg = (
        'AUTO'   => "Shrinking recomended segments...\n",
        'MANUAL' => "Segments in non-shrinkable tablespace...\n",
        );
  my %printed = (
        'AUTO'   => 0,
        'MANUAL' => 0,
        );

  for my $rec (Dobby::Reporting->segadv_recomendations($d)) {
    if (not $printed{$rec->{SEGMENT_SPACE_MANAGEMENT}}) {
        print $msg{$rec->{SEGMENT_SPACE_MANAGEMENT}};
        $printed{$rec->{SEGMENT_SPACE_MANAGEMENT}}++;
    }
    printf "%-32s %7s reclaimable\n", $rec->{SEGMENT_NAME},
           Dobby::CLI::MiscCommands->size_scale($rec->{RECLAIMABLE_SPACE});
    if ($rec->{SEGMENT_SPACE_MANAGEMENT} eq 'AUTO') {
        $d->shrink_segment($rec);
    }
  }

  print "done.\n";
}

1;
