package SQLServer::BufferCache;

use strict;

use constant OBJ_NAME => 'SQLServer:Buffer Manager';

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $hit_ratio      = $ss->perf_counter(OBJ_NAME, 'Buffer Cache Hit Ratio', undef);
    my $hit_ratio_base = $ss->perf_counter(OBJ_NAME, 'Buffer Cache Hit Ratio Base', undef);

    $result->context("SQL Server");
    $result->metric_percentage('buffer_cache_hit_ratio', $hit_ratio, $hit_ratio_base, '%.2f');
}

1;
