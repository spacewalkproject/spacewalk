package Unix::DiskIOThroughput;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};
    my $disk = $params{disk_0};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $iostat = $command->iostat($disk);

    if ($iostat->found_disk) {
        $result->context("Disk $disk");
        $result->metric_rate('kbrps', $iostat->kbytes_read, '%.3f');
        $result->metric_rate('kbwps', $iostat->kbytes_written, '%.3f');
    } else {
        $result->user_data_not_found('Disk', $disk);
    }
}

1;
