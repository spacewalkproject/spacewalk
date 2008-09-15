package Apache::Processes;

use strict;

use ProbeMessageCatalog;
use Apache::StatusPage;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $msgcat  = ProbeMessageCatalog->instance();

    my $status_page = $args{data_source_factory}->http(%params);
    $status_page->execute;

    if ($status_page->errors == '401') {
	$result->item_unknown(sprintf($msgcat->apache('authorization_required'), $status_page->complete_url));
	return;
    } elsif ($status_page->errors) {
	$result->item_unknown(sprintf($msgcat->apache('http_error'), $status_page->complete_url, $status_page->errors));	
	return;
    }

    my $processes = Apache::StatusPage->new($status_page->complete_url, $status_page->results);

    if (defined($processes->parse_error_msg)) {
	$result->item_unknown("", $processes->parse_error_msg);
    } elsif (!$processes->extended_status)  {
	$result->item_unknown($msgcat->apache('extended_status_off'));
    } elsif (defined($processes->max_childmb) && defined($processes->max_slotmb)) {
	$result->metric_value('childmb', $processes->max_childmb, '%.3f');
	$result->metric_value('slotmb', $processes->max_slotmb, '%.3f');	
    } else {
	$result->item_unknown(sprintf($msgcat->apache('no_processes_metrics'), $status_page->complete_url));
    }

}

1;
