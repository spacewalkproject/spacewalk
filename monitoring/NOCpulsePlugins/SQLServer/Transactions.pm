package SQLServer::Transactions;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $db_name = $params{dbName};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $trans = $ss->perf_counter('SQLServer:Databases', 'Active Transactions', $db_name);
    $result->context("Database $db_name");
    $result->metric_value('active_transactions', $trans, '%d');
}

1;
