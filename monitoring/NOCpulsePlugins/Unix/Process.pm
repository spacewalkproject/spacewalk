package Unix::Process;

use strict;
use ProbeMessageCatalog;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $pidfile = $params{'pidFile'};
    my $cpat    = $params{'commandName'};
    my $running = $params{'running'};
    my $run_min = $params{'number_running_min'};
    my $run_max = $params{'number_running_max'};
    my $groups  = $params{'groups'};

    throw NOCpulse::Probe::ConfigError(
	ProbeMessageCatalog->instance->config('pidfile_or_pattern')
    ) unless ($pidfile or $cpat);

    my $command = $args{data_source_factory}->unix_command(%params);

    my $ps_output = $command->ps();

    my @procs;
    if ($pidfile) {
	my $pid      = $command->execute("
          if [ -f $pidfile ]
          then
            if [ -r $pidfile ]
            then
              head -1 $pidfile
            else
              echo CANTREAD
            fi
          else
            echo NOSUCHFILE
          fi");
	chomp($pid);

	if (! $pid) {
	    $result->item_unknown("No PID in PID file $pidfile");
	    return;
        } elsif ($pid =~ /CANTREAD/) {
	    $result->item_unknown("PID file $pidfile is not readable");
	    return;
        } elsif ($pid =~ /NOSUCHFILE/) {
	    $result->item_unknown("PID file $pidfile does not exist");
	    return;
	} elsif ($pid =~ /\D/) {
	    $result->item_unknown(
	      "Cannot determine PID from contents of $pidfile: $pid");
	    return;
	}

	@procs = $ps_output->pgleader_by_pid($pid);

	unless (scalar(@procs)) {
	    $result->item_critical(
	                  "Process $pid (from $pidfile) is not running");
	    return;
	}


    } else {

	# Turn glob pattern into Perl5 regex
	$cpat =~ s/\*/.*/g;
	$cpat =~ s/\?/.?/g;

	# Get procs by match 
	if ($groups eq 'groups') {
	    @procs = $ps_output->pgleaders_by_match($cpat);
	} else {
	    @procs = $ps_output->processes_by_match($cpat);
	}

	unless (scalar(@procs)) {
	    $result->item_critical("No processes found matching '$cpat'");
	    return;
	}

    }

    if ($running) {

	$result->context("Process");

        my $nrunning = scalar(@procs);
	$result->item_thresholded_value('Number running', $nrunning, '%d', 
	    {
	      crit_min => $run_min,
	      crit_max => $run_max,
	    });

	return;

    }

    # Now we have a process and we're doing process health
    my $proc = $procs[0];

    $result->metric_value('nchildren',         $proc->nchildren, '%d');
    $result->metric_value('vsz',               $proc->vsz,       '%d');
    $result->metric_value('physical_mem_used', $proc->rss,       '%d');
    $result->metric_rate('cpu_time_rt',        $proc->cpu,       '%.2f');
    $result->metric_value('nthreads',          $proc->threads,   '%d')
    					         if (defined($proc->threads));

}

1;
