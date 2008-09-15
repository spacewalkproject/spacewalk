package SQLServer::UserCounter;

use strict;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};
    my $counter = $params{counterNumber};
    my $descr   = $params{counterDescription};

    my $ss = $args{data_source_factory}->sqlserver(%params);

    my $value = $ss->perf_counter('SQLServer:User Settable', 'Query', "User counter $counter");
    if (defined($value)) {
        $result->context("User counter $counter");
        my $item = $result->metric_value("counter_value", $value, '%d');
        if ($descr) {
            # Use the custom counter description in the output if it's set.
            $item->label($descr);
            $item->format_detailed_message();
        }
    } else {
        $result->item_unknown("User counter $counter not in range 1-10, " .
                              "or insufficient privileges for query of " .
                              "master..sysperfinfo table");
    }
}

1;
