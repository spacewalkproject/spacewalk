package MySQL::Threads;

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

    my $threads;
    foreach my $line (@lines) {
        if ($line =~ /Threads_running/) {
            my @fields = split(/\|/, $line);
            $threads = $fields[2];
            $threads =~ s/^\s+//;
            $threads =~ s/\s+$//;
        }
    }
    if ($threads && $threads >= 0) {
        $result->metric_value('threads', $threads);
    } else {
        $result->item_unknown("Threads data could not be found");
   }
}

1;
