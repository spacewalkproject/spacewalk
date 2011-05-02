package NOCpulse::SatConfig::GenerateConfig;

use strict;

use Apache2::Log ();
use DBI;
use CGI;  # for the multipart document stuff
use NOCpulse::SatConfig::ConfigDocument;
use NOCpulse::Config;
use NOCpulse::NPRecords;
use NOCpulse::DBRecord;

sub handler {
    my $request = shift;

    my $cgi = CGI->new($request->args());
    my $document = NOCpulse::SatConfig::ConfigDocument->newInitialized;

    eval {
        my $config = NOCpulse::Config->new;

        my $satClusterId = $cgi->param('satcluster')
          or die "No satcluster query parameter specified";

        SatClusterRecord->LoadFromSqlWithBind(q{
            select sat_cluster.recid, sat_cluster.customer_id,
                   location_name as physical_location_name,
                   sat_node.max_concurrent_checks, sat_node.sched_log_level,
                   sat_node.sput_log_level, sat_node.dq_log_level
            from   sat_cluster, sat_node, physical_location
            where  sat_cluster.recid = sat_node.sat_cluster_id
            and    sat_cluster.physical_location_id = physical_location.recid
            and    sat_cluster.recid = ?
            },
            [$satClusterId], 'RECID');
	
        # Ferret out the customer ID and location name for use below
        SatClusterRecord->InstanceCount() == 1
          or die "Cannot find a satellite cluster $satClusterId";

        my $satCluster = SatClusterRecord->InstancesList->[0];

        my $customerId = $satCluster->get_CUSTOMER_ID;
        my $location = $satCluster->get_PHYSICAL_LOCATION_NAME;
	
        # Get the auto_update flag
        CFDBRecord->LoadFromSqlWithBind(q{
            select recid, auto_update
            from   customer
            where  recid = ?
            },
            [$customerId], 'RECID');
        CFDBRecord->Called($customerId) or die "Cannot find customer $customerId";
        my $auto_update = CFDBRecord->Called($customerId)->get_AUTO_UPDATE;
        CFDBRecord->ReleaseAllInstances;
	
        # Generate the satellite configuration
        $satClusterId = $satCluster->get_RECID;
        eval {
            ProbeRecord->LoadForSatellite($satClusterId); # Loads CommandParamRecord as well
        };
        if ($@) {
            die "Cannot load satellite information\n" . $@;
        }

        # Add the physical location ID and auto_update flag to the probe records
        ProbeRecord->Map(sub { my $self = shift;
                               $self->addInstVar('auto_update', $auto_update);
                               $self->addInstVar('physical_location_name', $location);
                           }
                        );
        $document->set_netsaintSection(SatClusterRecord->AsXML);
        $document->set_probeSection(ProbeRecord->AsXML);
        $document->set_commandParamSection(CommandParameterRecord->AsXML());
        $document->set_commandMetricSection(CommandMetricRecord->AsXML());

        SatClusterRecord->ReleaseAllInstances();
        ProbeRecord->ReleaseAllInstances();
        CommandParameterRecord->ReleaseAllInstances();
        CommandMetricRecord->ReleaseAllInstances();
	
        # Update no-log instance probe and state tables
        my $synchMsg = synch_nolog($customerId, $satClusterId);
	if ( $synchMsg ) {
		my $byebye =  "Nolog synchronization failed: $synchMsg";
		print "$byebye\n";
		print STDERR "$byebye\n";
        	die $byebye;
	}
        $document->addMessage("Nolog probe table synchronized");
    };

    if ($@) {
        my $msg = scalar(localtime()) . ": ERROR: Spacewalk " . $cgi->param('satcluster') .
          ": Cannot generate configuration: $@";
        print STDERR  $msg;
        $request->log->crit($msg);
        $document->addMessage($msg);
    }

    $document->sendToSatellite($cgi, $request);

    return 0;
}

sub synch_nolog {
    my ($customer_id, $sat_cluster_id) = @_;

    # Log in to the nolog instance
    CSDBRecord->DatabaseConnection();

    my $sth;
    eval {
        $sth = CSDBRecord->DoSql(q{
            delete from deployed_probe
            where sat_cluster_id = ?
            or probe_type = 'url'
        },
        $sat_cluster_id);
    };
    if ($@ || CSDBRecord->DatabaseConnection->errstr()) {
        my $msg = $@ || CSDBRecord->DatabaseConnection->errstr();
        return "Cannot clear deployed probes: $msg";
    }

    my @probe_cols = qw(recid probe_type description customer_id command_id
                        contact_group_id notify_critical notify_warning 
                        notify_recovery notify_unknown notification_interval_minutes
                        check_interval_minutes retry_interval_minutes 
                        max_attempts last_update_user last_update_date);
    my $ins_probe_cols = join(', ', @probe_cols);
    my $sel_probe_cols = join(', ', map { 'probe.' . $_ } @probe_cols);

    eval {
           my $sql = qq{
             insert into deployed_probe($ins_probe_cols, sat_cluster_id, os_id)
             select $ins_probe_cols, sat_cluster_id, os_id
             from (
                select $sel_probe_cols, check_probe.sat_cluster_id, host.os_id
                from probe, check_probe, host
                where check_probe.probe_id = probe.recid
                and check_probe.sat_cluster_id = ?
                and host.recid = check_probe.host_id
             )
           };
         $sth = CSDBRecord->DoSql($sql, $sat_cluster_id);
    };
    my $msg;
    if (length($@) || length(CSDBRecord->DatabaseConnection->errstr())) {
        $msg = $@ || CSDBRecord->DatabaseConnection->errstr();
        CSDBRecord->DatabaseConnection->rollback();
    } else {
        CSDBRecord->DatabaseConnection->commit();
    }
    return $msg;
}

1;
