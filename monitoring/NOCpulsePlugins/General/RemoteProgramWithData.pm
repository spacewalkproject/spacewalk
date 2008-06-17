package General::RemoteProgramWithData;

use strict;

use Error qw(:try);
use XML::Parser;
use XML::Dumper;

use General::RemoteProgram;

sub run {
    my %args = @_;

    my $result = $args{result};

    my ($status_string, $command) = General::RemoteProgram::run_command(%args);

    my ($value, $output_string) = process_xml($command->results, $result);

    if (defined($value))  {
        $result->metric_value('value', $value);
    }

    $result->item_status($status_string, name => 'Status', value => $command->command_status);
    $result->item_ok('Output', '"' . $output_string . '"') if (defined($output_string));
    $result->item_ok('Error', '"' . $command->errors . '"')
      if $command->errors;
}

sub process_xml {
    my ($xml, $result) = @_;

    my $parser = new XML::Parser(Style => 'Tree');
    my $tree;
    eval {
        $tree = $parser->parse($xml);
    };
    if ($@) {
        $result->item_unknown('Cannot process output as XML:', $xml);
        return undef;
    }

    my $dumper = new XML::Dumper;
    my $data;
    # Need to use XML::Dumper calls differently on rhel3 vs. rhel4 b/c of API changes
    if ($] >= 5.008005) {
	#this is a rhel4 box, pass in the pure xml
	eval {
    	    $data = $dumper->xml2pl($xml);
	};
	if ($@) {
	   $result->item_unknown('Encountered error trying to dump xml: $@', $xml);
	   return undef;
	}
    } else {
	#this is a rhel3 box. pass in the parsed tree
	$data = $dumper->xml2pl($tree);
    }

    if ($data && (ref $data eq 'HASH') && (exists $data->{'data'})) {
        my $datapoint = $data->{'data'};
        if (!defined $datapoint) {
            $result->item_unknown('No data value found in this XML:', $xml);

        } elsif ($datapoint !~ /^-?(?:\d+(?:\.\d*)?|\.\d+)$/) {
            # regex is to validate that $datapoint is a number (Perl Cookbook, recipe 2.1)
            $result->item_unknown('Value found in XML output is not a number:', $datapoint);

	} elsif (exists $data->{'status_message'}) {
	    #limit the size of the newly available and optional status_message to 1024 bytes
	    my $output_string = substr($data->{'status_message'}, 0, 1024);
	    return ($datapoint, $output_string);
        } else {
	    return ($datapoint, undef);
        }

    } else {
        # XML::Dumper has failed
        if ($tree->[0] ne 'perldata') { 
            $result->item_unknown('Required "<perldata>" is not the first element of', $xml); 
        } else {
            my $perldataTag = $tree->[1];
            if( $perldataTag->[3] ne 'hash') {
                $result->item_unknown('Required "<hash>" is not the second element of', $xml); 
            } else {
                my $hashTag = $perldataTag->[4];
                if( $hashTag->[3] ne 'item') {
                    $result->item_unknown('Required "<item>" is not the third element of', $xml); 
             }
          }
      }
  }
  return undef;
}

1;
