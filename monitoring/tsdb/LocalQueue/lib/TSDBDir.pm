################
package TSDBDir;
################

use strict;

use vars qw($position_hash);  # for statfile loading (counting datapoints)

use TSDBLogFile;
use IO::File;

use Class::MethodMaker 
  new_with_init  => 'new',
  get_set        => [qw(
    path
    queue
    archive
    failed
    logfile
    statfile
    qfileinfo
  )],
  ;

# Set up for logging
use NOCpulse::Log::LogManager;
use NOCpulse::Log::Logger;

NOCpulse::Log::LogManager->instance->stream(FILE => \*STDOUT);
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

##########
sub init {
##########
  my $self = shift;
  my $path = shift;

  # Record dir data
  $self->path($path);
  $self->queue("$path/queue");
  $self->archive("$path/archive");
  $self->failed("$path/failed");
  $self->statfile("$path/queuefile.positions");

  # Record an empty queuefile cache
  $self->qfileinfo({});

  # Create a logfile object
  my $logfile = "$path/TSDBLocalQueue.log";
  $self->logfile(TSDBLogFile->new($logfile));

}

################
sub queuefiles {
################
  my $self = shift;

  opendir(DIR, $self->queue) or die "Couldn't open queue dir: $!";
  my @files = map(
                join('/', $self->queue , $_),
                grep(
                  !/^\.+$|^current/, readdir(DIR)
                )
              );
  closedir(DIR);

  return @files;

}


#######################
sub queued_datapoints {
#######################
  my $self = shift;
  my $queued;

  my $oldinfo = $self->qfileinfo;
  my $newinfo = {};

  $Log->log(2, "Counting datapoints in ", $self->queue, "\n");

  my $statfile = $self->statfile;
  if (-f $statfile) {
    do($statfile) or die "Couldn't do $statfile: $!";
  }

  my @queuefiles = $self->queuefiles;

  foreach my $queuefile (@queuefiles) {

    my $shortname = $queuefile; $shortname =~ s,^.*/,,;

    $Log->log(3, "  - queuefile $shortname\n");

    # Use cached data if the file hasn't changed and isn't
    # actively being dequeued.
    if (exists($oldinfo->{$queuefile}) and
        ! exists($position_hash->{$queuefile}) and
        (stat($queuefile))[7] == $oldinfo->{$queuefile}->{'size'}) {

      my $dp = $oldinfo->{$queuefile}->{'datapoints'};
      $Log->log(3, "    $dp uncommitted datapoints (cached)\n");

      $newinfo->{$queuefile} = $oldinfo->{$queuefile};

      $queued += $dp;

    } else {

      # Count the lines
      local * FILE;
      unless (open(FILE, '<', $queuefile)) {
        warn "Couldn't open $queuefile: $!";
        next;
      }

      # Handle partially-read queuefiles correctly
      if (exists($position_hash->{$queuefile})) {
        $Log->log(3, "    Live datafile\n");
        my $position = $position_hash->{$queuefile};
        seek(FILE, $position, 0) or die "Couldn't seek: $!";
      } else {
        $Log->log(3, "    Old datafile\n");
      }

      # Spin through the file ($. does the line counting)
      while (<FILE>) {
      }

      $Log->log(3, "    $. uncommitted datapoints\n");

      $newinfo->{$queuefile}->{'datapoints'} = $.;
      $newinfo->{$queuefile}->{'size'} = (stat($queuefile))[7];

      close(FILE);

      $queued += $newinfo->{$queuefile}->{'datapoints'};

    }
  }

  undef($position_hash);

  $self->qfileinfo($newinfo);

  return $queued;

}


1;
