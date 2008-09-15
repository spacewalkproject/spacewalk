package IIS::Requests;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'totalCGIRequests',
     oid       => '1.3.6.1.4.1.311.1.7.3.1.35.0',
     data_type => 'COUNTER32',
     metric    => 'cgireqs',
   },
   { name      => 'totalRejectedRequests',
     oid       => '1.3.6.1.4.1.311.1.7.3.1.42.0',
     data_type => 'COUNTER32',
     metric    => 'rejectedrq',
   },
   { name      => 'totalNotFoundErrors',
     oid       => '1.3.6.1.4.1.311.1.7.3.1.43.0',
     data_type => 'COUNTER32',
     metric    => 'notfnderr',
   },
   { name      => 'totalLockedErrors',
     oid       => '1.3.6.1.4.1.311.1.7.3.1.44.0',
     data_type => 'COUNTER32',
     metric    => 'lockederr',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
