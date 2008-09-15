package Unix::ProcessCountTotal;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $ps_output = $command->ps();

    $result->metric_value('nprocs', scalar(keys(%{$ps_output->process_table})), '%d');
}

1;
