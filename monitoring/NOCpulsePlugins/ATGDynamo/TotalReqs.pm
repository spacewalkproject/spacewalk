package ATGDynamo::TotalReqs;

use strict;

use POSIX 'ceil';
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::SNMP::MibEntryList;


my $requests = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'generic',
     oid       => '1.3.6.1.4.1.2725.1.4.3',
     data_type => 'INTEGER',
     metric    => 'reqs',
   });

sub run {
    my %args = @_;
    my $result = $args{result};
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    $args{params}->{version} = 2;

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new();
    $oid_list->add_entries($requests);
    $oid_list->run(%args);

    my $reqs = $requests->fetched_value;
    if (defined($reqs)) {
        $result->metric_rate('req_rate', $reqs, '%.3f');
    }
}

1;
