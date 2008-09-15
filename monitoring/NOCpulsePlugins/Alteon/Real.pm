package Alteon::Real;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

my @entries =
  (
   { name      => 'slbRealServerInfoEntry',
     oid       => '1.3.6.1.4.1.1872.2.1.9.2.2.1.2',
     data_type => 'OCTET_STRING',
     is_index  => 1,
     match_index_param => 'alteon_real',
   },
   { name      => 'slbStatRServerCurrSessions',
     oid       => '1.3.6.1.4.1.1872.2.1.8.2.5.1.2',
     data_type => 'INTEGER',
     metric    => 'sessions',
   },
   { name      => 'slbStatRServerHighestSessions',
     oid       => '1.3.6.1.4.1.1872.2.1.8.2.5.1.5',
     data_type => 'INTEGER',
     metric    => 'high_sessions',
   },
   { name      => 'slbRealServerInfoState',
     oid       => '1.3.6.1.4.1.1872.2.1.9.2.2.1.7',
     data_type => 'STATE_VALUE',
     vendor_enum =>
     { '1' => 'OTHER',
       '2' => 'RUNNING',
       '3' => 'FAILED',
       '4' => 'DISABLED',
     },
     status_enum =>
     { '1' => 'WARN',
       '2' => 'OK',
       '3' => 'CRITICAL',
       '4' => 'WARN',
     },
   },
  );

sub run {
    my %args = @_;
    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
