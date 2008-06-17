package Windows::PagingFileUsage;

use strict;

use NOCpulse::Probe::DataSource::WindowsCommand;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    my $instance = $params{instance};

    my $command = $args{data_source_factory}->windows_command(%params);

    my $paging_file_usage = $command->perf_data('Paging File', '% Usage', $instance);

    if (defined($paging_file_usage)) {

        $result->context("Paging File instance $instance");

        $result->metric_value('pctused', $paging_file_usage);

    } else {
        $result->user_data_not_found('Instance', $instance);
    }
}

1;
