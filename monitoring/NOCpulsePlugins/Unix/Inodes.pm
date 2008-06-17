package Unix::Inodes;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $fs = $params{fs_0};

    my $command = $args{data_source_factory}->unix_command(%params);

    my ($used, $free, $total) = $command->inodes($fs);
    if (($command->command_status == 0) && ($used)) {
        $result->context("Filesystem $fs");
        $result->item_value('Inodes used', $used, '%d');
        $result->item_value('Inodes total', $total, '%d');
        $result->metric_percentage('pctiused',  $used, $total, '%.2f');
    } else {
        $result->user_data_not_found('Filesystem', $fs);
    }
}

1;
