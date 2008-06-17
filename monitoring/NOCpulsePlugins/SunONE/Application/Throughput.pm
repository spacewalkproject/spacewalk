package SunONE::Application::Throughput;

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
       { name      => 'nasEngTotalSent',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.26.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'sentpacket',
       },
       { name      => 'nasEngTotalSentBytes',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.27.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'sentbytes',
       },
       { name      => 'nasEngTotalRecv',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.28.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'recvpacket',
       },
       { name      => 'nasEngTotalRecvBytes',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.29.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'recvbytes',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
