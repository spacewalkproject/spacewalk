package Windows::LoadAverage;

use strict;

use NOCpulse::Probe::DataSource::WindowsCommand;

my %METRIC_COUNTER = (load1  => '1 Minute Avg',
                      load5  => '5 Minute Avg', 
                      load15 => '15 Minute Avg',                     
                      );
sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    
    my $command = $args{data_source_factory}->windows_command(%params);

    $command->require_version('3.0');

    my $instance = $params{instance_0};

    $result->context("Processor $instance");

    foreach my $metric_name (qw(load1 load5 load15)) {

        my $load = $command->perf_data('Processor Load', $METRIC_COUNTER{$metric_name}, $instance);

        if ($load) {
            $result->metric_value($metric_name, $load, '%.2f');
        } else {
            $result->user_data_not_found('Processor', $instance);
            $result->context(undef);
            last;
        }
    }
}
