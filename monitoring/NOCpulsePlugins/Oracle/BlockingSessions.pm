package Oracle::BlockingSessions;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

     # Different param names for this probe than the others...
    $params{ora_host} = delete $params{ip_0};
    $params{ora_port} = delete $params{port_0};
    $params{ora_sid} = delete $params{sid_0};

    my $ora = $args{data_source_factory}->oracle(%params);

    my $row = $ora->fetch_first(q{
			    select count(*) as BLOCKED from v$lock
			    where ctime > ?
			    and   block = 1	
    }, ['V$LOCK'],$params{blocktime});

    $result->context("Instance $params{ora_sid}");
    my $blksession   = $result->metric_value('blksession', $row->{BLOCKED}, '%d');

}

1;
