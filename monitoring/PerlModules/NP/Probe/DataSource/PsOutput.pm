package NOCpulse::Probe::DataSource::PsEntry;

# Information for a single process table entry
use strict;

use Data::Dumper;

use Class::MethodMaker
  get_set =>
  [qw(
       pid
       ppid
       vsz
       rss
       cpu
       threads
       state
       args
     )],
  counter =>
  [qw(
       nchildren
     )],
  new => 'new',
  ;

package NOCpulse::Probe::DataSource::PsOutput;

use strict;

use Class::MethodMaker
  get_set =>
  [qw(
      process_table
     )],
  new_with_init => 'new',
  ;

# Parses ps output. 

sub init {
    my ($self, $ps_output) = @_;

    return unless(defined($ps_output));

    my @lines = split(/\n/, $ps_output);
    my $title = shift(@lines);     # Title line
    my %ptable;
    foreach my $line (@lines) {
        my($pid, $ppid, $vsz, $rss, $cpu, $threads, $state, $args);

	if ($title =~ /NLWP/) {
	    # Solaris - 8 fields
            ($pid, $ppid, $vsz, $rss, $cpu, $threads, $state, $args) =
	                                      split(' ', $line, 8);
	} else {
	    # Everybody else - 7 fields
            ($pid, $ppid, $vsz, $rss, $cpu, $state, $args) =
	                                      split(' ', $line, 7);
	}

	# Convert cpu time to miliseconds
	my $ms;
	my @tf = reverse(split(/:/, $cpu));
	$ms = ($tf[2] * 3600 + $tf[1] * 60 + $tf[0]) * 1000;

	my $ps_entry = NOCpulse::Probe::DataSource::PsEntry->new();
	$ps_entry->pid(     $pid     );
	$ps_entry->ppid(    $ppid    );
	$ps_entry->vsz(     $vsz     );
	$ps_entry->rss(     $rss     );
	$ps_entry->cpu(     $ms      );
	$ps_entry->threads( $threads );
	$ps_entry->state(   $state   );
	$ps_entry->args(    $args    );
        $ptable{$pid} = $ps_entry;
    }

    # Count the number of immediate children
    while (my($pid, $proc) = each %ptable) {
      $ptable{$proc->ppid}->nchildren_incr() if ($ptable{$proc->ppid});
    }

    # Save the process table
    $self->process_table(\%ptable);

    return $self;
}


sub process_by_pid {
    my $self = shift;
    my $pid  = shift;

    return $self->process_table->{$pid};
}

sub pgleader_by_pid {
    my $self = shift;
    my $pid  = shift;
    my $pgleader = $pid;

    return () unless ($self->process_table->{$pid});

    # Walk up the family tree until we see ppid == 1 
    # EDGE CASE:  for pid = 1, force pgleader = 1
    while (1) {
	my $ppid = $self->process_table->{$pid}->ppid() || 1;
	last if ($ppid == 1);
	$pid = $ppid;
    }

    return $self->process_table->{$pid};
}

sub processes_by_match {
    my $self = shift;
    my $pat  = shift;

    # Walk through the process table looking for processes whose
    # commands match $pat.  Return all matching processes (in no
    # particular order).
    my($pid, $proc, @matches);
    while (($pid, $proc) = each %{$self->process_table}) {
      push(@matches, $proc) if ($proc->args() =~ /$pat/);
    }

    return @matches;
}

sub pgleaders_by_match {
    my $self = shift;
    my $pat  = shift;

    # Get all processes that match $pat, then return their
    # process group leaders.
    my @procs = $self->processes_by_match($pat);

    my %pgleader;
    foreach my $proc (@procs) {
      my $pgleader = $self->pgleader_by_pid($proc->pid);
      $pgleader{$pgleader->pid} = $pgleader;
    }

    return values %pgleader;
}


1;

