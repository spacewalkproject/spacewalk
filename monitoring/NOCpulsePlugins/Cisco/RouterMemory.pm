package Cisco::RouterMemory;

use strict;

use POSIX 'ceil';
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::SNMP::MibEntryList;


my $used_entry = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'ciscoMemoryPoolUsed',
     oid       => '1.3.6.1.4.1.9.9.48.1.1.1.5.1',
     data_type => 'INTEGER',
     metric    => 'mem_used',
   });

my $free_entry = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'ciscoMemoryPoolFree',
     oid       => '1.3.6.1.4.1.9.9.48.1.1.1.6.1',
     data_type => 'INTEGER',
     metric    => 'mem_free',
   });

sub run {
    my %args = @_;

    my $result = $args{result};

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new();
    $oid_list->add_entries($used_entry, $free_entry);

    $oid_list->run(%args);

    my $used = $used_entry->fetched_value;
    my $free = $free_entry->fetched_value;

    if (defined($used) && defined($free)) {
        my $pct_used = ceil($used / ($used + $free) * 100);
        $result->metric_value('pct_mem_used', $pct_used, '%d');
    }
}

1;
