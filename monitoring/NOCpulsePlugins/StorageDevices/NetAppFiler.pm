package StorageDevices::NetAppFiler;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'miscNfsOps',
     oid       => '1.3.6.1.4.1.789.1.2.2.1.0',
     data_type => 'COUNTER32',
     metric    => 'nfsops',
   },
   { name      => 'miscNfsNetRecd',
     oid       => '1.3.6.1.4.1.789.1.2.2.2.0',
     data_type => 'COUNTER32',
     metric    => 'in_bit_rt',
   },
   { name      => 'miscNfsNetSent',
     oid       => '1.3.6.1.4.1.789.1.2.2.3.0',
     data_type => 'COUNTER32',
     metric    => 'out_bit_rt',
   },
   { name      => 'miscNfsPctIdle',
     oid       => '1.3.6.1.4.1.789.1.2.1.5.0',
     data_type => 'INTEGER',
     metric    => 'cpu_idle',
   },
   { name      => 'miscNfsPctUsed',
     oid       => '1.3.6.1.4.1.789.1.2.1.3.0',
     data_type => 'INTEGER',
     metric    => 'cpu_busy',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
