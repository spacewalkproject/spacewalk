package Windows::RemoteProgram;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my $command = run_command(%args);

    #need to limit message size we send to notif system to ~1024 bytes
    my $output_string = substr($command->results, 0, 1024);

    $result->item_ok('Output', '"' . $output_string . '"') if $command->results;

    $result->item_critical('Error', '"' . $command->errors . '"')   if $command->errors;
}


# Runs the command, assigns the status, and returns the WindowsCommand object.
sub run_command {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->windows_command(%params);

    $command->die_on_failure(0);

    $command->execute("run " . $params{command});

    return $command;
}

1;
