package SunONE::Messaging::MTAMessages;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'mtaReceivedMessages',
     oid       => '1.3.6.1.2.1.28.1.1.1.1',
     data_type => 'COUNTER32',
     metric    => 'msgsrecd',
   },
   { name      => 'mtaTransmittedMessages',
     oid       => '1.3.6.1.2.1.28.1.1.2.1',
     data_type => 'COUNTER32',
     metric    => 'msgssent',
   },
   { name      => 'mtaStoredMessages',
     oid       => '1.3.6.1.2.1.28.1.1.3.1',
     data_type => 'COUNTER32',
     metric    => 'msgsstored',
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
