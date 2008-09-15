package SunONE::Messaging::MTARecipients;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'mtaReceivedRecipients',
     oid       => '1.3.6.1.2.1.28.1.1.7.1',
     data_type => 'COUNTER32',
     metric    => 'reciprecd',
   },
   { name      => 'mtaTransmittedRecipients',
     oid       => '1.3.6.1.2.1.28.1.1.9.1',
     data_type => 'COUNTER32',
     metric    => 'recipsent',
   },
   { name      => 'mtaStoredRecipients',
     oid       => '1.3.6.1.2.1.28.1.1.8.1',
     data_type => 'COUNTER32',
     metric    => 'recipstore',
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
