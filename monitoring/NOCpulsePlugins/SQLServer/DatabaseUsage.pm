package SQLServer::DatabaseUsage;

use strict;
use Error ':try';

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $db_name = $params{dbName};

    my $ss = $args{data_source_factory}->sqlserver(%params);
    my $row;

    try {
        # sp_spaceused seems to emit a newline to stderr, so suppress that.
        $ss->_kill_stderr();
        $row = $ss->fetch_first("sp_spaceused");
    } otherwise {
        my $err = shift;
        throw $err;    
    } finally {
        $ss->_restore_stderr();
    };

    # Return value includes units, so strip those out.
    my $size = (split(' ', $row->{database_size}))[0];
    my $free = (split(' ', $row->{'unallocated space'}))[0];
    my $used = $size - $free;

    $result->context("Database $db_name");
    $result->metric_value('db_used', $used, '%.2f', label => 'Space used', units => 'MB');
    $result->metric_percentage('db_pct_used', $used, $size, '%.2f');
}

1;
