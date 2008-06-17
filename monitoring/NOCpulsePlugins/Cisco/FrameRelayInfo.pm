package Cisco::FrameRelayInfo;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'ifDescr',
     oid       => '1.3.6.1.4.1.9.9.49.1.2.2.1.1',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_index_param => 'interface_0'
   },
   { name      => 'frCircuitReceivedFECNs',
     oid       => '1.3.6.1.2.1.10.32.2.1.4',
     data_type => 'COUNTER32',
     metric    => 'recv_fecns',
   },
   { name      => 'frCircuitReceivedBECNs',
     oid       => '1.3.6.1.2.1.10.32.2.1.5',
     data_type => 'COUNTER32',
     metric    => 'recv_becns',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
