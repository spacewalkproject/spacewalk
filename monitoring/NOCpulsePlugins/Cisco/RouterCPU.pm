package Cisco::RouterCPU;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'cpmCPUTotal1min',
     oid       => '1.3.6.1.4.1.9.9.109.1.1.1.1.4.1',
     data_type => 'INTEGER',
     metric    => 'cpu1m',
   },
   { name      => 'cpmCPUTotal5min',
     oid       => '1.3.6.1.4.1.9.9.109.1.1.1.1.4.1',
     data_type => 'INTEGER',
     metric    => 'cpu5m',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
