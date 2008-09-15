package SunONE::Application::Connections;

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
       { name      => 'nasEngTotalConn',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.22.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'totalconn',
       },
       { name      => 'nasEngTotalConnNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.23.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'usedconn',
       },
       { name      => 'nasEngTotalAccept',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.24.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'listenconn',
       },
       { name      => 'nasEngTotalAcceptNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.25.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'usedlc',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
