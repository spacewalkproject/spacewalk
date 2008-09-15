package SunONE::Application::Requests;

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
       { name      => 'nasEngTotalReq',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.13.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'reqrate',
       },
       { name      => 'nasEngReqNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.14.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'reqrunning',
       },
       { name      => 'nasEngReqWait',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.15.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'reqswait',
       },
       { name      => 'nasEngReqReady',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.16.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'reqsready',
       },
       { name      => 'nasEngAvgReqTime',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.17.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'avgreqtime',
       },
       { name      => 'nasEngThreadNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.18.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'threads',
       },
       { name      => 'nasEngThreadWait',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.19.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'idlethread',
       },
       { name      => 'nasEngWebReqQueue',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.20.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'reqsqueued',
       },
       { name      => 'nasEngFailedReq',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.21.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'failedreqs',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
