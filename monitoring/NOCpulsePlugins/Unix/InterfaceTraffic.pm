package Unix::InterfaceTraffic;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    my $interface = $params{interface_0};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $traffic = $command->interface_traffic($interface);

    if ($traffic->found_interface) {
        $result->context("Interface $interface");
        $result->metric_rate('in_byte_rt',  $traffic->bytes_in, '%.0f');
        $result->metric_rate('out_byte_rt', $traffic->bytes_out, '%.0f');
    } else {
        $result->user_data_not_found('Interface', $interface);
    }
}

1;
