package Cisco::SwitchMemory;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'ciscoMemoryPoolUsed',
     oid       => '1.3.6.1.4.1.9.9.48.1.1.1.5.1',
     data_type => 'INTEGER',
     metric    => 'mem_used',
   },
   { name      => 'ciscoMemoryPoolFree',
     oid       => '1.3.6.1.4.1.9.9.48.1.1.1.6.1',
     data_type => 'INTEGER',
     metric    => 'mem_free',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
