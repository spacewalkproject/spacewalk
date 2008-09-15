package IIS::Connections;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'currentConnections',
     oid       => '1.3.6.1.4.1.311.1.7.3.1.13.0',
     data_type => 'INTEGER',
     metric    => 'conn',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
