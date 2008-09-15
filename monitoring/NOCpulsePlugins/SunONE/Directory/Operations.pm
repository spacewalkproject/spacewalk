package SunONE::Directory::Operations;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    my $dsport = $args{params}->{dsport};
    my @entries =
      (
       { name      => 'dsInOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.6.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'inops',
       },
       { name      => 'dsReadOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.7.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'readops',
       },
       { name      => 'dsCompareOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.8.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'compops',
       },
       { name      => 'dsAddEntryOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.9.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'addops',
       },
       { name      => 'dsRemoveEntryOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.10.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'removeops',
       },
       { name      => 'dsModifyEntryOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.11.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'modifyops',
       },
       { name      => 'dsModifyRDNOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.12.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'modrdnops',
       },
       { name      => 'dsListOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.13.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'listops',
       },
       { name      => 'dsSearchOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.14.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'searchops',
       },
       { name      => 'dsOneLevelSearchOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.15.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'olsops',
       },
       { name      => 'dsWholeSubtreeSearchOps',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.16.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'wssops',
       },
       { name      => 'dsReferrals',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.17.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'referrals',
       },
       { name      => 'dsChainings',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.18.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'chainings',
       },
       { name      => 'dsSecurityErrors',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.19.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'secerrors',
       },
       { name      => 'dsErrors',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.20.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'errps',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
