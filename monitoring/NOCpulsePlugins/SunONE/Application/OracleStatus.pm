package SunONE::Application::OracleStatus;

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
       { name      => 'nasEngORCLQueryTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.44.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'oraqps',
       },
       { name      => 'nasEngORCLPreparedQueryTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.45.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'orapqps',
       },
       { name      => 'nasEngORCLConnTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.46.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'oratlconn',
       },
       { name      => 'nasEngORCLConnNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.47.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'orauseconn',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
