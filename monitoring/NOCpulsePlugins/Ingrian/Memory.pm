package Ingrian::Memory;

use strict;

use POSIX 'ceil';
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::SNMP::MibEntryList;


my $used_entry = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'sysStatMem',
     oid       => '1.3.6.1.4.1.5595.2.3.2.0',
     data_type => 'INTEGER',
     metric    => 'pct_mem_used',
   });

sub run {
    my %args = @_;

    my $result = $args{result};

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new();
    $oid_list->add_entries($used_entry);

    $oid_list->run(%args);

}

1;
