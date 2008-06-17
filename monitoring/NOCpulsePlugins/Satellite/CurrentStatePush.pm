package Satellite::CurrentStatePush;

use strict;

use LWP;
use Getopt::Long;
use URI::Escape;
use FileHandle;

use NOCpulse::Log::Logger;
use NOCpulse::Config;
use NOCpulse::Gritch;
use NOCpulse::SatCluster;
use NOCpulse::Probe::PriorState;
use NOCpulse::Probe::Schedule;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

my $BADCHARS = '^-_a-zA-Z0-9'; # for URI escaping

# Puts probes into a hash by probe ID
sub hash_probes {
    my ($hashref, $probes) = @_;

    foreach my $probe (@$probes) {
        my $id;
        $id = $probe->probe_id();
        $hashref->{$id} = $probe;
    }
}

sub extract_fields {
    my $probe = shift;

    my %fields = ();

    $fields{id}    = $probe->probe_id();
    $fields{state} = $probe->status();
    $fields{lastx} = $probe->last_run_time();
    $fields{desc}  = $probe->status_message();

    $fields{nextx} = $probe->next_run_time();
    $fields{latnc} = $probe->latency();
    $fields{runtm} = $probe->last_run_duration();
    $fields{statc} = $probe->last_status_change();

    chomp $fields{desc};
    $fields{desc} = substr($fields{desc}, 0, 4000);

    return %fields;
}

sub process_states
{
    my $result = shift;
    my $probe_stats;
    $probe_stats->{'last_check'} = time();

    # Load state from new framework
    my $probes;
    push(@$probes, NOCpulse::Probe::PriorState->instance->all_schedules());

    if (scalar(@$probes) == 0) {
      my $item = $result->item_ok('Current state push');
      $item->need_second_iteration(1);
      $item->format_detailed_message();
      return undef;
    }

    my(%statecount, $statechanges, $pendingprobes,
       $totalruntm, $minruntm, $maxruntm, $avgruntm,
       $totallatnc, $minlatnc, $maxlatnc, $avglatnc);

    $statechanges, $pendingprobes = 0;

    my @lines;

    my %probe_hash = ();
    hash_probes(\%probe_hash, $probes);

    foreach my $probe (values %probe_hash)
    {
        my %fields = extract_fields($probe);

	my $id    = $fields{id};
	my $state = $fields{state} || 'PENDING';
	my $lastx = $fields{lastx} || 0;
	my $desc  = $fields{desc};
        my $nextx = $fields{nextx} || 0;
        my $latnc = $fields{latnc} || 0;
        my $runtm = $fields{runtm} || 0;
        my $statc = $fields{statc} || 0;

        # State percentage
        $statecount{$state}++;

        # State changes in the last hour
        $statechanges++ if ($statc > (time - 3600));

	# Probes scheduled to run in the next 10 minutes
	$pendingprobes++ if ($nextx < (time + 600));

	# Average/min/max exec time
	$totalruntm += $runtm; 
	$maxruntm = $runtm if ($runtm > $maxruntm || ! defined($maxruntm));
	$minruntm = $runtm if ($runtm < $minruntm || ! defined($minruntm));

	# Average/min/max latency
	$totallatnc += $latnc;
	$maxlatnc = $latnc if ($latnc > $maxlatnc || ! defined($maxlatnc));
	$minlatnc = $latnc if ($latnc < $minlatnc || ! defined($minlatnc));

	if( ( $id =~ /^\d+$/ ) and  ( $lastx =~ /^\d*$/ ) )
	{
	    if( not $state )
	    {
		$state = 'PENDING';
	    }
	    push @lines, "$id $lastx $state $desc";
	}
	else
	{
	    $Log->log(1, "Error: invalid state: id = $id t = $lastx state = $state desc = $desc\n");
	}
    }

    my $probe_state = join("\n", @lines);

    $Log->log(4, "probe state ---------------------\n");
    $Log->log(4, $probe_state, "\n");
    $Log->log(4, "---------------------------------\n");

    my $probe_count = scalar(@lines);
    $probe_stats->{'probe_count'} = $probe_count;

    $Log->log(2, "Probe count: $probe_count\n");
    $Log->log(2, "States:\n");
    foreach my $state (qw(OK WARNING CRITICAL UNKNOWN PENDING)) {

      my $pct = sprintf("%.2f", ($statecount{$state}/$probe_count)*100);

      $Log->log(2, sprintf("\t%-8s => %4d (%5.2f%%)\n", 
                       $state, $statecount{$state}, $pct));
      $probe_stats->{'pct_'.lc($state)} = $pct;
    }

    $probe_stats->{'recent_state_changes'} = $statechanges;
    $Log->log(2, "There have been $statechanges state changes in the last hour\n");

    $probe_stats->{'imminent_probes'} = $pendingprobes;
    $Log->log(2, "There are $pendingprobes probes scheduled to run in the next 10 minutes\n");

    my $avgruntm = sprintf("%.2f", $totalruntm/$probe_count);
    $probe_stats->{'max_exec_time'} = int($maxruntm);
    $probe_stats->{'min_exec_time'} = int($minruntm);
    $probe_stats->{'avg_exec_time'} = $avgruntm;

    $Log->log(2, "Exec time:\n");
    $Log->log(2, "\tMax: $maxruntm\n");
    $Log->log(2, "\tMin: $minruntm\n");
    $Log->log(2, sprintf("\tAvg: %0.1f\n", $avgruntm));


    my $avglatnc = sprintf("%.2f", $totallatnc/$probe_count);
    $probe_stats->{'max_latency'} = int($maxlatnc);
    $probe_stats->{'min_latency'} = int($minlatnc);
    $probe_stats->{'avg_latency'} = $avglatnc;

    $Log->log(2, "Latency:\n");
    $Log->log(2, "\tMax: $maxlatnc\n");
    $Log->log(2, "\tMin: $minlatnc\n");
    $Log->log(2, sprintf("\tAvg: %0.1f\n", $avglatnc));

    return($probe_stats, $probe_state);
}

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $cfg = NOCpulse::Config->new();
    my $cluster = SatCluster->newInitialized($cfg);
    my $id = $cluster->get_id();

    my($probe_stats, $probe_state) = process_states($result);

    unless(defined($probe_stats)) {
      # No probe state -- needs second iteration
      return;
    }

    my $url = $cfg->get('current_state', 'acceptor_url');
    my $ua = LWP::UserAgent->new();
    my $request = HTTP::Request->new('POST', $url);

    my $now = time();

    my $content = "sat_cluster_id=".$id.
		  "&probe_state=".uri_escape($probe_state, $BADCHARS);

    foreach my $param (sort keys %$probe_stats) {
      $content .= "&$param=".uri_escape($probe_stats->{$param}, $BADCHARS);
    }

    $Log->log(4, "POST CONTENT: $content\n");

    $request->content($content);

    $Log->log(2, "sending log to $url\n");

    my $response;
    eval {
      local($SIG{'PIPE'}) = sub {die "Broken pipe"};
      $response = $ua->request($request);
    };

    if ($response->is_success)
    {
        my $state_count = $probe_stats->{'probe_count'};

	$result->item_ok("Updated status for $state_count checks");
    }
    else
    {
	$result->item_critical("Problem updating status for satellite cluster " .
                               $id . " at ".scalar(localtime(time)) . ": " .
                               $response->status_line());
    }

    $Log->log(1, "response: ".$response->content."\n");
}

1;
