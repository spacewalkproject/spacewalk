package Oracle::Locks;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $ora = $args{data_source_factory}->oracle(%params);

    my $row = $ora->fetch_first(q{
				  select count(*) as LOCKS from v$lock
				 }, ['V$LOCK']);

    $result->context("Instance $params{ora_sid}");
    my $pins  = $result->metric_value('locks', $row->{LOCKS}, '%d');
}

1;
