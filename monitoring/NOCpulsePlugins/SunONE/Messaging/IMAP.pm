package SunONE::Messaging::IMAP;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'applOperStatus',
     oid       => '1.3.6.1.2.1.27.1.1.6.3',
     data_type => 'STATE_VALUE',
     vendor_enum =>
     { '1' => 'UP',
       '2' => 'DOWN',
       '3' => 'HALTED',
       '4' => 'CONGESTED',
       '5' => 'RESTARTING',
       '6' => 'QUIESCING',
     },
     status_enum =>
     { '1' => 'OK',
       '2' => 'CRITICAL',
       '3' => 'WARNING',
       '4' => 'WARNING',
       '5' => 'WARNING',
       '6' => 'WARNING',
     },
   },

   { name      => 'applAccumulatedInboundAssociations',
     oid       => '1.3.6.1.2.1.27.1.1.10.3',
     data_type => 'COUNTER32',
     metric    => 'connsin',
   },
   { name      => 'applAccumulatedOutboundAssociations',
     oid       => '1.3.6.1.2.1.27.1.1.11.3',
     data_type => 'COUNTER32',
     metric    => 'connsout',
   },
   { name      => 'applRejectedInboundAssociations',
     oid       => '1.3.6.1.2.1.27.1.1.14.3',
     data_type => 'COUNTER32',
     metric    => 'rconnsin',
   },
   { name      => 'applFailedOutboundAssociations',
     oid       => '1.3.6.1.2.1.27.1.1.15.3',
     data_type => 'COUNTER32',
     metric    => 'connsf',
   },
   { name      => 'applInboundAssociations',
     oid       => '1.3.6.1.2.1.27.1.1.8.3',
     data_type => 'INTEGER',
     metric    => 'nconnsin',
   },
   { name      => 'applOutboundAssociations',
     oid       => '1.3.6.1.2.1.27.1.1.9.3',
     data_type => 'INTEGER',
     metric    => 'nconnsout',
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
