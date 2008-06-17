package SQLServer::SessionsBlocked;

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
        and    waittime > $millisec
    }, ['master..sysprocesses']);
    my $sessions = $row->{sessions};

    $result->context(SQLServer::Sessions::format_context($owner, 'blocked', $seconds));
    $result->metric_value('blocked_sessions', $sessions, '%d');
    SQLServer::Sessions::session_percentage($sessions, $ss, $result, 'blocked');
}

1;
