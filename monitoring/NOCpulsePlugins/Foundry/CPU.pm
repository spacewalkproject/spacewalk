package Foundry::CPU;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'snAgGblCpuUtil1MinAvg',
     oid       => '1.3.6.1.4.1.1991.1.1.2.1.52.0',
     data_type => 'INTEGER',
     metric    => 'cpu1m',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
