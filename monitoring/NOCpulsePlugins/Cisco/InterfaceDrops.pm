package Cisco::InterfaceDrops;

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
   { name      => 'locIfInputQueueDrops',
     oid       => '1.3.6.1.4.1.9.2.2.1.1.26',
     data_type => 'COUNTER32',
     metric    => 'in_dr_rt',
   },
   { name      => 'locIfOutputQueueDrops',
     oid       => '1.3.6.1.4.1.9.2.2.1.1.27',
     data_type => 'COUNTER32',
     metric    => 'out_dr_rt',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
