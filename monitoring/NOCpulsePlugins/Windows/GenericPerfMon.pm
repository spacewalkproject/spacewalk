package Windows::GenericPerfMon;

use strict;

use Error ':try';

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $object   = $params{cobject};
    my $counter  = $params{counter};
    my $instance = $params{instance};

    my $command = $args{data_source_factory}->windows_command(%params);

    try {
        my $value = $command->perf_data($object, $counter, $instance);
        if ($value) {
            $result->context("$object $instance $counter");
            # Use %s to return exactly what perfdata gives
            $result->metric_value('value', $value, '%s');
        } else {
            $result->user_data_not_found("$object", $instance);
        }

    } catch NOCpulse::Probe::DataSource::PerfDataObjectError with {
        $result->user_data_not_found("Performance monitor object", $object);

    } catch NOCpulse::Probe::DataSource::PerfDataCounterError with {
        $result->user_data_not_found("Performance monitor counter for object $object",
                                     $counter);
    };        
}

1;
