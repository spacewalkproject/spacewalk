package Exchange::MTAStatus;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'mtaThreadsInUse',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.7.0',
     data_type => 'INTEGER',
     metric    => 'threads',
   },
   { name      => 'mtaWorkQueueLength',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.8.0',
     data_type => 'INTEGER',
     metric    => 'qlength',
   },
   { name      => 'mtaDeferredDeliveryMsgs',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.31.0',
     data_type => 'INTEGER',
     metric    => 'defmsgs',
   },
   { name      => 'mtaTotalFailedConversions',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.34.0',
     data_type => 'COUNTER32',
     metric    => 'failedconv',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
