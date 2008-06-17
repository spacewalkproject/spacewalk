package Oracle::LibraryCache;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $ora = $args{data_source_factory}->oracle(%params);

    my $row = $ora->fetch_first(q{
				  select sum(PINS) as PINS,
				  sum(RELOADS) as RELOADS
				  from v$librarycache
				 }, ['V$LIBRARYCACHE']);

    $result->context("Instance $params{ora_sid}");
    my $pins  = $result->metric_rate('executions', $row->{PINS}, '%d', 60);
    my $reloads = $result->metric_rate('misses', $row->{RELOADS}, '%d', 60);
    $result->metric_percentage('miss_ratio', $reloads->value,  $pins->value, '%.2f');

}

1;
