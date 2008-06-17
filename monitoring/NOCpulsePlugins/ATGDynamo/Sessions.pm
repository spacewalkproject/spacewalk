package ATGDynamo::Sessions;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'generic',
     oid       => '1.3.6.1.4.1.2725.1.3.2',
     data_type => 'INTEGER',
     metric    => 'sessions',
   },
  );

sub run {
    my %args = @_;
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    $args{params}->{version} = 2;

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
