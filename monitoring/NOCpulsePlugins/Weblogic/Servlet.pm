package Weblogic::Servlet;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;

    #need to add the 'ExecuteQueueRuntime' syntax to match the queue_name in the snmp output
    #$args{params}->{queue_name} = "ExecuteQueueRuntime:".$args{params}->{queue_name};

    #if the admin server param is set, send snmp queries to that ip address
    if ($args{params}->{admin_server}) {
        $args{params}->{ip} = $args{params}->{admin_server};
    }

    my @entries =
      (
       { name      => 'servletRuntimeServletName',
         oid       => '1.3.6.1.4.1.140.625.380.1.25',
         data_type => 'OCTET_STRING',
         is_index  => 1,
         match_index_param => 'servlet_name',
       },
       { name      => 'servletRuntimeExecutionTimeHigh',
         oid       => '1.3.6.1.4.1.140.625.380.1.50',
         data_type => 'INTEGER',
	 metric    => 'high_exec_time',
       },
       { name      => 'servletRuntimeExecutionTimeLow',
         oid       => '1.3.6.1.4.1.140.625.380.1.55',
         data_type => 'INTEGER',
	 metric    => 'low_exec_time',
       },
       { name      => 'servletRuntimeInvocationTotalCount',
         oid       => '1.3.6.1.4.1.140.625.380.1.35',
         data_type => 'COUNTER32',
	 metric    => 'invocation_rate',
       },
       { name      => 'servletRuntimeReloadTotalCount',
         oid       => '1.3.6.1.4.1.140.625.380.1.30',
         data_type => 'COUNTER32',
	 metric    => 'reload_rate',
       },
       { name      => 'servletRuntimeExecutionTimeAverage',
         oid       => '1.3.6.1.4.1.140.625.380.1.60',
         data_type => 'INTEGER',
	 metric    => 'avg_exec_time',
       },
       { name      => 'servletRuntimeExecutionTimeTotal',
         oid       => '1.3.6.1.4.1.140.625.380.1.45',
         data_type => 'INTEGER',
	 metric    => 'tot_exec_time',
       },
      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
