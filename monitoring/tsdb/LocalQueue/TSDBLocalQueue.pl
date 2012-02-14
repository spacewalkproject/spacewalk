#!/usr/bin/perl

use strict;

my %stat_cache;

use Getopt::Long;
use Error qw(:try);
use POSIX qw(strftime);

use NOCpulse::Utils::Error;
use NOCpulse::Database;
use NOCpulse::TSDB;
use NOCpulse::TSDB::LocalQueue::FileManager;
use NOCpulse::Log::Logger;

# Globals
use constant SCAN_INTERVAL      => 10;
use constant NO_FILES_SLEEP     => 1;
use constant NO_DATA_SLEEP      => 1;
use constant MISSING_DIRS_SLEEP => 60 * 5;

my $cfg = NOCpulse::Config->new();
my $QUEUE_DIR  = $cfg->get('TSDBLocalQueue', 'local_queue_dir');
my $LOG_FILE   = $cfg->get('TSDBLocalQueue', 'daemon_log_file')  || \*STDOUT;
my $LOG_CONFIG = $cfg->get('TSDBLocalQueue', 'daemon_log_config');
my $OLD_READ_SECONDS = $cfg->get('TSDBLocalQueue', 'read_old_file_seconds') || 3;
my $OLD_READ_LINES   = $cfg->get('TSDBLocalQueue', 'read_old_file_lines')   || 250;

my $logopt = {};
my $UNUSED_OPTION;
GetOptions('log=s%'    => $logopt,
           'logfile=s' => \$LOG_FILE,
           'dir=s'     => \$QUEUE_DIR,
           'bdbdir=s'  => \$UNUSED_OPTION);

my $FILE_DIR = File::Spec->catfile($QUEUE_DIR,
    NOCpulse::TSDB::LocalQueue::File::QUEUE_FILE_DIR);
my $ARCHIVE_DIR = File::Spec->catfile($QUEUE_DIR,
    NOCpulse::TSDB::LocalQueue::File::ARCHIVE_FILE_DIR);
my $FAILED_POINTS_DIR = File::Spec->catfile($QUEUE_DIR,
    NOCpulse::TSDB::LocalQueue::File::FAILED_POINTS_DIR);

# A LocalQueue::File holding points that could not be written to BDB, if any
my $FAILED_POINTS_FILE;

my ($Log, $ErrorOut) = setup_logging();

my $queue_manager = NOCpulse::TSDB::LocalQueue::FileManager->new(directory => $QUEUE_DIR);
my $odb = NOCpulse::Database->new(type => "time_series_data");

print_startup_message();

verify_dirs_exist();

# Last time the queue directory was read
my $last_scan_time = -1;

# For printing statistics
my $current_inserted = 0;
my $old_inserted     = 0;

#
# Main daemon loop
#
while (1) {
    my $now = time();

    # Rescan the directory periodically.
    if ($last_scan_time < 0 || $last_scan_time + SCAN_INTERVAL <= $now) {
        try {
            verify_dirs_exist();

            $queue_manager->scan_directory();

            if ($last_scan_time > 0) {
                my $total_inserted = $current_inserted + $old_inserted;
                my $interval = $now - $last_scan_time;
                $Log->log(1, "Inserts: $current_inserted current + ",
                          "$old_inserted old = $total_inserted in ",
                          "$interval seconds, ",
                          sprintf("%0.2f", $total_inserted / $interval),
                          " inserts/second\n");
                $current_inserted = $old_inserted = 0;
            }

            $last_scan_time = $now;
            $Log->log(1, "Rescanned directory: ", 
                      scalar(@{$queue_manager->current_file_keys}), " current, ",
                      scalar(@{$queue_manager->old_file_keys}), " old\n");
        } otherwise {
            my $err = shift;
            $ErrorOut->print("Problem scanning directory: $err\n");
        };
    }

    $Log->log(3, "Reading current files\n");
    try {
        my @lines = ();
        my $have_more = 1;
        while ($have_more) {
            my @read_result = $queue_manager->read_current_to_end(0.75);
            push(@lines, @read_result);
            $have_more = scalar(@read_result) > 0;
        }
        my $count = scalar(@lines);
        if ($count > 0) {
            $Log->log(2, "Inserting $count current points\n");
            $Log->flush();
            insert_time_series($queue_manager, $odb, \@lines);
            $Log->log(2, "Done\n");
            $current_inserted += $count;
            undef @lines;
        }
    } otherwise {
        my $err = shift;
        $ErrorOut->print("Problem reading current files: $err\n");
    };

    # Read an old file for a bounded period and number of lines
    my $start = time();
    my $until = $start + $OLD_READ_SECONDS;
    my $prev_file;

    my $old_file = $queue_manager->most_recent_old_file();
    my $have_more = 1;

    while (time() <= $until && $old_file && $have_more) {
        try {
            $Log->log(2, "Reading old file ", $old_file->basename, "\n")
              unless $prev_file eq $old_file->basename;
            $prev_file = $old_file->basename;
            my @lines = $queue_manager->read_old_file($old_file, $OLD_READ_LINES);
            my $count = scalar(@lines);
            if ($count > 0) {
                $Log->log(2, "Inserting $count old points\n");
                $Log->flush();
                insert_time_series($queue_manager, $odb, \@lines);
                $Log->log(2, "Done\n");
                $old_inserted += $count;
            } else {
                $have_more = 0;
            }
            $old_file = $queue_manager->most_recent_old_file();

        } otherwise {
            my $err = shift;
            $ErrorOut->print("Problem reading old files: ", $err, "\n");
        };
    }

    # This loop serves to throttle the process.  We watch for changes in the
    # queue file directory.  If there are no changes, we pause for 0.01 seconds, and
    # repeat the loop, logging whatever changed.

    while(1) {
        my $changed = 0;
        my $queue_dir = $queue_manager->queue_file_directory;
        opendir DIR, $queue_dir
          or die "opendir: $!";

        my @files = map { "$queue_dir/$_" } grep { /^[^.]/ } readdir DIR;
        closedir DIR;
        push @files, $queue_dir;

        for my $file (@files) {
            my $last_stat = $stat_cache{$file} || 0;
            my $now_stat = (stat $file)[9];

            if ($last_stat != $now_stat) {
              $stat_cache{$file} = $now_stat;
              $changed = 1;
              $Log->log(2, "File changed ($last_stat, $now_stat): $file\n");
            }
        }

        last if $changed;

        use Time::HiRes;
        Time::HiRes::sleep(0.01);
    }

    # If there are no files, nod off for a while.
    if (scalar(@{$queue_manager->current_file_keys}) == 0 
        && scalar(@{$queue_manager->old_file_keys}) == 0) {

        $Log->log(1, "No current or old files, sleep ", NO_FILES_SLEEP, "\n");
        $Log->flush();
        sleep(NO_FILES_SLEEP);

    } elsif ($current_inserted == 0) {

      # Don't kill the box
      $Log->log(1, "No current data, sleep ", NO_DATA_SLEEP, "\n");
      $Log->flush();
      sleep(NO_DATA_SLEEP);
      
    }
    $Log->flush();
}

#
# End of the main daemon loop
#


sub insert_time_series {
    my ($queue_manager, $odb, $line_arr) = @_;

    my $n = 0;

    foreach my $line (@$line_arr) {
	my ($oid, $t, $v) = split /,/, $line;
	if ($oid and $t and ($t =~ /^[\d\.]+$/)) {
            if ($Log->loggable(4)) {
                ++$n;
                $Log->log(4, "Insert #$n $oid, ", strftime("%m/%d %H:%M:%S", gmtime($t)),
                          ", $v into oracle\n");
            }
	    unless ($odb->insert($oid, $t, $v)) {
                # Write the failed point to an exceptions file.
                unless ($FAILED_POINTS_FILE) {
                    $FAILED_POINTS_FILE = NOCpulse::TSDB::LocalQueue::File->new(
                       directory            => $QUEUE_DIR,
                       queue_file_directory => $FAILED_POINTS_DIR);
                    $FAILED_POINTS_FILE->create();
                }
                $FAILED_POINTS_FILE->append($oid, $t, $v);
            }
        } else {
            $ErrorOut->print("Data point not formatted as oid,time,value: $line\n");
        }
    }

    $queue_manager->save_positions();
}


sub print_startup_message {
    my $logconfig = '';
    while (my ($k, $v) = each %{NOCpulse::Log::LogManager->instance->_namespace()}) {
        $logconfig .= "$k=$v ";
    }
    $Log->log(1, '*' x 75, "\n");
    $Log->log(1, "Starting TSDB local queue daemon\n");
    $Log->log(1, "Queue files: $QUEUE_DIR\n");
    $Log->log(1, "Logging to:  $LOG_FILE\n");
    $Log->log(1, "Log level:   $logconfig\n");
    $Log->log(1, '*' x 75, "\n");
    $Log->flush();

    $ErrorOut->print("Starting TSDB local queue daemon\n");
    $ErrorOut->flush();
}

# Sanity check the various directories. Gritches if there are problems,
# then sleeps for MISSING_DIRS_SLEEP, and tries again. Does not return
# until all directories exist and can be traversed.
sub verify_dirs_exist {
    while (1) {
        my @bad_dirs = ();

        unless (verify_dir($QUEUE_DIR, 'Local queue directory', \@bad_dirs)) {
            verify_dir($FILE_DIR, 'Queue file directory', \@bad_dirs);
            verify_dir($ARCHIVE_DIR, 'Archive directory', \@bad_dirs);
            verify_dir($FAILED_POINTS_DIR, 'Failed points directory', \@bad_dirs);
        }
        $Log->flush();
        last unless scalar(@bad_dirs) > 0;
        my $msg = 'DIRECTORY PROBLEM: ' . join('; ', @bad_dirs);
        #XXX Gritch...
        $ErrorOut->print('***** ', $msg, "\n");
        $ErrorOut->print("Will retry in ", MISSING_DIRS_SLEEP / 60, " minutes\n");
        $ErrorOut->flush();
        $Log->log(1, "$msg\n");
        $Log->flush();
        sleep(MISSING_DIRS_SLEEP);
    }
}

sub verify_dir {
    my ($dir, $descr, $bad_dirs_arr) = @_;
    my $found    = -d $dir;
    my $writeable = -w $dir;
    $Log->log(2, "Directory $dir: found $found, writeable $writeable\n");
    unless ($found && $writeable) {
        push(@$bad_dirs_arr, "$descr $dir not " . (!$found ? "found" : "accessible"));
        return 0;
    }
    return 1;
}

# Set up logging. The TSDBLocalQueue/daemon_log_config property should be a string
# representing a Perl hash, e.g.
# 'local_queue' => 2, 'NOCpulse::TSDB::LocalQueue::FileManager' => 4
sub setup_logging {
    NOCpulse::Log::LogManager->instance()->stream(FILE       => $LOG_FILE,
                                                  APPEND     => 1,
                                                  TIMESTAMPS => 1);
    NOCpulse::Log::LogManager->instance->configure(eval($LOG_CONFIG)) if $LOG_CONFIG;
    # The --log argument from the command line overrides the NOCpulse.ini setting.
    NOCpulse::Log::LogManager->instance->configure(%{$logopt}) if scalar(keys(%{$logopt}));

    my $Log = NOCpulse::Log::Logger->new('local_queue');
    # Don't prefix messages with the caller because this is the top call level.
    $Log->show_method(0);

    # Error messages go to STDERR.
    my $ErrorOut = NOCpulse::Debug->new();
    $ErrorOut->addstream(FILE => \*STDERR, TIMESTAMPS => 1);

    return $Log, $ErrorOut;
}
