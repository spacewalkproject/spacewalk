#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
use English;
use File::Basename qw/basename dirname/;
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
                      -description => "Backup the database instance of Red Hat Satellite",
                      -handler => \&command_backup);
  $cli->register_mode(-command => "restore",
                      -description => "Restore the database instance of Red Hat Satellite from backup",
                      -handler => \&command_restore);
  $cli->register_mode(-command => "verify",
                      -description => "Verify an database instance of Red Hat Satellite backup",
                      -handler => \&command_restore);
  $cli->register_mode(-command => "examine",
                      -description => "Display information about a database instance of Red Hat Satellite backup",
                      -handler => \&command_restore);
  $cli->register_mode(-command => "online-backup",
          -description => "Perform online backup of Red Hat Satellite database (PostgreSQL only)",
          -handler => \&command_pg_online_backup);
}

# returns $file cuted of prefix made from $cut_off_dir
sub cut_off_dir {
  my ($file, $cut_off_dir) = @_;
  $file =~ s/^$cut_off_dir//;
  return $file;
}

sub cut_dir {
  my ($file, $cut_off_dir) = @_;
  return dirname(cut_off_dir($file, $cut_off_dir));
}

sub directory_contents {
  my ($cli, $dir, $cut_off_dir) = @_;
  $cut_off_dir = $dir if not defined $cut_off_dir;

  my @files;
  opendir DIR, $dir or $cli->fatal("opendir $dir: $!");
  my @dir_content = readdir DIR;
  closedir DIR;
  my @without_up_dir = grep {$_ ne '.' and $_ ne '..'} @dir_content;
  foreach my $directory (grep { -d $_ } map { File::Spec->catfile($dir, $_) } @without_up_dir) {
    push @files, directory_contents($cli, $directory, $cut_off_dir);
  }
  push @files, map {[$_, cut_dir($_, $cut_off_dir)]} grep { -f $_ } map { File::Spec->catfile($dir, $_) } @dir_content;

  if (@files) {
    return @files;
  } else { #directory is empty, return directory itself
    return ([$dir, $cut_off_dir]) if ($dir ne $cut_off_dir);
  }
}

sub command_backup {
  my $cli = shift;
  my $command = shift;
  my $backup_dir = shift;
  $cli->usage("TARGET_DIR") unless $backup_dir;

  my $d = new Dobby::DB;

  my $logged_user = getpwuid($>);
  $cli->fatal("Error: $backup_dir is not a writable directory by $logged_user.") unless -d $backup_dir and -w $backup_dir;
  $cli->fatal("Database is running; please stop before running a cold backup.") if $d->instance_state ne 'OFFLINE';

  my $source_dir = $d->data_dir;
  my $backend = PXT::Config->get('db_backend');

  my $log = new Dobby::BackupLog;
  $log->type('cold');
  $log->sid($d->sid);
  $log->start(time);
  $log->base_dir($backup_dir);

  $|++;
  print "Initiating cold backup of database ", $d->sid, "...\n";

  my @files;

  if ($backend eq 'oracle') {
    push @files, [$d->lk_file, '/'];
    push @files, [$d->sp_file, '/'];
  }

  for my $dir ($d->data_dir, $d->archive_log_dir) {
    push @files, directory_contents($cli, $dir, $dir) if ($dir);
  }

  for my $ret (@files) {
    next unless $ret;
    my ($file, $rel_dir) = @{$ret};
    my $file_entry = Dobby::Files->backup_file($rel_dir, $file, $backup_dir);
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

  my $backend = PXT::Config->get('db_backend');
  my $cfg = new PXT::Config("dobby");
  $cli->usage("BACKUP") unless $restore_dir and -e $restore_dir;
  my $restore_log = File::Spec->catfile($restore_dir, "backup-log.dat");

  if ($backend eq 'postgresql' and -f $restore_dir) {
      # online backup dump
      return command_pg_restore($cli, $command, $restore_dir);
  } elsif (not (-r $restore_log)) {
      $cli->fatal("Error: restoration failed, unable to locate $restore_log");
  }

  my $d = new Dobby::DB;
  print "Parsing backup log.\n";
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
    push @existing_files, directory_contents($cli, $d->archive_log_dir) if $d->archive_log_dir;
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

  my $intended_username = $cfg->get("${backend}_user");
  my ($username, undef, $uid, $gid) = getpwnam($intended_username);
  for my $file_entry (@{$log->cold_files}) {
    # to and from reverse since their names come from the backup
    # script itself.

    my ($src, $dst) = ($file_entry->to, $file_entry->from);
    if ($log->base_dir) {
      $src = File::Spec->catfile($restore_dir, cut_off_dir($src, $log->base_dir));
    } else { # old backups (prior spacewalk 1.8) do not have basedir and assume all in one dir
      $src = File::Spec->catfile($restore_dir, basename($src));
    }
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
        $digest = eval { Dobby::Files->gunzip_copy($src, $tmpdst, $uid, $gid) };
        if (not defined $digest and $@) {
          $err_msg = $@;
        }
      }

      $seen_files{+$dst} = 1;
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
        system("/sbin/restorecon", $entry->[1]);

      }
      print "done.\n";

      # now, remove any archive logs that were not actually restored
      # in the backup set.  if we've seen it before, then we overwrote
      # it, so the contents are correct.
      print "Removing unnecessary files... ";
      for my $ret (@existing_files) {
        next unless $ret;
        my ($file, $rel_dir) = @{$ret};
        next if exists $seen_files{+$file};

        if (-d $file) {
          rmdir $file or warn "Error removing $file: $!";
        } else {
          unlink $file or warn "Error unlinking $file: $!";
        }
      }
      print "done.\n";

      print "Restoring empty directories... ";
      if ($log->cold_dirs) {
        for my $dir_entry (@{$log->cold_dirs}) {
          if (my @dirs = File::Path::mkpath($dir_entry->from, 0, 0700)) {
            chown $uid, $gid, @dirs;
          }
        }
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

sub command_pg_online_backup {
  my ($cli, $command, $file) = @_;
  $cli->usage("FILE") unless $file;

  my $backup_dir = dirname $file;

  my $backend = PXT::Config->get('db_backend');
  $cli->fatal("Error: This backup method works only with PostgreSQL.") unless ($backend eq 'postgresql');
  my $cfg = new PXT::Config("dobby");
  my @rec = getpwnam($cfg->get("postgresql_user"));
  $EUID = $rec[2];
  $UID = $rec[2];
  $cli->fatal("Error: $backup_dir is not a writable directory for user $rec[0].") unless -d $backup_dir and -w $backup_dir;
  $cli->fatal("Error: Backup file $file already exists in $file.") if -f $file;

  print "Backing up to file $file.\n";
  my $ret = system(@{Dobby::CLI::MiscCommands::pg_version('pg_dump')}, "--blobs", "--clean", "-Fc", "-v", "-Z7", "--file=$file", PXT::Config->get('db_name'));
  print "Backup complete.\n";
  return $ret;
}

sub command_pg_restore {
  my ($cli, $command, $file) = @_;
  $cli->usage("FILE") unless $file;

  $cli->fatal("Error: restoration failed, unable to locate $file") unless -r $file;

  my $backend = PXT::Config->get('db_backend');
  $cli->fatal("Error: This backup method works only with PostgreSQL.") unless ($backend eq 'postgresql');

  if ($command eq 'examine') {
      my $restore_command = join(' ', @{Dobby::CLI::MiscCommands::pg_version('pg_restore')}, '-l', $file);
      my @info = qx{$restore_command};
      @info = grep {m/^;  /} @info;
      print @info;
      return $?;
  } elsif ($command eq 'verify') {
      $cli->fatal("Error: Backup verification is available only for cold backups.");
      return 1;
  }

  my $cfg = new PXT::Config("dobby");
  my @rec = getpwnam($cfg->get("postgresql_user"));
  $EUID = $rec[2];
  $UID = $rec[2];
  $cli->fatal("Error: file $file is not readable by user $rec[0]") unless -r $file;

  my $service_status = system('service ' . Dobby::CLI::MiscCommands::pg_version('service') . ' status >/dev/null 2>&1');
  $cli->fatal("PostgreSQL database is not running.\n"
             ."Run 'service " . Dobby::CLI::MiscCommands::pg_version('service') . " start' to start it.") unless $service_status == 0;

  my $user = PXT::Config->get("db_user");
  my $password = PXT::Config->get("db_password");
  my $schema = PXT::Config->get("db_name");
  my $dsn = "dbi:Pg:dbname=$schema";
  my $dbh = RHN::DB->direct_connect($dsn);

  no warnings 'redefine';
  sub Spacewalk::Setup::system_debug {
     system @_;
  }

  my $is_active = (Dobby::Reporting->active_sessions_postgresql($dbh, $schema) > 1);
  if ($is_active) {
      $cli->fatal("There are running spacewalk services which are using database.\n"
                . "Run 'spacewalk-service --exclude=" . Dobby::CLI::MiscCommands::pg_version('service') . " stop' to stop them.");
      exit 1;
  }

  {
    my @schemas = ('rpm', 'rhn_exception', 'rhn_config', 'rhn_server', 'rhn_entitlements', 'rhn_bel',
                   'rhn_cache', 'rhn_channel', 'rhn_config_channel', 'rhn_org', 'rhn_user', 'logging', 'public');

    local $dbh->{RaiseError} = 0;
    local $dbh->{PrintError} = 1;
    local $dbh->{PrintWarn} = 0;
    local $dbh->{AutoCommit} = 1;

    foreach my $schema (@schemas) {
      $dbh->do("drop schema if exists $schema cascade;");
    }
    $dbh->do("create schema public authorization postgres;");
  }

  system(@{Dobby::CLI::MiscCommands::pg_version('droplang')}, 'plpgsql', PXT::Config->get('db_name'));
  system(@{Dobby::CLI::MiscCommands::pg_version('droplang'), 'pltclu', PXT::Config->get('db_name'));

  print "** Restoring from file $file.\n";
  my $ret = system(@{Dobby::CLI::MiscCommands::pg_version('pg_restore')}, "-Fc", "--jobs=2", "--dbname=".PXT::Config->get('db_name'), $file );
  print "Restoration complete.\n";
  return $ret;
}

1;
