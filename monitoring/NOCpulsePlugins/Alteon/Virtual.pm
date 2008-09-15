package Alteon::Virtual;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'slbCurCfgVirtServerIpAddress',
     oid       => '1.3.6.1.4.1.1872.2.1.5.5.1.2',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_index_param => 'alteon_virtual',
   },
   { name      => 'slbStatVServerCurrSessions',
     oid       => '1.3.6.1.4.1.1872.2.1.8.2.7.1.2',
     data_type => 'INTEGER',
     metric    => 'sessions',
   },
   { name      => 'slbStatVServerHighestSessions',
     oid       => '1.3.6.1.4.1.1872.2.1.8.2.7.1.4',
     data_type => 'INTEGER',
     metric    => 'high_sessions',
   },
   { name      => 'slbCurCfgVirtServerState',
     oid       => '1.3.6.1.4.1.1872.2.1.5.5.1.4',
     data_type => 'STATE_VALUE',
     vendor_enum =>
     { '1' => 'OTHER',
       '2' => 'ENABLED',
       '3' => 'DISABLED',
     },
     status_enum =>
     { '1' => 'WARN',
       '2' => 'OK',
       '3' => 'OK',
     },
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
