#!/usr/bin/perl

use strict;
use CGI qw/-unique_headers/;;
use NOCpulse::CF_DB;
use Data::Dumper;
use DateTime;
use URI::Escape;

# Keep in synch with CommandQueue.pm
my $PROTOCOL_VERSION = '1.0';

###################
sub netsaint_form {
###################

  my $MYURL = shift;
  my $CF_DB = shift;

  my $str = "Please select a satellite:<BR>\n";
  $str .= "<FORM ACTION='$MYURL'>\n";
  $str .= &satellitemenu('cluster_id', $CF_DB) . "<BR>";
  $str .= '<INPUT TYPE="submit"><INPUT TYPE="reset">';
  $str .= "</FORM>\n";

  return $str;
}

###################
sub satellitemenu {
###################
  my $name   = shift;
  my $CF_DB  = shift;

  my($satid, $last, $label);
  my $menu = "<SELECT SIZE=10 NAME='$name'>\n";

  my $satref = $CF_DB->getSatellites();
  my $satsort = sub {
    $satref->{$a}->{'customer_id'} <=> $satref->{$b}->{'customer_id'}
    or
    $satref->{$a}->{'description'} cmp $satref->{$b}->{'description'}
  };

  foreach $satid (sort $satsort keys %$satref) {
    my $cid  = $satref->{$satid}->{'customer_id'};
    my $desc = $satref->{$satid}->{'description'};
    my $url  = $satref->{$satid}->{'smon_url'};
    if ($cid eq $last) {
      $label = sprintf("%s%s (%s)", "&nbsp;" x 8, $desc, $url);
    } else {
      $label = sprintf("%s%s (%s)", $cid . "&nbsp;" x (8 - length($cid) - 2), 
                                       $desc, $url);
    }
    $menu .= "\t<OPTION VALUE='$satid'>$label\n";
    $last = $cid;
  }
  $menu .= "</SELECT>\n";


  return $menu;

}


##############
sub unixtime {
##############
  my $timestamp = shift;
  my($year, $month, $day, $hour, $min, $sec) = split(/\s+/, $timestamp);
  my $dt = DateTime->new( year => $year, month => $month, day => $day,
                          hour => $hour, minute => $min, second => $sec, 
			  time_zone => 'local' );
  return $dt->epoch;
}

###################
sub print_command {
###################

  my $CF_DB    = shift;
  my $iid      = shift;
  my $command  = shift;
  my $BADCHARS = shift;

  # Fetch command parameters
  my($pdata,$pord) = $CF_DB->getCQ_Params_by_instance_id($iid, ['ord']);
  my @params;
  foreach my $param (@$pord) {
    push(@params, $pdata->{$param}->{'value'});
  }

  # Expand the command line
  $command->{'command_line'} = sprintf($command->{'command_line'}, @params);

  # Send the command to the satellite
  print "  <INSTANCE ID='$iid'>\n";
  my $col;
  foreach $col (keys %{$command}) {
    next if ($col eq 'instance_id');  # Already got this one.
    my $value = $command->{$col};
    $value = &unixtime($value) if ($col eq 'expdate');
    $value = &uri_escape($value, $BADCHARS);
    printf "    <%s>%s</%s>\n", uc($col), $value, uc($col);
  }
  print "  </INSTANCE>\n\n";

}

############
# main
############

my $q         = new CGI;
my $MYURL     = $q->url();
my $nodeid    = $q->param('node_id');
my $clusterid = $q->param('cluster_id');
my $role      = $q->param('role');
my $version   = $q->param('version');
my $BADCHARS  = '\x00-\x1f\x25\x26\x3c\x3e\x5c\x7f';
$|=1;

if ($version ne $PROTOCOL_VERSION) {
    print STDERR scalar(localtime),
      ": fetch_commands for cluster $clusterid version mismatch: Expecting ",
        $PROTOCOL_VERSION, " but got $version\n";
}

# For debugging output
#print $q->header(-type=>'text/html'); 
#&NOCpulse::CF_DB::setDebug(9);
#&NOCpulse::CF_DB::setDebugParams(CONTEXT => 'html_comment');

my $CF_DB = new NOCpulse::CF_DB;
$CF_DB->dateformat('YYYY MM DD HH24 MI SS');

if( defined $clusterid ) {

  print $q->header(-type=>'application/xml');

  print "<COMMANDS>\n";

  if( $role eq 'lead' )
  {
    my $nsref = $CF_DB->getCurrent_CQ_Execs_by_target($clusterid, 'cluster');

    my $iid;
    foreach $iid (keys %$nsref) {

      print_command($CF_DB, $iid, $nsref->{$iid}, $BADCHARS);

      # Update the command_queue_execs table to indicate that the
      # satellite has downloaded the commands
      my $rv = $CF_DB->updateCQ_Exec($iid, $clusterid, 'cluster', ['date_accepted = current_timestamp']);
    }
  }

  my $nsref = $CF_DB->getCurrent_CQ_Execs_by_target($nodeid, 'node');
  
  my $iid;
  foreach $iid (keys %$nsref) {
      
      print_command($CF_DB, $iid, $nsref->{$iid}, $BADCHARS);
      
      # Update the command_queue_execs table to indicate that the
      # satellite has downloaded the commands
      my $rv = $CF_DB->updateCQ_Exec($iid, $nodeid, 'node', ['date_accepted = current_timestamp']);
  }

  print "</COMMANDS>\n";

} else {

  print $q->header(-type=>'text/html');
  print &netsaint_form($MYURL, $CF_DB);

}

