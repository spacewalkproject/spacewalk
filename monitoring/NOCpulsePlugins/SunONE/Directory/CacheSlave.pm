package SunONE::Directory::CacheSlave;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    my $dsport = $args{params}->{dsport};
    my @entries =
      (
       { name      => 'dsCopyEntries',
	 oid       => "1.3.6.1.4.1.1450.7.2.1.2.$dsport",
	 data_type => 'INTEGER',
	 metric    => 'copyentry',
       },
       { name      => 'dsCacheEntries',
	 oid       => "1.3.6.1.4.1.1450.7.2.1.3.$dsport",
	 data_type => 'INTEGER',
	 metric    => 'cacheentry',
       },
       { name      => 'dsCacheHits',
	 oid       => "1.3.6.1.4.1.1450.7.2.1.4.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'cachehits',
       },
       { name      => 'dsSlaveHits',
	 oid       => "1.3.6.1.4.1.1450.7.2.1.5.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'slavehits',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
