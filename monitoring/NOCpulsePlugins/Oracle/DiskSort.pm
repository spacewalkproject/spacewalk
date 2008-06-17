package Oracle::DiskSort;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $ora = $args{data_source_factory}->oracle(%params);

    my $row1 = $ora->fetch_first(q{
				  select value as MEMSORTS from v$sysstat
				  where name = 'sorts (memory)'}, ['V$SYSSTAT']);
    my $row2 = $ora->fetch_first(q{
				  select value as DISKSORTS from v$sysstat
				  where name = 'sorts (disk)'}, ['V$SYSSTAT']);

    $result->context("Instance $params{ora_sid}");
    my $mem_sorts  = $result->metric_rate('mem_sorts', $row1->{MEMSORTS}, '%.2f', 60);
    my $disk_sorts = $result->metric_rate('dsk_sorts', $row2->{DISKSORTS}, '%.2f', 60);
    $result->metric_percentage('ratio', $disk_sorts->value,  $mem_sorts->value + $disk_sorts->value, '%.2f');

}

1;
