package RHAPS::JDBCConnectionPool;

use NOCpulse::Probe::DataSource::SoapLite;

use strict;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub run {
    my %args = @_;
    my $result  = $args{result};

    my %params = %{$args{params}};

    # Get the SoapLite datasource object.
    my $service = $args{data_source_factory}->soap(%params);

    my $domain = $params{domain};
    my $server = $params{server};
    my $datasource = $params{datasource};
    
    my $on = $domain . ":j2eeType=JDBCDataSource,name=". $datasource . ",JDBCResource=JDBCResource,J2EEServer=". $server;
    
    # The command name and parameters to execute on the webservice.
    my $command = "getAttribute";

    my @currentOpened_params = ($server,
                          $on,
                          "currentOpened");
    my @currentWaiters_params = ($server,
                          $on,
                          "currentWaiters");
    my @waitersHigh_params = ($server,
                          $on,
                          "waitersHigh");
    my @waitingHigh_params = ($server,
                          $on,
                          "waitingHigh");
    my @rejectedOpen_params = ($server,
                          $on,
                          "rejectedOpen");
    my @rejectedFull_params = ($server,
                          $on,
                          "rejectedFull");
    my @currentBusy_params = ($server,
                          $on,
                          "currentBusy");
    my @connectionLeaks_params = ($server,
                          $on,
                          "connectionLeaks");
    my @connectionFailures_params = ($server,
                          $on,
                          "connectionFailures");


    # Execute each command with its parameters and check for errors.
    # If an error has occured, set the status to unknown and return.
    $service->execute($command, @currentOpened_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: ". $service->errors);
        return;
    }
    my $currentOpened = @{$service->result}[0];

    $service->execute($command, @currentWaiters_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $currentWaiters = @{$service->result}[0];

    $service->execute($command, @waitersHigh_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $waitersHigh = @{$service->result}[0];

    $service->execute($command, @waitingHigh_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $waitingHigh = @{$service->result}[0];

    $service->execute($command, @rejectedOpen_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $rejectedOpen = @{$service->result}[0];

    $service->execute($command, @rejectedFull_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $rejectedFull = @{$service->result}[0];

    $service->execute($command, @currentBusy_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $currentBusy = @{$service->result}[0];

    $service->execute($command, @connectionLeaks_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $connectionLeaks = @{$service->result}[0];

    $service->execute($command, @connectionFailures_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $connectionFailures = @{$service->result}[0];

    $result->metric_value("currentOpened", $currentOpened, '%d');
    $result->metric_value("currentWaiters", $currentWaiters, '%d');
    $result->metric_value("waitersHigh", $waitersHigh, '%d');
    $result->metric_value("waitingHigh", $waitingHigh, '%d');
    $result->metric_value("rejectedOpen", $rejectedOpen, '%d');
    $result->metric_value("rejectedFull", $rejectedFull, '%d');
    $result->metric_value("currentBusy", $currentBusy, '%d');
    $result->metric_value("connectionLeaks", $connectionLeaks, '%d');
    $result->metric_value("connectionFailures", $connectionFailures, '%d');


}

1;
