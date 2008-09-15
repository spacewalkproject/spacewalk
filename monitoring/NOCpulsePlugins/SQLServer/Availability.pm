package SQLServer::Availability;

use strict;
use Error ':try';

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $db_name = $params{dbName};

    # Different param names for this probe than the others...
    $params{serverName} = delete $params{servername};
    $params{userName}   = delete $params{username};

    $result->context("SQL Server");

    try {
        my $ss = $args{data_source_factory}->sqlserver(%params);
        my $row = $ss->fetch_first(q{select @@version as running});
        $result->item_ok('Running');

    } catch NOCpulse::Probe::DbConnectError with {
        my $err = shift;
        $result->item_critical($err->message);
    };
}

1;
