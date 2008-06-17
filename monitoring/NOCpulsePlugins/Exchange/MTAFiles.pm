package Exchange::MTAFiles;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'mtaDiskFileDeletesPerSec',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.11.0',
     data_type => 'INTEGER',
     metric    => 'delps',
   },
   { name      => 'mtaDiskFileSyncsPerSec',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.12.0',
     data_type => 'INTEGER',
     metric    => 'syncps',
   },
   { name      => 'mtaDiskFileOpensPerSec',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.13.0',
     data_type => 'INTEGER',
     metric    => 'openps',
   },
   { name      => 'mtaDiskFileReadsPerSec',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.14.0',
     data_type => 'INTEGER',
     metric    => 'readps',
   },
   { name      => 'mtaDiskFileWritesPerSec',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.15.0',
     data_type => 'INTEGER',
     metric    => 'writeps',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
