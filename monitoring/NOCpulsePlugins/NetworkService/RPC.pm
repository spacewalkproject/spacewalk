package NetworkService::RPC;

use strict;

use Error qw(:try);

sub run {
    my %args = @_;

    my %params = %{$args{params}};
    my $result = $args{result};

    my $host = $params{ip};
    my $proto = $params{proto};
    my $service = $params{service};

    my $command = $args{data_source_factory}->network_service_command(%params);

    my ($latency) = $command->rpc($host, $proto, $service);

    if ($latency =~ /\d+/) {
	$result->context("RPC service $service");
	$result->metric_value('latency', $latency, '%.3f');
    } else {
	$result->item_critical("Unable to establish rpc connection to service $service on host $host");
    }
}


1;
