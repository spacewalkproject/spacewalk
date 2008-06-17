package Cisco::InterfaceTraffic;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'ifDescr',
     oid       => '1.3.6.1.2.1.2.2.1.2',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_index_param => 'interface_0'
   },
   { name      => 'locIfInBitsSec',
     oid       => '1.3.6.1.4.1.9.2.2.1.1.6',
     data_type => 'INTEGER',
     metric    => 'in_bit_rt',
   },
   { name      => 'locIfOutBitsSec',
     oid       => '1.3.6.1.4.1.9.2.2.1.1.8',
     data_type => 'INTEGER',
     metric    => 'out_bit_rt',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
