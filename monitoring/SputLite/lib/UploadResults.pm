package NOCpulse::SputLite::UploadResults;

use strict;
use CGI;
use NOCpulse::CF_DB;
use Data::Dumper;
use Time::Local;
use Mail::Send;

# Keep in synch with MessageQueue/CommandOutputQueue.pm
my $PROTOCOL_VERSION = '1.0';

##################
sub ProcessInput {
##################
  my $q = shift;
  my $template = shift;

  my @required = keys %$template;

  # Return hash:
  #  { values => \@values, bindvars => \@bindvars }

  my(@values, @bindvars, @errors);

  my $version = $q->param('version');
  if ($version ne $PROTOCOL_VERSION) {
    push(@errors, "SputLite::UploadResults version mismatch: Expecting ",
         $PROTOCOL_VERSION, " but got $version\n");
  }

  my $field;
  foreach $field (@required) {

    my $value = $q->param($field);
    if (! defined($value)) {
      push(@errors, "Missing field '$field'");
      next;
    }

    if ($field eq 'date_executed') {

      my($sec,$min,$hour,$mday,$mon,$year) = gmtime($value);
      my $timespec = "TO_DATE(?, ?)";
      my $timestr  = sprintf("%s/%s/%s %s:%s:%s",
	                      $mon+1, $mday, $year+1900, $hour, $min, $sec);
      push(@values,   "$field = $timespec");
      push(@bindvars, $timestr, 'MM/DD/YYYY HH24:MI:SS');

    } elsif ($field eq 'STDOUT' or $field eq 'STDERR') {

      # URI-unescape these text fields (which are URI-escaped
      # for the dequeueing agent)
      $value =~ s/%(..)/chr(hex($1))/ge;

      # Truncate to fit into a varchar2(4000)
      $value = substr($value, 0, 3996) . '...' if (length($value) > 4000);

      push(@values, "$field = ?");
      push(@bindvars, $value);

    } else {

      push(@values, "$field = ?");
      push(@bindvars, $value);

    }

  }

  if (scalar(@errors)) {

    # Bad data point.  Fake a good one, with details in STDERR.
    @values = ();
    my $message = join('\n', @errors);
    $message .= "\nQuery object:\n" . &Dumper($q) . "\n";

    my $field;
    foreach $field (@required) {
      if ($field eq 'STDERR') {
        push(@values, "$field = ?");
      } else {
	push(@values, "$field = " . $template->{$field});
      }
    }

    return {
      values   => \@values,
      bindvars => [$message]
    };


  } else {

    return {
      values   => \@values,
      bindvars => \@bindvars
    };

  }

}


#####################
sub do_notification {
#####################
  my($iid, $cluster_id, $target_id, $target_type, $CF_DB) = @_;

  my $instance = $CF_DB->getCQ_Instance_by_recid($iid);
  my $recipient = $instance->{'notify_email'};
  return unless ($recipient =~ /\S/);

  my $command  = $CF_DB->getCQ_Command_by_recid($instance->{'command_id'});
  my $sat      = $CF_DB->getNetsaint_by_recid($cluster_id);
  my $exec     = $CF_DB->getCQ_Execs_by_instance_target($iid, $target_id, $target_type);

  my $message = <<EOMSG;
Command:            $command->{'description'}
Executed by:        $sat->{'description'} (NSID $exec->{'netsaint_id'}) 
Downloaded on:      $exec->{'date_accepted'} GMT
Started on:         $exec->{'date_executed'} GMT
Completed in:       $exec->{'execution_time'} seconds
And exited with:    $exec->{'exit_status'} exit status
STDOUT:             
$exec->{'stdout'}
---------------------------------------------------------------------------
STDERR:             
$exec->{'stderr'}
---------------------------------------------------------------------------


Command details:
  Command line:    $command->{'command_line'}
  As user:         $command->{'effective_user'}
  As group:        $command->{'effective_group'}
  Notes:           $command->{'notes'}


Instance details:
  Timeout:         $instance->{'timeout'}
  Date submitted:  $instance->{'date_submitted'} GMT
  Expiration date: $instance->{'expiration_date'} GMT
  Notes:           $instance->{'notes'}
EOMSG

  my $msg = Mail::Send->new(Subject => 'Command Execution Report', To => $recipient);
  my $fh = $msg->open('sendmail');
  print $fh $message;
  $fh->close;
}


############
sub Accept {
############
    my $request = shift;
    
    # Accept the data point
    
    $request->send_http_header();
    $request->print('<html><h2>Datapoint successfully uploaded</h2></html>');
    
    return 200;
}


############
sub Reject {
############
    my $request = shift;
    my $message = join('', @_);
    
    # Reject the data point with a 503 Service Unavailable status
    $request->send_http_header();
    $request->print('<html><h2>Datapoint rejected</h2><strong>'.$message.'</strong></html>');
    
    return 503;
}


##########
sub Drop {
##########
    my $request = shift;
    my $message = join('', @_);
    
    # There's no good way to handle this one -- drop it with
    # a 200 exit status
    
    $request->send_http_header();
    $request->print('<html><h2>Datapoint dropped</h2><strong>'.$message.'</strong></html>');
    
    return 202;
}


#######################################
# mod_perl handler()
#######################################

sub handler
{
    my $request = shift;

    # Save execution output from a CommandQueue command.

    my $q = CGI->new($request->query_string());

    my $MYURL  = $q->url();
    my $CF_DB  = new NOCpulse::CF_DB;
    my $iid    = $q->param('instance_id');
    
    my $target_id = $q->param('netsaint_id');
    my $target_type = $q->param('target_type');
    my $cluster_id = $q->param('cluster_id');
    
    if( not defined $cluster_id )
    {
	# assume that this is a pre 2.12 command,
	# which means we can assume that the cluster_id
	# is the same as the target_id
	# (in other words, target_type is 'cluster')
	
	$cluster_id = $target_id;
    }
    
    if ( not defined($iid) or not defined($target_id) )
    {
	# Dammit, Jim, I'm a program, not a miracle worker!
	return &Drop($request, 'Missing required param');
    }
    
    # Template for a good point (with good fake values for fake datapoints)
    my %template = (
		    instance_id    => $iid,        # instance ID
		    netsaint_id    => $target_id,
		    target_type    => $target_type,
		    exit_status    => -1,          # exit status of command
		    execution_time => 0,           # time command took to execute
		    date_executed  => "'sysdate'", # date command was executed
		    STDOUT         => 'NULL',      # standard output
		    STDERR         => 'NULL',      # standard error
		    );
    
    my($parsed) = &ProcessInput($q, \%template);
    
    my $rv = $CF_DB->updateCQ_Exec($iid, $target_id, $target_type,
				   $parsed->{'values'}, 
				   $parsed->{'bindvars'}); 
    if ($rv) {
	
	# Send notification, if requested
	&do_notification($iid, $cluster_id, $target_id, $target_type, $CF_DB);
	
	# Return successful exit status to client
	return &Accept($request);
	
    } else {
	
	return &Reject($request, "Couldn't insert into database: $@");
	
    }
    
}

1;
