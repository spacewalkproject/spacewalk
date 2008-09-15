package NetworkService::SMB;

use strict;

use Error qw(:try);

sub run {
    my %args = @_;

    my %params = %{$args{params}};
    my $result = $args{result};

    my $host = $params{host};
    my $workgroup = $params{workgroup};
    my $share = $params{sharename_0};
    my $user = $params{user};
    my $password = $params{password};

    my $command = $args{data_source_factory}->network_service_command(%params);

    my ($pct_free, $avail) = $command->smb($host, $share, $workgroup, $user, $password);

    if ($pct_free =~ /\d+/) {
	$result->context("SMB Share //$host/$share in Workgroup $workgroup");
	$result->metric_value('pctfree', $pct_free, '%d');
	$result->item_value('Space available:', $avail);
    } else {
        $result->item_unknown("$pct_free");
    }

}


1;
