
package NOCpulse::SatConfig::TranslateKey;

use strict;

use CGI;
use NOCpulse::NPRecords;

############
sub Return {
############
    my $request = shift;
    my $nsinfo = shift;
    
    # Return the translated key  
    
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
    my $key    = $q->param('scout_shared_key');

    my $sat_record = SatNodeRecord->LoadOneFromSql("select sat_cluster_id from rhn_sat_node where scout_shared_key = '$key'");
    if (not defined($sat_record)) {
        return &Reject($request, "Could not determine sat_record for the given shared key of \'$key\'");
    }

    my $sat_cluster_id = $sat_record->get_SAT_CLUSTER_ID;
    CFDBRecord->ReleaseAllInstances;
    CFDBRecord->Rollback;
	
    if ($sat_cluster_id) {
	return &Return($request, $sat_cluster_id);
    }
    else {
	return &Reject($request, "Could not determine sat_cluster_id for the given shared key of \'$key\'");
    }

}

1;
