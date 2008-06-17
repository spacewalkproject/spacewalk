package Arrowpoint::Redundancy;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'apIpv4RedundancyState',
     oid       => '1.3.6.1.4.1.2467.1.9.1.19.0',
     data_type => 'STATE_VALUE',
     label     => 'State',
     vendor_enum =>
     { '1' => 'INIT',
       '2' => 'BACKUP',
       '3' => 'MASTER',
     },
     status_enum => 
     { '1' => 'OK',
       '2' => 'OK',
       '3' => 'OK',
     },
   },
   { name      => 'apIpv4RedundancyMasterMode',
     oid       => '1.3.6.1.4.1.2467.1.9.1.22.0',
     data_type => 'STATE_VALUE',
     label     => 'Master mode',
     vendor_enum => 
     { '0' => 'YES',
       '1' => 'NO',
     },
     status_enum => 
     { '0' => 'OK',
       '1' => 'OK',
     },
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
