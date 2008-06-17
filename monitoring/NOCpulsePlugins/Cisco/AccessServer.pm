package Cisco::AccessServer;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'cmSystemModemsInUse',
     oid       => '1.3.6.1.4.1.9.9.47.1.1.6.0',
     data_type => 'INTEGER',
     metric    => 'used_mdm',
   },
   { name      => 'cmSystemModemsAvailable',
     oid       => '1.3.6.1.4.1.9.9.47.1.1.7.0',
     data_type => 'INTEGER',
     metric    => 'avl_mdm',
   },
   { name      => 'cmSystemModemsUnavailable',
     oid       => '1.3.6.1.4.1.9.9.47.1.1.8.0',
     data_type => 'INTEGER',
     metric    => 'unavl_mdm',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
