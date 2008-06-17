package Satellite::ProbeLatency;

use strict;

use Storable;

use NOCpulse::Scheduler::Statistics;
use Satellite::CurrentStatePush;

sub run {
    my %args = @_;

    my $result = $args{result};

    my $latency = NOCpulse::Scheduler::Statistics::averageLatency();
    if ($latency < 0) {
        # Means we're running from the command line, or there's been no
        # latency calculation from the kernel. Scrounge through the
        # state files to get the latency.
        my($probe_stats, $probe_state) = 
                           Satellite::CurrentStatePush::process_states($result);

        unless(defined($probe_stats)) {
          # No probe state -- needs second iteration
          return;
        }

        $latency = $probe_stats->{avg_latency};
    }

    $result->metric_value('probelatnc', $latency, '%.2f');
}

1;
