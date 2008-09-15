package Unix::PageScans;

use strict;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->unix_command(%params);

    my $page_scans = $command->page_scans();

    if (defined($page_scans)) {
	#note: I use metric_value here instead of metric_rate due to the fact that the number being returned from vmstat is
	#already a rate and I do not need to compute it again as a rate.
	$result->metric_value('page_scan_rate', $page_scans, '%d' );
    } else {
        $result->item_unknown('Cannot find page scanning rate in "' .
                              $command->results . '"');
    }
}

1;
