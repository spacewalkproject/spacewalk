package Weblogic::HeapFree;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;

    #need to add the 'JVMRuntime:' syntax to match the queue_name in the snmp output
    $args{params}->{server_name} = "JVMRuntime:".$args{params}->{server_name};

    #if the admin server param is set, send snmp queries to that ip address
    if ($args{params}->{admin_server}) {
        $args{params}->{ip} = $args{params}->{admin_server};
    }

    my @entries =
      (
       { name      => 'jvmRuntimeObjectName',
         oid       => '1.3.6.1.4.1.140.625.340.1.5',
         data_type => 'OCTET_STRING',
         is_index  => 1,
         match_index_param => 'server_name',
       },
       { name      => 'jvmRuntimeHeapFreeCurrent',
         oid       => '1.3.6.1.4.1.140.625.340.1.25',
         data_type => 'INTEGER',
	 metric    => 'value',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
