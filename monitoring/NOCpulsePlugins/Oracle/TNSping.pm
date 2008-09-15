package Oracle::TNSping;

use strict;

use Error ':try';

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $host = $params{ip};
    my $port = $params{port};
    my $ora_home = $params{ORACLE_HOME};

    my $tns = "'(ADDRESS=(PROTOCOL=TCP)(HOST=$host)(PORT=$port))'";

    my $command = $args{data_source_factory}->unix_command(%params);
    #need to turn off die_on_failure default setting from unix_command data source to let TNS connect errors pass through
    $command->die_on_failure(0);
    $command->execute("ORACLE_HOME=$ora_home $ora_home/bin/tnsping $tns");
	
    if ($command->command_status != 0) {
	if ($command->errors) {
	    throw NOCpulse::Probe::InternalError("Cannot run TNSping: ".$command->errors);
	} else {
	    my $error = $command->results =~ /TNS-(\d+):(.*)/;
	    my $err_no = $1;
	    my $err_txt = $2;
	    $result->item_critical("TNS-$err_no", $err_txt);
	}	
    } else {
	if ($command->results =~ /OK\s\((\d+)/ ) {
	    $result->context("TNS Listener");
	    #adjust time from msec to sec
	    my $time = ($1 / 1000);
	    $result->metric_value('latency', $time, '%.3f');
	} else {
	    $result->item_unknown("Cannot find latency value in TNSping output:". $command->results);
	}
    }
}

1;
