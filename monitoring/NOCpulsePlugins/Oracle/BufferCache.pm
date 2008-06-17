package Oracle::BufferCache;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $ora = $args{data_source_factory}->oracle(%params);

    my $row = $ora->fetch_first(q{
        select sum(decode(name, 'consistent gets', value, 0)) as consistent_gets,
               sum(decode(name, 'db block gets',   value, 0)) as db_block_gets,
               sum(decode(name, 'physical reads',  value, 0)) as physical_reads
        from v$sysstat
    }, ['V$SYSSTAT']);

    $result->context("Instance " . $params{ora_sid});
    my $con_item   = $result->metric_rate('consistent_gets', $row->{CONSISTENT_GETS}, '%d', 60);
    my $block_item = $result->metric_rate('db_block_gets',   $row->{DB_BLOCK_GETS},   '%d', 60);
    my $phys_item  = $result->metric_rate('physical_reads',  $row->{PHYSICAL_READS},  '%d', 60);

    my $all_gets = $con_item->value + $block_item->value;
    $result->metric_percentage('hit_ratio', $all_gets - $phys_item->value, $all_gets, '%.2f');
}

1;
