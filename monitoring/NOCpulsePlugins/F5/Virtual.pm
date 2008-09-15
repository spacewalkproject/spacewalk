package F5::Virtual;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;

    my @entries =
      (
       { name      => 'vaddressIpAddr',
         oid       => '1.3.6.1.4.1.3375.1.1.100.2.1.3',
         data_type => 'OCTET_STRING',
         is_index  => 1,
         match_index_param => 'interface',
       },
       { name      => 'vaddressBitsin',
         oid       => '1.3.6.1.4.1.3375.1.1.100.2.1.6',
         data_type => 'COUNTER32',
	 metric    => 'in_bit_rt',
       },
       { name      => 'vaddressBitsout',
         oid       => '1.3.6.1.4.1.3375.1.1.100.2.1.7',
         data_type => 'COUNTER32',
	 metric    => 'out_bit_rt',
       },
       { name      => 'vaddressConcur',
         oid       => '1.3.6.1.4.1.3375.1.1.100.2.1.8',
         data_type => 'INTEGER',
	 label     => 'Connections',
       },
       { name      => 'vaddressConmax',
         oid       => '1.3.6.1.4.1.3375.1.1.100.2.1.9',
         data_type => 'INTEGER',
	 label     => 'MaxConns',
       },
       { name      => 'vaddressStatus',
         oid       => '1.3.6.1.4.1.3375.1.1.100.2.1.12',
         data_type => 'STATE_VALUE',
	 vendor_enum =>
	 { '1'      => 'READY',
	   '2'      => 'MAINTENANCE',
	 },
	 status_enum =>
	 {  '1'      => 'OK',
	    '2'      => 'WARN',
	 },
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
