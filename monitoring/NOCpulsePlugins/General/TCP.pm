package General::TCP;

# Probe connects to an arbitrary port and conducts a simple (and optional) conversation.

use strict;

use Error qw(:try);
use ProbeMessageCatalog;

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    $params{service}         ||= 'TCP';
    $params{host}            = delete $params{r_ip_0};
    $params{port}            = delete $params{r_port_0};
    $params{protocol}        = delete $params{r_tproto_0};
    $params{read_bytes}      = delete $params{readcount};
    $params{timeout_seconds} = delete $params{timeout};

    $result->context(uc($params{service}) . ' port ' . $params{port});

    try {
        my $socket = $args{data_source_factory}->inet_socket(%params);
        $socket->execute(%params);
        unless ($socket->found_expected_content) {
            $result->item_critical(ProbeMessageCatalog->tcp('expect_string'),
                                   "\"$params{expect}\"");
        }
        $result->metric_value('latency', $socket->latency, '%.4f');
        $result->item_value('Response', $socket->results) if ($params{expect});
    } catch NOCpulse::Probe::Error with {
        my $err = shift;
        my $msg = $err->message;
        $msg =~ s/^IO::Socket::INET: //;
        $result->item_critical($msg);
    } otherwise {
        my $err = shift;
        $result->item_critical($err->text);
    };
}

1;
