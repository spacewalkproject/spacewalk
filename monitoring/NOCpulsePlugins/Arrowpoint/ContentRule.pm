package Arrowpoint::ContentRule;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries = 
  (
   { name      => 'apCntsvcCntName',
     oid       => '1.3.6.1.4.1.2467.1.18.2.1.2',
     label     => 'Content rule',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_index_param => 'ap_virtual_0'
   },
   { name      => 'apCntsvcHits',
     oid       => '1.3.6.1.4.1.2467.1.18.2.1.4',
     data_type => 'COUNTER32',
     label     => 'Hits',
     metric    => 'hit_rate',
     value_format => '%.2f',
   },
   { name      => 'apCntsvcFrames',
     oid       => '1.3.6.1.4.1.2467.1.16.4.1.26',
     data_type => 'COUNTER32',
     metric    => 'frame_rate',
     value_format => '%.2f',
   },
   { name      => 'apCntsvcBytes',
     oid       => '1.3.6.1.4.1.2467.1.16.4.1.25',
     data_type => 'COUNTER32',
     metric    => 'bit_rate',
     value_format => '%.2f'
   },
   {
    name        => 'apCntsvcState',
    oid         => '1.3.6.1.4.1.2467.1.16.4.1.11',
    label       => 'State',
    data_type   => 'STATE_VALUE',
    vendor_enum =>
    { 0 => 'DISABLE',
      1 => 'ENABLE',
    },
    status_enum =>
    { 0 => 'OK',
      1 => 'OK',
    },
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
