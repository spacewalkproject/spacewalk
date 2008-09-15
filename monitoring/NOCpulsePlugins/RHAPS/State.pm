package RHAPS::State;

use NOCpulse::Probe::DataSource::SoapLite;

use strict;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub run {
    my %args = @_;
    my $result  = $args{result};

    my %params = %{$args{params}};
 
    # Get the SoapLite datasource.
    my $service = $args{data_source_factory}->soap(%params);

    my $domain = $params{domain};
    my $server = $params{server};
    
    # The object name for the server.
    my $on = $domain . ":j2eeType=J2EEServer,name=". $server;
    
    # The command name and parameters to execute on the web service.
    my $command = "getAttribute";
    my @state = ($server,
                 $on,
                 "serverName");
  
    # Execute the command with its parameters and check for errors.
    # If an error has occured, set the status to unknown and return.
    $service->execute($command, @state);
    if(defined($service->errors)) {
        $result->item_unknown("Could not connect to the endpoint. Error: ". $service->errors);
        return;
    }
    $result->item_ok("Running");
}

1;
