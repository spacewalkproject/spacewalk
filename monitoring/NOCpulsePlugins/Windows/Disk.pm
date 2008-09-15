package Windows::Disk;

use strict;

use Error ':try';

sub run {
    my %args = @_;
    
    my $result = $args{result};
    my %params = %{$args{params}};
    my $fs = $params{fs_0};
    
    my $command = $args{data_source_factory}->windows_command(%params);
    
    my $df = undef;
    
    try {
        my $wql_output = $command->wql_query("select DeviceID, Size, FreeSpace from Win32_LogicalDisk where DeviceID=\\\"$fs\\\"");
        
        if (($wql_output) && ($wql_output->can("DeviceID")) &&
	    ($wql_output->can("FreeSpace")) && ($wql_output->can("Size")))
	{
            $df = NOCpulse::Probe::DataSource::DfEntry->new();
            $df->device($wql_output->DeviceID);
            $df->available($wql_output->FreeSpace / 1024);
            $df->used(($wql_output->Size - $wql_output->FreeSpace)/1024);
            if ($wql_output->Size > 0) {
                $df->percent_used($df->used / ($wql_output->Size/1024) * 100);
            }
            else {
                $df->percent_used(100);
            }
        }
        
    } catch NOCpulse::Probe::DataSource::WmiNotSupportedError with {
        
        # If WMI is not supported or WQLQuery.exe is not on the host, fall back to df.
        my $df_output = $command->df($fs);

        $df = $df_output->for_device(uc($fs)) || $df_output->for_device(lc($fs));
    };

    if ($df) {
        $df->convert_to_megabytes();

        # Take off the colon in the drive name to avoid "Drive C::" in the message.
        $fs =~ s/://;
        $result->context("Drive $fs");

        $result->metric_value('pctused', $df->percent_used, '%d');
        $result->metric_value('space_avail', $df->available, '%d');
        $result->metric_value('space_used', $df->used, '%d');
    } else {
        $result->user_data_not_found('Drive', $fs);
    }
}

1;

__END__
