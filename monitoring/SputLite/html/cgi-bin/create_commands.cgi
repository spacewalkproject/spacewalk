#!/usr/bin/perl

use strict;
use CGI qw/-unique_headers/;
use Data::Dumper;
use Digest::MD5;
use HTTP::Date;
use NOCpulse::CF_DB;
use POSIX qw(strftime);
use URI::URL;
use URI::Escape;


##############################################################################
#                   Global Variables and Configuration                       #
##############################################################################

my $q           = new CGI;
my $MYURL       = $q->url();
my $DEFAULTPAGE = "main";

# Cookie parameters
my $PATH        = $q->url(-absolute=>1);
my $uri         = new URI($MYURL);
my $DOMAIN      = $uri->host();
my $COOKIENAME  = 'SputLiteSession';
my $SESSIONLIFE  = 8*60*60;    # 8-hour session life
my $WHEN_TO_EXTEND = 60*60;   # 60 minutes left

# Requirements for access
my $CUSTOMER_ID = 1;
my $PRIV_TYPE   = 'EditAll';

# Refresh parameters
my $REFRESH_SECONDS = 30;  # refresh the status page every 30 seconds
my $EXECUTE_LATENCY = 15;  # an extra few seconds for things to report back

# Globals
my $DB_DATE_FORMAT = 'MM-DD-YY HH24:MI:SS';
my $DB_SORT_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
my $F_DATE_FORMAT  = '%m-%d-%Y  %H:%M:%S';
my $MAX_ROW_COUNT  = 150;

# User information
my $userid;

##############################################################################
#                                 Notes                                      #
##############################################################################

# Global:
# Parameters:
#   page=new - do create/view/annotate page
#   no 'page' param - do list commands page


# Create/view/annotate page:
# Variables:
#   title - page title
#   myurl - URL to post to
#   descrption - <INPUT TYPE=text NAME='description' SIZE=40 MAXSIZE=40> 
#   commandline - <INPUT TYPE=text NAME='description' SIZE=80 MAXSIZE=2000>
#   perm_select - <SELECT NAME="permanent">
#                   <OPTION VALUE=1 SELECTED>Reusable
#                   <OPTION VALUE=0>Ephemeral
#                 </SELECT>
#   euid - <INPUT TYPE=text NAME='euid' SIZE=40 MAXSIZE=40>
#   egid - <INPUT TYPE=text NAME='egid' SIZE=40 MAXSIZE=40>
#   notes - current value of notes column
#   buttons - <INPUT TYPE="submit" VALUE="Create"><INPUT TYPE="reset" VALUE="Reset">
#
# Parameters:
#   command_id=X - show current values for command X (and no buttons)


# List commands page:
# Variables:
#   commands_list - table rows for list of commands
#
# Parameters:
#   ephemeral={0,1} - whether or not to list ephemeral commands




##############################################################################
#                                 Main                                       #
##############################################################################

my $page = $q->param('page') || $DEFAULTPAGE;

if ($page eq 'logout') {
  &unauthorize($q);
}

# Need to do authorization before printing the header so we can set a cookie
&NOCpulse::CF_DB::setDebugParams(CONTEXT => 'html_comment');
my $CF_DB = new NOCpulse::CF_DB;

# Check for special production auth file
if (-f $CF_DB->cfg->get('CommandQueue', 'dbAuthFile')) {
  my $authinfo = $CF_DB->cfg->getContents('CommandQueue', 'dbAuthFile');
  if ($authinfo) {
    chomp($authinfo);
    my($username, $passwd) = split(/:/, $authinfo);
    $CF_DB->dbuname($username);
    $CF_DB->dbpasswd($passwd);
  } 
}


# Authenticate the user
&authorize($q);

if ($page eq 'download_results') {
  print $q->header(-type => 'text/plain');
  &download_results($q);
  exit 0
}

if ($page eq 'status_report') {
  print $q->header(-type => 'text/plain');
  &status_report($q);
  exit 0
}


# Print header first so debugging statements don't screw up the webserver
$|=1;
print $q->header();
$CF_DB->debug->level(3);


$CF_DB->dprint(3, "CGI OBJECT:\n", &Dumper($q), "\n");


if ($page eq 'main') {

  print &main_menu($q);

} elsif ($page eq 'list') {

  print &list_commands($q);

} elsif ($page eq 'new') {

  print &create_view_command($q);

} elsif ($page eq 'create_cmd') {

  print &insert_command($q);

} elsif ($page eq 'create_instance') {

  print &create_instance($q);

} elsif ($page eq 'execute') {

  print &execute($q);
  
} elsif ($page eq 'status') {

  print &show_status($q);
  
} elsif ($page eq 'status_report') {

  print &status_report($q);

} elsif ($page eq 'query_exec_history') {

  print &query_history($q)

} elsif ($page eq 'show_history') {
  
  print &show_history($q)

} elsif ($page eq 'update') {

# +++ NEED TO WRITE THIS
# print &update_command($q);
print "<B>Sorry, but 'update command' functionality is not yet implemented.</B>\n";

} else {
print "<B>Sorry, the page you requested ('$page') was not found.</B>\n";
}


print $q->end_html();



##############################################################################
#                         Page creation Subroutines                          #
##############################################################################

###############
sub main_menu {
###############
  my $q = shift;

  # Preserve the cluster and node lists from the last command execution if any
  my ($paramlist, $paramtitle);
  my @clusters=$q->param('clusters');
  if (@clusters) {
    $paramtitle .= ' for selected sat cluster id(s): ' . join(', ',@clusters);
  }
  my @nodes=$q->param('nodes');
  if (@nodes) {
    $paramtitle .= ' for selected sat node id(s): ' . join(', ',@nodes);
  }
  return &form('front_page', 
                  myurl    => $MYURL,
                  subtitle => $paramtitle,
                  hidden   => &hidden_hash('clusters' => \@clusters, 
                                           'nodes'    => \@nodes)
              );
}

###################
sub list_commands {
###################
  my $q           = shift;
  my $ephemeral   = $q->param('ephemeral');
  my $search_desc = $q->param('search_desc');
  my $search_line = $q->param('search_line');
  my($cmdref, $ordref, $id);
  my $tablerows;

  # Preserve the cluster and node lists from the last command execution if any
  my ($paramlist, $paramtitle);
  my @clusters=$q->param('clusters');
  if (@clusters) {
    $paramlist  .= &url_params('clusters',@clusters); 
    $paramtitle .= ' for selected sat cluster id(s): ' . join(', ',@clusters);
  }
  my @nodes=$q->param('nodes');
  if (@nodes) {
    $paramlist  .= &url_params('nodes',@nodes); 
    $paramtitle .= ' for selected sat node id(s): ' . join(', ',@nodes);
  }

  my $fullparamlist = $paramlist;
  $fullparamlist .= &url_params('search_desc',$search_desc);
  $fullparamlist .= &url_params('search_line',$search_line);
  $search_desc = '%' unless $search_desc;
  $search_line = '%' unless $search_line;

  # First, fetch the command list
  my $elinkformat = "<A HREF='$MYURL?page=new&command_id=%s'>View/Edit</A>";
  my $xlinkformat = "<A HREF='$MYURL?page=create_instance&command_id=%s$paramlist'>%s</A>";
  my $rowformat = " <TR>
    <TD><FONT SIZE=-1>%s</FONT></TD>
    <TD><FONT SIZE=-1><A HREF='note:%s'>%s</A></FONT></TD>
    <TD ALIGN=center><FONT SIZE=-1>%s</FONT></TD>
    <TD ALIGN=center><FONT SIZE=-1>%s</FONT></TD>
    <TD><FONT SIZE=-1>%s</FONT></TD>
    <TD><FONT SIZE=-1>%s</FONT></TD>
    <TD><FONT SIZE=-1>%s</FONT></TD>
    <TD><FONT SIZE=-1>$elinkformat</FONT></TD>
  </TR>
  ";

  if ($ephemeral) {
      ($cmdref, $ordref) = $CF_DB->getCQ_CommandsLike($search_desc,$search_line,['recid']);
  } else {
    ($cmdref, $ordref) = $CF_DB->getPermanent_CQ_CommandsLike($search_desc,$search_line,['recid']);
  }


  # - Print the rows in the sorted order
  foreach $id (@$ordref) {

    my $recid = $cmdref->{$id}->{'recid'};
    $tablerows .= sprintf($rowformat, sprintf($xlinkformat, $recid, $recid),
                              &html_escape($cmdref->{$id}->{'command_line'}),
                              $cmdref->{$id}->{'description'},
                              $cmdref->{$id}->{'permanent'},
                              $cmdref->{$id}->{'effective_user'},
                              $cmdref->{$id}->{'effective_group'},
                              $cmdref->{$id}->{'last_update_date'},
                              $cmdref->{$id}->{'last_update_user'},
			      $recid);
  }


  # Construct links for the top and bottom of the page.
  my $links = "<A HREF='$MYURL?page=main'>Home</A><BR>";
  $links .= "<A HREF='$MYURL?page=new'>Create new command</A><BR>";
  my $resetlink;
  if ($ephemeral) {
    $links .= "<A HREF='$MYURL?page=list&ephemeral=0$fullparamlist'>Show only reusable commands matching criteria</A><BR>";
    $resetlink .= "<A HREF='$MYURL?page=list&ephemeral=1$paramlist'>Show full list of commands</A>";
  } else {
    $links .= "<A HREF='$MYURL?page=list&ephemeral=1$fullparamlist'>List all commands matching criteria (including non-reusable)</A><BR>";
    $resetlink .= "<A HREF='$MYURL?page=list&ephemeral=0$paramlist'>Show full list of reusable commands</A>";
  }
  $links .= "<A HREF='$MYURL?page=query_exec_history'>Query execution history</A><BR>";
  $links .= "<A HREF='$MYURL?page=logout'>Log out</A><BR>";


  # Finally, return the form
  return &form('show_CQ_commands_deux',
       links            => $links, 
       resetlink        => $resetlink, 
       commands_list    => $tablerows,
       myurl            => $MYURL,
       hidden           => &hidden_params($q,'page','ephemeral'),
       hidden2          => &hidden_hash('clusters' => \@clusters, 
                                        'nodes' => \@nodes),
       paramtitle       => $paramtitle,
       search_desc      => $search_desc,
       search_line      => $search_line );


}




#########################
sub create_view_command {
#########################
  my $q     = shift;
  my $title = shift;
  my $cid   = $q->param('command_id');
  my $pst   = "<SELECT NAME='permanent'>\n<OPTION VALUE=1 %s>Reusable\n" .
              "<OPTION VALUE=0 %s>Ephemeral\n</SELECT>\n";

  if (defined($cid)) {

    # View an existing command
    my $record = $CF_DB->getCQ_Command_by_recid($cid);

    $title ||= "View Command";

    # Generate drop-down lists from templates
    my $pslist = $record->{'permanent'}       ?
                 sprintf($pst, 'SELECTED', ''): 
	 sprintf($pst, '', 'SELECTED');


    # Make sure the "Update" button goes to the right place
    $q->param('page', 'update');

    return &form('create_CQ_command',
	 myurl          => $MYURL,
	 title          => $title,
                 description    => $record->{'description'}, 
                 commandline    => $record->{'command_line'},
                 perm_select    => $pslist,
                 euid           => $record->{'effective_user'},
                 egid           => $record->{'effective_group'},
                 notes          => $record->{'notes'},
                 buttons        => '<INPUT TYPE="submit" NAME="update" VALUE="Update"><INPUT TYPE="reset" VALUE="Reset">',
	 hidden         => ''
	);

    
  } else {

    # Print the form to create a new command
    my $pslist = sprintf($pst, 'SELECTED', '');
    $title ||= "Create Command";

    # Set the page parameter to 'create_cmd'
    $q->param(page => "create_cmd");

    return &form('create_CQ_command',
	myurl       => $MYURL,
	# +++ myurl       => "http://davepc.nocpulse.net/~dfaraldo/bin/vars.cgi",
	title       => $title,
                description => "<INPUT TYPE=text NAME='description' SIZE=40 MAXSIZE=40>", 
                commandline => "<FONT SIZE=-1>&lt;&lt;Enter an sprintf string, where '%' marks an sprintf format and '%%' is a literal percent sign.&gt;&gt;</FONT><BR><INPUT TYPE=text NAME='commandline' SIZE=80 MAXSIZE=2000>",
                perm_select => $pslist,
                euid        => "<INPUT TYPE=text NAME='euid' SIZE=40 MAXSIZE=40>",
                egid        => "<INPUT TYPE=text NAME='egid' SIZE=40 MAXSIZE=40>",
                notes       => "",
                buttons     => '<INPUT TYPE="submit" NAME="create" VALUE="Create"><INPUT TYPE="reset" VALUE="Reset">',
	hidden      => &hidden_params($q, 'page'),
	);

  }
}



####################
sub insert_command {
####################
  my $q = shift;

  $CF_DB->dprint(1, "Creating command\n");
  my $command_id = $CF_DB->createCQ_Command(
                             $q->param('description'),  # Description
                             $q->param('cqc_notes'),    # Notes
                             $q->param('commandline'),  # Command line
                             $q->param('permanent'),    # Permanent?
                             0,                         # Restartable?
                             $q->param('euid'),         # EUID
                             $q->param('egid')          # EGID
                           );

  if ($command_id) {
    $q->param('command_id', $command_id);
    return &create_instance($q);
  } else {
    print "+++ ERROR:  Command creation failed: $@\n";
  }

}



#####################
sub create_instance {
#####################
  my $q = shift;
  my $command = $q->param('command_id');

  if (! defined($command)) {
    return "+++ ERROR: No command id was specified.  Please try again.\n"
  } 
  my $value=$CF_DB->getCQ_Command_by_recid($command);
  unless ($value) {
    return "+++ ERROR: Invalid command id was specified.  Please try again.\n"
  }

  $CF_DB->dprint(1, "Creating instance form\n");

  # Get any values from prior submissions
  my @clusters = $q->param('clusters');
  my @nodes    = $q->param('nodes');
  my $timeout  = $q->param('timeout') || 60;
  my $notify   = $q->param('notify');
  my $notes    = $q->param('cqi_notes') || "";
  my $sysdate  = $CF_DB->get_sysdate;

  my ($expmins,$exphours,$expdays) = (0,0,0);
  if ($q->param('expirelen') > 60) {
    my $rem   = $q->param('expirelen');
    $expdays  = int($q->param('expirelen') / (60 * 60 * 24));
    $rem      = $rem - $expdays * 60 * 60 * 24;
    $exphours = int($rem / (60 * 60));
    $rem      = $rem - $exphours * 60 * 60;
    $expmins = int($rem / 60);
  } else {
    $expmins = 5;
  }

  # Derive other values
  my $commandstr  = "<UL>" . &create_view_command($q, 'Command') . "</UL>";
  my $clustermenu = &clustermenu('clusters',@clusters);
  my $nodemenu    = &nodemenu('nodes',@nodes);

  # Figure out how many param fields to include
  my($cmd_raw, $param_inputs) = &command_param_inputs($q);

  # Set the page parameter to 'execute'
  $q->param(page => "execute");

  return &form('create_CQ_instance_deux',
	myurl       => $MYURL,
	# +++ myurl       => "http://davepc.nocpulse.net/~dfaraldo/bin/vars.cgi",
	title       => "Create Instance",
                command     => $commandstr,
	timeout     => "<INPUT TYPE=text NAME='timeout' SIZE=5 MAXSIZE=15 VALUE='$timeout'>",
        expiremin   => $expmins,
        expirehours => $exphours,
        expiredays  => $expdays,
	notify      => "<INPUT TYPE=text NAME='notify' SIZE=50 MAXSIZE=50 VALUE='$notify'>",
	notes       => $notes,
	clusters      => $clustermenu,
        nodes       => $nodemenu,
	commandline_raw => $cmd_raw,
	param_inputs => $param_inputs,
                buttons     => '<INPUT TYPE="submit" NAME="execute" VALUE="Execute"><INPUT TYPE="reset" VALUE="Reset">',
	hidden      => &hidden_params($q, 'command_id', 'page'),
              );

}


#############
sub execute {
#############
  my $q = shift;

  # This is it, folks.
  my @clusters = $q->param('clusters');
  my @nodes  = $q->param('nodes');

  unless(scalar(@clusters) or scalar(@nodes)) {
    return "+++ ERROR:  You must select at least one sat cluster or node\n";
  }

  # Check for the proper number of parameters
  my @params = $q->param('cmdparam');
  my $pcount = &count_param_inputs($q->param('command_id'));
  @params = grep { $_ =! /^\s*$/ } @params;
  $CF_DB->dprint(1, "params: @params");
  unless (scalar(@params) == $pcount) {
    return "+++ ERROR:  You must provide exactly $pcount parameters\n";
  }
  
  # First, create the instance record in the database.
  $CF_DB->dprint(1, "Creating instance\n");

  #  Determine the expire date for the command
  my $now       = str2time($CF_DB->get_sysdate);
  my $timestamp = $now + $q->param('expiremin') * 60 +  $q->param('expirehours') * 60 * 60 +  $q->param('expiredays') * 60 * 60 * 24;
  my $expstring = strftime($F_DATE_FORMAT,gmtime($timestamp));
  my $expdate   = "TO_DATE('$expstring', '$DB_DATE_FORMAT')";

  my $instance_id = $CF_DB->createCQ_Instance(
                              $q->param('command_id'),  # COMMAND_ID
                              $q->param('cqi_notes'),   # NOTES
                              $expdate,                 # EXPIRATION_DATE
                              $q->param('notify'),      # NOTIFY_EMAIL
                              $q->param('timeout')      # TIMEOUT
                            );

  $CF_DB->dprint(1, "Instance id is '$instance_id'\n");
  unless ($instance_id) {
    return "+++ ERROR:  Instance creation failed: $@\n";
  }

  # Then, create parameters if they exist
  @params = $q->param('cmdparam');
  my $pcount = &count_param_inputs($q->param('command_id'));
  $CF_DB->dprint(1, "Creating parameters\n");
  $CF_DB->dprint(1, "\tPARAMS: '", join("', '", @params), "'\n");
  my $i;
  for ($i = 0; $i < scalar(@params); $i++) {
    my $rv = $CF_DB->createCQ_Param($instance_id, $i, $params[$i]);
    $CF_DB->dprint(3, "\tParam $i RV: $rv\n");
  }



  # Then, create an exec record for each netsaint and node.
  $CF_DB->dprint(1, "Creating Execs\n");

  my $cluster;
  foreach $cluster (@clusters) {
      $CF_DB->dprint(2, "\tScout $cluster ...\n");
      my $rv = $CF_DB->createCQ_Exec(
			     $instance_id,  # INSTANCE_ID
			     $cluster,      # NETSAINT_ID (aka target id)
			     'cluster');    # TARGET_TYPE

    $CF_DB->dprint(3, "\t\tRV: '$rv'; \$\@:  '$@'; ERRSTR: $DBI::errstr\n");
  }

  my $node;
  foreach $node (@nodes) {
    $CF_DB->dprint(1, "\tNode $node ...\n");
    my $rv = $CF_DB->createCQ_Exec(
                                   $instance_id,  # INSTANCE_ID
                                   $node,         # NETSAINT_ID (aka target id)
                                   'node'         # target type
            );
    $CF_DB->dprint(3, "\t\tRV: '$rv'; \$\@:  '$@'; ERRSTR: $DBI::errstr\n");
  }

  #show the status; redirect so multiple executes do not occur on reload
  my $rv .= &form('status_redirect',
                 myurl => "$MYURL?page=status&instance_id=$instance_id");
  return $rv
}

#################
sub show_status {
#################
  my $q = shift;
  my ($rv,@pending,@accepted,@completed,@failed,@succeeded,@total,$done);
  my $failed_color='black';

  # Show the status of a particular instance
  my $iid = $q->param('instance_id');
  $CF_DB->dprint(1, "Showing status for instance $iid\n");
  return "+++ ERROR:  show_status called with no instance_id" unless ($iid);

  my $instance      = $CF_DB->getCQ_Instance_by_recid($iid);
  my $command       = $CF_DB->getCQ_Command_by_recid($instance->{'command_id'});
  my $execs         = $CF_DB->getCQ_Execs_by_instance_id($iid, ['netsaint_id']);
  my ($pdata,$pord) = $CF_DB->getCQ_Params_by_instance_id($iid, ['ord']);
  my $noderef       = $CF_DB->getNodes;
  my $clusterref    = $CF_DB->getSatellites;
  my $custref       = $CF_DB->getCustomers;
  my $sysdate       = $CF_DB->get_sysdate;
  my $now           = str2time($sysdate);

  my @params;
  foreach my $param (@$pord) {
    push(@params, $pdata->{$param}->{'value'});
  }

  # Sort the output
  my @sorted;
  my $sort_param=$q->param('sortby') || 'cluster_id';
 
  my @presort = map {
    &addCustomerData($_,$noderef,$clusterref,$custref);
    [$_, $_->{$sort_param}] 
  } values(%$execs);

  @sorted= map $_->[0] => sort sort_it @presort;

  my $statusrows;
  foreach my $exec (@sorted) {
    $CF_DB->dprint(2, "\tExec:", &Dumper($exec), "\n");
    
    my @values;
    $statusrows .= "<TR>\n";

    # describe the sat node/cluster and customer in a mouseover

    # cluster id
    $statusrows .= sprintf("  <TD><FONT SIZE=-1><A HREF='note: clusterid=%d clustername=%s custid=%d custdesc=%s'>%d</A></FONT></TD>\n", 
                     $exec->{'cluster_id'}, 
                     $exec->{'cluster_desc'}, 
                     $exec->{'customer_id'}, 
                     $exec->{'customer_desc'}, 
                     $exec->{'cluster_id'} );
    
    # node id (optional)
    $statusrows .= sprintf("  <TD><FONT SIZE=-1>%s</FONT></TD>\n", $exec->{'node_id'} || '&nbsp;');

    # customer id
    $statusrows .= sprintf("  <TD><FONT SIZE=-1><A HREF='note: custid=%d custdesc=%s'>%d</A></FONT></TD>\n", 
                     $exec->{'customer_id'}, 
                     $exec->{'customer_desc'}, 
                     $exec->{'customer_id'} );

    foreach my $col (qw( date_accepted date_executed 
                         execution_time exit_status stdout stderr)) {

      my $value = $exec->{$col};
      $CF_DB->dprint(3, "\tCOL '$col' has value '$value'\n");

      # Escape appropriately for HTML display
      $value = &html_escape($value);

      $statusrows .= sprintf("  <TD><FONT SIZE=-1>%s</FONT></TD>\n", $value);
    }
    $statusrows .= "</TR>\n\n";

    # Tally what's in what status by cluster or node id
    my $tag=uc($exec->{'target_type'}) eq 'cluster' ? 'clusters' : 'nodes';
    $tag .= ':' . $exec->{'netsaint_id'};

    push(@total,$tag);

    if ($exec->{'exit_status'}) {
      push(@failed,$tag);
      $failed_color='red';
    } else {
      push(@succeeded,$tag) if $exec->{'date_executed'}
    }

    if ($exec->{'date_executed'}) {
      push(@completed,$tag);
    } elsif ($exec->{'date_accepted'}) {
      push(@accepted,$tag);
    } else {
        push(@pending,$tag);
    }

  } 

  # Check to see if all commands have executed
  my $completed_color='black';
  if (scalar(@completed) == scalar(@total)) {
    $completed_color='LimeGreen';
    $done = 1;
  }
 
  # Check the time out date
  my $timeout_color='black';
  my $timeout_time=str2time($instance->{'expiration_date'}) + $instance->{'timeout'} + $EXECUTE_LATENCY;

  if ($now >= $timeout_time) {
    $timeout_color='red';
    $done = 1;
  }

  my $timeout_str=strftime('%Y-%m-%d %H:%M:%S',gmtime($timeout_time));

  # Check the refresh rate
  my ($refreshurl,$refreshtext);
  my $statusurl = "$MYURL?instance_id=$iid&page=status";

  my $meta;
  if ($q->param('refresh') eq 'none' || $done) {
    $refreshurl  = "$statusurl&sortby=$sort_param";
    $refreshtext = 'Enable refresh';
    $statusurl  .= '&refresh=none';
  } else {
    $meta="<META HTTP-EQUIV=\"refresh\" CONTENT=\"$REFRESH_SECONDS;URL=$statusurl&sortby=$sort_param\">";

    $refreshurl  = "$statusurl&refresh=none&sortby=$sort_param";
    $refreshtext = 'Stop refresh';
  }

  # Calculate the expire length
  my $subtime=str2time($instance->{'date_submitted'});
  my $exptime=str2time($instance->{'expiration_date'});
  my $explen=$exptime - $subtime;

  # Construct any urls
  my $samecommand = "$MYURL?page=create_instance&";
  $samecommand .= join ('&',
     'command_id=' . $instance->{'command_id'},
     'expirelen='  . $explen,
     'timeout='    . $instance->{'timeout'},
     'notify='     . &uri_escape($instance->{'notify_email'}),
     'cqi_notes='  . &uri_escape($instance->{'notes'}) );
  $samecommand .= &url_params('cmdparam',@params);

  my $differentcommand="$MYURL?page=main";

  # Finally, build the form
  my $downloadurl = "$MYURL?instance_id=$iid&page=download_results";
  my $reporturl   = "$MYURL?instance_id=$iid&page=status_report";
  my $historyurl  = "$MYURL?page=query_exec_history";
  $rv .= &form('instance_status_deux',
                title        => "Status of instance $iid",
                meta         => $meta,
                refreshurl   => $refreshurl,
                refreshtext  => $refreshtext,
                myurl        => $statusurl,
                baseurl      => $MYURL,
                downloadurl  => $downloadurl,
                reporturl    => $reporturl,
                historyurl   => $historyurl,
                commandid    => $instance->{'command_id'},
                description  => $command->{'description'},
                commandline  => sprintf($command->{'command_line'}, @params),
                cqi_notes    => $instance->{'notes'},
                subdate      => $instance->{'date_submitted'},
                expdate      => $instance->{'expiration_date'},
                timeoutdate  => $timeout_str,
                timeoutcolor => $timeout_color,
                currentdate  => $sysdate,
                statusrows   => $statusrows,
	        instance_id  => "<A HREF=$statusurl>$iid</A>",
                pending      => @total     ? int(scalar(@pending)   / scalar(@total)     * 10000) / 100 : 0,
                accepted     => @total     ? int(scalar(@accepted)  / scalar(@total)     * 10000) / 100 : 0,
                completed    => @total     ? int(scalar(@completed) / scalar(@total)     * 10000) / 100 : 0,
                compcolor    => $completed_color,
                failed       => @total     ? int(scalar(@failed)    / scalar(@total)     * 10000) / 100 : 0,
                failofcomp   => @completed ? int(scalar(@failed)    / scalar(@completed) * 10000) / 100 : 0,
                succeeded    => @total     ? int(scalar(@succeeded) / scalar(@total)     * 10000) / 100 : 0,
                failcolor    => $failed_color,
                samecommand      => $samecommand,
                differentcommand => $differentcommand,
                pendingparam     => &url_params_with_key(@pending),
                acceptedparam    => &url_params_with_key(@accepted),
                completedparam   => &url_params_with_key(@completed),
                failedparam      => &url_params_with_key(@failed),
                succeededparam   => &url_params_with_key(@succeeded),
                totalparam       => &url_params_with_key(@total)
      );

   # Return the form
   return $rv
}

###################
sub status_report {
###################
  my $q = shift;
  my (@pending,@accepted,@completed,@failed,@succeeded,@total);

  # Show the status of a particular instance
  my $iid = $q->param('instance_id');

  my $instance      = $CF_DB->getCQ_Instance_by_recid($iid);
  my $command       = $CF_DB->getCQ_Command_by_recid($instance->{'command_id'});
  my $execs         = $CF_DB->getCQ_Execs_by_instance_id($iid, ['netsaint_id']);
  my ($pdata,$pord) = $CF_DB->getCQ_Params_by_instance_id($iid, ['ord']);
  my $noderef       = $CF_DB->getNodes;
  my $clusterref    = $CF_DB->getSatellites;
  my $custref       = $CF_DB->getCustomers;

  my @params;  
  foreach my $param (@$pord) {
    push(@params, $pdata->{$param}->{'value'});
  }

  my $timeout_time=str2time($instance->{'expiration_date'}) + $instance->{'timeout'} + $EXECUTE_LATENCY;
  my $timeout_str=strftime('%Y-%m-%d %H:%M:%S',gmtime($timeout_time));

  # Print the header

  printf "Instance Id:            %d\n", $iid;
  printf "Command Id/Description: %d %s\n", $instance->{'command_id'};
  printf "Command Line:           " . sprintf($command->{'command_line'}, @params) . "\n";
  printf "Instance Notes:         %s\n", $instance->{'notes'};
  printf "Date Submitted:         %s GMT\n", $instance->{'date_submitted'};
  printf "Expiration Date:        %s GMT\n", $instance->{'expiration_date'};
  printf "Timeout Date:           %s GMT\n\n", $timeout_str;


  foreach my $exec (values(%$execs)) {

    # Add customer data
    &addCustomerData($exec,$noderef,$clusterref,$custref);
## HELP HERE

    # Tally what's in what status
    push(@total,$exec);

    if ($exec->{'exit_status'}) {
      push(@failed,$exec);
    } else {
      push(@succeeded,$exec) if $exec->{'date_executed'}
    }
    if ($exec->{'date_executed'}) {
      push(@completed,$exec);
    } elsif ($exec->{'date_accepted'}) {
      push(@accepted,$exec);
    } else {
        push(@pending,$exec);
    }
  } 

  # Print summary information
  printf "Pending: %5.2f%% Accepted: %5.2f%% Completed: %5.2f%% ",
    scalar(@pending)    / scalar(@total) * 100,
    scalar(@accepted)   / scalar(@total) * 100,
    scalar(@completed)  / scalar(@total) * 100 ;
  printf "(Succeeded: %5.2f%% Failed: %5.2f%%)\n\n",
    scalar(@succeeded)  / scalar(@total) * 100,
    scalar(@failed  )   / scalar(@total) * 100 ;

  # Do the report
  &report_lines('Scouts that did not accept',@pending);
  &report_lines('Scouts that did not complete',@accepted);
  &report_lines('Scouts that failed',@failed);
  &report_lines('Scouts that succeeded',@succeeded);

  print "[Legend:  D=deployed, CID=customer id, SID=sat cluster id, NID=sat node id]\n"
}



######################
sub download_results {
######################
  # Deliver the results in comma delimited format
  my $q = shift;
  my $iid = $q->param('instance_id');

  my $instance      = $CF_DB->getCQ_Instance_by_recid($iid);
  my $command       = $CF_DB->getCQ_Command_by_recid($instance->{'command_id'});
  my $execs         = $CF_DB->getCQ_Execs_by_instance_id($iid, ['netsaint_id']);
  my ($pdata,$pord) = $CF_DB->getCQ_Params_by_instance_id($iid, ['ord']);
  my $noderef       = $CF_DB->getNodes;
  my $clusterref    = $CF_DB->getSatellites;
  my $custref       = $CF_DB->getCustomers;

  my @cols= qw(cluster_id cluster_desc customer_id customer_desc 
               date_accepted date_executed execution_time
	       exit_status stdout stderr node_id 
               deployed cluster_vip node_ip);

  # Print the column headers
  print join(',',@cols), "\n";

  # Print the data
  foreach my $exec (values(%$execs)) {

    &addCustomerData($exec,$noderef,$clusterref,$custref);

    my @items=map { my $val=$exec->{$_}; $val =~ /[,]/ ? "\"$val\"" : $val} @cols;
   my $line=join(',',@items);
   $line =~ s/\n/\\n/g;
   print "$line\n";
  }

}

########$##########
sub query_history {
###################
  my $q = shift();

  my $rv .= &form('search_CQ_instance_history',
	           myurl          => $MYURL,
                   title   => 'Search Command Execution History',
                   order1  => exec_query_menu(name => 'order1', size => 1, blank => 'choose one ...'),
                   order2  => exec_query_menu(name => 'order2', size => 1, blank => 'choose one ...'),
                   order3  => exec_query_menu(name => 'order3', size => 1, blank => 'choose one ...'),
                   select1 => exec_query_menu(name => 'selections', size => 10, multiple => 1, selected => [ 'command id','command description','instance id' ] ),
                   query1  => exec_query_menu(name => 'field1', text_fields => 'y'),
                   query2  => exec_query_menu(name => 'field2', text_fields => 'y'),
                   query3  => exec_query_menu(name => 'field3', text_fields => 'y'),
                   query4  => exec_query_menu(name => 'field4', text_fields => 'y'),
                   query5  => exec_query_menu(name => 'field5', text_fields => 'y'),
                   hidden  => &hidden_hash(page => 'show_history')
            );

  return $rv;
}

##################
sub show_history {
##################
  my $q = shift();
  my $err;

  #Build the sql to execute
  my $select1 = "SELECT\n";
  my $select2 = $select1;

  # parse the user's order by fields
  my @orders;
  if ($q->param('order1'))  {push(@orders,$q->param('order1'))};
  if ($q->param('order2'))  {push(@orders,$q->param('order2'))};
  if ($q->param('order3'))  {push(@orders,$q->param('order3'))};
  @orders = map { my ($col)=split(/:/); $col } @orders; 
  my @fields=$q->param('selections');

  # parse the user's selected fields to display
  return "<p>no fields selected to display</p>" unless @fields;
  my %temp = map { split(/:/) } @fields;
  my @cols = keys(%temp); my @descs = values(%temp); 
  my $size_cols=scalar(@cols);
  my @selects  = map { /date/i ? "TO_CHAR($_,'$DB_DATE_FORMAT')" : $_ } @cols;
  my @selects1 = map { /sat_node/i ? "NULL" :  $_ } @selects;

  # also select the fields the user chose for sorting
  my $count;
  my @order_selects  = map { /date/i ? "TO_CHAR($_,'$DB_SORT_FORMAT')" : $_ } @orders;
  my @order_selects1 = map { $count++; /sat_node/i ? "NULL as order$count" :  "$_ as order$count" } @order_selects;
  $count=0;
  @order_selects     = map { $count++; "$_ as order$count" } @order_selects;
  my $iid_line       =  'command_queue_execs.INSTANCE_ID as iid';
  $select1 .= join(",\n",@selects1,$iid_line,@order_selects1);
  $select2 .= join(",\n",@selects,$iid_line,@order_selects);

  # from
  my $from1 = "\nFROM\ncommand_queue_commands,\ncommand_queue_execs,\ncommand_queue_instances,\ncustomer,\nsat_cluster";
  my $from2 = $from1 . ",\nsat_node\n";
  $from1   .= "\n";

# standard where clause
  my $where = "
AND  sat_cluster.customer_id = customer.recid
AND  command_queue_execs.instance_id = command_queue_instances.recid 
AND  command_queue_instances.command_id = command_queue_commands.recid\n";

# clusters
my $where1 = 
"AND  sat_cluster.recid = command_queue_execs.netsaint_id 
AND command_queue_execs.target_type = 'cluster'\n";

# nodes
my $where2 = 
"AND sat_node.recid = command_queue_execs.netsaint_id 
AND command_queue_execs.target_type = 'node'
AND sat_node.sat_cluster_id = sat_cluster.recid\n";
  
  # additional where clauses for user's search criteria
  foreach (1..5) {
    if ($q->param("val_field$_")) {
      my $key = $q->param("key_field$_");
      my $op  = $q->param("op_field$_");
      
my $val = $q->param("val_field$_");
      my ($col,$desc)=split(/:/,$key);

      if ($key =~ /date/i) {
        my $ts = str2time($val);
        if (!$ts) {
          $err .= "Invalid date time format entered for \"$desc\".\n";
          last
        }
        $val   = sprintf("TO_DATE('%s','DD-MM-YY HH24:MI:SS')",strftime('%d-%m-%Y  %H:%M:%S',gmtime($ts)));
      } elsif ($op =~ /like/) {
        $val=uc($val);
        $val = "'%$val%'"
      } else {
        $val=uc($val);
        if ($val =~ /\D/) {
          $val="'$val'";
        }
      }
      return "<p>invalid search criteria</p>" unless $key && $op && $val;      
      $where .= "AND UPPER($col) $op $val\n";
    }
  }
  
  #return if a parsing error was found
  if ($err) {
    return $err . "Please press your browser's Back button and try again.\n"
  }

  #execute the newly constructed sql statement
my $sql1 = "
    $select1
    $from1
    WHERE ROWNUM <= $MAX_ROW_COUNT
    $where $where1";
  my $rv1=$CF_DB->dbexec($sql1);
  my $size=scalar(@$rv1);
  $size = $MAX_ROW_COUNT - $size;
  my $sql2 = "
    $select2
    $from2
    WHERE ROWNUM <= $size
    $where $where2";
  my $rv2=$CF_DB->dbexec($sql2);
  my @results;
  push(@results,@$rv1,@$rv2);

  # add the query parameters, if necessary
  # grab the array index of the command line parameter
  my ($found,$index);
  foreach (@cols) {
    if (/COMMAND_LINE/i) {
      $found = 1;
      last 
    }
    $index++;
  }
  #apply the params to the command line using sprintf
  if ($found) {
    my $p_ref = &fetch_command_params();
    foreach (@results) {
      my $iid      = $_->[$size_cols]; #iid follows user selected columns
      my $params   = $p_ref->{$iid} || [];
      my $line     = $_->[$index];
      $_->[$index] = sprintf($line,@$params);
    }
  }

  # sorting
  # create a sort routine using the appropriate alpha or numeric sort
  my $sort_routine = sub {
    my $val;  
    my $index=$size_cols;  #arrays start with 0, but add one for iid col
                           #iid and order columns follow user selected columns
    foreach (@orders) {
      $index++;
      if ($a->[$index] =~ /^[.\d]+$/ && $b->[$index] =~ /^[.\d]+$/) {
        $val = $a->[$index] <=> $b->[$index]
      } else {
        $val = lc($a->[$index]) cmp lc($b->[$index])
      }
      last unless $val == 0
    }
    $val
  };

  # apply the sort
  if (@orders) {
    @results = sort $sort_routine @results;
  };

  #create the information for the output display form
  my @headers=map { "<Th><font size='-2'>$_</font></Th>" } @descs;

  my $historylist;
  foreach my $row (@results) {
    foreach(@orders) { pop(@$row) }; #drop the sorting fields from the display
    pop(@$row);                      #drop instance id row
    $historylist .= "<TR>\n";
    my $i;
    foreach my $col (@$row) {
      $col = &html_escape($col);
      if ($descs[$i] eq 'instance id') {
        $historylist .= sprintf('<TD><font size ="-2"><A HREF="%s?page=status&instance_id=%s">%s</A></font></TD>',$MYURL,$col,$col);
      } else {
        $historylist .= sprintf('<TD><font size ="-2">%s</font></TD>',$col || '&nbsp');
      }
      $i++; 
    }
    $historylist .= '</TR>';
  }

  # create links for the output display form
  my $links = "<A HREF='$MYURL?page=main'>Home</A>&nbsp;&nbsp;";
  $links .= "<A HREF='$MYURL?page=new'>Create new command</A>&nbsp;&nbsp;";
  $links .= "<A HREF='$MYURL'>Execute a command</A>&nbsp;&nbsp;";
  $links .= "<A HREF='$MYURL?page=query_exec_history'>Query execution history</A>&nbsp;&nbsp;";
  $links .= "<A HREF='$MYURL?page=logout'>Log out</A><BR>";

  # produce the display form
  my $rv .= &form('show_CQ_instance_history',
                  links       => $links,
                  headers     => '<Tr>'. join("\n",@headers) . '</Tr>',
                  historylist => $historylist,
                  maxrows     => $MAX_ROW_COUNT,
                  query       => "$sql1\n--order by @orders;\n$sql2\n--order by @orders;\n");

  return $rv;
}



##############################################################################
#                           Utility Subroutines                              #
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

  my ($key, $value);
  while (($key, $value) = each %subs) {
    $template =~ s/&&$key\b/$value/g;
  }

  return $template;

}


###################
sub hidden_params {
###################

  my($q, @params) = @_;
  my($param, $str);

  foreach $param (@params) {
    my $value = $q->param($param);
    if (ref($value)) {
      foreach(@$value) {
        $str .= "<INPUT TYPE='hidden' NAME='$param' VALUE='$_'>\n";
      }
    } else {
      $str .= "<INPUT TYPE='hidden' NAME='$param' VALUE='$value'>\n";
    }
  }

  return $str;
}


#################
sub hidden_hash {
#################

  my %hash= @_;
  my ($key,$value,$val,$str);
 
  while (($key,$value)=each(%hash)) {
    if (ref($value)) {
      foreach (@$value) {
	$str .= "<INPUT TYPE='hidden' NAME='$key' VALUE='$_'>\n";
      }
    } else {
      $val=$value;
      $str .= "<INPUT TYPE='hidden' NAME='$key' VALUE='$val'>\n";
    }
  }
  return $str
}



####################
sub verify_or_bust {
####################
  my($q, @required) = @_;
  my($param, $errors);

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


#################
sub clustermenu {
#################

  my ($name,@clusters) = @_;
  my($clusterid, $last_cid, $label);

  my %clusters=map { $_ => 1 } @clusters;
  print "<!-- (clustermenu) clusters are: ", &Dumper(keys(%clusters)), " -->\n";

#  my $menu = "<SELECT MULTIPLE SIZE=10 NAME='$name'>\n";
  my $menu;

  my $clusterref  = $CF_DB->getSatellites();
  my $custref     = $CF_DB->getCustomers();

  my $clustersort = sub {
    $clusterref->{$a}->{'customer_id'} <=> $clusterref->{$b}->{'customer_id'}
    or
    $clusterref->{$a}->{'description'} cmp $clusterref->{$b}->{'description'}
  };

  foreach $clusterid (sort $clustersort keys %$clusterref) {
    my $cid      = $clusterref->{$clusterid}->{'customer_id'};
    my $desc     = $clusterref->{$clusterid}->{'description'};
    my $vip      = $clusterref->{$clusterid}->{'vip'};
    my $deployed = $clusterref->{$clusterid}->{'deployed'} ? '+' : '-';
    my $cname    = $custref->{$cid}->{'description'};
    my $type     = $custref->{$cid}->{'type'};

    $menu .= "<SELECT MULTIPLE NAME='$name'>\n";

    if ($cid eq $last_cid) {
      $label = sprintf("%s[%5.5d%s] %s (%s)", "&nbsp;" x 8, $clusterid, $deployed, $desc, $vip, $deployed);
    } else {
      $label = sprintf("%s [%5.5d%s] %s (%s) for %s", $cid . "&nbsp;" x (8 - length($cid) - 1), $clusterid,  $deployed, $desc, $vip, $cname);
    }

    my $selected = exists($clusters{$clusterid}) ? 'SELECTED' : '';
    $menu .= "\t<OPTION VALUE='$clusterid' $selected>$label\n";

    $last_cid  = $cid;
  }
  $menu .= "</SELECT>\n";

  return $menu;

}



##############
sub nodemenu {
##############
  my ($name,@nodes)=@_;
  my $menu   = "<SELECT MULTIPLE SIZE=10 NAME='$name'>\n";

  my %nodes =map { $_ => 1 } @nodes;
  print "<!-- (nodemenu) nodes are: ", &Dumper(keys(%nodes)), " -->\n";

  my $noderef    = $CF_DB->getNodes();
  my $clusterref = $CF_DB->getSatellites();
  my $custref    = $CF_DB->getCustomers();
  my $nodesort = sub {
    $noderef->{$a}->{'sat_cluster_id'} <=> $noderef->{$b}->{'sat_cluster_id'}

  };

  my($nodeid, $last);
  foreach $nodeid (sort $nodesort keys %$noderef) {
    my $clid = $noderef->{$nodeid}->{'sat_cluster_id'};
    my $ip   = $noderef->{$nodeid}->{'ip'};
    my $mac  = $noderef->{$nodeid}->{'mac_address'};
    my $cid  = $clusterref->{$clid}->{'customer_id'};
    my $desc = $clusterref->{$clid}->{'description'};
    my $name = $custref->{$cid}->{'description'};

    $ip  .= '&nbsp;' x (16 - length($ip) +1);
    $mac .= '&nbsp;' x (12 - length($mac)+1);

    my $selected = exists($nodes{$nodeid}) ? 'SELECTED' : '';
    my $label = sprintf("%05d [%05d] %s %s (%s for %s)", $clid, $nodeid, $ip, $mac, $desc, $name);
    $menu .= "\t<OPTION VALUE='$nodeid' $selected>$label\n";
    $last = $cid;
  }
  $menu .= "</SELECT>\n";


  return $menu;

}

###############
sub store_sid {
###############

  my $contact_id = shift;
  my $sysdate = $CF_DB->get_sysdate;
  my $now     = str2time($sysdate);

  # Generate a session ID
  my $skey = join(':', $$, $now);
  my $sid  = &md5($skey);
  my $exp  = $now + $SESSIONLIFE; 


  # Store the session ID in the database.  First, try to insert; if
  # that fails, update.
  my $rv;
  unless( $rv = $CF_DB->createCQ_Session($contact_id, $sid, $exp)) {
    $rv = $CF_DB->updateCQ_Session($contact_id, $sid, $exp);
  }

  return $rv ? $sid : undef;

}


#########
sub md5 {
#########
  my $data = shift;
  my ($md5) = Digest::MD5->new;
  $md5->add($data);
  return $md5->hexdigest;
}





###############
sub authorize {
###############
  my $q = shift;
  my @msgs;

  my $errmsg;
  
  if ($q->param('login')) {
    # This is a login attempt.  Verify authentication information,
    # set a cookie, and redirect to the application.
    push(@msgs, "       LOGGING IN          \n");

    # Fetch username/password parameters supplied by user
    my $username = $q->param('login');
    my $passwd   = $q->param('passwd');

    # Encrypt the password
    my $encrypted = &md5($passwd);

    # Fetch the encrypted password from the database
    my $record = $CF_DB->getContactByCustomerUsername($CUSTOMER_ID, $username);


    # Authorize
    if ($record->{'password'} eq $encrypted and
	$record->{'privilege_type_name'} eq $PRIV_TYPE) {
      
      # Success!  
      push(@msgs, "LOGIN SUCCESS!\n");

      # Store a session ID in the database ...
      my $sid = &store_sid($record->{'recid'});

      if ($sid) {
	push(@msgs, "STORE_SID RETURNS:  '$sid'\n");

	# ... and pass it to the user in a cookie

	my $cookie = $q->cookie(-name    => $COOKIENAME,
				-value   => $sid,
#				-expires => "+${SESSIONLIFE}s",
				-path    => $PATH,
				-domain  => $DOMAIN,
				-secure  => 0);

	print $q->header(-cookie => $cookie), "\n";

	print "<HEAD><META HTTP-EQUIV='Refresh' CONTENT='0'>\n",
	      "</HEAD>\n";

	exit 0;

      } else {

	$errmsg = "Failed to store session cookie: $@";

      }
      
    } else {
      
      $errmsg = "Authorization failed\n";
    }

  }
    
  my $sid = $q->cookie(-name => $COOKIENAME);

  if (defined($sid)) {

    # Cookie set -- do cookie verification.
    my $session = $CF_DB->getUnexpiredCQ_SessionBySessionId($sid);

    $sid = undef unless (defined($session));

    check_cookie_expiration($session,$q);

    # Set the user id for future use
    $CF_DB->username(get_user_id($session));

  }

  if (not defined($sid)) {

    # No cookie at this point == rejection -- send back to login page.
    print $q->header, "\n";
    print &form('login',
		 errs             => $errmsg,
		 title            => "SputLite Login", 
		 myurl            => $MYURL);


    exit 0;

  }


}



#################
sub unauthorize {
#################
  my $q = shift;
  my @msgs;

  # Clobber the user cookie

  my $cookie = $q->cookie(-name    => $COOKIENAME,
			  -value   => 0,
			  -expires => "now",
			  -path    => $PATH,
			  -domain  => $DOMAIN,
			  -secure  => 0);

  print $q->header(-cookie => $cookie), "\n";

  print "<HEAD><META HTTP-EQUIV='Refresh' CONTENT='0;URL=$MYURL'>\n",
	"</HEAD>\n";

  exit 0;

}

########################
sub count_param_inputs {
########################
  my $cid = shift; 
  my $record  = $CF_DB->getCQ_Command_by_recid($cid);
  my $cmd_raw = $record->{'command_line'};
  my $tst = $cmd_raw;
  $tst =~ s/%%/LIT/g;  # Get rid of literals
  my $pcount = ($tst =~ s/%/FLD/g);
  return wantarray ? ($cmd_raw,$pcount) : $pcount;
}

##########################
sub command_param_inputs {
##########################
  my $q       = shift;
  my $cid     = $q->param('command_id');

  # How many fields are there?
  my ($cmd_raw,$pcount) = &count_param_inputs($cid);

  # Split out prepopulated values, if any
  my @values=$q->param('cmdparam');

  # Calculate the size of the text box
  my $size;
  $size=int(100/$pcount) if $pcount;
  $size = 10 if $size < 10;
 
  my($i, $param_inputs);
  for ($i = 0; $i < $pcount; $i++) {
    my $value=shift(@values);
    $value=$value ? &uri_unescape($value) : '';
    $param_inputs .= "<INPUT TYPE=text NAME='cmdparam' SIZE='$size' MAXSIZE='1024' VALUE='$value'> ";
  }
  
  return($cmd_raw, $param_inputs);

}

#############
sub sort_it {
#############
# Sort routine for show_status

  if ($a->[1] =~ /^[.\d]+$/ && $b->[1] =~ /^[.\d]+$/) {
    $a->[1] <=> $b->[1]
  } else {
    lc($a->[1]) cmp lc($b->[1])
  }
}

#############################
sub check_cookie_expiration {
#############################
# Renew the session if we're close to expiring

  my ($session,$q) = @_;

  my $sysdate = $CF_DB->get_sysdate;
  my $now     = str2time($sysdate);

  my $expire_date = str2time($session->{'expiration_date'});

  # Leave this place unless we have work to do
  return unless $expire_date < $now + $WHEN_TO_EXTEND;

  my $sid=$session->{'session_id'};
  my $contact_id=$session->{'contact_id'};

  # Update the database with the new expire time
  my $exp  = $now + $SESSIONLIFE; 
  my $rv = $CF_DB->updateCQ_Session($contact_id, $sid, $exp);
}


#################
sub get_user_id {
#################
  my $session = shift();
  return undef unless $session;
  my $contact_id = $session->{'contact_id'};
  my $contact = $CF_DB->getContactById($contact_id);
  if ($contact) {
    return $contact->{'username'}
  } else {
    return undef
  }
}

#################
sub dump_params {
#################
  # Print the query parameters as html comments
  my ($q,$comment) = @_;
  my @params=$q->param();

  print "<!-- $comment\n";
  foreach (@params) {
    print "  $_:", $q->param($_), "\n"
  }
  print "-->\n";
}

################
sub url_params {
################
  #Create params suitable for use in a url, espacing uri sensitive characters
  my ($param,@list) = @_;
  my $str;

  foreach (@list) {
    my $temp = &uri_escape($_);
    $temp = &uri_escape($temp,"^A-Za-z0-9");
    $str .= "&$param=" . $temp;
  }
  return $str
}

#########################
sub url_params_with_key {
#########################
  #Create params suitable for use in a url, espacing uri sensitive characters,
  #from a list of param:value
  my (@list) = @_;
  my $str;

  foreach (@list) {
    print "<!--list item: $_-->\n";
    my ($key,$value) = split(':',$_);
    $str .= "&$key=" . &uri_escape($value)
  }
  return $str
}

##################
sub report_lines {
##################
 # print the report lines for displaying a report of a command execution
  my ($title,@execs) = @_;

  print "$title:\n";

  unless (@execs) {
    print "  (none)\n\n";
    return 
  }

  my @sorted = sort { $a->{'customer_id'} <=> $b->{'customer_id'}  or 
                      $a->{'cluster_id'}  <=> $b->{'cluster_id'}   or
                      $a->{'node_id'}     <=> $b->{'node_id'}
                    } @execs;

  print "D  CID   Customer            SID    NID    IP               Satellite\n";
  print "-  ----  ------------------  -----  -----  ---------------  --------------------------\n";

  foreach my $exec (@sorted) {
  printf "%1.1s  %4d  %-18.18s  %5d  %5d  %-15.15s  %-25.25s\n",
         $exec->{'deployed'} ? 'y' : 'n',
         $exec->{'customer_id'},
         $exec->{'customer_desc'},
         $exec->{'cluster_id'},
         $exec->{'node_id'},
         $exec->{'node_ip'} || $exec->{'cluster_vip'},
         $exec->{'cluster_desc'};
  }
  print "\n\n";
}

#####################
sub addCustomerData {
#####################
  # Add customer and satellite data to a CQ_Execs hash ref

  my ($exec,$noderef,$clusterref,$custref) = @_;

  my $type = uc($exec->{'target_type'});
  if ($type eq 'cluster') {

      $exec->{'cluster_id'} = $exec->{'netsaint_id'};

    } elsif ($type eq 'node') { 

      $exec->{'node_id'}    = $exec->{'netsaint_id'};
      my $node              = $noderef->{$exec->{'node_id'}};

      $exec->{'node_ip'}    = $node->{'ip'};
      $exec->{'cluster_id'} = $node->{'sat_cluster_id'}

    } else { # No clue what we're dealing with ...

      return
    }

    my $cluster = $clusterref->{$exec->{'cluster_id'}};
    $exec->{'cluster_desc'}  = $cluster->{'description'}; 
    $exec->{'customer_id'}   = $cluster->{'customer_id'}; 
    $exec->{'cluster_vip'}   = $cluster->{'ip'}; 
    $exec->{'deployed'}      = $cluster->{'deployed'}; 

    my $cust = $custref->{$exec->{'customer_id'}};
    $exec->{'customer_desc'} = $cust->{'description'}; 
}

#####################
sub exec_query_menu {
#####################
# Create a select list or multiple select list for fields using in querying
# command execution history
  my %params = @_;
  my $name  = $params{'name'};
  my $op    = $params{'op'};
  my $blank = $params{'blank'};  #empty first field

  my %fields = ( 
    'command line'            => 'command_queue_commands.COMMAND_LINE',
    'command description'     => 'command_queue_commands.DESCRIPTION',
    'command effective group' => 'command_queue_commands.EFFECTIVE_GROUP',
    'command effective user'  => 'command_queue_commands.EFFECTIVE_USER',
    'command notes'           => 'command_queue_commands.NOTES',
    'command is permanent'    => 'command_queue_commands.PERMANENT',
    'command id'              => 'command_queue_commands.RECID',
    'date accepted'           => 'command_queue_execs.DATE_ACCEPTED',
    'date executed'           => 'command_queue_execs.DATE_EXECUTED',
    'execution time'          => 'command_queue_execs.EXECUTION_TIME',
    'exit status'             => 'command_queue_execs.EXIT_STATUS',
    'instance id'             => 'command_queue_execs.INSTANCE_ID',
    'stderr'                  => 'command_queue_execs.STDERR',
    'stdout'                  => 'command_queue_execs.STDOUT',
    'target type'             => 'command_queue_execs.TARGET_TYPE',
    'date submitted'          => 'command_queue_instances.DATE_SUBMITTED',
    'expiration date'         => 'command_queue_instances.EXPIRATION_DATE',
    'instance notes'          => 'command_queue_instances.NOTES',
    'notify_email'            => 'command_queue_instances.NOTIFY_EMAIL',
    'timeout'                 => 'command_queue_instances.TIMEOUT',
    'customer is deleted'     => 'customer.DELETED',
    'customer description'    => 'customer.DESCRIPTION',
    'customer type'           => 'customer.TYPE',
    'customer id'             => 'sat_cluster.CUSTOMER_ID',
    'sat cluster description' => 'sat_cluster.DESCRIPTION',
    'sat cluster id'          => 'sat_cluster.RECID',
    'sat cluster is deployed' => 'sat_cluster.DEPLOYED',
    'sat node ip'             => 'sat_node.IP',
    'sat node mac'            => 'sat_node.MAC_ADDRESS',
    'sat node recid'          => 'sat_node.RECID',
  );

  my $namekey = $name;
  $namekey    = "key_$name" if exists($params{'text_fields'});

  my $size=$params{'size'} || 1;
  my $multiple=$params{'multiple'} ? 'MULTIPLE' : '';
  my @selected;
  @selected = exists($params{'selected'}) ? @{$params{'selected'}} : ();
  $CF_DB->dprint(3, "\tselected has value @selected\n");

  # field selection
  my $rv .= "      <TD><SELECT NAME='$namekey' SIZE='$size' $multiple>\n";

  if ($blank) {
    $rv .= "        <OPTION VALUE=''>$blank\n";
  }

  foreach my $item (sort(keys(%fields))) {
    my $selectme = (grep { /^$item$/ } @selected ) ? 'SELECTED' : undef;
    $rv .= sprintf("        <OPTION $selectme VALUE='%s:%s'>%s\n",$fields{$item},$item,$item);
  }
  $rv .= "      </SELECT></TD>\n";

  if (exists($params{'text_fields'})) {
    # operator selection
    my @operators = qw ( = != < <= > >= );
  
    $rv .= "      <TD><SELECT NAME='op_$name' SIZE='1'>\n";

    foreach my $op (@operators) {
      $rv .= "        <OPTION VALUE='$op'>$op\n"
    }
    $rv .= "        <OPTION VALUE='like'>contains\n";
    $rv .= "        <OPTION VALUE='not like'>does not contain\n";
    $rv .= "      </SELECT></TD>\n";
    $rv .= "      <TD><INPUT TYPE='text' name='val_$name'></TD>\n\n"
  }

  return $rv
}

#################
sub html_escape {
#################
#escape any characters that will interfere with html processing/display

  my $string = shift();

  $string =~ s/[&]/\&amp;/g;
  $string =~ s/[<]/\&lt;/g;
  $string =~ s/[>]/\&gt;/g;
  $string =~ s/["]/\&#34;/g;
  $string =~ s/[']/\&#39;/g;
  $string =~ s/\n/<BR>/g;

  if ($string eq '0') {
    return '0'
  } 
  return $string || '&nbsp;'
}

##########################
sub fetch_command_params {
##########################
#return an array of command parameters, indexed by command instance recid

  my $p_ref = $CF_DB->getCQ_Params;
  my %result;

  my @temp= map { my @vals=split(/[|]/); \@vals } keys(%$p_ref);

  my $sort_me = sub {
    ($a->[0] <=> $b->[0]) || ($a->[1] <=> $b->[1])
  };

  foreach (sort $sort_me @temp) {
   my ($one,$two)=@$_;
   push(@{$result{$one}},$p_ref->{"$one|$two"}->{'value'});
  }

  return \%result
}

