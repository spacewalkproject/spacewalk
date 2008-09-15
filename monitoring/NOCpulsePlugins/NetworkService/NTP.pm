package NetworkService::NTP;

use strict;

use Error qw(:try);

sub run {
    my %args = @_;

    my %params = %{$args{params}};
    my $result = $args{result};

    my $host = $params{ip};

    my $command = $args{data_source_factory}->unix_command(%params);

    my ($offset) = $command->ntpq($host);

    if ($offset =~ /\d+/) {
	$result->context("NTP server $host");
	$result->metric_value('ntpoffset', $offset, '%.2f');
    } else {
	$result->item_critical("Could not query NTP server at $host");
    }
}


1;
