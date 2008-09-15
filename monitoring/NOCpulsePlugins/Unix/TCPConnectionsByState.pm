package Unix::TCPConnectionsByState;

use strict;

use NOCpulse::Probe::Utils::IPAddressRange;

use constant TRACK_STATES =>
  { TIME_WAIT   => 1,
    CLOSE_WAIT  => 2,
    FIN_WAIT    => 3,			    
    ESTABLISHED => 4,
    SYN_RCVD    => 5,
  };

sub run {
    my %args = @_;

    my $result = $args{result};
    my %params = %{$args{params}};

    my $local_port_filter  = $params{local_port};
    my $remote_port_filter = $params{remote_port};
    my @local_ips          = ip_list($params{local_ip});
    my @remote_ips         = ip_list($params{remote_ip});

    my $command = $args{data_source_factory}->unix_command(%params);

    my $netstat = $command->netstat_tcp();

    my @filtered = $netstat->filtered_entries($local_port_filter, \@local_ips,
                                              $remote_port_filter, \@remote_ips);
    my $total_conns = scalar(@filtered);

    my %state_counts = ();

    foreach my $entry (@filtered) {
        $state_counts{$entry->state}++ if (exists(TRACK_STATES->{$entry->state}));
    }

    $result->context('TCP');

    $result->metric_value('nconns', $total_conns, '%d');

    my @sorted_states = sort { TRACK_STATES->{$a} <=> TRACK_STATES->{$b} } keys %state_counts;
    foreach my $state (@sorted_states) {
        $result->metric_value(lc($state).'_conn', $state_counts{$state}, '%d');
    }
}

# Parses a comma-delimited list of IP addresses and
# returns an array of IPAddressRange instances.
sub ip_list {
    my $ip_list = shift;

    my @ips = ();

    if ($ip_list) {
        my @ip_strings = split(/\s*,\s*/, $ip_list);
        foreach my $ip (@ip_strings) {
            push(@ips, NOCpulse::Probe::Utils::IPAddressRange->new(ip => $ip));
        }
    }
    return @ips;
}

1;
