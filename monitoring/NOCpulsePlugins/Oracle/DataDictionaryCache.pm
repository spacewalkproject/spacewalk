package Oracle::DataDictionaryCache;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $ora = $args{data_source_factory}->oracle(%params);

    my $row = $ora->fetch_first(q{
				  select
				  sum(GETS) as GETS,
				  sum(GETMISSES) as GETMISSES
				  from v$rowcache
				 }, ['V$ROWCACHE']);

    $result->context("Instance $params{ora_sid}");
    my $gets       = $result->metric_rate('gets',       $row->{GETS},      '%d', 60);
    my $get_misses = $result->metric_rate('get_misses', $row->{GETMISSES}, '%d', 60);
    $result->metric_percentage('hit_ratio', $gets->value - $get_misses->value,  $gets->value, '%d');

}

1;
