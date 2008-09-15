package Exchange::IMSMessages;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'imsInboundMessagesTotal',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.20.0',
     data_type => 'COUNTER32',
     metric    => 'inmess',
   },
   { name      => 'imsOutboundMessagesTotal',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.21.0',
     data_type => 'COUNTER32',
     metric    => 'outmess',
   },
   { name      => 'imsQueuedOutbound',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.14.0',
     data_type => 'INTEGER',
     metric    => 'outqueue',
   },
   { name      => 'imsQueuedInbound',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.15.0',
     data_type => 'INTEGER',
     metric    => 'inqueue',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
