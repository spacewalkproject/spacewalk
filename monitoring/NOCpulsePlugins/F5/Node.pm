package F5::Node;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;

    my @entries =
      (
       { name      => 'ndaddrIpAddr',
         oid       => '1.3.6.1.4.1.3375.1.1.101.2.1.3',
         data_type => 'OCTET_STRING',
         is_index  => 1,
         match_index_param => 'node',
       },
       { name      => 'ndaddrBitsin',
         oid       => '1.3.6.1.4.1.3375.1.1.101.2.1.6',
         data_type => 'COUNTER32',
	 metric    => 'in_bit_rt',
       },
       { name      => 'ndaddrBitsout',
         oid       => '1.3.6.1.4.1.3375.1.1.101.2.1.7',
         data_type => 'COUNTER32',
	 metric    => 'out_bit_rt',
       },
       { name      => 'ndaddrConcur',
         oid       => '1.3.6.1.4.1.3375.1.1.101.2.1.8',
         data_type => 'INTEGER',
	 label     => 'Connections',
       },
       { name      => 'ndaddrConmax',
         oid       => '1.3.6.1.4.1.3375.1.1.101.2.1.9',
         data_type => 'INTEGER',
	 label     => 'MaxConns',
       },
       { name      => 'ndaddrStatus',
         oid       => '1.3.6.1.4.1.3375.1.1.101.2.1.12',
         data_type => 'STATE_VALUE',
	 vendor_enum =>
	 { '1'      => 'UP',
	   '2'      => 'DOWN',
	   '3'      => 'INVALID',
	   '4'      => 'VALID',
	   '6'      => 'UNCHECKED',
	   '7'      => 'UNKNOWN',
	 },
	 status_enum =>
	 {  '1'      => 'OK',
	    '2'      => 'CRITICAL',
	    '3'      => 'WARN',
	    '4'      => 'OK',
	    '6'      => 'OK',
	    '7'      => 'WARN',
	 },
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
