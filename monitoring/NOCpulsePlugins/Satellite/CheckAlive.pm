package Satellite::CheckAlive;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $cfg = NOCpulse::Config->new();

    $params{use_tnsnames} = 1;
    $params{ora_sid}      = $cfg->get('cs_db', 'name');
    $params{ora_user}     = $cfg->get('cs_db', 'username');
    $params{ora_password} = $cfg->get('cs_db', 'password');
    $params{ORACLE_HOME}  = $cfg->get('oracle', 'ora_home');
    $params{ora_port}     = 1521;

    my $ora = $args{data_source_factory}->oracle(%params);

    my $row = $ora->fetch_first(q{
        select TRUNC((sysdate - last_check) * 24 * 3600) as PERIOD,
        PROBE_COUNT,
        PCT_OK,
        PCT_WARNING,
        PCT_CRITICAL,
        PCT_UNKNOWN,
        PCT_PENDING,
        RECENT_STATE_CHANGES,
        IMMINENT_PROBES,
        MAX_EXEC_TIME,
        MIN_EXEC_TIME,
        AVG_EXEC_TIME,
        MAX_LATENCY,
        MIN_LATENCY,
        AVG_LATENCY
        from satellite_state
        where satellite_id = ?
    }, ['SATELLITE_STATE'], $params{satellite});

    $result->context("Spacewalk $params{satellite}");

    $result->metric_value('sat_latency', $row->{PERIOD}, '%d');
    $result->metric_value('probe_count', $row->{PROBE_COUNT});
    $result->metric_value('pct_ok', $row->{PCT_OK});
    $result->metric_value('pct_warning', $row->{PCT_WARNING});
    $result->metric_value('pct_critical', $row->{PCT_CRITICAL});
    $result->metric_value('pct_pending', $row->{PCT_PENDING});
    $result->metric_value('pct_unknown', $row->{PCT_UNKNOWN});
    $result->metric_value('recent_state_changes', $row->{RECENT_STATE_CHANGES});
    $result->metric_value('imminent_probes', $row->{IMMINENT_PROBES});
    $result->metric_value('max_exec_time', $row->{MAX_EXEC_TIME});
    $result->metric_value('min_exec_time', $row->{MIN_EXEC_TIME});
    $result->metric_value('avg_exec_time', $row->{AVG_EXEC_TIME});
    $result->metric_value('max_latency', $row->{MAX_LATENCY});
    $result->metric_value('min_latency', $row->{MIN_LATENCY});
    $result->metric_value('avg_latency', $row->{AVG_LATENCY});
}

1;
