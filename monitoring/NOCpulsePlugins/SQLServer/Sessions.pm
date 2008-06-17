package SQLServer::Sessions;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    my $owner  = $params{sessionOwner};

    # Different param name for this probe than the others...
    $params{serverName} = $params{servername};
    delete $params{servername};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $row = $ss->fetch_first(qq{
        select 'sessions' = count(*)
        from   master..sysprocesses
        where  rtrim(loginame) like '$owner'
    }, ['master..sysprocesses']);

    $result->context(format_context($owner));
    $result->metric_value('sessions', $row->{sessions}, '%d');
    session_percentage($row->{sessions}, $ss, $result);
}

sub format_context {
    my ($owner, $session_type, $seconds) = @_;
    my $ctx;
    if ($owner =~ '%') {
        if ($session_type) {
            $ctx = "Session owners matching \"$owner\" with sessions " .
              "$session_type more than $seconds seconds";
        } else {
            $ctx = "Session owners matching \"$owner\"";
        }
    } else {
        if ($session_type) {
            $ctx = "Session owner $owner sessions $session_type more than $seconds seconds";
        } else {
            $ctx = "Session owner $owner";
        }
    }
}

# Calculates a session count as a percentage of the maximum configured.
# Session type is undef, idle, or blocked.
sub session_percentage {
    my ($num_sessions, $ss, $result, $session_type) = @_;

    my $max_conn = $ss->sp_configure('user connections');

    my $metric = 'sessions_pct_used';
    if ($session_type) {
        $metric = "${session_type}_$metric";
    }

    if ($max_conn > 0) {
        $result->metric_percentage($metric, $num_sessions, $max_conn, '%.2f');
    } else {
        $result->item_ok('Maximum sessions configured dynamically');
    }
}

1;
