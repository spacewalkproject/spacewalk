#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
package Dobby::CLI::BackupCommands;

use Carp;
use Dobby::Files;
use Dobby::BackupLog;
use File::Basename qw/basename/;
use File::Spec;
use Filesys::Df;
use POSIX;

use Dobby::DB;
use Dobby::Reporting;
use Dobby::CLI::MiscCommands;


sub register_dobby_commands {
  my $class = shift;
  my $cli = shift;

  $cli->register_mode(-command => "backup",
		      -description => "Backup the RHN Oracle Instance",
		      -handler => \&command_backup);
  $cli->register_mode(-command => "restore",
		      -description => "Restore the RHN Oracle Instance from backup",
		      -handler => \&command_restore);
  $cli->register_mode(-command => "verify",
		      -description => "Verify an RHN Oracle Instance backup",
		      -handler => \&command_restore);
  $cli->register_mode(-command => "examine",
		      -description => "Display information about an RHN Oracle Instance backup",
		      -handler => \&command_restore);
}

sub directory_contents {
  my $cli = shift;
  my $dir = shift;

  my @files;
  opendir DIR, $dir or $cli->fatal("opendir $dir: $!");
  push @files, grep { -f $_ } map { File::Spec->catfile($dir, $_) } readdir DIR;
  closedir DIR;

  return @files;
}

sub command_backup {
  my $cli = shift;
  my $command = shift;
  my $backup_dir = shift;
  $cli->usage("TARGET_DIR") unless $backup_dir;

  my $d = new Dobby::DB;

  $cli->fatal("Error: $backup_dir is not a writable directory.") unless -d $backup_dir and -w $backup_dir;
  $cli->fatal("Database is running; please stop before running a cold backup.") if $d->instance_state ne 'OFFLINE';

  my $source_dir = $d->data_dir;

  my $log = new Dobby::BackupLog;
  $log->type('cold');
  $log->sid($d->sid);
  $log->start(time);

  $|++;
  print "Initiating cold backup of database ", $d->sid, "...\n";

  my @files;

  push @files, $d->lk_file;
  push @files, $d->sp_file;

  for my $dir ($d->data_dir, $d->archive_log_dir) {
    push @files, directory_contents($cli, $dir);
  }

  for my $file (@files) {
    my $file_entry = Dobby::Files->backup_file($file, $backup_dir);
    $log->add_cold_file($file_entry);
  }

  $log->finish(time);
  $log->serialize("$backup_dir/backup-log.dat");

  print "Full cold backup complete.\n";

  return 0;
}

sub command_restore {
  my $cli = shift;
  my $command = shift;
  my $restore_dir = shift;

  $cli->usage("BACKUP_DIR") unless $restore_dir and -d $restore_dir;
  my $restore_log = File::Spec->catfile($restore_dir, "backup-log.dat");
  $cli->fatal("Error: restoration failed, unable to locate $restore_log") unless -r $restore_log;

  my $d = new Dobby::DB;
  my $log = Dobby::BackupLog->parse($restore_log);

  if ($log->type ne 'cold') {
    $cli->fatal("Error: backup not a cold backup.");
  }

  if ($command eq 'verify') {
    printf "Verifying backup from %s...\n", scalar localtime $log->start;
  }
  elsif ($command eq 'restore') {
    $cli->fatal("Database is currently running; please stop it before restoring a backup.") if $d->instance_state ne 'OFFLINE';
    printf "Restoring backup from %s...\n", scalar localtime $log->start;
  }
  elsif ($command eq 'examine') {
    printf "Backup made on %s:\n", scalar localtime $log->start;
  }
  else {
    $cli->fatal("unknown subcommand of command_restore");
  }

  my @rename_queue;
  my $error_count;

  my %seen_files;
  my @existing_files;
  if ($command eq 'restore') {
    push @existing_files, directory_contents($cli, $d->data_dir);
    push @existing_files, directory_contents($cli, $d->archive_log_dir);
  }

  my $df = df($d->data_dir, "1024");
  my $available_space = $df->{bavail} * 1024;


  my $required_space = 0;
  for my $file_entry (@{$log->cold_files}) {
    $required_space += $file_entry->original_size;
  }

  if ($command eq 'restore' and $available_space < $required_space) {
    print "Error: Not enough free space for restoration.\n";
    printf "Available: %7s\n", Dobby::CLI::MiscCommands->size_scale($available_space);
    printf "Required : %7s\n", Dobby::CLI::MiscCommands->size_scale($required_space);
    return 1;
  }

  for my $file_entry (@{$log->cold_files}) {
    # to and from reverse since their names come from the backup
    # script itself.

    my ($src, $dst) = ($file_entry->to, $file_entry->from);
    $src = File::Spec->catfile($restore_dir, basename($src));
    my ($digest, $missing);

    printf "  %s", $src;

    my $err_msg;
    $missing++ unless -e $src;

    if ($command eq 'verify') {
      printf "...";
      $digest = Dobby::Files->gunzip_copy($src) unless $missing;
    }
    elsif ($command eq 'restore') {
      # extract to temporary files to be renamed over originals once
      # entire process succeeds.  populate list of pending renames.

      my $tmpdst = $dst . ".tmp";

      printf " -> %s...", $tmpdst;
      if (not $missing) {
	$digest = eval { Dobby::Files->gunzip_copy($src, $tmpdst) };
	if (not defined $digest and $@) {
	  $err_msg = $@;
	}
      }

      $seen_files{+basename($dst)} = 1;
      push @rename_queue, [ $tmpdst, $dst ];
    }
    elsif ($command eq 'examine') {
      # nop, messaging comes in below
    }

    if ($missing) {
      print " (MISSING)\n";
      $error_count++;
    }
    elsif ($err_msg) {
      print "\n\nFatal error: $err_msg";
      $error_count++;
      last;
    }
    elsif (defined $digest and $digest ne $file_entry->digest) {
      printf " done.  (ERROR: checksum mismatch)\n";
      $error_count++;
    }
    else {
      if (defined $digest) {
	print " done.  Checksum verified.\n";
      }
      else {
	print "\n";
      }
    }
  }

  if ($command eq 'restore') {
    if ($error_count) {
      print "Cannot restore database, errors encountered.  Please correct and re-attempt restoration.\n";

      # now remove the .tmp files we made, ignoring errors
      unlink $_->[0] for @rename_queue;
      return 1;
    }
    else {
      print "Extraction and verification complete, renaming files... ";
      for my $entry (@rename_queue) {
	rename $entry->[0] => $entry->[1] or warn "Rename $entry->[0] => $entry->[1] error: $!";
      }
      print "done.\n";

      # now, remove any archive logs that were not actually restored
      # in the backup set.  if we've seen it before, then we overwrote
      # it, so the contents are correct.
      print "Removing unnecessary files... ";
      for my $file (@existing_files) {
	next if exists $seen_files{+basename($file)};

	unlink $file or warn "Error unlinking $file: $!";
      }

      print "done.\n";

      print "Restoration complete, you may now start the database.\n";
    }
  }
  elsif ($command eq 'examine' or $command eq 'verify') {
    if ($error_count) {
      return 1;
    } else {
      return 0;
    }
  }
  return 0;
}

1;
