package RHAPS::Servlet;

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
    my $host = $params{host};
    my $appPath = $params{appPath};
    my $appName = $params{appName};
   
    # The object name for the jsps.
    my $on = $domain . ":j2eeType=Servlet,name=jsp,WebModule=//" . $host . "/"  . $appPath . ",J2EEApplication=" . $appName . ",J2EEServer=".  $server;

	# The jsp monitoring object name.
    my $onMonitor = $domain . ":type=JspMonitor,name=jsp,WebModule=//" . $host . "/" .  $appPath . ",J2EEApplication=" . $appName . ",J2EEServer=". $server;
    
    # The command name and parameters to execute on the webservice.
    my $command = "getAttribute";
    my @maxTime_params = ($server,
                          $on,
                          "maxTime");
    my @minTime_params = ($server,
                          $on,
                          "minTime");
    my @requestCount_params = ($server,
                          $on,
                          "requestCount");
    my @processingTime_params = ($server,
                          $on,
                          "processingTime");
   
    my @jspReloadCount_params = ($server,
                          $onMonitor,
                          "jspReloadCount");
  
    # Execute each command with its parameters and check for errors.
    # If an error has occured, set the status to unknown and return.
    $service->execute($command, @maxTime_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: ". $service->errors);
        return;
    }
    my $maxTime = @{$service->result}[0];

    $service->execute($command, @minTime_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $minTime = @{$service->result}[0];


    $service->execute($command, @requestCount_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: ". $service->errors);
        return;
    }
    my $requestCount = @{$service->result}[0];

    $service->execute($command, @processingTime_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $processingTime = @{$service->result}[0];

    $service->execute($command, @jspReloadCount_params);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: " . $service->errors);
        return;
    }
    my $jspReloadCount = @{$service->result}[0];


    $result->metric_value("maxTime", $maxTime, '%d');
    $result->metric_value("minTime", $minTime, '%d');
    $result->metric_value("requestCount", $requestCount, '%d');
    $result->metric_value("processingTime", $processingTime, '%d');
    $result->metric_value("jspReloadCount", $jspReloadCount, '%d');
    
    if ($processingTime == 0) {
         $result->metric_value("execTimeAverage", 0, '%f');
    } else {
         $result->metric_value("execTimeAverage", ($requestCount/$processingTime), '%f');
    }

}

1;
