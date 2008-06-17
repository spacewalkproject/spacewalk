package Foundry::RouterStatus;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => '',
     label     => 'Router',
     oid       => '',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_any => 1,
   },
   { name      => '',
     oid       => '',
     data_type => 'INTEGER',
     metric    => 'temp',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
