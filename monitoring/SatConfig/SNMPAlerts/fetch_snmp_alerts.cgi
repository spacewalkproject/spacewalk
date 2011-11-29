#!/usr/bin/perl

use strict;
use CGI qw/-unique_headers/;;
use NOCpulse::Config;
use NOCpulse::NPRecords;
use Time::Local;
use URI::Escape;
use Data::Dumper;

###################
sub netsaint_form {
###################

  my $MYURL = shift;

  my $str = "Please select a satellite:<BR>\n";
  $str .= "<FORM ACTION='$MYURL'>\n";
  $str .= &satellitemenu('cluster_id') . "<BR>";
  $str .= '<INPUT TYPE="submit"><INPUT TYPE="reset">';
  $str .= "</FORM>\n";

  return $str;
}

###################
sub satellitemenu {
###################
  my $name   = shift;

  my($satid, $last, $label);
  my $menu = "<SELECT SIZE=10 NAME='$name'>\n";

  my $satref = SatClusterRecord->LoadFromSql(
                                  "SELECT * FROM rhn_sat_cluster", 'RECID');
  my $satsort = sub {
    $_[0]->{'CUSTOMER_ID'} <=> $_[1]->{'CUSTOMER_ID'} 
    or
    $_[0]->{'DESCRIPTION'} cmp $_[1]->{'DESCRIPTION'} 
  };


  SatClusterRecord->Map(sub {
    my $cluster = shift;
    my $clid    = $cluster->{'RECID'};
    my $cid     = $cluster->{'CUSTOMER_ID'};
    my $desc    = $cluster->{'DESCRIPTION'};
    my $url     = $cluster->{'VIP'};
    if ($cid eq $last) {
      $label = sprintf("%s%s (%s)", "&nbsp;" x 8, $desc, $url);
    } else {
      $label = sprintf("%s%s (%s)", $cid . "&nbsp;" x (8 - length($cid) - 2), 
                                       $desc, $url);
    }
    $menu .= "\t<OPTION VALUE='$clid'>$label\n";
    $last = $cid;
  }, $satsort);

  $menu .= "</SELECT>\n";

  return $menu;

}


##############
sub unixtime {
##############
  my $timestamp = shift;
  my($year, $month, $day, $hour, $min, $sec) = split(/\s+/, $timestamp);
  return timegm($sec,$min,$hour,$day,$month-1,$year-1900);
}

###################
sub print_command {
###################

  my $iid = shift;
  my $command = shift;
  my $BADCHARS = shift;

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
my $clusterid = $q->param('cluster_id');
my $lastrecid = $q->param('last_recid');
my $BADCHARS  = '\x25\x26\x2f\x3b\x3c\x3e\x5c\x0a\0d'; # % & / ; < > \ NL CR
$|=1;

if ($clusterid =~ /^\d+$/) {

  # Clear out old alerts
  if ($lastrecid =~ /^\d+$/) {
    SNMPAlertRecord->ClearForSatCluster($clusterid, $lastrecid);
  }

  # Fetch current alerts
  SNMPAlertRecord->LoadForSatCluster($clusterid);

  # Return current alerts to the satellite
  print $q->header(-type=>'application/xml');
  print SNMPAlertRecord->AsXML;

} else {

  print $q->header(-type=>'text/html');
  print &netsaint_form($MYURL);

}

