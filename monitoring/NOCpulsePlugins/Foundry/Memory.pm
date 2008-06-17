package Foundry::Memory;

use strict;

use POSIX 'ceil';
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::SNMP::MibEntryList;


my $used_entry = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'snAgGblDynMemUtil',
     oid       => '1.3.6.1.4.1.1991.1.1.2.1.53.0',
     data_type => 'INTEGER',
     metric    => 'pct_mem_used',
   });

my $free_entry = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'snAgGblDynMemFree',
     oid       => '1.3.6.1.4.1.1991.1.1.2.1.55.0',
     data_type => 'INTEGER',
     metric    => 'mem_free',
   });

sub run {
    my %args = @_;

    my $result = $args{result};

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new();
    $oid_list->add_entries($used_entry, $free_entry);

    $oid_list->run(%args);

}

1;
