package Ingrian::CPU;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'sysStatCPU',
     oid       => '1.3.6.1.4.1.5595.2.3.3.0',
     data_type => 'INTEGER',
     metric    => 'cpu_avg',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
