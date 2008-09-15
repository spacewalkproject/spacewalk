package RealServer::Availability;

use strict;

use General::TCP;

sub run {
    my %args = @_;

    my $result = $args{result};
    my $params = $args{params};

    $params->{service} = 'RTSP';
    $params->{send}    = "OPTIONS * RTSP/1.0\n\n\n";
    $params->{quit}    = "QUIT\n";

    General::TCP::run(%args);

    # If there was a connection error, there will be no response
    # item, so bail out.
    my $item = $result->item_named('Response');
    return unless $item;

    # Strip off just the first line of the response.
    $item->value =~ /^(.*)\r\n/;
    $item->value($1);
    $item->format_detailed_message();
}

1;
