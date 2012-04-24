
package NOCpulse::AcceptStatusLog;

use strict;

use RHN::DBI;
use PXT::Config;
use CGI;
use NOCpulse::Config;
use LWP::UserAgent;
use vars qw($timeout %KeyToId);
use Apache2::RequestRec;

$timeout = 2; 
%KeyToId;  # Global cache - See bug #133581 for details and notes

sub store_probe_state
{
    my $cs_dbh = shift;
    my $sat_cluster_id = shift;
    my $probe_state = shift;
    
    # print "storing probe state...\n";

    my $update_probe = $cs_dbh->prepare(q{
      UPDATE RHN_PROBE_STATE
      SET    LAST_CHECK = to_timestamp(?, 'YYYY-MM-DD HH24:MI:SS'),
             STATE = ?,
             OUTPUT = ?
      WHERE  SCOUT_ID = ?
      AND    PROBE_ID = ?
    });
    
    my $insert_probe = $cs_dbh->prepare(q{
      INSERT INTO RHN_PROBE_STATE
        (LAST_CHECK, STATE, OUTPUT, SCOUT_ID, PROBE_ID) 
      VALUES 
        (to_timestamp(?, 'YYYY-MM-DD HH24:MI:SS'), ?, ?, ?, ?)
    });
    
    my @lines = split("\n", $probe_state);
    my $line;
    my $count = 0;
    my $probes_per_commit = PXT::Config->get('monitoring_probes_batch_size');
    
    foreach $line (@lines)
    {
        my ($probe_id, $last_check, $state, $output);

        if( $line =~ /^(\d+)\s(\d*)\s(\S*)\s(.*)$/ )
	{
            ($probe_id, $last_check, $state, $output) = ($1, $2, $3, $4);
	}
	else
	{
            #$self->dprint(1, "Error: Can't parse $line\n");
	    next;
        }
	
	# print "storing PROBE $probe_id state $state last_check $last_check output $output\n";

        my($sec,$min,$hour,$mday,$mon,$year) = localtime($last_check);
        my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d",
          $year + 1900, $mon + 1, $mday, $hour, $min, $sec);

	
	$update_probe->execute($timestamp, $state, $output, 
                               $sat_cluster_id, $probe_id)
	    or die(sprintf("%s sat_cluster_id = %s, probe_id = %s",
                           $cs_dbh->errstr, $sat_cluster_id,  $probe_id));
	
	if( $update_probe->rows == 0 ) {
	    $insert_probe->execute($timestamp, $state, $output, 
                                   $sat_cluster_id, $probe_id)
                or die(sprintf("%s sat_cluster_id = %s, probe_id = %s",
                               $cs_dbh->errstr, $sat_cluster_id,  $probe_id));
	}

	$count ++;
	if ( $count >= $probes_per_commit ) {
	    $count = 0;
	    $cs_dbh->commit();
	}

    }

    $cs_dbh->commit();

    # print "probe state stored\n";
    
}


sub store_program
{
    my $cs_dbh         = shift;
    my $sat_cluster_id = shift;
    my $q              = shift;

    # print "storing node state...\n";

    my @params = qw( probe_count pct_ok pct_warning pct_critical pct_unknown
                     pct_pending recent_state_changes imminent_probes
                     max_exec_time min_exec_time avg_exec_time max_latency
                     min_latency avg_latency );

    my $update_sql = 
        "UPDATE RHN_SATELLITE_STATE SET LAST_CHECK = CURRENT_TIMESTAMP";

    my $insert_sql = sprintf(
       "INSERT INTO RHN_SATELLITE_STATE (SATELLITE_ID, LAST_CHECK, %s) " .
       "VALUES (?, CURRENT_TIMESTAMP", join(",\n", @params));

    my @bindvars;

    foreach my $param (@params) {
      $update_sql .= ",\n\t$param = ?";
      $insert_sql .= ", ?";
      push(@bindvars, 0 + $q->param($param));
    }

    $update_sql .= "\nWHERE satellite_id = ?";
    $insert_sql .= ")";

    my $update_program = $cs_dbh->prepare($update_sql);
     
    my $insert_program = $cs_dbh->prepare($insert_sql);
    
    # print "storing PROGRAM $sat_cluster_id\n";
    
    $update_program->execute(@bindvars, $sat_cluster_id)
	or die $cs_dbh->errstr." sat_cluster_id = $sat_cluster_id";
    
    if( $update_program->rows == 0 ) {
	$insert_program->execute($sat_cluster_id, @bindvars)
	    or die $cs_dbh->errstr." sat_cluster_id = $sat_cluster_id";
    }

    $cs_dbh->commit();

    # print "node state stored\n";

}



sub clusterIdFromKey
{
	my $key = shift();
	if (exists($KeyToId{$key})) {
		return $KeyToId{$key}
	} else {
		my $ua = LWP::UserAgent->new;
		$ua->agent("SatIDXL8r/1.0 ");
		my $req = HTTP::Request->new(GET => "http://localhost/cgi-bin/translate_key.cgi?scout_shared_key=$key");
		$req->content_type('application/x-www-form-urlencoded');
	
		# alarm around this else apache can hang
		my $res;
		eval {
			local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
			alarm $timeout;
			$res = $ua->request($req);
			alarm 0;
		};
		
		if ($res->is_success) {
			my $id = $res->content;
			chomp($id);
			$KeyToId{$key} = $id;
			return $id;
		} else {
			return;
		}
	}
}


#######################################
# mod_perl handler()
#######################################

sub handler
{
    my $r = shift;

    my $query = CGI->new($r->args());

    my $q = $query->param('queuename');

    my $log_process_start = time();
    
    my $sat_cluster_id = clusterIdFromKey($query->param('sat_cluster_id'));
    my $probe_state    = $query->param('probe_state');
    
    my $cs_dbh;
    
    eval
    {
	if( not defined $sat_cluster_id)
	{
	    die "unspecified satellite cluster id";
	}
	
	my $cfg = new NOCpulse::Config;
	
	$ENV{'ORACLE_HOME'} = $cfg->get('oracle', 'ora_home');
	
	my $cs_dbd     = $cfg->get('cs_db', 'dbd');
	my $cs_dbname  = $cfg->get('cs_db', 'name');
	my $cs_dbuname = $cfg->get('cs_db', 'username');
	my $cs_dbpass  = $cfg->get('cs_db', 'password');
	
	eval
	{
	    # print "connecting to current state database...\n";
	    
	    $cs_dbh = RHN::DBI->connect();
	};
	if( not defined $cs_dbh )
	{
	    die "Can't connect to current state database: $DBI::errstr";
	}
	
	# print "connected.\n";
	
	store_probe_state($cs_dbh, $sat_cluster_id, $probe_state);
	
	store_program($cs_dbh, $sat_cluster_id, $query);
	
	$cs_dbh->disconnect();
	
    };

    my $error = $@;

    $r->content_type('text/html');
    
    if( $error )
    {
	if( defined $cs_dbh ) {
	    $cs_dbh->rollback();
	    $cs_dbh->disconnect();
	}
	$r->log_error("Error while processing status log: $error\n");
	$r->print("$error\n");

	return 500;
    }
    else
    {
	return 0;
    }
    
}

1;
