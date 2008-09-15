package Cisco::RouterTemperature;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'ciscoEnvMonTemperatureStatusDescr',
     label     => 'Router',
     oid       => '1.3.6.1.4.1.9.9.13.1.3.1.2',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_any => 1,
   },
   { name      => 'ciscoEnvMonTemperatureStatusValue',
     oid       => '1.3.6.1.4.1.9.9.13.1.3.1.3',
     data_type => 'INTEGER',
     metric    => 'temp',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
