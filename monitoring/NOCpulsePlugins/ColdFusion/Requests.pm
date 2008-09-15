package ColdFusion::Requests;

use strict;

use NOCpulse::Probe::DataSource::WindowsCommand;

my %METRIC_COUNTER = ( reqrate       => 'Page Hits / Sec',
                       avgreqtime    => 'Avg Req Time (msec)',
                       avgqtime      => 'Avg Queue Time (msec)',
                       reqrunning    => 'Running Requests',
                       reqsqueued    => 'Queued Requests',
                       reqtimeout    => 'Timed Out Requests',
                      );
sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->windows_command(%params);

    $command->require_version('3.0');

    my $instance = $params{instance};

    $result->context("ColdFusion Server $instance");

    foreach my $metric_name (qw(reqrate avgreqtime avgqtime reqrunning reqsqueued)) {

        my $value = $command->perf_data('ColdFusion Server', $METRIC_COUNTER{$metric_name}, $instance);

        if ($value) {
            $result->metric_value($metric_name, $value, '%.2f');
        } else {
            $result->user_data_not_found('ColdFusion Server', $instance);
            $result->context(undef);
            last;
        }
    }

    my $torate = $command->perf_data('ColdFusion Server', $METRIC_COUNTER{reqtimeout}, $instance);

    if ($torate) {
        $result->metric_rate('reqtimeout', $torate, '%.2f');
    } else {
        $result->user_data_not_found('ColdFusion Server', $instance);
        $result->context(undef);
    }



}
