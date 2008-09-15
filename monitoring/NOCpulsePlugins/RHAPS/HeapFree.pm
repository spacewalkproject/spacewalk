package RHAPS::HeapFree;

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
    
    # The object name for the server.
    my $on = $domain . ":j2eeType=J2EEServer,name=". $server;
     
    # The command and parameters to execute on the webservice.
    my $command = "getAttribute";
    my @total_params = ($server,
                          $on,
                          "currentTotalMemory");
    my @used_params = ($server,
                          $on,
                          "currentUsedMemory");
  
    # Execute each command with its parameters and check for errors.
    # If an error has occured, set the status to unknown and return.
    $service->execute($command, @total_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: ". $service->errors);
        return;
    }

    my @service_result = $service->result;
    my $total = @{$service->result}[0];

    $service->execute($command, @used_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $used = @{$service->result}[0];

    $result->metric_value("used", $used, '%d');
    $result->metric_value("total", $total, '%d');
    $result->metric_value("free", ($total-$used), '%d');
}

1;
