package Unix::MemoryFree;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};

    my $command = $args{data_source_factory}->unix_command(%{$args{params}});

    my $free_mb = $command->free_memory($args{params}) / 1024;
    
    $result->metric_value('free', $free_mb, '%.2f');
}

1;
