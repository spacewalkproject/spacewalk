package RHAPS::ExecuteQueue;

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
    
    # The object name for the pool params
    my $on_pool = $domain . ":type=ThreadPool,name=http-" . $params{port};
    
    # The object name for the JVM.
    my $on_jvm  = $domain . ":j2eeType=JVM,name=" . $server . ",J2EEServer=" . $server;

    # The command to execute on the webservice and the parameters to pass to it.
    my $command = "getAttribute";
    my @count_params = ($server,
                          $on_pool,
                          "currentThreadCount");
    my @busy_params = ($server,
                          $on_pool,
                          "currentThreadsBusy");
    my @all_params = ($server,
                          $on_jvm,
                          "allThreadsCount");


    #Execute each command with its parameters and check for errors.
    # If an error has occurred, set the status to unknown and return.
  
    $service->execute($command, @count_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: ". $service->errors);
        return;
    }
    my $count = @{$service->result}[0];

    $service->execute($command, @busy_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $busy = @{$service->result}[0];

    $service->execute($command, @all_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $all = @{$service->result}[0];


    $result->metric_value("thread_count", $count, '%d');
    $result->metric_value("busy_threads", $busy, '%d');
    $result->metric_value("all_threads", $all, '%d');
}

1;
