package General::UptimeSNMP;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'Uptime',
     oid       => '1.3.6.1.2.1.1.3.0',
     data_type => 'OCTET_STRING',
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
