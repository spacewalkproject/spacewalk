########################
package TSDBStatHandler;
########################

use strict;

use TSDBDir;

use Class::MethodMaker 
  new_with_init  => 'new',
  list           => [qw(
    dirs
  )],
  get_set        => [qw(
    vardir
    nqfiles_file
    dqrate_file
    drainers_file
    datapoints_file
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
  my %args = @_;


  # Varfiles directory
  if (! -d $args{'vardir'}) {
    mkdir($args{'vardir'}, 0755) or die "Couldn't mkdir $args{vardir}: $!";
  }
  $self->vardir($args{'vardir'});

  # Varfile locations
  foreach my $stat (qw(nqfiles dqrate drainers datapoints)) {
    my $method = "${stat}_file";
    $self->$method("$args{'vardir'}/$stat");
  }

  # Directories to monitor
  foreach my $dir (@{$args{'dirs'}}) {
    $self->dirs_push(TSDBDir->new($dir));
  }

}


##################
sub update_rates {
##################
  my $self = shift;

  foreach my $dir ($self->dirs) {
    $dir->logfile->update_rate();
  }

}



##########
sub rate {
##########
  my $self = shift;
  my $totalrate;

  foreach my $dir ($self->dirs) {
    my $logfile = $dir->logfile;
    if ($Log->loggable(1)) {
      my $path    = $logfile->path;
      my $rate    = $logfile->rate;
      $Log->log(1, "Rate for $path:  $rate\n");
    }
    $totalrate += $logfile->rate();
  }

  return $totalrate;

}

#################
sub nqueuefiles {
#################
  my $self = shift;
  my $nqueuefiles;

  foreach my $dir ($self->dirs) {
    $nqueuefiles += $dir->queuefiles();
  }

  return $nqueuefiles;

}


#####################
sub active_drainers {
#####################
  my $self = shift;
  my $active;

  foreach my $dir ($self->dirs) {
    if ($dir->logfile->rate() > 0) {
      $active++ 
    }
  }

  return $active;

}

#######################
sub queued_datapoints {
#######################
  my $self = shift;
  
  my $total_queued;

  $Log->log(1, "Counting queued datapoints\n");

  foreach my $dir ($self->dirs) {

    $total_queued += $dir->queued_datapoints;

  }

  $Log->log(1, "Found $total_queued uncommitted datapoints.\n");

  return $total_queued;

}

#################
sub write_stats {
#################
  my $self = shift;

  my %stats = (

    # Number of queue files
    nqfiles    => $self->nqueuefiles,

    # Dequeue rate
    dqrate     => $self->rate,

    # Number of active drainers
    drainers   => $self->active_drainers,

    # Number of uncommitted datapoints
    datapoints => $self->queued_datapoints,

  );

  $Log->log(1, scalar(localtime(time)), "\n");

  foreach my $stat (sort keys %stats) {
    my $method = "${stat}_file";

    local * FILE;
    open(FILE, '>', $self->$method());
    print FILE $stats{$stat}, "\n";
    close(FILE);

    $Log->log(1, sprintf("  %-20s %s\n", "$stat:",   $stats{$stat}));

  }

}



################
sub get_metric {
################
  my $self   = shift;
  my $metric = shift;

  my $method = "${metric}_file";
  my $file   = $self->$method();

  $Log->log(1, "Opening metric file $file\n");

  local * FILE;
  open(FILE, '<', $file) or die "Couldn't open $file: $!";
  chomp(my $metric = <FILE>);
  close(FILE);

  return $metric;

}

1;
