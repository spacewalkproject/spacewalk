#!/usr/bin/perl

use strict;
use CGI;
use NOCpulse::CF_DB;
use Data::Dumper;
use Time::Local;
use Mail::Send;

# Save execution output from a CommandQueue command.

# Global variables
my $q      = new CGI;
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
    &Drop($q, 'Missing required param');
    exit 0;
}

# Template for a good point (with good fake values for fake datapoints)
my %TEMPLATE = (
  instance_id    => $iid,        # instance ID
  netsaint_id    => $target_id,
  target_type    => $target_type,
  exit_status    => -1,          # exit status of command
  execution_time => 0,           # time command took to execute
  date_executed  => "'sysdate'", # date command was executed
  STDOUT         => 'NULL',      # standard output
  STDERR         => 'NULL',      # standard error
);

# Required fields:
my @REQUIRED = keys %TEMPLATE;


my($parsed) = &ProcessInput($q);

my $rv = $CF_DB->updateCQ_Exec($iid, $target_id, $target_type,
			       $parsed->{'values'}, 
			       $parsed->{'bindvars'}); 
if ($rv) {
    
  # Send notification, if requested
  &do_notification($iid, $cluster_id, $target_id, $target_type);
    
  # Return successful exit status to client
  &Accept($q);

} else {

  &Reject($q, "Couldn't insert into database: $@");

}

exit 0;


##############################################################################
###############################  Subroutines  ################################
##############################################################################

##################
sub ProcessInput {
##################
  my $q = shift;

  # Return hash:
  #  { values => \@values, bindvars => \@bindvars }

  my(@values, @bindvars, @errors);
  my $field;
  foreach $field (@REQUIRED) {

    my $value = $q->param($field);
    if (! defined($value)) {
      push(@errors, "Missing field '$field'");
      next;
    }

    if ($field eq 'date_executed') {

      my($sec,$min,$hour,$mday,$mon,$year) = localtime($value);
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
    foreach $field (@REQUIRED) {
      if ($field eq 'STDERR') {
        push(@values, "$field = ?");
      } else {
	push(@values, "$field = " . $TEMPLATE{$field});
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
  my($iid, $cluster_id, $target_id, $target_type) = @_;
  my $instance = $CF_DB->getCQ_Instance_by_recid($iid);
  my $recipient = $instance->{'notify_email'};
  return unless ($recipient =~ /\S/);

  my $command  = $CF_DB->getCQ_Command_by_recid($instance->{'command_id'});
  my $sat      = $CF_DB->getNetsaint_by_recid($cluster_id);
  my $exec     = $CF_DB->getCQ_Execs_by_instance_target($iid, $target_id, $target_type);
  my ($pdata,$pord) = $CF_DB->getCQ_Params_by_instance_id($iid, ['ord']);

  my @params;
  foreach my $param (@$pord) {
    push(@params, $pdata->{$param}->{'value'});
  }
  my $command_line=sprintf($command->{'command_line'}, @params);


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
  Command line:    $command_line
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
  my $query = shift;

  # Accept the data point
  print $query->header(-status=>200),
        $query->start_html('Success'),
        $query->h2('Datapoint successfully uploaded'),
        $query->end_html(), "\n";

}


############
sub Reject {
############
  my $query   = shift;
  my $message = join('', @_);

  # Reject the data point with a 503 Service Unavailable status
  print $query->header(-status=>503),
        $query->start_html('Error'),
        $query->h2('Datapoint rejected'),
        $query->strong($message),
        $query->end_html(), "\n";

}


##########
sub Drop {
##########
  my $query   = shift;
  my $message = join('', @_);

  # There's no good way to handle this one -- drop it with
  # a 200 exit status
  print $query->header(-status=>202),
        $query->start_html('Datapoint dropped'),
        $query->h2('Datapoint dropped'),
        $query->strong($message),
        $query->end_html(), "\n";

}
