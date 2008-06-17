package Exchange::MTAMessages;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'mtaMessagesPerSec',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.2.0',
     data_type => 'INTEGER',
     metric    => 'mps',
   },
   { name      => 'mtaOutboundMessagesTotal',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.37.0',
     data_type => 'COUNTER32',
     metric    => 'omps',
   },
   { name      => 'mtaInboundMessagesTotal',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.1.36.0',
     data_type => 'COUNTER32',
     metric    => 'imps',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
