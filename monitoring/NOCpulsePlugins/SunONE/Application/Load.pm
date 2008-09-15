package SunONE::Application::Load;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

sub run {
    my %args = @_;
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    $args{params}->{version} = 1;
    my $kesport = $args{params}->{kesport};

    my @entries =
      (
       { name      => 'nasKesRequestLoad',
	 oid       => "1.3.6.1.4.1.1450.3.10.1.8.$kesport",
	 data_type => 'INTEGER',
	 metric    => 'reqs',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
