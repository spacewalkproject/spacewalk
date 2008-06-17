package Unix::VirtualMemory;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $virtual_memory = $command->virtual_memory();

    if ($virtual_memory->found) {
        $result->metric_percentage('pctfree',
                                   $virtual_memory->free,
                                   $virtual_memory->total,
                                   '%.2f');
        $result->item_value('Used', $virtual_memory->used / 1024, '%.2f', units => 'MB');
        $result->item_value('Free', $virtual_memory->free / 1024, '%.2f', units => 'MB');
    } else {
        $result->item_unknown('Cannot calculate virtual memory from "' .
                              $command->results . '"');
    }
}

1;
