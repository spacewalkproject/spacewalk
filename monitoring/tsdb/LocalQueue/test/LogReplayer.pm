package NOCpulse::TSDB::LocalQueue::test::LogReplayer;

# Reads a TSDB apache log and writes the same data points to local queue files.

use strict;

use Getopt::Long;
use IO::File;
use URI::Escape;
use Date::Manip;

use NOCpulse::TSDB::LocalQueue::File;
use NOCpulse::Log::LogManager;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub run {
    @ARGV = @_;

    my $tmpdir = $ENV{TMPDIR} || '/tmp';

    my $read_log    = undef;
    my $write_lines = 1000;
    my $rotate_kb   = 100;
    my $dir         = "$tmpdir/tsdbq";
    my $log         = {};
    my $show_help   = 0;

    Getopt::Long::Configure('prefix_pattern=--|-');
    GetOptions('read_log=s'    => \$read_log,
               'write_lines=i' => \$write_lines,
               'rotate_kb=i'   => \$rotate_kb,
               'dir=s'         => \$dir,
               'log=s%'        => $log,
               'help'          => \$show_help)
      or bail();

    $show_help and bail();

    NOCpulse::Log::LogManager->instance->configure(%{$log});

    $Log->log(1, "Read $read_log, read ", $write_lines == 0 ? "all" : "$write_lines",
              " lines, rotate at $rotate_kb, write to directory $dir\n");

    my $qfile = NOCpulse::TSDB::LocalQueue::File->new(directory      => $dir,
                                                      rotate_size_kb => $rotate_kb);
    $qfile->create();
    $Log->log(1, "Writing to ", $qfile->full_path, "\n");

    my $logfile = IO::File->new($read_log, "r") or die "Cannot open $read_log: $!";

    my $prev_time;
    my $n = 0;
    while (my $line = <$logfile>) {
        chomp $line;
        next unless $line =~ /fn=batch_insert/;
        # Get the date/time from the first bracketed field, and
        # sleep for the period between this
        $line =~ /\[([^\]]+)\]/;
        my $line_time = ParseDateString($1);
        if ($prev_time) {
            my $sleep = Delta_Format(DateCalc($prev_time, $line_time), 1, "%st");
            sleep($sleep);
        }
        $prev_time = $line_time;

        my @points = split(/\n/, uri_unescape($line));
        foreach my $point (@points[1 .. scalar(@points)-1]) {
            my ($oid, $time, $value) = split(/\t/, $point);
            $qfile->append($oid, $time, $value);
        }
        ++$n;
        last if $write_lines > 0 && $n >= $write_lines;
    }
    $logfile->close();
    return 1;
}

sub usage {
    return <<END
Usage: replaylog.pl read_log=<path> write_lines=<n> rotate_kb=<kb>
                    dir=<path> log=<logspec>
  write_lines how many lines to write before quitting
  rotate_kb   size after which file gets rotated (default 10 kb)
  log         Logging spec, e.g., all=4
  dir         queue directory (default \$TMPDIR/tsdbq)
END
}

sub bail {
    print usage();
    exit(1);
}

1;
