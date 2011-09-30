
package NOCpulse::SatConfig::Bootstrap;

use strict;

use CGI;
use NOCpulse::NPRecords;

############
sub Return {
############
    my $request = shift;
    my $nsinfo = shift;
    
    # Return the netsaint record 
    
    $request->content_type('text/plain');
    $request->print($nsinfo);
    
    return 0;
}


############
sub Reject {
############
    my $request = shift;
    my $message = join('', @_);
    
    # Reject the data point with a 503 Service Unavailable status

    # +++ How do you set the message?  Something to figure out
    # +++ later.

    return 503;
}

#######################################
# mod_perl handler()
#######################################

sub handler
{
    my $request = shift;

    my $q = CGI->new($request->args());

    my $MYURL  = $q->url();
    my $ssk    = $q->param('ssk');
    my $key    = $q->param('publickey');
    my $cert   = $q->param('cert');
    my $certHash   = $q->param('certhash');
    
    if (defined($ssk)) {

	my $satrec;
	
	if (defined($ssk)) {
	    $satrec  = SatNodeRecord->LoadOneFromSql("select recid,ip,sat_cluster_id,scout_shared_key from rhn_sat_node where scout_shared_key = '$ssk'");
	    if (! defined($satrec)) {
		return &Reject($request, "Couldn't look up record for Scout Shared Key $ssk: $@");
	    } 
	}

	my $clustid = $satrec->get_SAT_CLUSTER_ID;
	my $satid = $satrec->get_RECID;
	my $scout_shared_key = $satrec->get_SCOUT_SHARED_KEY;
	my $clustrec = SatClusterRecord->LoadOneFromSql("select recid,description,customer_id from rhn_sat_cluster where recid = '$clustid'");
	my $isll = CFDBRecord->LoadOneFromSql("select netsaint_id from rhn_ll_netsaint where netsaint_id = '$clustid'") ? 1 : 0;
	CFDBRecord->ReleaseAllInstances;
	
	# Store the satellite public key if one was provided
	if (defined($key)) {
	    CFDBRecord->DatabaseConnection->prepare("update rhn_sat_cluster set public_key = '$key' where recid = $clustid")->execute;
	    CFDBRecord->Commit;
	}
	if (defined($cert)) {
	    CFDBRecord->DatabaseConnection->prepare("update rhn_sat_cluster set pem_public_key = '$cert', pem_public_key_hash = '$certHash' where recid = $clustid")->execute;
	    CFDBRecord->Commit;
	}
    
	return &Return($request, join(':', $isll, $scout_shared_key, $satid, $clustrec->get_DESCRIPTION, $clustrec->get_CUSTOMER_ID, $satrec->get_IP));
	
    }
    else {
	
	return &Reject($request, "Parameter 'ssk' required but not supplied");
	
    }
}

1;
