package Windows::ServiceStatus;

use strict;

use Error ':try';

sub run {
    my %args = @_;
    
    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->windows_command(%params);

    my %state_map = (

        'Running' => $params{status_running},
        'Start Pending' => $params{status_start_pending},
        'Continue Pending' => $params{status_continue_pending},
        'Pause Pending' => $params{status_pause_pending},
        'Paused' => $params{status_paused},
        'Stop Pending' => $params{status_stop_pending},
        'Stopped' => $params{status_stopped}
    );

    $command->require_version('3.0.5');
    
    my $service_name = $params{service_name};
    
    $result->context("Service $service_name");

    my $service_state = undef;
    try {
	# Prefer WMI for getting this information.
        my $wql_output = $command->wql_query("select State from Win32_Service where Name=\\\"$service_name\\\"");
        
        if (($wql_output) && ($wql_output->can("State")))
	{
	    $service_state = $wql_output->State;
	}
        
    } catch NOCpulse::Probe::DataSource::WmiNotSupportedError with {
        
        # If WMI is not supported or WQLQuery.exe is not on the host, fall back to service.exe.
	$service_state = $command->service("status", $service_name);
    };

    if (defined $service_state) {
	
	# map the service state to a probe state based on the parameters.
	my $probe_state = $state_map{$service_state};

	if ($result->is_valid_state($probe_state)) {
	    $result->item_status($probe_state, name => '', value => $service_state );
	}
	else {
	    $result->item_unknown('Unknown:', $service_state);
	} 
    } else {
        $result->user_data_not_found('Service', $service_name);
    }
}


1;

__END__
