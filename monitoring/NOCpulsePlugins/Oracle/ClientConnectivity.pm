package Oracle::ClientConnectivity;

use strict;

use Error ':try';

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $sid = $params{ora_sid};
    my $dbname = $params{dbname};

    try {
	my $command = $args{data_source_factory}->sqlplus_query(%params);
	$command->execute("select 'NAME:'||name from v\$database");
	if ($command->results !~ /NAME:$dbname$/i) {
	    $result->item_unknown("Expected DB Name $dbname not found");
	} else {
	    $result->context("Instance $sid");
	    $result->item_ok('Running');
	}
    } catch NOCpulse::Probe::DbLoginError with {
	my $error = shift;
	$result->item_critical($error->message);
    };
}

1;
