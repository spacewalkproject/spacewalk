package Cisco::RouterBuffers;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'bufferSmFree',
     oid       => '1.3.6.1.4.1.9.2.1.16.0',
     data_type => 'INTEGER',
     metric    => 'fr_sm_buff',
   },
   { name      => 'bufferMdFree',
     oid       => '1.3.6.1.4.1.9.2.1.24.0',
     data_type => 'INTEGER',
     metric    => 'fr_md_buff',
   },
   { name      => 'bufferBgFree',
     oid       => '1.3.6.1.4.1.9.2.1.32.0',
     data_type => 'INTEGER',
     metric    => 'fr_bg_buff',
   },
   { name      => 'bufferLgFree',
     oid       => '1.3.6.1.4.1.9.2.1.40.0',
     data_type => 'INTEGER',
     metric    => 'fr_lg_buff',
   },
   { name      => 'bufferHgFree',
     oid       => '1.3.6.1.4.1.9.2.1.64.0',
     data_type => 'INTEGER',
     metric    => 'fr_hg_buff',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
