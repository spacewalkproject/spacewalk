package Exchange::IMSSMTP;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'imsConnectionsInbound',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.8.0',
     data_type => 'INTEGER',
     metric    => 'inconn',
   },
   { name      => 'imsConnectionsOutbound',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.9.0',
     data_type => 'INTEGER',
     metric    => 'outconn',
   },
   { name      => 'imsConnectionsTotalRejected',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.12.0',
     data_type => 'COUNTER32',
     metric    => 'rejconn',
   },
   { name      => 'imsConnectionsTotalFailed',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.13.0',
     data_type => 'COUNTER32',
     metric    => 'failedconn',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
