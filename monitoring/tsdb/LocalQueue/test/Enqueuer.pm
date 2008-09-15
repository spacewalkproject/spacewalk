package NOCpulse::TSDB::LocalQueue::test::Enqueuer;

# Writes some TSDB queue files for use in testing multiple processes.

use strict;

use Getopt::Long;
use NOCpulse::TSDB::LocalQueue::File;
use NOCpulse::Log::LogManager;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub run {
    @ARGV = @_;

    my $tmpdir = $ENV{TMPDIR} || '/tmp';

    my $live_secs   = 30;
    my $write_lines = 0;
    my $sleep_secs  = 0.5;
    my $rotate_kb   = 1;
    my $dir         = "$tmpdir/tsdbq";
    my $log         = {};
    my $show_help   = 0;

    Getopt::Long::Configure('prefix_pattern=--|-');
    GetOptions('live_secs=i'   => \$live_secs,
               'write_lines=i' => \$write_lines,
               'sleep_secs=f'  => \$sleep_secs,
               'rotate_kb=i'   => \$rotate_kb,
               'dir=s'         => \$dir,
               'log=s%'        => $log,
               'help'          => \$show_help)
      or bail();

    $show_help and bail();

    NOCpulse::Log::LogManager->instance->configure(%{$log});

    $Log->log(1, "Run for $live_secs, write $write_lines lines, ",
              "sleep $sleep_secs between writes, rotate at $rotate_kb, ",
              "write to directory $dir\n");

    my $file = NOCpulse::TSDB::LocalQueue::File->new(directory      => $dir,
                                                     rotate_size_kb => $rotate_kb);
    $file->create();
    $Log->log(1, "Writing to ", $file->full_path, "\n");

    my $start_time = time();
    my $n = 0;
    while (1) {
        $file->append($$ . ":" . $n++ . ":30-23234-load15," . time() . "," . rand());
        last if $write_lines > 0 && $n >= $write_lines;
        select undef, undef, undef, $sleep_secs if $sleep_secs;
        last if (time() - $start_time > $live_secs);
    }
    $file->filehandle->close();
    return 1;
}

sub usage {
    return <<END
Usage: enqueue.pl live_secs=<n> write_lines=<n> sleep_secs=<n> rotate_kb=<kb>
                  dir=<path> log=<logspec>
  live_secs   how long to keep running (default 30 seconds)
  write_lines how many lines to write before quitting
  sleep_secs  how long to sleep between writes (default 1/2 second)
  rotate_kb   size after which file gets rotated (default 1 kb)
  log         Logging spec, e.g., all=4
  dir         queue directory (default \$TMPDIR/tsdbq)
END
}

sub bail {
    print usage();
    exit(1);
}

1;
