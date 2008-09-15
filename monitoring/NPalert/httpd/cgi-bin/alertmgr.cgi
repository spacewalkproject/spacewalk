#!/usr/bin/perl 

#
# file: alertmgr.cgi
#
# This script is a simple web based manager server for notifcation servers
#
# USAGE:
#
# <FORM NAME="your_choice" METHOD=POST ACTION="alertmgr.cgi">
#
#


use strict;
use CGI;
use URI;
use Net::hostent;
use NOCpulse::Config;
use NOCpulse::Notif::NotificationDB;


#--- Globals
my $cfg         = new NOCpulse::Config;
my $HOMEDIR = $cfg->get('notification','home');
my $LOGDIR = $cfg->get('notification','log_dir');
my $TMPDIR = $cfg->get('notification','tmp_dir');

my $SCRIPT = "$HOMEDIR/scripts/notif";

my @notifHosts;
my $notifHostsList;
my @tracefiles;
my $tracefilesList;
my $tracefile;

my ($query, $template, $rc, $exit_status);


#--- Form related variables
my $FUNC;
my $CHOICE;
my $SERVER_NAME;
my $SERVER_IPADDR;
my $INIT;
my $PROTOCOL = 'http';
#my $PORT= $cfg->get('notification', 'admin_port');
my $PORT= '80';
my $ARCHIVE_LOG_DIR;
my $SEND_ID;
my $URL;


#--- HTML font format vars
my $g_blackVerdana1 = '<FONT COLOR="black"   FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="1">';
my $g_blackVerdana2 = '<FONT COLOR="black"   FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="2">';
my $g_blackVerdana3 = '<FONT COLOR="black"   FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="3">';
my $g_redVerdana1  = '<FONT COLOR="red"   FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="1">';
my $g_redVerdana2  = '<FONT COLOR="red"   FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="2">';
my $g_greenVerdana1 = '<FONT COLOR="#009900" FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="1">';
my $g_greenVerdana2 = '<FONT COLOR="#009900" FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="2">';

my $g_blackTimes1 = '<FONT COLOR="black"   FACE="Times New Roman, Times, serif" SIZE="1">';
my $g_blackTimes2 = '<FONT COLOR="black"   FACE="Times New Roman, Times, serif" SIZE="2">';
my $g_blackTimes3 = '<FONT COLOR="black"   FACE="Times New Roman, Times, serif" SIZE="3">';
my $g_redTimes1    = '<FONT COLOR="red"     FACE="Times New Roman, Times, serif" SIZE="1">';
my $g_redTimes2    = '<FONT COLOR="red"     FACE="Times New Roman, Times, serif" SIZE="2">';
my $g_redTimes3    = '<FONT COLOR="red"     FACE="Times New Roman, Times, serif" SIZE="3">';
my $g_greenTimes1 = '<FONT COLOR="#009900" FACE="Times New Roman, Times, serif" SIZE="1">';
my $g_greenTimes2 = '<FONT COLOR="#009900" FACE="Times New Roman, Times, serif" SIZE="2">';
my $g_greenTimes3 = '<FONT COLOR="#009900" FACE="Times New Roman, Times, serif" SIZE="3">';


my $ndb=NOCpulse::Notif::NotificationDB->new;

#----------------------------------------------
# M A I N
#----------------------------------------------


#----- Create a new CGI object
$query = new CGI;
print $query->header();
$FUNC     = $query->param('FUNC');
$CHOICE     = $query->param('choice');
$SERVER_IPADDR   = $query->param('SERVER_NAME');
$INIT     = $query->param('init');
$ARCHIVE_LOG_DIR = $query->param('logdir');
$SEND_ID         = $query->param('send_id');
#print $query->dump(); exit;


#*************************************************
# Display list of hosts to manage (default)
#*************************************************
if (!$FUNC) {

  #--- Build HTML select list for Notification Servers
  my $ref = $ndb->select_notifservers;
  @notifHosts = map { $_->{NAME} } @$ref;


  #--- Pull in the HTML form template
  $template = '';
  open (TL, "< ../templates/alertmgr_hostlist.html") or die "Can't open file alertmgr_hostlist.html: $!\n";
  while (<TL>) { $template .= $_ }
  close TL;


  #--- Print out the columns for each row
  foreach $SERVER_IPADDR (@notifHosts) {
    my $r = &gethost($SERVER_IPADDR);
    $SERVER_NAME = $r ? $r->name : $SERVER_IPADDR;

    #--- Begin tag for this row
    $notifHostsList .= sprintf<<EOHTML;
  <TR>
EOHTML


    #--- Print out the first column of data, containing an HREF to a detailed record report
    $notifHostsList .= sprintf<<EOHTML;
  <TD ALIGN="left" NOWRAP>$g_blackVerdana1 <A HREF="$PROTOCOL://$SERVER_IPADDR:$PORT/cgi-bin/alertmgr.cgi?&FUNC=2&SERVER_NAME=$SERVER_IPADDR"> $SERVER_NAME [$SERVER_IPADDR] </A></FONT></TD>
EOHTML


    #--- End tag for this row
    $notifHostsList .= sprintf<<EOHTML;
  </TR>
EOHTML

  }


  #--- Make HTML object substitutions
  $template =~ s/&&notifHostsList/$notifHostsList/g;


  #--- Output final HTML
  print $template;

}

#*************************************************
# Display list of host functions available
#*************************************************
if ($FUNC == 2) {

  #--- Get the list of trace files and form HTML table rows with it
  my $tracefilesList = &traceFileList;

  #--- Pull in the HTML form template
  open (TL, "< ../templates/alertmgr_form.html") or die "Can't open file alertmgr_form.html: $!\n";
  while (<TL>) { $template .= $_ }
  close TL;


  #--- Make HTML object substitutions

  if ($SERVER_IPADDR =~ /^\d+\.\d+\.\d+\.\d+$/) {
    &get_server_name($SERVER_IPADDR) if ! $SERVER_NAME;
    $template =~ s/&&servername/$SERVER_NAME [$SERVER_IPADDR]/g;
  }
  else {
    $template =~ s/&&servername/$SERVER_IPADDR/g;
  }
  $template =~ s/&&tracefilesList/$tracefilesList/g;
  $template =~ s/&&results//g;


  #--- Output final HTML
  print $template;

}


#*************************************************
# Process the form request
#*************************************************
if ($FUNC == 3) {

  #--- Get the list of trace files and form HTML table rows with it
  my $tracefilesList = &traceFileList;


  #--- Pull in the HTML form template
  open (TL, "< ../templates/alertmgr_form.html") or die "Can't open file alertmgr_form.html: $!\n";
  while (<TL>) { $template .= $_ }
  close TL;


  #--- Default case where form was submitted with no choices
  $rc = '';


  #--- Make HTML object substitutions
  if ($CHOICE eq 'stop') {
    $rc = `$SCRIPT --stop`;
    $exit_status = $?;
  }

  if ($CHOICE eq 'start') {
    $rc = `$SCRIPT --start`;
    $exit_status = $?;
  }

  if ($CHOICE eq 'showstatus') {
    $rc = `$SCRIPT --status`;
    $exit_status = $?;
  }

  if ($CHOICE eq 'showalerts') {
    $rc = `$SCRIPT show alert all`;
  }

  if ($CHOICE eq 'clearalert') {
    $rc = `$SCRIPT clear send $SEND_ID`;
    $exit_status = $?;
  }
  
  if ($CHOICE eq 'ackalert') {
    $rc = `$SCRIPT ack send $SEND_ID`;
    $exit_status = $?;
  }
  
  if ($CHOICE eq 'nakalert') {
    $rc = `$SCRIPT nak send $SEND_ID`;
    $exit_status = $?;
  }

  #--- Make HTML object substitutions
  if ($SERVER_IPADDR =~ /^\d+\.\d+\.\d+\.\d+$/) {
    &get_server_name($SERVER_IPADDR) if ! $SERVER_NAME;
    $template =~ s/&&servername/$SERVER_NAME [$SERVER_IPADDR]/g;
  }
  else {
    $template =~ s/&&servername/$SERVER_IPADDR/g;
  }
  $template =~ s/&&servername/$SERVER_NAME [$SERVER_IPADDR]/g;
  $template =~ s/&&results/$rc/g;
  $template =~ s/&&tracefilesList/$tracefilesList/g;


  #--- Output final HTML
  print $template;

}


#----------------------------------------------
# S U B S
#----------------------------------------------


#----------------------------------------------
sub get_server_name {
  my $ipaddr = shift;
  my $hostent = gethost($ipaddr) if ($ipaddr && $ipaddr ne "");
  $SERVER_NAME = $hostent->name if $hostent;
}

#----------------------------------------------
sub traceFileList {

  my ($html);

  #--- Get the list of trace files to choose from
  opendir(DIR, $LOGDIR);
  @tracefiles = readdir(DIR);
  closedir(DIR);
  @tracefiles = grep(-f "$LOGDIR/$_", @tracefiles);


  $html .= "Current log files:<BR>";

  #--- Form hyperlink list with the file names
  foreach $tracefile (@tracefiles) {
    next if ($tracefile =~ /^archive$/ || $tracefile =~ /^ticketlog$/);
    $html .= sprintf<<EOHTML;
&nbsp;&nbsp;&nbsp;<A HREF="/alert_logs/$tracefile"> $tracefile &nbsp;</A>
<BR>
EOHTML
  }

  $html .= &show_ticketlogs($LOGDIR, '&nbsp;&nbsp;&nbsp;');
  $html .= &show_archived_logs();
  $html .= &show_daemonlogs();

  return $html;

} # End of sub traceFileList

#----------------------------------------------
sub datestamp {
  my $time = shift;
  my ($year, $month, $day) = (localtime($time))[5, 4, 3];

  return sprintf("%04s-%02s-%02s", $year + 1900, $month + 1, $day);
}

sub show_archived_logs {
my ($html);

  #--- Show dates of archived logs
  #--- If ARCHIVE_LOG_DIR is null, yesterday's archive is
  #--- expanded and its log files selectable for viewing;
  #--- otherwise, the ARCHIVE_LOG_DIR is expanded and
  #--- its log files selectable for viewing.
  #--- Clicking on an archive log directory expands it and
  #--- collapses any others.

  #--- get yesterday's logs if ARCHIVE_LOG_DIR isn't set
  if (!$ARCHIVE_LOG_DIR || $ARCHIVE_LOG_DIR == "") {
    # Get yesterday's date without Time::Local or Date::Manip
    # by rolling back the hours.
    my $time = time;
    my $datestamp = &datestamp($time);
    my $tmptime = $time;
    my $tmpstamp = $datestamp;
    while ($tmpstamp eq $datestamp) {
      $tmptime -= 60 * 60;
      $tmpstamp = &datestamp($tmptime);
    }
    $ARCHIVE_LOG_DIR = $tmpstamp;
  }

  #--- make selection list of archive dates,
  #--- in reverse chronological order

  my $dir = join('/', $LOGDIR, 'archive');
  opendir(DIR, $dir);
  my @subdirs = readdir(DIR);
  closedir(DIR);
  @subdirs = grep(/\d{4}-\d{2}-\d{2}/, @subdirs);
  @subdirs = sort {$b cmp $a} @subdirs;

  $html .= sprintf<<EOHTML;
<BR>Archived log files:<BR>
&nbsp;&nbsp;&nbsp;<SELECT SIZE="1" NAME="logdir" CLASS="select" 
                   onChange="window.document.forms[0].submit[0].click();">
EOHTML
  foreach $dir (@subdirs) {
    my $selected = "";
    $selected = " SELECTED" if ($dir =~ /^$ARCHIVE_LOG_DIR$/);
    $html .= sprintf<<EOHTML;
<OPTION VALUE="$dir"$selected>$dir
EOHTML
  }
  $html .= sprintf<<EOHTML;
</SELECT> <NOSCRIPT><INPUT TYPE="submit" NAME="submit" VALUE="Change archive date"></NOSCRIPT><BR>
EOHTML

  #--- make links for log files in currently selected archive

  $dir = join('/', $LOGDIR, 'archive', $ARCHIVE_LOG_DIR);
  opendir(DIR, $dir);
  @tracefiles = readdir(DIR);
  closedir(DIR);
  @tracefiles = grep(-f "$dir/$_" && ! /^ticketlog$/, @tracefiles);

  foreach $tracefile (@tracefiles) {
    $html .= sprintf<<EOHTML;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="/alert_logs/archive/$ARCHIVE_LOG_DIR/$tracefile"> $tracefile &nbsp;</A>
<BR>
EOHTML
  }

  $html .= &show_ticketlogs($dir, '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');

  return $html;
}

#----------------------------------------------
sub show_ticketlogs {
  my $dir = shift;
  my $indent = shift;
  my ($file, $html, $subdir);

  $dir = join('/', $dir, 'ticketlog');
  opendir(DIR, $dir);
  my @files = readdir(DIR);
  closedir(DIR);
  @files = grep(-f "$dir/$_", @files);

  $dir =~ s/$LOGDIR//;

  $html .= sprintf<<EOHTML;
<BR>Ticket log files:<BR>
EOHTML

  foreach $file (@files) {
    $html .= sprintf<<EOHTML;
$indent<A HREF="/alert_logs$dir/$file"> $file &nbsp;</A>
<BR>
EOHTML
  }

  return $html;
}

#----------------------------------------------
sub show_daemonlogs {
  my ($dir, $file, $html);

  $dir = $TMPDIR;
  opendir(DIR, $dir);
  my @files = readdir(DIR);
  closedir(DIR);
  @files = grep(/.*log$/, @files);

  $html .= sprintf<<EOHTML;
<BR>Daemon log files:<BR>
EOHTML
  foreach $file (@files) {
    $html .= sprintf<<EOHTML;
&nbsp;&nbsp;&nbsp;<A HREF="/alert_logs/daemonlog/$file"> $file &nbsp;</A>
<BR>
EOHTML
  }

  return $html;
}

