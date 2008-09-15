package SunONE::Application::AppLogicStatus;

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
       { name      => 'nasEngBindTotal',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.30.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'bound',
       },
       { name      => 'nasEngBindTotalCached',
	 oid       => "1.3.6.1.4.1.1450.3.21.1.31.$kesport.$engport",
	 data_type => 'COUNTER32',
	 metric    => 'cacheps',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
