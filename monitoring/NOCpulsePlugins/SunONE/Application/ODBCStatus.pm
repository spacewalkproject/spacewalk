package SunONE::Application::ODBCStatus;

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
       { name      => 'nasEngODBCQueryTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.40.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'odbcqps',
       },
       { name      => 'nasEngODBCPreparedQueryTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.41.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'odbcpqps',
       },
       { name      => 'nasEngODBCConnTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.42.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'odbctlconn',
       },
       { name      => 'nasEngODBCConnNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.43.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'odbcusecon',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
