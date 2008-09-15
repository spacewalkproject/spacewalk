package Unix::CPU;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->unix_command(%params);

    $result->metric_value('pctused', $command->cpu(), '%d');
}

1;
