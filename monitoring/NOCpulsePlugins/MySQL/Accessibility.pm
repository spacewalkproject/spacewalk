package MySQL::Accessibility;

use strict;

sub run {
    my %args = @_;

    my %params = %{$args{params}};
    my $result = $args{result};

    my $host = $params{host};
    my $port = $params{port};
    my $user = $params{user};
    my $password = $params{pass};
    my $db = $params{db};

    my $command = $args{data_source_factory}->mysql(%params);

    my $data = $command->accessibility($host, $port, $db, $user, $password);

    if ($data =~ /Uptime:/) {
	$result->item_ok("Client connectivity for user $user to database $db successful");
    } else {
	$result->item_critical("Client connectivity test failed when trying to connect to database $db");
    }

}

1;


