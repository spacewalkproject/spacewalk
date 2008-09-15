#!/usr/bin/perl -w

use CGI qw/-unique_headers/;
use NOCpulse::Notif::NotificationDB;
use Data::Dumper;

use vars qw/$q $MYURL $NOTIFSERVER @HOSTSTATES $TIMESTAMP %DEBUG $cfg $ndb/;

#######################
#        MAIN         #
#######################
{
$cfg = new NOCpulse::Config;
$ENV{'ORACLE_HOME'} = $cfg->get('oracle', 'ora_home');

   $q           = new CGI;
   $MYURL       = $q->url(-relative=>1);
   $NOTIFSERVER = "enqueue.cgi";
   @HOSTSTATES  = qw( UP DOWN UNKNOWN );
   $TIMESTAMP   = time();

# Debugging levels
   %DEBUG = (
  0 => "0 - Silence",
  1 => "1 - Reticence",
  2 => "2 - Verbosity",
  3 => "3 - Stream of Consciousness",
  4 => "4 - Insane Ramblings of Detail",
);

# Flow:
#  - customer selection form
#  - host probe form
#  - service probe form (optional)

$ndb = new NOCpulse::Notif::NotificationDB;
my $scout_cid=1;


if ($q->param('finished') or $q->param('show')) {

  # FINAL PAGE:  Redirection or URL & parameter display

  # The user has filled out all required information.  
  # First, fill in any missing derived fields

  if ($q->param('probetype') eq 'LongLegs') {

    my ($urlid, $url) = split(/:/, $q->param('serviceid'), 2);
    $url =~ /[A-Za-z]+:\/\/([^:\/]+)/;
    my $host = $1;
    $host = $url unless $host;
    $q->param('hostname',    $host);
    $q->param('hostid',      $host);
    $q->param('servicedesc', "$url");
    $q->param('serviceid',   $urlid);
    
  } else {

    my($hostid, $svcid) = ($q->param('hostid'), $q->param('serviceid'));
    if (defined($hostid) && ! defined($q->param('hostname'))) {
      my $record=$ndb->select_host(RECID => $hostid);
      $q->param('hostname', $record->{'NAME'});
    };

    if (defined($svcid) && ! defined($q->param('servicedesc'))) {
      my $record=$ndb->select_probe('RECID' => $svcid);
      $q->param('servicedesc', $record->{'DESCRIPTION'})
    } 
  }

  # Now construct an appropriate URL and display it ('show') or redirect 
  # to it ('finished').
  my($nserver_url, $nserver_params) = &generate_notification_url($q);

  if ($q->param('show')) {

    print $q->header(), "\n";

    # Print the URL
    print "<B>URL:</B>  <A HREF='$nserver_url'>$nserver_url</A><BR><BR>\n";

    # Print the parameters (for command-line invocation)
    print "<B>Parameters:</B><BR>$nserver_params\n";

    # Print the CGI object for debugging
    print "<!-- CGI object:\n", &Dumper($q), "\n-->\n";


  } else {

    print $q->redirect($nserver_url);

  }


} elsif ($q->param('continue')) {

  # PAGE 3 (optional):  Service Probe / LongLegs alert configuration

  # The user has completed the host probe form and wants the service
  # probe form.  
  print $q->header(), "\n";

  # The user might've selected "Host Probe" and then changed his mind.
  # Make sure the probe type is set correctly.
  if ($q->param('probetype') eq 'HostProbe') {
    $q->param('probetype', 'ServiceProbe');
    $q->param('type', 'service');
  }

  # First, make sure all required fields were filled out & bail out otherwise
  &verify_or_bust($q, 'destination', 'satellite');

  # Find the hostname if it wasn't provided
    my $hostid = $q->param('hostid');
    if (defined($hostid) && ! defined($q->param('hostname'))) {
      my $record=$ndb->select_host(RECID => $hostid);
      $q->param('hostname', $record->{'NAME'});
    };



  # Now generate the service probe form

  my $custsubform = &customer_subform($q, 'data');
  my $svcsubform  = &service_probe_subform($q, 'form');
  my $hidden      = &hidden($q, 'custid', 'destination', 'satellite', 'debug',
                                'hostid', 'hoststate', 'hostname', 'probetype', 'type');

  print &form('notifserver_form',
              myurl            => $MYURL,
	      customer_subform => $custsubform,
	      probe_subform    => $svcsubform, 
	      hidden_fields    => $hidden);


} elsif ($q->param('probetype')) {

  # PAGE 2:  Host Probe / Ad Hoc alert configuration

  # The user has completed the customer selection form and needs the
  # appropriate alert form
  print $q->header(), "\n";

  # Add the additional field 'type' to the query
  my $temp=$q->param('probetype');
  
  my %type_map = ('HostProbe' => 'host',
                  'ServiceProbe' => 'service',
                  'LongLegs' => 'longlegs',
                  'None' => 'adhoc');

  $q->param('type', $type_map{$temp});
  

  my $hidden      = &hidden($q, 'custid', 'probetype', 'type', 'debug');
  my $custsubform = &customer_subform($q, 'data');

  my $probetype   = $q->param('probetype');
  my $probesubform;
  if ($probetype eq 'HostProbe' || $probetype eq 'ServiceProbe') {

    # The host probe form is prerequisite to the service probe form.
    $probesubform = &host_subform($q, 'form');

  } elsif ($probetype eq 'LongLegs') {

    $probesubform = &llurl_subform($q, 'form');

  } else {

    $probesubform = &adhoc_subform($q, 'form');

  }

  print &form('notifserver_form',
              myurl            => $MYURL,
	      customer_subform => $custsubform,
	      probe_subform    => $probesubform,
	      hidden_fields    => $hidden);

} else {

  # PAGE 1:  Customer / Probe Type selection

  # No data posted -- need to select a customer ID and host/service probe
  print $q->header(), "\n";

  my $custsubform = &customer_subform($q, 'form');

  print &form('notifserver_form',
	      myurl             => $MYURL,
	      customer_subform  => $custsubform,
	      probe_subform     => '',
	      hidden_fields     => '');


}



print $q->end_html();

}
##############################################################################
#                                 Subroutines                                #
##############################################################################


##########
sub form {
##########

  my($form_name, %subs) = @_;

  #--- Pull in the HTML form template
  open (TL, "< ../templates/${form_name}.html") 
                     or die "Can't open file ${form_name}.html: $!<BR>\n";
  my $template = join("", <TL>);
  close TL;

  while (($key, $value) = each %subs) {
    $template =~ s/&&$key/$value/g;
  }

  return $template;

}


############
sub hidden {
############

  my($q, @params) = @_;
  my($param, $str) = (undef,'');

  foreach $param (@params) {
    my $value = $q->param($param);
    $str .= "<INPUT TYPE='hidden' NAME='$param' VALUE='$value'>\n";
  }

  return $str;
}





####################
sub verify_or_bust {
####################
  my($q, @required) = @_;
  my $param;
  my $errors='';

  foreach $param (@required) {
    if (! defined($q->param($param))) {
      $errors .= "<FONT COLOR='red'>Parameter '$param' required but not found</FONT><BR>\n";
    } 
  }

  if (length($errors)) {
    print $q->header(), "\n";

    $errors .= "<BR><BR><BR>\n";
    $errors .= "Please use the <B>Back</B> button on your browser to return ";
    $errors .= "to the form and correct the above errors.<BR>\n";
    print $errors;

    print "<!-- CGI object:\n", &Dumper($q), "\n-->\n";

    # Bail out so the user can go fix his/her errors
    exit 0;
  }
}



######################
sub customer_subform {
######################
  my($q, $mode) = @_;

  if ($mode eq 'form') {
    # Generate the empty form

    my $records   = $ndb->select_customers();
    my %custref = map { $_->{'RECID'} => "[" . $_->{'RECID'} . "] " . $_->{'DESCRIPTION'} } @$records;
    my $custmenu  = $q->popup_menu(-name   => 'custid', 
				   -values => [sort {$a <=> $b} keys %custref],
				   -labels => \%custref);

#    $records      = $ndb->select_probe_types();
#    my %proberef  = map { $_->{'PROBE_TYPE'} => $_->{'TYPE_DESCRIPTION'} } @$records;

    $records =   { 
                   'ServiceProbe' => 'Service Probe',
#                   'HostProbe'    => 'Host Probe',
#                   'LongLegs'     => 'LongLegs',
                   'None'         => 'None specified',
#                   'CheckSuite'   => 'Check Suite' 
                 };

    my %proberef = %$records;
    my $probemenu = $q->popup_menu(-name   => 'probetype', 
				  -values => [sort keys %proberef], 
				  -labels => \%proberef);

    my $debugmenu = $q->popup_menu(-name   => 'debug', 
				  -values  => [sort {$a <=> $b} keys %DEBUG], 
				  -default => 2,
				  -labels  => \%DEBUG);

    my $custbuttons = &form('notifserver_customer_buttons');

    return &form('notifserver_customer_subform', 
		 customer_select  => $custmenu,
		 probetype_select => $probemenu,
		 debug_select     => $debugmenu,
		 customer_buttons => $custbuttons);

  } else {

    # Generate static HTML with data
    my $custid      = $q->param('custid');
    my $record      = $ndb->select_customer('RECID' => $custid);  
    my $custname    = $record->{'DESCRIPTION'};
    my $probetype   = $q->param('probetype');
    my $debug       = $q->param('debug');
    return &form('notifserver_customer_subform', 
		 customer_select  => "$custid $custname",
		 probetype_select => $probetype,
		 debug_select     => $debug,
		 customer_buttons => '');
  }

}


##################
sub host_subform {
##################
  my($q, $mode) = @_;

  my $custid = $q->param('custid');

  if ($mode eq 'form') {
    # Generate the empty form

    my $destmenu = &destmenu($custid);
    my $satmenu  = &satellitemenu($custid);

    my $records = $ndb->select_hosts( CUSTOMER_ID => $custid );
    my %hostref    = map { $_->{'RECID'} => $_->{'NAME'} } @$records; 
    my $hostmenu    = $q->popup_menu(
				-name   => 'hostid', 
				-values => [sort {$a <=> $b} keys %hostref], 
				-labels => \%hostref);

#    my $hoststatemenu=$q->popup_menu(
#				-name   => 'hoststate', 
#				-values => [@HOSTSTATES]);

    my $hostbuttons = &form('notifserver_host_buttons');

    return &form('notifserver_host_subform',
		 satellite_select   => $satmenu,
		 destination_select => $destmenu,
		 host_select        => $hostmenu,
#		 hoststate_select   => $hoststatemenu,
		 host_buttons       => $hostbuttons);


  } else {
    # Generate static HTML with data

    my $satid         = $q->param('satellite');
    my $record        = $ndb->select_sat_cluster('RECID' => $satid);
    my $satname       = $record->{'DESCRIPTION'};

    my $destmenu      = $q->param('destination');

    my $hostid        = $q->param('hostid');
       $record        = $ndb->select_host(RECID => $hostid);
    my $hostname      = $rec->{'NAME'};
    $q->param('hostname', $hostname);

    my $hoststatemenu = $q->param('hoststate');
    my $hostbuttons   = '';

    return &form('notifserver_host_subform',
		 satellite_select   => "$satid $satname",
		 destination_select => $destmenu,
		 host_select        => "$hostid $hostname",
		 hoststate_select   => $hoststatemenu,
		 host_buttons       => $hostbuttons);

  }

}


###########################
sub service_probe_subform {
###########################
  my($q, $mode) = @_;

  if ($mode eq 'form') {
    # Generate the empty form

    # The service probe form includes the host probe form
    my $hostsubform = &host_subform($q, 'data');

    my ($hostid, $hostname) = split(/:/, $q->param('hostid'), 2);
    my $records = $ndb->select_service_probes_by_host_id($hostid);
    my %svcref  = map { $_->{'RECID'} => $_->{'DESCRIPTION'} } @$records;

    my $svcmenu;
    if (scalar(keys %svcref) > 1) {
      $svcmenu     = $q->popup_menu(
				-name   => 'serviceid', 
				-values => [sort keys %svcref], 
				-labels => \%svcref);
    } else {
      my ($key, $value) = each %svcref;
      $svcmenu     = "<INPUT TYPE='hidden' NAME='serviceid' VALUE='$key'>$value";
    }

    my $svcsubform  = &form('notifserver_service_subform',
			    service_select      => $svcmenu);

    return join("\n", $hostsubform, $svcsubform);


  } else {
    # Generate static HTML with data
  }

}


###################
sub llurl_subform {
###################
  my($q, $mode) = @_;

  my $custid = $q->param('custid');

  if ($mode eq 'form') {
    # Generate the empty form

    my $destmenu  = &destmenu($custid);
    my $scoutmenu = &remotescoutmenu($custid);
    my $urlmenu   = &urlmenu($custid);

    my $buttons   = &form('notifserver_llurl_buttons');

    return &form('notifserver_llurl_subform',
		 scout_select       => $scoutmenu,
		 destination_select => $destmenu,
		 llurl_select       => $urlmenu,
		 llurl_buttons      => $buttons);


  } else {
    # Generate static HTML with data

    my $satid         = $q->param('satellite');
    my $record        = $ndb->select_sat_cluster('RECID' => $satid);
    my $satname       = $record->{'DESCRIPTION'};

    my $destmenu      = $q->param('destination');

    my $hostid        = $q->param('hostid');
       $record        = $ndb->select_host(RECID => $hostid);
    my $hostname      = $rec->{'NAME'};
    $q->param('hostname', $hostname);

    my $hoststatemenu = $q->param('hoststate');
    my $hostbuttons   = '';

    return &form('notifserver_host_subform',
		 satellite_select   => "$satid $satname",
		 destination_select => $destmenu,
		 host_select        => "$hostid $hostname",
		 hoststate_select   => $hoststatemenu,
		 host_buttons       => $hostbuttons);

  }


}


###################
sub adhoc_subform {
###################
  my($q, $mode) = @_;

  if ($mode eq 'form') {
    # Generate the empty form

    my $custid   = $q->param('custid');
    my $destmenu = &destmenu($custid);
    my $buttons  = &form('notifserver_adhoc_buttons');

    return &form('notifserver_adhoc_subform',
		 destination_select => $destmenu,
		 adhoc_buttons      => $buttons);



  } else {
    # Generate static HTML with data
  }

}


##############
sub destmenu {
##############
  my $custid  = shift;

  my $records = $ndb->select_contact_groups('CUSTOMER_ID' => $custid);
  my %destref = map { $_->{'RECID'} => $_->{'CONTACT_GROUP_NAME'} } @$records;
  my @v = sort { lc ($destref{$a}) cmp lc ($destref{$b}) } (keys %destref);

  return  $q->scrolling_list(
		      -size   => 5,
		      -name   => 'destination', 
		      -values => \@v,
		      -labels => \%destref);
}

####################
sub satellitemenu {
####################
  my $custid  = shift;

  my $records = $ndb->select_sat_clusters('CUSTOMER_ID' => $custid);
  my %satref = map { $_->{'RECID'} => $_->{'DESCRIPTION'} } @$records;

  return $q->scrolling_list(
		      -size   => 5,
		      -name   => 'satellite', 
		      -values => [sort keys %satref], 
		      -labels => \%satref);
}

###############
sub scoutmenu {
###############
  my $custid   = shift;

  my $records  = $ndb->select_sat_clusters_by_customer_id($custid);
  my %scoutref = map { $_->{'RECID'} => $_->{'DESCRIPTION'} } @$records;

  return $q->scrolling_list(
		      -size   => 5,
		      -name   => 'satellite', 
		      -values => [sort keys %scoutref], 
		      -labels => \%scoutref);
}


#####################
sub remotescoutmenu {
#####################
  my $custid   = shift;

  my $records1  = $ndb->select_sat_clusters_by_customer_id($custid);
  my $records2 = $ndb->select_scout_clusters_by_customer_id($custid);
  my @records=(@$records1,@$records2);
  my %scoutref = map { $_->{'RECID'} => $_->{'DESCRIPTION'} } @records;

  return $q->scrolling_list(
		      -size   => 5,
		      -name   => 'satellite', 
		      -values => [sort keys %scoutref], 
		      -labels => \%scoutref);
}




#############
sub urlmenu {
#############
  my $custid = shift;

  my $records = $ndb->select_URLs_by_customer_id($custid);

  my($record, $menuref);
  foreach $record (@$records) {
    my $id   =$record->{'URL_PROBE_ID'};
    my $desc =$record->{'DESCRIPTION'};
    my $url  =$record->{'URL'};
    $menuref->{"$id:$url"} = 
         "$desc ($url)";
  }

  return $q->scrolling_list(
		      -size   => 5,
		      -name   => 'serviceid', 
		      -values => [sort keys %$menuref], 
		      -labels => $menuref);
}


###############################
sub generate_notification_url {
###############################
  my $q = shift;
  my ($required, $param);

  #Do any preprocessing

  my $hostid=$q->param('hostid');
  if ($hostid =~ /^\d+$/) {
    my $record = $ndb->select_host(RECID => $hostid);
    $q->param('hostAddress',$record->{'IP'})
  } else {
    $q->param('hostAddress','')
  }

  $q->param('timestamp', $TIMESTAMP);

  my $probetype = $q->param('type');
  my $servicestate = $q->param('servicestate');

  my $custid=$q->param('custid');
  if ($custid) {
    my $groupId = $q->param('destination');
    if ($groupId) {
      my $record = $ndb->select_contact_group('RECID' => $groupId);
      $q->param('groupName',$record->{'CONTACT_GROUP_NAME'});
    }
  }
 
  if ($probetype eq 'service' && !$servicestate) {
    $probetype='host';
  }

  $record = $ndb->select_sat_cluster('RECID' => $q->param('satellite'));
  $q->param('clusterDesc',$record->{'DESCRIPTION'});

  my $records = $ndb->select_sat_node_by_sat_cluster_id($q->param('satellite'));
  $record=$records->[0];
  $q->param('mac',$record->{'MAC_ADDRESS'});

  # Create a new empty CGI object
  my $nq = new CGI('');

  # Field mappings for static fields
  my %staticmap = (

      adhoc                => 'adhoc',
      clusterDesc          => 'clusterDesc',
      clusterId            => 'satellite',
      customerId           => 'custid',
      debug                => 'debug',
      email                => 'email',
      groupId              => 'destination',
      groupName            => 'groupName',
      hostAddress          => 'hostAddress',
      hostName             => 'hostname',
      hostProbeId          => 'hostid',
      mac                  => 'mac',
      netsaintId           => 'satellite',
      probeDescription     => 'servicedesc',
      probeId              => 'serviceid',
      probeType            => 'probetype',
      subject              => 'subject',
      time                 => 'timestamp',
      type                 => 'type',
  );
#      commandLongName      => '',
#      osName               => '',
#      physicalLocationName => '',
#      probeGroupName       => '',
#      snmp                 => '',
#      snmpPort             => '',

 if ($probetype eq 'host') {
  $staticmap{'state'}='hoststate'
 } else {
  $staticmap{'state'}='servicestate'
 }

 if ($probetype eq 'adhoc') {
  $staticmap{'message'}='message';
  $q->param('clusterId',1)
 } else {
  $staticmap{'message'}='output'
 }

  # Build instructions for dynamic fields
  my %buildmap = (
#    'HOSTNAME'    => 'custid:hostname',
#    'SERVICEDESC' => 'serviceid:custid:probetype:servicedesc',
  );


  # Determine what fields need to be sent
  my @required;
  push(@required, qw(customerId debug time type));

  if ($q->param('destination')) {
    push(@required, qw(groupId groupName));

  } elsif ($q->param('email')) {
    push(@required, qw(email));

  } else {
    # Oops!  At least one of those is required!
    push(@required, 'adhoc');
  }

  if ($probetype  =~ /adhoc/) {

    push(@required, qw(subject message));
     
  } else {
    # It's not adhoc

    push(@required, qw(clusterId clusterDesc customerId groupId groupName mac probeType state time));

    if ($probetype eq 'host') {
      push(@required, qw(hostName hostProbeId hostAddress))
    }
    if ($probetype eq 'service') {
      push(@required, qw(hostName hostProbeId  hostAddress message probeDescription probeId))
    }
    if ($probetype =~ /longlegs/i) {
      push(@required, qw(message probeDescription probeId))
    }

  }
#  print STDERR "required is @required\n";

  # Make sure all required fields have been provided
  my($req, @required_in);
  foreach $param (@required) {
    if (exists($staticmap{$param})) {
      push(@required_in, $staticmap{$param});
    } else {
      push(@required_in, split(/:/, $buildmap{$param}));
    }
  }
#  print STDERR "required_in is @required_in\n";
  &verify_or_bust($q, @required_in);


  # Copy the required fields into $nq
  foreach $param (@required) {

    if (exists($staticmap{$param})) {

      # Single-value field -- just copy it over
      $nq->param($param, $q->param($staticmap{$param}));

    } else {
      my($part, @parts);
      foreach $part (split(/:/, $buildmap{$param})) {
        push(@parts, $q->param($part));
      }
      $nq->param($param, join(":", @parts));
    }
  }


  # Then send them packing.
  my $qs = $nq->query_string();

  my $params = '';
  foreach $param ($nq->param()) {
    $params .= "${param}=" . $nq->param($param) . "<BR>\n";
  }

  return ("$NOTIFSERVER?$qs", $params);
  
}



#__END__
#
#Parameter		From			Alert type(s)
#---------		----			-------------
#checkCommand	        (not required)          HLS
#clusterDesc            satellite (derived)     HLS
#clusterId              satellite               HLS
#commandLongName        (not required)          HLS
#customerId             custid                  HLS
#email                  email                   A
#groupId                destination             HLS
#groupName              destination (derived)   HLS
#hostAddress            (not required)          HS
#hostName               hostname                HS
#hostProbeId            hostid                  HS
#mac                    satellite (derived)     HLS
#message                output,message          ALS 
#osName                 (not required)          HS
#physicalLocationName   (not required)          HS
#probeDescription       servicedesc             LS
#probeGroupName         (not required)          HS
#probeId                serviceId               LS
#probeType              probeType               AHLS
#snmp                   (not required)
#snmpPort               (not required)
#state                  hoststate,servicestate  HLS
#subject                subject                 A
#time                   (derived)               AHLS
#type                   type (derived)          AHLS

#Required fields by type:
#  Host probe:     clusterDesc, clusterId, customerId, groupId, groupName
#                  hostName, hostProbeId, probeType, state, time, type
#  Service probe:  clusterDesc, clusterId, customerId, groupId, groupName
#                  hostName, hostProbeId, message, probeDescription, probeId, probeType, state, time, type
#  LongLegs probe: clusterDesc, clusterId, customerId, groupId, groupName
#                  message, probeDescription, probeId, probeType, state, time, type 
#  Ad-hoc probe:   clusterDesc, clusterId, customerId, message, probeType, time,
#                  (groupId, groupName) or (email)
