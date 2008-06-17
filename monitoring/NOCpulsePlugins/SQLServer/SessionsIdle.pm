package SQLServer::SessionsIdle;

use strict;
use SQLServer::Sessions;

sub run {
    my %args = @_;

    my $result   = $args{result};
    my %params   = %{$args{params}};
    my $seconds  = $params{sessionTime};
    my $millisec = $seconds * 1000;
    my $owner    = $params{sessionOwner};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $row = $ss->fetch_first(qq{
        select 'sessions' = count(*)
        from   master..sysprocesses
        where  rtrim(loginame) like '$owner'
        and    blocked = 0
        and    (convert(float, getdate() - last_batch) * 24 * 3600) > $millisec
    }, ['master..sysprocesses']);
    my $sessions = $row->{sessions};

    $result->context(SQLServer::Sessions::format_context($owner, 'idle', $seconds));
    $result->metric_value('idle_sessions', $sessions, '%d');
    SQLServer::Sessions::session_percentage($sessions, $ss, $result, 'idle');
}

1;
