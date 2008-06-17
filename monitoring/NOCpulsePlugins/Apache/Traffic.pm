package Apache::Traffic;

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

    my $traffic = Apache::StatusPage->new($status_page->complete_url, $status_page->results);

    if (defined($traffic->parse_error_msg)) {
	$result->item_unknown("", $traffic->parse_error_msg);
    } elsif (!$traffic->extended_status)  {
	$result->item_unknown($msgcat->apache('extended_status_off'));
    } else {
	$result->metric_rate('traffic', $traffic->traffic, '%.3f');
	$result->metric_rate('accesses', $traffic->accesses, '%.3f');
	$result->metric_value('reqs', $traffic->reqs, '%d');
    }
}


1;
