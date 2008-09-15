package Apache::Uptime;

use strict;

use ProbeMessageCatalog;
use Apache::StatusPage;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $msgcat  = ProbeMessageCatalog->instance();

    my $status_page = $args{data_source_factory}->http(%params);
    $status_page->execute();

    if ($status_page->errors == '401') {
	$result->item_unknown(sprintf($msgcat->apache('authorization_required'), $status_page->complete_url));
	return;
    } elsif ($status_page->errors) {
	$result->item_unknown(sprintf($msgcat->apache('http_error'), $status_page->complete_url, $status_page->errors));	
	return;
    }

    my $uptime = Apache::StatusPage->new($status_page->complete_url, $status_page->results);
	
    if (defined($uptime->parse_error_msg)) {
	$result->item_unknown($uptime->parse_error_msg);
    } elsif (!defined($uptime->uptime)) {
	$result->item_unknown(sprintf($msgcat->apache('no_uptime'), $status_page->complete_url));
    } else {
	$result->item_value("Apache", $uptime->uptime);
    }

}

1;
