package NetworkService::NMB;

use strict;

use Error qw(:try);

sub run {
    my %args = @_;

    my %params = %{$args{params}};
    my $result = $args{result};

    my $server = $params{server};
    my $nmbname = $params{nmbname};

    my $command = $args{data_source_factory}->network_service_command(%params);

    my ($status) = $command->nmb($server, $nmbname);

    if ($status =~ /.*failed$/) {
	$result->item_critical('NMBLookup', $status);
    } else {
	$result->item_ok('NMBLookup', $status);
    }
}


1;
