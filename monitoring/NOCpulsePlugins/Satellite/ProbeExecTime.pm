package Satellite::ProbeExecTime;

use strict;

use Storable;

use Satellite::CurrentStatePush;

sub run {
    my %args = @_;

    my $result = $args{result};

    my($probe_stats, $probe_state) =
                        Satellite::CurrentStatePush::process_states($result);

    unless(defined($probe_stats)) {
      # No probe state -- needs second iteration
      return;
    }

    $result->metric_value('probextm', $probe_stats->{avg_exec_time}, '%.2f');
}

1;
