package Windows::InterfaceTraffic;

use strict;

use NOCpulse::Probe::DataSource::WindowsCommand;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    my $interface = $params{interface_0};

    my $command = $args{data_source_factory}->windows_command(%params);

    my $input_bytes = $command->perf_data('Network Interface', 'Bytes Received/sec', $interface);
    my $output_bytes = $command->perf_data('Network Interface', 'Bytes Sent/sec', $interface);

    if ((defined($input_bytes)) && (defined($output_bytes))) {

        $result->context("Interface $interface");

        $result->metric_value('in_bit_rt', $input_bytes, '%.3f');
	$result->metric_value('out_bit_rt', $output_bytes, '%.3f');

    } else {
        $result->user_data_not_found('Interface', $interface);
    }
}

1;
