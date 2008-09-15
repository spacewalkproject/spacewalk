package NetworkService::Ping;

use strict;

use ProbeMessageCatalog;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    # Ping seems to time out in about 10 seconds, so give it a chance to do so.
    $params{timeout} ||= 15;

    my $ip            = $params{ip} || $params{r_ip_0};
    my $is_host_check = $params{host_check};
    my $packets       = $params{packets};

    # Parsing fails if there are fewer than two packets.
    # The ping subroutine adds one because the first is ignored,
    # so ensure the value is at least one.
    $packets ||= 1;

    if ($ip eq 'localhost' || $ip eq '127.0.0.1') {
        my $msg = sprintf(ProbeMessageCatalog->instance->config('no_loopback'), $ip);
        throw NOCpulse::Probe::ConfigError($msg);
    }

    my $command = $args{data_source_factory}->unix_command(%params);

    my @times = $command->ping($ip, $packets);
    my $ping_count = scalar(@times);

    my $pct_loss = 0;
    my $round_trip_avg = 0;
    my $record_result = 1;

    if ($command->command_status == 1) {
        $pct_loss = 100;

    } elsif ($ping_count) {
        $pct_loss = 100 - (($ping_count / $packets) * 100);
        my $total_time = 0;
        foreach my $time (@times) {
            $total_time += $time;
        }
        $round_trip_avg = $total_time / $ping_count;

    } elsif ($command->failed) {
        $record_result = 0;
        $result->item_unknown('Cannot execute ping command: ' . $command->errors);

    } else {
        $record_result = 0;
        $result->item_unknown('No results from ping command');
    }

    set_values($result, \%params, $is_host_check, $round_trip_avg, $pct_loss)
      if ($record_result);
}

sub set_values {
    my ($result, $param_ref, $is_host_check, $round_trip_avg, $pct_loss) = @_;

    my $time_format = '%.3f';
    my $loss_format = '%d';

    if ($is_host_check) {
        $result->item_thresholded_value('pingtime', $round_trip_avg, $time_format,
                                        { crit_max => $param_ref->{critical_time},
                                          warn_max => $param_ref->{warn_time} });
        $result->item_thresholded_value('pctlost', $pct_loss, $loss_format,
                                        { crit_max => $param_ref->{critical_loss},
                                          warn_max => $param_ref->{warn_loss} });
    } else {
        if ($pct_loss == 100) {
	    $result->metric_value('pctlost', $pct_loss, $loss_format);
	} else {
	    $result->metric_value('pingtime', $round_trip_avg, $time_format);
	    $result->metric_value('pctlost', $pct_loss, $loss_format);
	}
    }
}

1;
