package SunONE::Messaging::MTAVolume;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'mtaReceivedVolume',
     oid       => '1.3.6.1.2.1.28.1.1.4.1',
     data_type => 'COUNTER32',
     metric    => 'volrecd',
   },
   { name      => 'mtaTransmittedVolume',
     oid       => '1.3.6.1.2.1.28.1.1.6.1',
     data_type => 'COUNTER32',
     metric    => 'volsent',
   },
   { name      => 'mtaStoredVolume',
     oid       => '1.3.6.1.2.1.28.1.1.5.1',
     data_type => 'INTEGER',
     metric    => 'volstored',
   },
  );


sub run {
    my %args = @_;
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
