package SQLServer::TranLogUsage;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $db_name = $params{dbName};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $row = $ss->fetch_first(qq{
        select pct.cntr_value as pct,
               size.cntr_value as size,
               used.cntr_value as used
        from   master..sysperfinfo pct,
               master..sysperfinfo size,
               master..sysperfinfo used
        where  pct.object_name = 'SQLServer:Databases'
        and    pct.counter_name = 'Percent Log Used'
        and    pct.instance_name = '$db_name'
        and    size.object_name = 'SQLServer:Databases'
        and    size.counter_name = 'Log File(s) Size (KB)'
        and    size.instance_name = '$db_name'
        and    used.object_name = 'SQLServer:Databases'
        and    used.counter_name = 'Log File(s) Used Size (KB)'
        and    used.instance_name = '$db_name' 
    }, ['master..sysperfinfo']);

    my $size = $row->{size} / 1024;
    my $used = $row->{used} / 1024;

    $result->context("Database $db_name");
    $result->metric_value('tran_log_pct_used', $row->{pct}, '%d');
    $result->metric_value('tran_log_size', $size, '%.2f');
    $result->metric_value('tran_log_used', $used, '%.2f');
}

1;
