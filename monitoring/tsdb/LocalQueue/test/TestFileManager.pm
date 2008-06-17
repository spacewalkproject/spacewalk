package NOCpulse::TSDB::LocalQueue::test::TestFileManager;

use strict;

use File::stat;
use File::Basename;
use File::Spec;
use Error;

use NOCpulse::TSDB::LocalQueue::File;
use NOCpulse::TSDB::LocalQueue::FileManager;
use NOCpulse::TSDB::LocalQueue::test::Enqueuer;

use base qw(Test::Unit::TestCase);

my $tmpdir = $ENV{TMPDIR} || 'tmp';
my $DIR    = "$tmpdir/tsdbq";

$Error::Debug = 1;

sub set_up {
    my $self = shift;

    # Blitz file positions.
    unlink "$DIR/" . NOCpulse::TSDB::LocalQueue::FileManager::MARK_FILE;

    $self->{mgr} = NOCpulse::TSDB::LocalQueue::FileManager->new(directory => $DIR);
    $self->cleanout();
}

sub tear_down {
    my $self = shift;

    foreach my $pid (@{$self->{kids}}) {
        waitpid($pid, 0);
    }
    $self->cleanout();
}

sub cleanout {
    my $self = shift;

    return unless -d $DIR;

    $self->{mgr}->scan_directory();
    foreach my $file ($self->{mgr}->current_file_values, $self->{mgr}->old_file_values) {
        $file->delete();
    }
    $self->{mgr}->scan_directory();
    my $ncurr = scalar($self->{mgr}->current_file_values);
    my $nold = scalar($self->{mgr}->old_file_values);
    $self->assert($ncurr == 0, "Scan of cleaned directory returns current files: $ncurr");
    $self->assert($nold == 0, "Scan of cleaned directory returns old files: $ncurr");
}

sub test_scan {
    my $self = shift;

    my $num_kids = 3;
    $self->fork_enqueuers($num_kids, '--live_secs' => 5, '--sleep_secs' => 1);
    sleep(1);

    $self->{mgr}->scan_directory();
    my @current_files = $self->{mgr}->current_file_keys();
    $self->assert(scalar(@current_files) == $num_kids,
                  "Wrong current file count: expected $num_kids, got " .
                  scalar(@current_files), " = ", join(', ', @current_files));
    my @old_files = $self->{mgr}->old_file_keys();
    $self->assert(scalar(@old_files) == 0, "Wrong old file count: Expected 0, got: " .
                  join(', ', @old_files));

}

# Simulates a crashed writer to verify that its current link is ignored and deleted.
sub test_crash {
    my $self = shift;

    $self->{kids} = [];
    my $kid = $self->fork_enqueuer('--live_secs' => 1);
    waitpid($kid, 0);

    $self->{mgr}->scan_directory();
    my @current_files = $self->{mgr}->current_file_keys();
    $self->assert(scalar(@current_files) == 0,
                  "Got current files after writer died " .
                  scalar(@current_files), " = ", join(', ', @current_files));
    my @old_files = $self->{mgr}->old_file_keys();
    $self->assert(scalar(@old_files) == 1, "Wrong old file count: Expected 1, got: " .
                  join(', ', @old_files));

}

sub test_read_current {
    my $self = shift;

    my $lines_per_kid = 20;
    my $num_kids = 3;
    $self->fork_enqueuers($num_kids,
                          '--write_lines' => $lines_per_kid,
                          '--sleep_secs'  => 0);
    sleep(1);

    $self->{mgr}->scan_directory();

    my @lines = ();
    while (1) {
        my @results = $self->{mgr}->read_current_to_end(0.75);
        push(@lines, @results);
        last if scalar(@results) == 0;
    }
    $self->assert(scalar(@lines) == $lines_per_kid * $num_kids,
                  "Line count: Expected ", $lines_per_kid * $num_kids, ", got ", 
                  scalar(@lines));
}

sub test_mark {
    my $self = shift;

    my $lines_per_kid = 20;
    my $num_kids = 3;
    $self->fork_enqueuers($num_kids,
                          '--write_lines' => $lines_per_kid,
                          '--sleep_secs'  => 0);
    sleep(1);

    $self->{mgr}->scan_directory();

    my @current = $self->{mgr}->select_current(0.5);
    foreach my $file (@current) {
        my $pos = $self->{mgr}->file_position($file->hash_key);
        $self->{mgr}->read_to_end($file);
        my $newpos = $self->{mgr}->file_position($file->hash_key);
        $self->assert($pos < $newpos, "Position not moved after read: was $pos, now $newpos");
    }
}

sub test_read_old {
    my $self = shift;

    my $lines_per_kid = 20;

    my $num_kids = 3;
    $self->fork_enqueuers($num_kids,
                          '--write_lines' => $lines_per_kid,
                          '--sleep_secs'  => 0);
    foreach my $pid (@{$self->{kids}}) {
        waitpid($pid, 0);
    }

    $self->{mgr}->scan_directory();

    my @current_files = $self->{mgr}->current_file_keys();
    $self->assert(scalar(@current_files) == 0,
                  "Have current files after kids died: " .
                  scalar(@current_files), " = ", join(', ', @current_files));

    my @old_files = $self->{mgr}->old_file_keys();
    $self->assert(scalar(@old_files) == $num_kids,
                  "Wrong old file count: " .
                  scalar(@old_files), " = ", join(', ', @old_files));

    my ($file, @lines, $line_count);

    # Read the newest file in two chunks.
    $file = $self->{mgr}->most_recent_old_file();

    $line_count = 8;
    @lines = $self->{mgr}->read_old_file($file, $line_count);

    $self->assert(scalar(@lines) == $line_count,
                  "Line count mismatch: Expected $line_count, got ",
                  scalar(@lines));
    $self->assert($self->{mgr}->old_file_exists($file->hash_key),
                  "File ", $file->basename, " removed from list prematurely");

    $line_count = 50;
    my $expect = 12;  # 20 written - 8 read before
    @lines = $self->{mgr}->read_old_file($file, $line_count);
    $self->assert(scalar(@lines) == $expect,
                  "Line count mismatch: Expected $expect, got ",
                  scalar(@lines));
    $self->assert(! $self->{mgr}->old_file_exists($file->hash_key),
                  "File ", $file->basename, " not removed from list");

    # Check that fully-read old file got archived.
    $self->assert(-e $self->{mgr}->archive_directory . "/" . $file->basename,
                  "File ", $file->basename, " not archived");
}

sub fork_enqueuers {
    my ($self, $child_count, %args) = @_;

    $self->{kids} = [];
    foreach (0..$child_count-1) {
        push(@{$self->{kids}}, $self->fork_enqueuer(%args));
    }
}

sub fork_enqueuer {
    my ($self, @enqueuer_args) = @_;

    my $logopt = '';
    while (my ($k, $v) = each %{NOCpulse::Log::LogManager->instance->_namespace()}) {
        $logopt .= "$k=$v ";
    }
    push(@enqueuer_args, '--log' => $logopt);

    my $pid;
    if ($pid = fork()) {
        # Parent
        return $pid;
    } elsif (defined($pid)) {
        # Child
        NOCpulse::TSDB::LocalQueue::test::Enqueuer::run(@enqueuer_args, dir => "$DIR/queue")
            or die "$$: Cannot start enqueuer: $!";
        exit;
    } else {
        die "Cannot fork: $!\n";
    }
}

1;
