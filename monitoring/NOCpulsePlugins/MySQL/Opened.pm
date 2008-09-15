package MySQL::Opened;

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

    my $tables;
    foreach my $line (@lines) {
	if ($line =~ /Opened_tables/) {
	    my @fields = split(/\|/, $line);
	    $tables = $fields[2];
	    $tables =~ s/^\s+//;
	    $tables =~ s/\s+$//;
	}
    }
    if ($tables && $tables >= 0) {
	$result->metric_value('opened', $tables);
    } else {
	$result->item_unknown("Opened tables data could not be found");
   }	
}

1;

