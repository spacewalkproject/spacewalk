package Weblogic::ExecuteQueue;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;

    #need to add the 'ExecuteQueueRuntime' syntax to match the queue_name in the snmp output
    $args{params}->{queue_name} = "ExecuteQueueRuntime:".$args{params}->{queue_name};

    #if the admin server param is set, send snmp queries to that ip address
    if ($args{params}->{admin_server}) {
        $args{params}->{ip} = $args{params}->{admin_server};
    }

    my @entries =
      (
       { name      => 'executeQueueRuntimeObjectName',
         oid       => '1.3.6.1.4.1.140.625.180.1.5',
         data_type => 'OCTET_STRING',
         is_index  => 1,
         match_index_param => 'queue_name',
       },
       { name      => 'executeQueueRuntimePendingRequestCurrentCount',
         oid       => '1.3.6.1.4.1.140.625.180.1.35',
         data_type => 'INTEGER',
	 metric    => 'queue_length',
       },
       { name      => 'executeQueueRuntimeExecuteThreadCurrentIdleCount',
         oid       => '1.3.6.1.4.1.140.625.180.1.25',
         data_type => 'INTEGER',
	 metric    => 'idle_threads',
       },
       { name      => 'executeQueueRuntimeServicedRequestTotalCount',
         oid       => '1.3.6.1.4.1.140.625.180.1.40',
         data_type => 'COUNTER32',
	 metric    => 'request_rate',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
