package Unix::Load;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $uptime = $command->uptime();

    if ($uptime->found) {
        $result->metric_value('load1', $uptime->one_minute_load, '%.2f');
        $result->metric_value('load5', $uptime->five_minute_load, '%.2f');
        $result->metric_value('load15', $uptime->fifteen_minute_load, '%.2f');
    } else {
        $result->item_unknown('Cannot calculate load from "' . $command->results . '"');
    }
}

1;
