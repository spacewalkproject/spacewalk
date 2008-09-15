package SunONE::Application::SybaseStatus;

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
       { name      => 'nasEngSYBQueryTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.48.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'sybqps',
       },
       { name      => 'nasEngSYBPreparedQueryTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.49.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'sybpqps',
       },
       { name      => 'nasEngSYBConnTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.50.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'sybtlconn',
       },
       { name      => 'nasEngSYBConnNow',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.51.$kesport.$engport",
	 data_type => 'INTEGER',
	 metric    => 'sybuseconn',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
