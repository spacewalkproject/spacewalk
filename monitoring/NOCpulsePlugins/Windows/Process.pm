package Windows::Process;

use strict;

use NOCpulse::Probe::DataSource::WindowsCommand;

my $metric = 'pct_processor_time';

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->windows_command(%params);

    my $process = $params{process};

    $result->context("Process $process");

    my $pct_cpu = $command->perf_data('Process', '% Processor Time', $process);
    if (defined($pct_cpu)) {
	$result->metric_value($metric, $pct_cpu);
    } else {
	$result->item_critical("Not running");
    }
}

1;
