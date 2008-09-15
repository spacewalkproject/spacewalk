package SunONE::Application::DBEngineStatus;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

sub run {
    my %args = @_;
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    $args{params}->{version} = 1;
    my $kesport = $args{params}->{kesport};
    my $engport = $args{params}->{engport};

    my @entries =
      (
       { name      => 'nasEngDAETotalQuery',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.35.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'dbqps',
       },
       { name      => 'nasEngDAEQueryNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.36.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'queries',
       },
       { name      => 'nasEngDAETotalConn',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.37.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'dbtlconn',
       },
       { name      => 'nasEngDAEConnNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.38.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'dbusedconn',
       },
       { name      => 'nasEngDAECacheCount',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.39.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'caches',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
