package Windows::PhysicalMemoryUsage;

use strict;

use NOCpulse::Probe::DataSource::WindowsCommand;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->windows_command(%params);

    $command->require_version('3.0');

    my $pctused = $command->perf_data('Physical Memory', '% Usage');

    if (defined($pctused)) {

        $result->context("Physical Memory");

        $result->metric_value('pctused', $pctused);

    } else {
        $result->user_data_not_found('Counter not found');
    }
}

1;
