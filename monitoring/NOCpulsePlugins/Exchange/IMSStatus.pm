package Exchange::IMSStatus;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'imsNDRsTotalInbound',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.16.0',
     data_type => 'INTEGER',
     metric    => 'inndrs',
   },
   { name      => 'imsNDRsTotalOutbound',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.17.0',
     data_type => 'INTEGER',
     metric    => 'outndrs',
   },
   { name      => 'imsTotalFailedConversions',
     oid       => '1.3.6.1.4.1.311.1.1.3.1.1.3.34.0',
     data_type => 'INTEGER',
     metric    => 'failedconv',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
