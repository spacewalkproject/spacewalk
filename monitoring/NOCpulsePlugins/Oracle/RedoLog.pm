package Oracle::RedoLog;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $ora = $args{data_source_factory}->oracle(%params);

    my $row = $ora->fetch_first(q{
        select a.value as REQUESTS, b.value as RETRIES
        from   v$sysstat a, v$sysstat b
        where  a.name = 'redo log space requests'
        and    b.name = 'redo buffer allocation retries'
    }, ['V$SYSSTAT']);

    $result->context("Instance " . $params{ora_sid});
    $result->metric_rate('requests', $row->{REQUESTS}, '%.2f', 60);
    $result->metric_rate('retries', $row->{RETRIES}, '%.2f', 60);
}

1;
