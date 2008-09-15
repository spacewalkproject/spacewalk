package Cisco::RouterBGPInfo;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'bgpPeerRemoteAddr',
     oid       => '1.3.6.1.2.1.15.3.1.7',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_index_param => 'bgp_peer_0'
   },
   { name      => 'bgpPeerRemoteAs',
     oid       => '1.3.6.1.2.1.15.3.1.9',
     label     => 'ASN',
     data_type => 'OCTET_STRING',
   },
   { name      => 'bgpPeerFsmEstablishedTransitions',
     oid       => '1.3.6.1.2.1.15.3.1.15',
     data_type => 'COUNTER32',
     metric    => 'tran_rate',
   },
   { name      => 'bgpPeerState',
     oid       => '1.3.6.1.2.1.15.3.1.2',
     data_type => 'STATE_VALUE',
     vendor_enum =>
     { '1' => 'IDLE',
       '2' => 'CONNECT',
       '3' => 'ACTIVE',
       '4' => 'OPENSENT',
       '5' => 'OPENCONFIRM',
       '6' => 'ESTABLISHED',
     },
     status_enum =>
     { '1' => 'WARN',
       '2' => 'WARN',
       '3' => 'CRITICAL',
       '4' => 'WARN',
       '5' => 'WARN',
       '6' => 'OK',
     },
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
