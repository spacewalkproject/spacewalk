package Windows::RemoteProgramWithData;

use strict;

use XML::Parser;
use XML::Dumper;

use Windows::RemoteProgram;
use General::RemoteProgramWithData;

sub run {
    my %args = @_;

    my $result = $args{result};

    my $command = Windows::RemoteProgram::run_command(%args);

    my ($value, $output_string);
    if (!$command->errors) {
        ($value, $output_string) = General::RemoteProgramWithData::process_xml($command->results, $result);
        
        if (defined($value))  {
            $result->metric_value('value', $value);
        }
    }
    
    $result->item_ok('Output', '"' . $output_string . '"') if (defined($output_string));
    $result->item_unknown('"' . $command->errors . '"') if $command->errors;
}

1;
