package SQLServer::DatabaseFileSize;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $db_name = $params{dbName};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $size = $ss->perf_counter('SQLServer:Databases', 'Data File(s) Size (KB)', $db_name);
    $result->context("Database $db_name");
    $result->metric_value('db_file_size', $size / 1024, '%.2f');
}

1;
