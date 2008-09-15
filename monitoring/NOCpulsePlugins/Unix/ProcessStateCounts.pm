package Unix::ProcessStateCounts;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $ps_output = $command->ps();

    my @states = ();

    foreach my $ps (values %{$ps_output->process_table}) {
        # Track states for counting up by type below
        push(@states, $ps->state);

        next if $ps->pid == 1;      # Don't alert on pid 1's kids...

        # Threshold on child process count
        my $label = 'PID '.$ps->pid.' child count';
        my $item = $result->item_thresholded_value($label,
                                                   $ps->nchildren,
                                                   '%d',
                                                   { crit_max => $params{nchildren_critical},
                                                     warn_max => $params{nchildren_warn},
                                                   },
                                                   remove_if_ok => 1);
    }

    my $nblocked = grep(/^R/, @states);
    my $ndefunct = grep(/^Z/, @states);
    my $nstopped = grep(/^T/, @states);
    my $nswapped = grep(/^S/, @states);

    $result->metric_value('nblocked', $nblocked, '%d');
    $result->metric_value('ndefunct', $ndefunct, '%d');
    $result->metric_value('nstopped', $nstopped, '%d');
    $result->metric_value('nswapped', $nswapped, '%d');
}

1;
