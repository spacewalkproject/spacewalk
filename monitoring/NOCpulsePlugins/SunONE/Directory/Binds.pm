package SunONE::Directory::Binds;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    my $dsport = $args{params}->{dsport};
    my @entries =
      (
       { name      => 'dsAnonymousBinds',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.1.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'anonbinds',
       },
       { name      => 'dsUnAuthBinds',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.2.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'unauthbind',
       },
       { name      => 'dsBindSecurityErrors',
	 oid       => "1.3.6.1.4.1.1450.7.1.1.5.$dsport",
	 data_type => 'COUNTER32',
	 metric    => 'bsecerrors',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
