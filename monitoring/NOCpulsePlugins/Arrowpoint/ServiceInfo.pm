package Arrowpoint::ServiceInfo;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'apSvcName',
     oid       => '1.3.6.1.4.1.2467.1.15.2.1.1',
     label     => 'Service',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_index_param => 'ap_host_0'
   },
   { name      => 'apSvcState',
     oid       => '1.3.6.1.4.1.2467.1.15.2.1.17',
     data_type => 'STATE_VALUE',
     label     => 'State',
     vendor_enum => {
                    '1'      => 'SUSPENDED',
                    '2'      => 'DOWN',
                    '4'      => 'ALIVE',
                    '5'      => 'DYING',
                   },
     status_enum  => {
		      '1' => NOCpulse::Probe::Result::OK,
                      '2' => NOCpulse::Probe::Result::CRITICAL,
                      '4' => NOCpulse::Probe::Result::OK,
                      '5' => NOCpulse::Probe::Result::WARNING,
		     },
   },
   { name      => 'apSvcConnections',
     oid       => '1.3.6.1.4.1.2467.1.15.2.1.20',
     data_type => 'INTEGER',
     metric    => 'conn_rate',
     value_format => '%d',
   },
   { name      => 'apSvcTransitions',
     oid       => '1.3.6.1.4.1.2467.1.15.2.1.21',
     data_type => 'COUNTER32',
     metric    => 'trans_rate',
     value_format => '%.2f'
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
