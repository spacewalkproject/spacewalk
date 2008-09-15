package IIS::Files;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'totalFilesSent',
     oid       => '1.3.6.1.4.1.311.1.7.3.1.5.0',
     data_type => 'COUNTER32',
     metric    => 'sentfiles',
   },
   { name      => 'totalFilesReceived',
     oid       => '1.3.6.1.4.1.311.1.7.3.1.6.0',
     data_type => 'COUNTER32',
     metric    => 'recvdfiles',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
