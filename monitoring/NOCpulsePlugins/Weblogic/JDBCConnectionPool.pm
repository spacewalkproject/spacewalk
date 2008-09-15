package Weblogic::JDBCConnectionPool;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;


sub run {
    my %args = @_;

    #need to add the 'JDBCConnectionPoolRuntime:' syntax to match the pool_name in the snmp output
    $args{params}->{pool_name} = "JDBCConnectionPoolRuntime:".$args{params}->{pool_name};

    #if the admin server param is set, send snmp queries to that ip address
    if ($args{params}->{admin_server}) {
        $args{params}->{ip} = $args{params}->{admin_server};
    }

    my @entries =
      (
       { name      => 'jdbcConnectionPoolRuntimeObjectName',
         oid       => '1.3.6.1.4.1.140.625.190.1.5',
         data_type => 'INTEGER',
         is_index  => 1,
         match_index_param => 'pool_name',
       },
       { name      => 'jdbcConnectionPoolRuntimeActiveConnectionsCurrentCount',
         oid       => '1.3.6.1.4.1.140.625.190.1.25',
         data_type => 'INTEGER',
	 metric    => 'connections',
       },
       { name      => 'jdbcConnectionPoolRuntimeConnectionsTotalCount',
         oid       => '1.3.6.1.4.1.140.625.190.1.55',
         data_type => 'COUNTER32',
	 metric    => 'conn_rate',
       },

       { name      => 'jdbcConnectionPoolRuntimeWaitingForConnectionCurrentCount',
         oid       => '1.3.6.1.4.1.140.625.190.1.30',
         data_type => 'INTEGER',
	 metric    => 'waiters',
       },
       { name      => 'jdbcConnectionPoolRuntimeWaitingForConnectionHighCount',
         oid       => '1.3.6.1.4.1.140.625.190.1.45',
         data_type => 'INTEGER',
	 label     => 'High Waiters',
       },
       { name      => 'jdbcConnectionPoolRuntimeActiveConnectionsHighCount',
         oid       => '1.3.6.1.4.1.140.625.190.1.40',
         data_type => 'INTEGER',
	 label     => 'High Connections',
       },
       { name      => 'jdbcConnectionPoolRuntimeWaitSecondsHighCount',
         oid       => '1.3.6.1.4.1.140.625.190.1.50',
         data_type => 'INTEGER',
	 label     => 'High Wait Time',
       },
       { name      => 'jdbcConnectionPoolRuntimeMaxCapacity',
         oid       => '1.3.6.1.4.1.140.625.190.1.60',
         data_type => 'INTEGER',
	 label     => 'Max Capacity',
       },


      );

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;
