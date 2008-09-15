package MySQL::Queries;

use strict;

sub run {
    my %args = @_;

    my %params = %{$args{params}};
    my $result = $args{result};

    my $host = $params{ip_0};
    my $port = $params{port_0};
    my $user = $params{user};
    my $password = $params{pass};

    my $command = $args{data_source_factory}->mysql(%params);

    my $data = $command->status($host, $port, $user, $password);

    my @lines = split(/\n/, $data);

    my $queries;
    foreach my $line (@lines) {
	if ($line =~ /Questions/) {
	    my @fields = split(/\|/, $line);
	    $queries = $fields[2];
	    $queries =~ s/^\s+//;
	    $queries =~ s/\s+$//;
	}
    }
    if ($queries && $queries >= 0) {
	$result->metric_rate('qps', $queries, '%.2f');
    } else {
	$result->item_unknown("Queries per second data could not be found");
   }	
}

1;

