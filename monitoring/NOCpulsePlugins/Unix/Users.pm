package Unix::Users;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->unix_command(%params);

    my @who = $command->w();

    $result->metric_value('nusers', scalar(@who), '%d');
}

1;
