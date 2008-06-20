#!/usr/bin/perl

use strict;
use CGI;
use LWP::UserAgent;
use URI::Escape;
use URI::URL;
use NOCpulse::Config;
use NOCpulse::NPRecords;
use Data::Dumper;

use vars qw($VERSION);
$VERSION = (split(/\s+/,
           q$Id: llconfig.cgi,v 1.29 2001-06-12 03:11:31 dfaraldo Exp $,
	   4))[2];


###################
# Global variables
#
my $SERVICE_NOTIFY = 'NOCpulse_S_Notify';   # Service notifier command name
my $HOST_NOTIFY    = 'NOCpulse_H_Notify';   # Host notifier command name
my $SERVICE_EH     = 'NOCpulse_Service_EH'; # Service event handler command name
my $HOST_EH        = 'NOCpulse_Host_EH';    # Host event handler command name
my $NOBODY         = 'nobody@nowhere.org';  # Bogus email address
my $BADCHARS       = '^-_A-Za-z0-9';        # Character class to be escaped

# Columns for Netsaint config generation
my @NSCOLS = qw( recid description smon_url log_file cfg_file status_file 
                 program_mode check_external_commands command_check_interval
                 command_file log_rotation_method log_archive_path temp_file
                 log_level use_syslog syslog_level log_notifications
                 log_service_retries log_host_retries log_event_handlers
                 inter_check_delay_method service_interleave_factor
                 max_concurrent_checks service_reaper_frequency
                 sleep_time interval_length use_agressive_host_checking
                 admin_email admin_pager global_service_event_handler
                 global_host_event_handler);


# Config handle
my $cfg = new NOCpulse::Config;


##############################################################################
###################################  Main  ###################################
##############################################################################

# Generate the "static" portion of the config (same for every scout)
print "Generating URL probe records for all scouts\n";
my $staticcfg = &generate_hosts_cfg();

if (0) {
  print "STATIC CONFIG:\n"; # +++
  $staticcfg =~ s/\&/\n/g; # +++
  print &uri_unescape($staticcfg), "\n"; # +++
  exit 0; # +++
}


# Set up a UserAgent;
my $ua = new LWP::UserAgent;
$ua->agent("LongLegsConfigPusher/$VERSION");
my $gw = $cfg->get('satellite', 'gatewayUrl');

# Now, for each scout, generate the "dynamic" portions of the config
# (netsaint config and ID file) and push the config.
my $scouts = &get_scout_records();
my $scout_id;
foreach $scout_id (sort {$a <=> $b} keys %$scouts) {

  my $nsid = $scouts->{$scout_id}->get_RECID;
  my $desc = $scouts->{$scout_id}->get_DESCRIPTION;

  print "Generating config for $desc (scout $nsid)\n";
  my $dynamiccfg = &generate_netsaint_cfg($scouts->{$scout_id});

  # Get the satellite host address
  my $uri  = new URI($scouts->{$scout_id}->get_SMON_URL);
  my $host = $uri->host();
  my $url  = "$gw/$host/satgen/installConfig.cgi";

  print "Sending update to $url\n";
  my $req = new HTTP::Request(POST => $url);
  $req->content_type('application/x-www-form-urlencoded');
  $req->content(join('&', $dynamiccfg, $staticcfg));

  my $res = $ua->request($req);
  if ($res->is_success) {
    print "Update successful:\n";
    my $response = $res->content;
    $response =~ s/^Warning: Contact group.*is not used.*\n//gm;
    $response =~ s/^NetSaint.*\n//gm;
    $response =~ s/^Copyright.*\n//gm;
    $response =~ s/^Last Modified.*\n//gm;
    $response =~ s/^License: GPL.*\n//gm;
    print "$response\n";
  } else {
    print "ERROR\nUnable to post update to $url: ".$res->message."\n\n";
  }

}



##############################################################################
###############################  Subroutines  ################################
##############################################################################


########################
sub generate_hosts_cfg {
########################
  
  my @file;

  # Generate hosts.cfg file and LongLegs config files

  # - Time periods
  my $periods = &get_time_periods();
  push(@file, "#\n# Time periods\n#\n", @$periods);


  # - Commands
  my $commands = &get_commands();
  push(@file, "#\n# Commands\n#\n", @$commands);


  # - Contacts and contact groups
  my($contacts, $contactgroups) = &get_contacts();
  push(@file, "#\n# Contacts\n#\n", @$contacts);
  push(@file, "#\n# Contact groups\n#\n", @$contactgroups);


  # - Hosts and host groups
  my($hosts, $hostgroups) = &get_hosts();
  push(@file, "#\n# Hosts\n#\n", @$hosts);
  push(@file, "#\n# Host groups\n#\n", @$hostgroups);


  # - Services
  my($services, $llfiles) = &get_services();
  push(@file, "#\n# Services\n#\n", @$services);





  # URL encode everything to pass to the scouts.

  # - Hosts file
  my $config_content;
  $config_content  = 'hosts=' . &uri_escape(join('', @file), $BADCHARS);

  # - List of LongLegs probes
  my @llprobes = sort {$a <=> $b} keys %$llfiles;
  $config_content .= "&llconfigs=" . join(',', @llprobes);

  # - LongLegs probe config files
  my $url_probe_id;
  foreach $url_probe_id (@llprobes) {
    $config_content .= "&llconfig_$url_probe_id=" . 
                       &uri_escape($llfiles->{$url_probe_id}, $BADCHARS);
  }


  return $config_content;

}


######################
sub get_time_periods {
######################

  my @lines;

  CFDBRecord->LoadFromSql('SELECT period_name,alias,ranges 
                           FROM time_periods',
			   'PERIOD_NAME');
  my $record;
  CFDBRecord->Map(
    sub {
      my $record = shift;
      push(@lines, sprintf("timeperiod[%s]=%s;%s\n", 
			    $record->get_PERIOD_NAME, 
			    $record->get_ALIAS, 
			    $record->get_RANGES));
    }
  );
  CFDBRecord->ReleaseAllInstances;

  return \@lines;

}



##################
sub get_commands {
##################

  my @commands;
  # Return five commands:  the 'longlegs' command, plus
  # $SERVICE_NOTIFY, $HOST_NOTIFY, $SERVICE_EH, and $HOST_EH

  push(@commands, 
    "command[longlegs]=/opt/home/nocpulse/libexec/LongLegs/webclient \$ARG1\$\n");


  CFDBRecord->LoadFromSql("
      SELECT  command_name, command_line
      FROM    commands
      WHERE   command_name = '$SERVICE_NOTIFY'
      OR      command_name = '$HOST_NOTIFY'
      OR      command_name = '$SERVICE_EH'
      OR      command_name = '$HOST_EH'",
                          'COMMAND_NAME');
  CFDBRecord->Map(
    sub {
      my $record = shift;
      push(@commands, sprintf("command[%s]=%s\n", $record->get_COMMAND_NAME,
                                                  $record->get_COMMAND_LINE));
    }
  );
  CFDBRecord->ReleaseAllInstances;

  return \@commands;

}


##################
sub get_contacts {
##################

  my @contactlines;
  my @grouplines;

  # First, get a list of contact groups for LongLegs probes
  my %contacts;
  CFDBRecord->LoadFromSql("
      SELECT  DISTINCT cg.recid || ':' || cg.contact_group_name AS record
      FROM    probes p, contact_groups cg
      WHERE   p.probe_type = 'LongLegs'
      AND     p.contact_groups = cg.recid",
                          'RECORD');
  CFDBRecord->Map(
    sub {
      my $record = shift;
      my($recid, $group) = split(/:/, $record->get_RECORD);
      $contacts{$recid} = $group;
    }
  );
  CFDBRecord->ReleaseAllInstances;


  # Next, generate 'contact' and 'contactgroup' lines for all the contacts
  my $contactfmt = "contact[%s]=%s;24x7;24x7;1;1;1;1;1;1;%s;%s;%s;\n";
  my $groupfmt   = "contactgroup[%s]=%s;%s\n";
  my $contact;
  foreach $contact (sort {$a <=> $b} keys %contacts) {
    push(@contactlines, sprintf($contactfmt, $contact, $contacts{$contact}, 
                                $SERVICE_NOTIFY, $HOST_NOTIFY, $NOBODY));
    push(@grouplines,   sprintf($groupfmt, $contact, $contacts{$contact}, 
                                $contact));
  }

  return (\@contactlines, \@grouplines);

}


###############
sub get_hosts {
###############

  my @hosts;
  my @hostgroups;

  # Use probe recids as host ids
  CFDBRecord->LoadFromSql("SELECT  urlp.recid as recid, 
                                   p.description as description
                           FROM    url_probe urlp, probes p
			   WHERE   urlp.recid = p.recid",
                          'RECID');
  my %hosts;
  CFDBRecord->Map(
    sub {
      my $record = shift;
      my $desc   = $record->get_DESCRIPTION;
      $desc =~ s/;/%3b/g;
      $hosts{$record->get_RECID} = $desc;
    }
  );
  CFDBRecord->ReleaseAllInstances;


  # Next, generate 'contact' and 'contactgroup' lines for all the contacts
  my $hostfmt = "host[%s]=%s;%s;;;1;30;24x7;0;0;0;\n";
  my $host;
  foreach $host (sort {$a <=> $b} keys %hosts) {
    push(@hosts, sprintf($hostfmt, $host, $host, $hosts{$host} || $host));
  }

  # Finally, generate an 'all' hostgroup
  my $hostgroup = sprintf("hostgroup[all]=all hosts;;%s\n", 
                          join(',', sort {$a <=> $b} keys %hosts));

  return (\@hosts, [$hostgroup]);

}



##################
sub get_services {
##################

  # Note:  Transaction groups with 0 transactions are allowed, but
  #        shouldn't be propagated to the satellite.

  # First, load all the probe records
  CFDBRecord->LoadFromSql("SELECT  *
                           FROM    probes
			   WHERE   probe_type = 'LongLegs'",
                          'RECID');
  my $probe = CFDBRecord->Instances;
  CFDBRecord->ReleaseAllInstances;


  # Next, load all of the url_probe records
  CFDBRecord->LoadFromSql("SELECT  *
			   FROM    url_probe",
			  'RECID');
  my $url_probe = CFDBRecord->Instances;
  CFDBRecord->ReleaseAllInstances;


  # Next, load all of the url_probe_step records.
  CFDBRecord->LoadFromSql(
    "SELECT  
          recid, url_probe_id, step_number, description,
	  url, protocol_method,
          verify_links, load_subsidiary,
          pattern, vpattern,
          post_content, post_content_type,
          connect_warn || ':' || connect_crit  AS connect_thresh,
          latency_warn || ':' || latency_crit  AS latency_thresh,
          dns_warn || ':' || dns_crit          AS dns_thresh,
          total_warn || ':' || total_crit      AS totaltime_thresh,
          trans_warn || ':' || trans_crit      AS transfer_thresh,
          through_warn || ':' || through_crit  AS throughput_thresh,
          cookie_key, cookie_value,
          cookie_key || ':' || cookie_value  || ':' || cookie_path || ':' ||
                               cookie_domain || ':' || cookie_port || ':' ||
                               cookie_secure || ':' || cookie_maxage AS cookie
    FROM    url_probe_step",
    'RECID');

  my $probe_step = CFDBRecord->Instances;

  # Record the probe ID's that have at least one probe step.
  my %nsteps;
  CFDBRecord->Map(
    sub {
      my $record = shift;
      $nsteps{$record->get_URL_PROBE_ID}++;
    }
  );

  CFDBRecord->ReleaseAllInstances;


  # Generate a config file line for each probe
  my $svcfmt = "service[%s]=%s;0;24x7;%s;%s;%s;%s;%s;24x7;%s;%s;%s;;" .
                            "longlegs!--file=%s\n";
  my(@services, $probeid);
  foreach $probeid (sort {$a <=> $b} keys %nsteps) {
    my $probe     = $probe->{$probeid};
    my $url_probe = $url_probe->{$probeid};
    my $svcdesc   = join(":", $probeid, $probe->get_CUSTOMER_ID, 
                              'LongLegs', $probe->get_DESCRIPTION);

    # Config record
    push(@services, sprintf($svcfmt,
                            $probe->get_RECID,
			    $svcdesc,
			    $probe->get_MAX_ATTEMPTS,
			    $probe->get_CHECK_INTERVAL,
			    $probe->get_RETRY_INTERVAL,
			    $probe->get_CONTACT_GROUPS,
			    $probe->get_NOTIFICATION_INTERVAL,
			    $probe->get_NOTIFY_RECOVERY,
			    $probe->get_NOTIFY_CRITICAL,
			    $probe->get_NOTIFY_WARNING,
			    $probeid));


  }

  # Generate config files
  my(%steps, %comment, $stepid);
  foreach $stepid (keys %$probe_step) {
    my $record    = $probe_step->{$stepid};
    my $probeid   = $record->get_URL_PROBE_ID;
    my $probe     = $probe->{$probeid};
    my $url_probe = $url_probe->{$probeid};
    my $stepno    = $record->get_STEP_NUMBER;
    my $stepcfg;

    $stepcfg  = sprintf("%s\t%s\n", "url", $record->get_URL);

    if (defined($record->get_COOKIE_KEY) and 
        defined($record->get_COOKIE_VALUE)) {

      $stepcfg .= sprintf("%s\t%s\n", "cookie", $record->get_COOKIE);

    } elsif ($url_probe->get_COOKIE_ENABLED) {

      $stepcfg .= sprintf("%s\t%s\n", "cookies", $url_probe->get_COOKIE_ENABLED);

    }

    $stepcfg .= sprintf("%s\t%s\n", "urlid", $record->get_RECID);
    $stepcfg .= sprintf("%s\t%s\n", "method", $record->get_PROTOCOL_METHOD);

    if ($url_probe->get_USERNAME =~ /\S/) {
      $stepcfg .= sprintf("%s\t%s\n", "username", $url_probe->get_USERNAME);
      $stepcfg .= sprintf("%s\t%s\n", "password", $url_probe->get_PASSWORD);
    }

    $stepcfg .= sprintf("%s\t%s\n", "linkverify",  $record->get_VERIFY_LINKS)
					       if ($record->get_VERIFY_LINKS);

    $stepcfg .= sprintf("%s\t%s\n", "subs",  $record->get_LOAD_SUBSIDIARY)
					 if ($record->get_LOAD_SUBSIDIARY);

    $stepcfg .= sprintf("%s\t%s\n", "checkpattern",  $record->get_PATTERN)
					         if ($record->get_PATTERN);

    $stepcfg .= sprintf("%s\t%s\n", "vpattern",  $record->get_VPATTERN)
					     if ($record->get_VPATTERN);

    $stepcfg .= sprintf("%s\t%s\n", "content", $record->get_POST_CONTENT)
					   if ($record->get_POST_CONTENT);

    $stepcfg .= sprintf("%s\t%s\n", "content-type", 
                                               $record->get_POST_CONTENT_TYPE)
					   if ($record->get_POST_CONTENT_TYPE);


    # Thresholds
    $stepcfg .= sprintf("%s\t%s\n" x 6, 
                "connect_thresh",    $record->get_CONNECT_THRESH,
                "dns_thresh",        $record->get_DNS_THRESH,
                "latency_thresh",    $record->get_LATENCY_THRESH,
                "transfer_thresh",   $record->get_TRANSFER_THRESH,
                "throughput_thresh", $record->get_THROUGHPUT_THRESH,
                "totaltime_thresh",  $record->get_TOTALTIME_THRESH);



    $steps{$probeid}{$stepno}   = $stepcfg;
    $comment{$probeid}{$stepno} = 
      sprintf("# Step %s (urlid %s)\n", $record->get_STEP_NUMBER,
                                        $record->get_RECID);
    $comment{$probeid}{$stepno} .= 
                         sprintf("# '%s'\n", $record->get_DESCRIPTION)
				  if (length($record->get_DESCRIPTION));
    
  }


  # Finally, consolidate all of the config steps into a single config
  # file for each probe.
  my($probeid, $stepno, %files);
  foreach $probeid (sort {$a <=> $b} keys %steps) {
    foreach $stepno (sort {$a <=> $b} keys %{$steps{$probeid}}) {
      $files{$probeid} .= $comment{$probeid}{$stepno} .
                          $steps{$probeid}{$stepno} . "\n";
    }
  }

  return(\@services, \%files);

}



#######################
sub get_scout_records {
#######################

  # Fetch Netsaint records for all scouts
  my($col, @cols);
  foreach $col (@NSCOLS) {
    push(@cols, "ns.$col as $col");
  }
  my $columns = join(',', @cols);

  CFDBRecord->LoadFromSql("SELECT $columns
                           FROM   netsaint ns, ll_netsaint ll
                           WHERE  ns.recid = ll.netsaint_id",
                           'RECID');
  my $records = CFDBRecord->Instances;
  CFDBRecord->ReleaseAllInstances;

  return $records;

}

###########################
sub generate_netsaint_cfg {
###########################
  my ($record) = @_;
  my $cfg;
  my $nsid = $record->get_RECID;
  my $desc = $record->get_DESCRIPTION;

  # Generate netsaint config:  

  #  1) netsaintId file
  $cfg = "netsaintId=" . uri_escape("${nsid}:$desc", $BADCHARS);


  #  2) netsaint.cfg file.
  my $nscfg = "# Config for scout $nsid ('$desc')\n";

  my($param, @lines);
  foreach $param (@NSCOLS) {
    next if ($param eq 'recid');
    next if ($param eq 'description');
    next if ($param eq 'smon_url');

    if ($param eq 'global_service_event_handler') {

      push(@lines, "$param=$SERVICE_EH\n");

    } elsif ($param eq 'global_host_event_handler') {

      push(@lines, "$param=$HOST_EH\n");

    } else {

      push(@lines, "$param=" . $record->get(uc($param)) . "\n");

    }
  }

  # Add some hard-coded config per DAP for state retention
  push(@lines, "retain_state_information=1\n");
  push(@lines, "state_retention_file=/opt/home/nocpulse/var/status.sav\n");


  $nscfg .= join('', @lines);
  $cfg   .= "&netsaint=" . uri_escape($nscfg, $BADCHARS);

  return $cfg;

};


