package Unix::Swap;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    my $os = $args{data_source_factory}{probe_record}->os_name;

    my $command = $args{data_source_factory}->unix_command(%params);

    my $swap = $command->swap();

    if (($os =~ /AIX/) && ($swap->found)) {
        $result->metric_value('pctfree', $swap->free, '%d');
    } elsif ($swap->found) {
        $result->metric_percentage('pctfree', $swap->free, $swap->total, '%.2f');
        $result->item_value('Used', to_megabytes($swap->used), '%.2f', units => 'MB');
        $result->item_value('Free', to_megabytes($swap->free), '%.2f', units => 'MB');
    } else {
        $result->item_unknown('Cannot calculate free swap space from "' .
                              $command->results . '"');
    }
}

sub to_megabytes {
    my $bytes = shift;
    return $bytes / (1024 * 1024);
}

1;
