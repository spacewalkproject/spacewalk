package Oracle::ActiveSessions;

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

    my $row1 = $ora->fetch_first(q{select count(*) as SESSIONS from v$session}, ['V$SESSION']);
    my $row2 = $ora->fetch_first(q{select value as MAX from v$parameter where name = 'sessions'}, ['V$PARAMETER']);

    $result->context("Instance $params{ora_sid}");
    my $active_sessions = $result->metric_value('actsession', $row1->{SESSIONS}, '%d');
    my $max_sessions = $row2->{MAX};
    $result->metric_percentage('usedsesspct',  $active_sessions->value, $max_sessions, '%.2f');
}

1;
