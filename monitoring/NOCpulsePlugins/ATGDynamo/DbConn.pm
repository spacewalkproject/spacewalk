package ATGDynamo::DbConn;

use strict;

use POSIX 'ceil';
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::SNMP::MibEntryList;

my $conns = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'generic',
     oid       => '1.3.6.1.4.1.2725.1.5.1.1.7.1',
     data_type => 'INTEGER',
     metric    => 'dbconn',
   }
  );

sub run {
    my %args = @_;

    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    $args{params}->{version} = 2;

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new();
    $oid_list->add_entries($conns);
    $oid_list->run(%args);

}

1;
