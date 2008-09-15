package SQLServer::BatchRequestRate;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $req_rate = $ss->perf_counter('SQLServer:SQL Statistics', 'Batch Requests/sec', undef);
    $result->context("SQL Server");
    $result->metric_rate('batch_req_rate', $req_rate, '%.2f');
}

1;
