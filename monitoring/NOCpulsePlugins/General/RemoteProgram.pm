package General::RemoteProgram;

use strict;

use Error qw(:try);

sub run {
    my %args = @_;

    my $result = $args{result};

    my ($status_string, $command) = run_command(%args);

    #need to limit message size we send to notif system to ~1024 bytes
    my $output_string = substr($command->results, 0, 1024);

    $result->item_status($status_string, name => 'Status', value => $command->command_status);
    $result->item_ok('Output', '"' . $output_string . '"') if $command->results;
    $result->item_ok('Error', '"' . $command->errors . '"')   if $command->errors;
}

# Runs the command, assigns the status, and returns the UnixCommand object.
sub run_command {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my %status_map =
      (
       $params{ok}       => $result->OK,
       $params{warn}     => $result->WARNING,
       $params{critical} => $result->CRITICAL,
      );

    my $command = $args{data_source_factory}->unix_command(%params);

    $command->die_on_failure(0);

    $command->execute($params{command});

    my $status = $command->command_status();
    my $status_string = $status_map{$status} || $result->UNKNOWN;

    return ($status_string, $command);
}

1;
