package Oracle::IdleSessions;

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

    my $row = $ora->fetch_first(q{select count(*) as COUNT 
				  from v$session_wait a, v$session b
				  where a.event = 'SQL*Net message from client'
				  and a.seconds_in_wait >= ?
				  and a.sid = b.sid
				  and b.username is not null
				 }, ['V$SESSION', 'V$SESSION_WAIT'], $params{idletime});

    $result->context("Instance $params{ora_sid}");
    my $idlesessions = $result->metric_value('idlsession', $row->{COUNT}, '%d');

}

1;
