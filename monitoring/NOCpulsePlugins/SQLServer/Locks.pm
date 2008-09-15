package SQLServer::Locks;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $db_name = $params{dbName};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $row = $ss->fetch_first(q{
        select 'locks' = count(*)
        from   master..syslockinfo
    }, ['master..syslockinfo']);
    my $locks_used = $row->{locks};
    my $max_locks = $ss->sp_configure('locks');

    $result->metric_value('locks_used', $locks_used, '%d');

    if ($max_locks > 0) {
        $result->metric_percentage('locks_pct_used', $locks_used, $max_locks, '%.2f');
    } else {
        $result->item_ok('Maximum locks configured dynamically');
    }
}

1;
