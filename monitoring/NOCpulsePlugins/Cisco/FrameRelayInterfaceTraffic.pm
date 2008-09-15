package Cisco::FrameRelayInterfaceTraffic;

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
   { name      => 'frCircuitState',
     oid       => '1.3.6.1.2.1.10.32.2.1.3',
     data_type => 'STATE_VALUE',
     vendor_enum =>
     { '1' => 'INVALID',
       '2' => 'ACTIVE',
       '3' => 'INACTIVE',
     },
     status_enum =>
     { '1' => 'CRITICAL',
       '2' => 'OK',
       '3' => 'WARNING',
     },
   },
   { name      => 'frCircuitReceivedOctets',
     oid       => '1.3.6.1.2.1.10.32.2.1.9',
     data_type => 'COUNTER32',
     metric    => 'in_bit_rt',
   },
   { name      => 'frCircuitSentOctets',
     oid       => '1.3.6.1.2.1.10.32.2.1.7',
     data_type => 'COUNTER32',
     metric    => 'out_bit_rt',
   },
   { name      => 'frCircuitCommittedBurst',
     oid       => '1.3.6.1.2.1.10.32.2.1.12',
     data_type => 'INTEGER',
     metric    => 'cmmt_burst',
   },
   { name      => 'frCircuitExcessBurst',
     oid       => '1.3.6.1.2.1.10.32.2.1.13',
     data_type => 'INTEGER',
     metric    => 'exss_burst',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
