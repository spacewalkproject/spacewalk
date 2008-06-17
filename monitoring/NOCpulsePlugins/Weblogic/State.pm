package Weblogic::State;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;

    #if the admin server param is set, send snmp queries to that ip address
    if ($args{params}->{admin_server}) {
        $args{params}->{ip} = $args{params}->{admin_server};
    }

    my @entries =
      (
       { name      => 'serverRuntimeName',
         oid       => '1.3.6.1.4.1.140.625.360.1.15',
         data_type => 'OCTET_STRING',
         is_index  => 1,
         match_index_param => 'server_name',
       },
       { name      => 'serverRuntimeState',
         oid       => '1.3.6.1.4.1.140.625.360.1.60',
         data_type => 'OCTET_STRING',
         label     => 'State'
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
