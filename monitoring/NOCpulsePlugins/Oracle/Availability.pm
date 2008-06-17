package Oracle::Availability;

use strict;

use Error ':try';

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $sid = $params{ora_sid};

    $result->context("Instance $sid");

    try {
	my $ora = $args{data_source_factory}->oracle(%params);
	#if the data_source_factory can connect, this check is good
	$result->item_ok('Running');

    } catch NOCpulse::Probe::DbConnectError with {
	#if error is caught, simply give the connect error message
	my $error = shift;
	$result->item_critical($error->message);
    };

}

1;
