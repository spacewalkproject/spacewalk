package Unix::Dig;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $dns_server = $params{ip_0};
    my $find_host  = $params{lookuphost};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $dig = $command->dig($dns_server, $find_host);

    $result->context("DNS server " . $result->probe_record->host_name . ", $dns_server");

    if ($dig->hits_count == 0) {
        $result->item_critical("Cannot resolve host", $find_host);
    } else {
        foreach my $hit (@{$dig->hits}) {
            $result->item_value($hit->name.' ('. $hit->ip.')', $hit->dns_info);
        }
	$result->metric_value('query_time', $dig->total_time, '%d');
    }

}

1;
