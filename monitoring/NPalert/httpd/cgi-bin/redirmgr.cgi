#!/usr/bin/perl

=pod

=head1 NAME

redirmgr.cgi - web based utility for managing NOCpulse alert redirects

=head1 DESCRIPTION

This script allows the user to manage NOCpulse alert REDIRECTS.
There are currently five redirect types:

1) REDIR - Redirect alert data to a destination(s) other than the
default destination. This is done ONLY if ALL pattern matches associated
with the redirect are true. Pattern matches are performed on the HOST name
of the machine associated with the alert, the name of the network SERVICE,
and the MESSAGE reported. All three of these parameters are reported by
NetSaint. Case is ignored during the pattern matches except for the MESSAGE. However,
an HTML form option is available for case insensitive match on the MESSAGE.

2) METOO - This rule works the same way as REDIR, except that the default
destination is not overridden, but rather appended to.

3) BLACKHOLE - The default destination for an alert is ignored, hence the alert
is never delivered to that destination. The exception to this rule is if there
is a REDIR defined for the default destination.

4) ACK - Automatically acknowledge alerts that match all patterns, for the
chosen destinations.

5) CANCEL - Removes an exsting redirect rule.

All of the above types (except for CANCEL) will not work when the rule's expiration
date & time has been met/exceeded. Expirations can be set down to the minute.

=head1 SYNOPSIS

 <HTML>
 <BODY>
 <FORM NAME="your_choice" METHOD=POST ACTION="redirmgr.cgi?f=func&redirid=redirid">
 ...
 </BODY>
 </HTML>

=over 2

=item C<func>

Function the script performs:

func    = 0, display a summary of all redirects
          1, display the HTML form for creating a
             new redirect
          2, process the new redirect HTML form
          3, display details of an already created
             redirect

=item C<redirid>

ID of an alert redirect that is to be processed by  notification server

=back

=head1 FILES

=over 2

=item C<redir_form.html>

HTML template used to display a summary of all redirects for a particular customer

=item C<redir_status.html>

HTML template used to display the status of a redirect CANCEL request

=head1 BUGS

The ACK redirect rule is currently not implemented.

=head1 SEE ALSO

=over 3


=item C</var/www/cgi-bin/failover.cgi>

=item C</var/www/cgi-bin/notifserver.cgi>

=back

=cut


use strict;
use CGI;
use DBI;
use NOCpulse::Config;
use NOCpulse::Notif::NotificationDB;


#--- Globals
my $ndb = new NOCpulse::Notif::NotificationDB; #DB interface object

use constant DATE_FMT => '%m-%d-%Y %H:%M:%S';


#--- Form related variables
my $custID;
my $contactID;
my $redirid;
my $expired;
my $reason;
my $description;
my $optype;
my $caseins;
my $emails;
my $expire;
my $start_date;
my $customer;
my %customers;
my $expireMonth;
my $expireDay;
my $expireYear;
my $expireHour = '--';
my $expireMin  = '--';
my $expireSec  = '00';
my $startMonth;
my $startDay;
my $startYear;
my $startHour = '--';
my $startMin  = '--';
my $startSec  = '00';
my @groups;
my @methods;
my $contacts_list;
my $groups_list;
my @selectedGroups;
my $methods_list;
my @selectedMethods;
my $match_types;
my @redirs;

my (%month);
@month{'00'..'12'} = ('<Month>', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC');
my %month_s2n;
@month_s2n{values %month} = (keys %month);

my %day;
@day{'00'..'31'}       = ("<Day>",  '01'..'31');

my %year;
@year{0,   2001..2009} = ("<Year>", 2001..2009);

my %hour;
@hour{'--','00'..'23'} = ("<Hour>", '00'..'23');

my %min;
@min{ '--','00'..'59'} = ("<Min>",  '00'..'59');

my %sec;
@sec{ '--','00'..'59'} = ("<Sec>",  '00'..'59');

my $expireMonthSelect;
my $expireDaySelect;
my $expireYearSelect;
my $expireHourSelect;
my $expireMinSelect;
my $expireSecSelect;
my $startMonthSelect;
my $startDaySelect;
my $startYearSelect;
my $startHourSelect;
my $startMinSelect;
my $startSecSelect;


#--- Misc vars
my ($g_func, $query, $g_ticket_id, $template, $sql_statement, $g_db_handle, $g_statement_handle,
    $rc, $rows_ref, $row_ref, @row, $cust_list, $op_list, %optypes, @values, $cmd);


#--- HTML font format vars
my $g_blackVerdana1 = '<FONT COLOR="black"   FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="1">';
my $g_blackVerdana2 = '<FONT COLOR="black"   FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="2">';
my $g_blackVerdana3 = '<FONT COLOR="black"   FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="3">';
my $g_redVerdana1   = '<FONT COLOR="red"     FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="1">';
my $g_redVerdana2   = '<FONT COLOR="red"     FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="2">';
my $g_greenVerdana1 = '<FONT COLOR="#009900" FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="1">';
my $g_greenVerdana2 = '<FONT COLOR="#009900" FACE="Verdana, Arial, Helvetica, sans-serif" SIZE="2">';

my $g_blackTimes1 = '<FONT COLOR="black"   FACE="Times New Roman, Times, serif" SIZE="1">';
my $g_blackTimes2 = '<FONT COLOR="black"   FACE="Times New Roman, Times, serif" SIZE="2">';
my $g_blackTimes3 = '<FONT COLOR="black"   FACE="Times New Roman, Times, serif" SIZE="3">';
my $g_redTimes1   = '<FONT COLOR="red"     FACE="Times New Roman, Times, serif" SIZE="1">';
my $g_redTimes2   = '<FONT COLOR="red"     FACE="Times New Roman, Times, serif" SIZE="2">';
my $g_redTimes3   = '<FONT COLOR="red"     FACE="Times New Roman, Times, serif" SIZE="3">';
my $g_greenTimes1 = '<FONT COLOR="#009900" FACE="Times New Roman, Times, serif" SIZE="1">';
my $g_greenTimes2 = '<FONT COLOR="#009900" FACE="Times New Roman, Times, serif" SIZE="2">';
my $g_greenTimes3 = '<FONT COLOR="#009900" FACE="Times New Roman, Times, serif" SIZE="3">';


my $MAX_CRITERIA = 15;


#----------------------------------------------
# M A I N
#----------------------------------------------

$ENV{TZ}='GMT';

#----- Create a new CGI object
$query   = new CGI;
$g_func  = $query->param('f');
$redirid = $query->param('redirid');

$custID  = $query->param('cid');

print $query->header();
#print $query->dump();

if (!$ndb->dbIsOkay) {
  print "Sorry. The database is not available at this time.<br>";
  print "$@";
  my $date=scalar(localtime());
  print STDERR "$date $0 database error: $@";
  exit(1);
}

if    ($g_func == 1) {

 &createOrModifyForm;
}

elsif ($g_func == 2) {

  &createOrUpdateRedirect;
}

elsif ($g_func == 3) { 

  &createOrModifyForm;
}

elsif ($g_func == 4) {

 &customerSelectForm;

}
elsif ($g_func == 5) {
  &validDataSelectForm;
}
elsif (!$g_func) {

  $custID      = $query->param('cid');

  &showSummary;
}

#----------------------------------------------
# S U B S
#----------------------------------------------

#############
sub newticket
#############
{
  my $ticket = time();
  $ticket   .= '-' . int rand (9999);
  $ticket   .= "-$$";
  return $ticket;


} 
# End of sub newticket
#----------------------------------------------

#################
sub showSummary {
#################

  my %COLOR = (
                0 => 'white',                 # Unexpired, even rows 
                1 => 'thistle',               # Unexpired, odd rows   
                2 => 'slategray',             # Expired, even rows    
                3 => 'darkorchid',            # Expired, odd rows     
  );

  my $summary_report;


  #--- Get table of redir values
  my $ref;
  if ($custID) {
    $ref= $ndb->select_redirects(CUSTOMER_ID => $custID);
  } else {
    $ref= $ndb->select_global_redirects();
  }
  @redirs= sort { $b->{'EXPIRATION'} <=> $a->{'EXPIRATION'} } @$ref; 

  my $cust_desc= $custID ? "Customer $custID" : 'ALL CUSTOMERS (global redirects)';

  #--- Start output of HTML for the table of redir values
  $summary_report .= sprintf<<EOHTML;
    <HTML>
    <HEAD>
    <TITLE>Redirect Summary Report</TITLE>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
    <LINK REL="stylesheet" HREF="/styles.css">
    </HEAD>
    <BODY LINK="#0000CC" VLINK="#0000CC" ALINK="#0000CC">
    <h3>Redirects for $cust_desc</h3>
  <BR>
    $g_blackVerdana2 <A HREF="redirmgr.cgi?f=0&cid=$custID"> Refresh this list &nbsp;</A></FONT>&nbsp;&nbsp;|&nbsp;&nbsp;
    $g_blackVerdana2 <A HREF="redirmgr.cgi?f=1&cid=$custID"> Create a new Redirect &nbsp;</A></FONT>
  <BR>
  <BR>
    <TABLE WIDTH="100%%" CELLSPACING="0" CELLPADDING="0">
       <TR>
       <TD NOWRAP> $g_blackVerdana1 ID &nbsp;&nbsp; </FONT></TD>
       <TD NOWRAP> $g_blackVerdana1 Description &nbsp;&nbsp; </FONT></TD>
       <TD NOWRAP> $g_blackVerdana1 Type &nbsp;&nbsp; </FONT></TD>
       <TD NOWRAP> $g_blackVerdana1 Start &nbsp;&nbsp; </FONT></TD>
       <TD NOWRAP> $g_blackVerdana1 Expiration &nbsp;&nbsp; </FONT></TD>
       <TD NOWRAP> $g_blackVerdana1 Reason &nbsp;&nbsp; </FONT></TD>
       </TR>
EOHTML


  #--- Output rows of data
  my $num_recs   = 0;
  foreach $row_ref (@redirs) {

    my %row = %$row_ref;                

    #--- Extract the redir id for contruction of HREF to a detailed record report
    $redirid = $row{'RECID'};
    $expired = ($row{'EXPIRATION'} - time() > 0) && (time() - $row{'START_DATE'} >= 0) ? 0 : 1;
    my $temp = $num_recs % 2 + 2 * $expired;
    my $color = $COLOR{$temp};

    #--- Start a new row for the summary of records
    $summary_report .= "<TR BGCOLOR='" .
                       $COLOR{$temp} .
                       "'>\n";

    #--- Print out the first column of data, containing an HREF to a detailed record report
    $summary_report .= sprintf<<EOHTML;
    <TD>$g_blackVerdana1 <A HREF="redirmgr.cgi?f=3&redirid=$redirid"> $redirid &nbsp;</A></FONT></TD>
EOHTML


    #--- Print out the remaining columns for this row

    $row{FMT_EXPIRATION}=$ndb->timestamp_to_string($row{EXPIRATION},DATE_FMT);
    $row{FMT_START_DATE}=$ndb->timestamp_to_string($row{START_DATE},DATE_FMT);
    my @values = map { $row{$_} } qw(DESCRIPTION REDIRECT_TYPE FMT_START_DATE FMT_EXPIRATION REASON);
    
    foreach (@values){
      $summary_report .= sprintf<<EOHTML;
        <TD> $g_blackVerdana1 $_ &nbsp;&nbsp;&nbsp</FONT></TD>
EOHTML
    }  # End of foreach @row


    #--- End tag for this row
    $summary_report .= sprintf<<EOHTML;
      </TR>
EOHTML


    #--- Keep track of the number of records selected
    $num_recs++;


  }  # End of foreach @redirs


  #----- Wrap up the HTML for this report
  $summary_report .= sprintf<<EOHTML;
    </TABLE>
    </BODY>
    </HTML>
EOHTML


  print $summary_report;


} 
# End of sub showSummary
#----------------------------------------------

#####################
sub getRedirValues {
#####################

  #--- Fetch the values for this redir from DB

  my $ref=$ndb->select_redirect(RECID => $redirid);
  $optype       = $ref->{'REDIRECT_TYPE'};
  $expire       = $ndb->timestamp_to_string($ref->{'EXPIRATION'},DATE_FMT);
  $contactID    = $ref->{'CONTACT_ID'};
  $reason       = $ref->{'REASON'};
  $description  = $ref->{'DESCRIPTION'};
  $custID       = $ref->{'CUSTOMER_ID'};
  $start_date   = $ndb->timestamp_to_string($ref->{'START_DATE'},DATE_FMT);
 
  if ($custID) {
    $ref=$ndb->select_customer(RECID => $custID);
    $customer     = $ref->{'DESCRIPTION'};  
  } else {
    $custID = 0;
    $customer = 'ALL CUSTOMERS'
  }

  $ref=$ndb->select_redirect_email_targets(REDIRECT_ID => $redirid);
  my @array=map {$_->{EMAIL_ADDRESS} } @$ref;
  $emails=join(',',@array);

  #--- Break up the expire date components for use in the HTML select lists
  my ($date, $time) = split (/ /, $expire, 2);
  ($expireYear, $expireMonth, $expireDay) = split (/\-/, $date);
  ($expireHour, $expireMin, $expireSec)   = split (/\:/, $time);
  ($date, $time) = split (/ /, $start_date, 2);
  ($startYear, $startMonth, $startDay)    = split (/\-/, $date);
  ($startHour, $startMin, $startSec)      = split (/\:/, $time);
  return {}

} 
# End of sub getRedirValues
#----------------------------------------------

#####################
sub putRedirValues {
#####################

  my ($dest_map_recid, $dest_recid, $new_recid);

#**********

  #--- Populate the REDIRECTS table

  #escape description and reason for single quotes -- sql don't like it!

  $description =~ s/'/''/g;
  $reason =~ s/'/''/g;

  #--- Are we creating a new record?
  if (!$redirid) {
    my $cust_val;
    $cust_val= $custID ? $custID : undef;

    (undef,$redirid)=
    $ndb->create_redirect( CUSTOMER_ID      => $cust_val,
                           CONTACT_ID       => $contactID,
                           REDIRECT_TYPE    => $optype,
                           DESCRIPTION      => $description,
                           REASON           => $reason,
                           EXPIRATION       => $expire,
                           LAST_UPDATE_USER => 'redirmgr',
                           LAST_UPDATE_DATE => time(),
                           START_DATE       => $start_date );
    $ndb->commit();
  }

  #--- Or are we updating an existing record?

  else {
    #--- Clear out existing redirect data
    &delete_redirect_data($redirid);

    my $cust_val;
    $cust_val= $custID ? $custID : undef;

    $ndb->update_redirect( RECID            => $redirid,
                           set => {
                             CUSTOMER_ID      => $cust_val,
                             CONTACT_ID       => $contactID,
                             REDIRECT_TYPE    => $optype,
                             DESCRIPTION      => $description,
                             REASON           => $reason,
                             EXPIRATION       => $expire,
                             LAST_UPDATE_USER => 'redirmgr',
                             LAST_UPDATE_DATE => time(),
                             START_DATE       => $start_date } );
  }


#**********

  #--- Populate redirect criteria

  my $i;
  for ($i=1; $i<=$MAX_CRITERIA; $i++) {
    my $key= $query->param("match_types_$i");
    my $value= $query->param("match_value_$i");
    my $inverted=$query->param("inverted_$i");
    $inverted = '0' unless $inverted;

    if ($key && $key ne 'null') {
      $ndb->create_redirect_criteria( REDIRECT_ID => $redirid,
                                      MATCH_PARAM => $key,
                                      MATCH_VALUE => $value,
                                      INVERTED    => $inverted );
    }
  }

    
  #--- Populate redirect contact methods
  foreach (@methods)
  {
    $ndb->create_redirect_method_target ( REDIRECT_ID       => $redirid,
                                          CONTACT_METHOD_ID => $_ );
  }

  #--- Populate redirect contact groups
  foreach (@groups)
  {
    $ndb->create_redirect_group_target ( REDIRECT_ID       => $redirid,
                                         CONTACT_GROUP_ID => $_ );
  }

  #--- Populate redirect email addresses
  foreach (split(/,/,$emails))
  {
    $ndb->create_redirect_email_target ( REDIRECT_ID       => $redirid,
                                         EMAIL_ADDRESS     => $_ );
  }
  
  $ndb->commit();

} 
# End of sub putRedirValues
#----------------------------------------------

#################
sub numerically { 
#################

  $a<=>$b 
}
#end of sub numerically
#----------------------------------------------

############################
sub generateMatchParamList {
############################

  print <<EOHTML;
  <script language="javascript">

  function openHelp(pn_select,fn_input){
    var si=pn_select.selectedIndex;
    if (si > 0) {
      pn=(pn_select.options[si]).value;
      if (pn.match(/PATTERN/)) {
        alert("Sorry, no help is available for patterns (regular expressions)");
      } else {
        fn="document.forms[0]." + fn_input.name;
        fv=fn_input.value;
        newWindow=window.open("redirmgr.cgi?f=5&cid=$custID&pn=" + pn + "&fn=" + fn + "&fv=" + fv,'f5');
        newWindow.focus();
      }
    } else {
      alert("Please choose a param before clicking the help (?) button");
    }
  }
  </script>
  
EOHTML


  my %BG_COLOR = (  
                    0 => '#D8BFD8',  # Thistle
                    1 => '#FFB6C1',  # Lt Pink
                    2 => 'navajowhite',  # Lt Salmon
                    3 => '#FFFACD',  # Lemon Chiffon
                    4 => '#98FB98',  # Pale Green
                    5 => '#B0E0E6'); # Powder Blue

  #---Get the list of match parameters for this redirect
  my $records=$ndb->select_redirect_criteria_by_redirect_id($redirid);

  my $return_string="<table border=\"0\" cellpadding=\"0\">\n";

  #--- Get list of all match types
  my $r=$ndb->select_redirect_match_types();
  my %hash = map { $_->{NAME} => $_->{NAME} } @$r;
  @values = sort { lc ($a) cmp lc ($b) } keys(%hash);
  unshift (@values,'null');
  $hash{'null'}="....pick one....";

  my $i;
  for ($i=1; $i<=$MAX_CRITERIA; $i++) {

    my ($key, $value,$inverted);
    my $row=$records->[$i-1];
    if ($row) {
      $key     =$row->{'MATCH_PARAM'};
      $value   =$row->{'MATCH_VALUE'};
      $inverted=$row->{'INVERTED'} ? "CHECKED" : '';

    } else {
       $key='null';
       $value   ='';
       $inverted='';
    }

     my $bg_color = $BG_COLOR{($i % 6)};

     $return_string .= "\t<tr bgcolor=\"$bg_color\">\n\t\t<td>$g_blackVerdana1 param:&nbsp;";

     $return_string .= sprintf "%s", $query->popup_menu(-name=>"match_types_$i",
                                                        -values=>\@values,
                                                        -default=>$key,
                                                        -labels=>\%hash);
     $return_string .= "</font>\n\t\t</td>\n";
     $return_string .= "\t\t<td>$g_blackVerdana1 value:&nbsp;";
     $return_string .= "<input type=\"button\" value=\"?\" 
        onclick=\"openHelp(document.forms[0].match_types_$i,document.forms[0].match_value_$i)\">";
     $return_string .= "&nbsp;<input type=\"text\" name=\"match_value_$i\" value=\"$value\">\n";
     $return_string .= "\t\t</font></td>\n";
     $return_string .= "\t\t<td>$g_blackVerdana1 negate:&nbsp;<input type=\"checkbox\" name=\"inverted_$i\" value = \"1\" $inverted>\n";
     $return_string .= "\t\t</font></td>\n";
     $return_string .= "\t</tr>\n";
   }

   $return_string .= "\n</table>";
   return $return_string;
}
#end of sub generateMatchParamList 

#----------------------------------------------------------------------------#

########################
sub customerSelectForm {
########################

  #--- Get the list of all customers (for NOC use only!)
  my $records   = $ndb->select_customers();
  my %customers = map { $_->{RECID} => $_->{DESCRIPTION} } @$records;
  $customers{0} = 'ALL CUSTOMERS';
  @values       = sort { lc ($customers{$a}) cmp lc ($customers{$b}) } keys %customers;
  $cust_list    = sprintf "%s", $query->popup_menu(-name=>'cid',
                                                   -values=>\@values,
                                                   -default=>$custID,
                                                   -labels=>\%customers);


  #--- Pull in the HTML form template
  $template = '';
  open (TL, "< ../templates/redir_cust.html") or die "Can't open file redir_cust.html: $!\n";
  while (<TL>) { $template .= $_ }
  close TL;


  $template =~ s/&&cid/$cust_list/g;


  #--- Output final HTML
  print $template;

}
#end of sub customerSelectForm 

#----------------------------------------------------------------------------#

########################
sub createOrModifyForm {
########################

  $custID      = $query->param('cid');

  #--- Get values for this redir and set HTML object default values
  if ($g_func == 3) {
    &getRedirValues;

  }


  #--- Get redirect op (redirect types) list and build op HTML select list
  my $records  = $ndb->select_redirect_types;
  my %r = map { $_->{NAME} => join(' - ',$_->{NAME},$_->{DESCRIPTION} ) } @$records;
  
  @values  = sort { lc ($a) cmp lc ($b) } keys(%r);
  $op_list = sprintf "%s", $query->popup_menu(-name=>'optype',
                                                    -values=>\@values,
                                                    -default=>$optype,
                                                    -labels=>\%r);

  #--- Get all the match types

  $match_types=&generateMatchParamList();


  #--- Get the contact methods already belonging to this redirect
  $records = $ndb->select_redirect_method_targets(REDIRECT_ID => $redirid);
  @selectedMethods= map { $_->{CONTACT_METHOD_ID} } @$records;

  #--- Get the contact groups already belonging to this redirect
  $records = $ndb->select_redirect_group_targets(REDIRECT_ID => $redirid);
  @selectedGroups= map { $_->{CONTACT_GROUP_ID} } @$records;

  #--- Get contact list for the customer
  my $cust_val = $custID ? $custID : 1;
  $records=$ndb->select_contacts(CUSTOMER_ID => $cust_val);
  my %contacts = map { $_->{RECID} => join(', ',$_->{CONTACT_LAST_NAME},$_->{CONTACT_FIRST_NAME}) } @$records;

  @values  = sort { lc ($r{$a}) cmp lc ($r{$b}) } keys(%contacts);

  $contacts_list = sprintf "%s", $query->popup_menu(-name=>'contacts',
                                                           -values=>\@values,
                                                           -default=>$contactID,
                                                           -labels=>\%contacts);

  #--- Get contact method list the user has ownership of

  $records= $ndb->select_contact_methods_by_customer_id($cust_val);
  %r = map { $_->{RECID} => $_->{METHOD_NAME} } @$records;

  @values  = sort { lc ($r{$a}) cmp lc ($r{$b}) } keys(%r);

  $methods_list = sprintf "%s", $query->scrolling_list(-name=>'methods',
                                                           -values=>\@values,
                                                           -size=>10,
                                                           -multiple=>1,
                                                           -default=>\@selectedMethods,
                                                           -labels=>\%r);

  #--- Get contact group list the user has ownership of

  $records= $ndb->select_contact_groups('CUSTOMER_ID' => $cust_val);
  %r = map { $_->{RECID} => $_->{CONTACT_GROUP_NAME} } @$records;

  @values  = sort { lc ($r{$a}) cmp lc ($r{$b}) } keys(%r);

  $groups_list = sprintf "%s", $query->scrolling_list(-name=>'groups',
                                                           -values=>\@values,
                                                           -size=>10,
                                                           -multiple=>1,
                                                           -default=>\@selectedGroups,
                                                           -labels=>\%r);

  #--- Build the expire date select objects

  @values            = sort numerically keys %month;
  $expireMonthSelect = sprintf "%s", $query->popup_menu(-name=>'expireMonth',
                                                              -values=>\@values,
                                                              -default=>$expireMonth,
                                                              -labels=>\%month);
  @values          = sort numerically keys %day;
  $expireDaySelect = sprintf "%s", $query->popup_menu(-name=>'expireDay',
                                                            -values=>\@values,
                                                            -default=>$expireDay,
                                                            -labels=>\%day);
  @values           = sort numerically keys %year;
  $expireYearSelect = sprintf "%s", $query->popup_menu(-name=>'expireYear',
                                                             -values=>\@values,
                                                             -default=>$expireYear,
                                                             -labels=>\%year);

  @values           = sort numerically keys %hour;
  $expireHourSelect = sprintf "%s", $query->popup_menu(-name=>'expireHour',
                                                             -values=>\@values,
                                                             -default=>$expireHour,
                                                             -labels=>\%hour);

  @values           = sort numerically keys %min;
  $expireMinSelect = sprintf "%s", $query->popup_menu(-name=>'expireMin',
                                                             -values=>\@values,
                                                             -default=>$expireMin,
                                                             -labels=>\%min);

  #@values           = sort numerically keys %sec;
  #$expireSecSelect = sprintf "%s", $query->popup_menu(-name=>'expireSec',
        #                                                     -values=>\@values,
        #                                                     -default=>$expireSec,
        #                                                     -labels=>\%sec);

  #--- Build the start date select objects

  @values            = sort numerically keys %month;
  $startMonthSelect = sprintf "%s", $query->popup_menu(-name=>'startMonth',
                                                              -values=>\@values,
                                                              -default=>$startMonth,
                                                              -labels=>\%month);
  @values          = sort numerically keys %day;
  $startDaySelect = sprintf "%s", $query->popup_menu(-name=>'startDay',
                                                            -values=>\@values,
                                                            -default=>$startDay,
                                                            -labels=>\%day);
  @values           = sort numerically keys %year;
  $startYearSelect = sprintf "%s", $query->popup_menu(-name=>'startYear',
                                                             -values=>\@values,
                                                             -default=>$startYear,
                                                             -labels=>\%year);

  @values           = sort numerically keys %hour;
  $startHourSelect = sprintf "%s", $query->popup_menu(-name=>'startHour',
                                                             -values=>\@values,
                                                             -default=>$startHour,
                                                             -labels=>\%hour);

  @values           = sort numerically keys %min;
  $startMinSelect = sprintf "%s", $query->popup_menu(-name=>'startMin',
                                                             -values=>\@values,
                                                             -default=>$startMin,
                                                             -labels=>\%min);

  #@values           = sort numerically keys %sec;
  #$startSecSelect = sprintf "%s", $query->popup_menu(-name=>'startSec',
        #                                                     -values=>\@values,
        #                                                     -default=>$startSec,
        #                                                     -labels=>\%sec);


  #--- Pull in the HTML form template
  $template = '';
  open (TL, "< ../templates/redir_form.html") or die "Can't open file redir_form.html: $!\n";
  while (<TL>) { $template .= $_ }
  close TL;


  #--- Make HTML object substitutions
  $template =~ s/&&cid/$custID/g;
  $template =~ s/&&redirid/$redirid/g;
  $template =~ s/&&customer/$customer/g;
  $template =~ s/&&formType/Create/   if ($g_func == 1);
  $template =~ s/&&formType/Modify/   if ($g_func == 3);
  $template =~ s/&&reason/$reason/;
  $template =~ s/&&description/$description/;
  $template =~ s/&&emails/$emails/;
  $template =~ s/&&optypes/$op_list/;
  $template =~ s/&&caseins/CHECKED/   if ( $caseins);
  $template =~ s/&&caseins//          if (!$caseins);
  $template =~ s/&&expireMonth/$expireMonthSelect/;
  $template =~ s/&&expireDay/$expireDaySelect/;
  $template =~ s/&&expireYear/$expireYearSelect/;
  $template =~ s/&&expireHour/$expireHourSelect/;
  $template =~ s/&&expireMin/$expireMinSelect/;
  $template =~ s/&&expireSec//;
  #$template =~ s/&&expireSec/$expireSecSelect/;
  $template =~ s/&&startMonth/$startMonthSelect/;
  $template =~ s/&&startDay/$startDaySelect/;
  $template =~ s/&&startYear/$startYearSelect/;
  $template =~ s/&&startHour/$startHourSelect/;
  $template =~ s/&&startMin/$startMinSelect/;
  $template =~ s/&&startSec//;
  #$template =~ s/&&startSec/$startSecSelect/;
  $template =~ s/&&methods/$methods_list/;
  $template =~ s/&&groups/$groups_list/;
  $template =~ s/&&contacts/$contacts_list/;
  $template =~ s/&&match_types/$match_types/;


  #--- Output final HTML
  print $template;

}
# end of sub createOrModifyForm
#----------------------------------------------------------------------------#

#############################
sub createOrUpdateRedirect {
#############################

  $contactID   = $query->param('contacts');
  $reason      = $query->param('reason');
  $description = $query->param('description');
  $optype      = $query->param('optype');
  $emails      = $query->param('emails');
  $expireMonth = $query->param('expireMonth');
  $expireDay   = $query->param('expireDay');
  $expireYear  = $query->param('expireYear');
  $expireHour  = $query->param('expireHour');
  $expireMin   = $query->param('expireMin');
  #$expireSec   = $query->param('expireSec');
  $startMonth = $query->param('startMonth');
  $startDay   = $query->param('startDay');
  $startYear  = $query->param('startYear');
  $startHour  = $query->param('startHour');
  $startMin   = $query->param('startMin');
  #$startSec   = $query->param('startSec');
  @groups      = $query->param('groups');
  @methods     = $query->param('methods');

  #--- Handle special case for 'cancel'
  if ($optype == 5 && $redirid) {
    &delete_redirect_data($redirid);
    &ndb->delete_redirect(RECID => $redirid);
    $ndb->commit();
    $template = '';
    open (TL, "< ../templates/redir_status.html") or die "Can't open file redir_status.html: $!\n";
    while (<TL>) { $template .= $_ }
    close TL;
    $template =~ s/&&status/\<B\>Redirect $redirid has been deleted\<\/B\>/g;
    $template =~ s/&&cid/$custID/g;
    print  $template;
    exit;
  }


  #--- Check form input params
  my $param_error;
  $param_error .= "Redirect type not selected<BR>\n"                if (!$optype);
  $param_error .= "Expire month not selected<BR>\n"                 if ($expireMonth  == 0);
  $param_error .= "Expire day not selected<BR>\n"                   if ($expireDay    == 0);
  $param_error .= "Expire year not selected<BR>\n"                  if ($expireYear   == 0);
  $param_error .= "Expire hour not selected<BR>\n"                  if ($expireHour   eq '--');
  $param_error .= "Expire min not selected<BR>\n"                   if ($expireMin    eq '--');
  #$param_error .= "Expire sec not selected<BR>\n"                if ($expireSec    == 0);
  $param_error .= "Only a maximum of 5 contact groups allowed\n"    if (scalar @groups  > 5);
  $param_error .= "Start month not selected<BR>\n"                 if ($startMonth  == 0);
  $param_error .= "Start day not selected<BR>\n"                   if ($startDay    == 0);
  $param_error .= "Start year not selected<BR>\n"                  if ($startYear   == 0);
  $param_error .= "Start hour not selected<BR>\n"                  if ($startHour   eq '--');
  $param_error .= "Start min not selected<BR>\n"                   if ($startMin    eq '--');
  #$param_error .= "Start sec not selected<BR>\n"                if ($startSec    == 0);
  $param_error .= "Only a maximum of 5 contact methods allowed\n"   if (scalar @methods  > 5);

  $param_error .= "At least one destination must be selected\n"  
      if (scalar @groups == 0 && scalar @methods == 0 
          && !$emails && ($optype eq 'METOO' || $optype eq 'REDIR'));

  if ($param_error) {
    $param_error = "<B>Error(s) occurred in form:</B><BR>\n" . $param_error;
    print $param_error;
        exit;
  }


  #--- Construct proper expire date
  my $string=sprintf ("%02d/%02d/%04d %02d:%02d:%02d GMT", $expireDay, $expireMonth, $expireYear, $expireHour, $expireMin, $expireSec);
  $expire     = $ndb->string_to_timestamp($string);
  print STDERR "expire is $expire\n";
  $string=sprintf ("%02d/%02d/%04d %02d:%02d:%02d GMT", $startDay, $startMonth, $startYear, $startHour, $startMin, $startSec);
  $start_date = $ndb->string_to_timestamp($string);
  print STDERR "start date is $start_date\n";


  #--- Save the data
  &putRedirValues;


  #--- Print a success message
  &showSummary;

}
# end of sub createOrUpdateRedirect 
#----------------------------------------------------------------------------#

#########################
sub validDataSelectForm {
#########################

  my $NUM_COLUMNS = 4;

  my $custID      = $query->param('cid');
  my $paramName   = $query->param('pn');
  my $fieldName   = $query->param('fn');
  my $value       = $query->param('v');
  my $submit      = $query->param('it');
  my $fieldValue  = $query->param('fv');

  my $name        ='redirmgr.cgi';
  my $submit_label='Use this one!';

  my $cust_val=$custID ? $custID : 1;

  print <<EOHTML;

  <form name="my_form" method="post" action="$name">

  <input type="hidden" name="cid" value="$custID">
  <input type="hidden" name="fn" value="$fieldName">
  <input type="hidden" name="f" value="5">
  <input type="hidden" name="pn" value="$paramName">
  <input type="hidden" name="fv" value="$fieldValue">
  
  <script language="javascript">

    function serviceClicked() {
      document.my_form.pn.value="HOST_ID";
    }

    function populateValue() {
      win=self.opener;
      win.$fieldName.value="$value";
      self.close();
    }

  </script>
EOHTML

  my $r;  
  my $label;

  if ($submit eq $submit_label) {
    print <<EOS;
    <script language="Javascript">
      populateValue();
    </script>
EOS
  }
  else {
  if ($paramName eq 'PROBE_TYPE')  {

    $label = 'Probe Type';

    my %hash = ( 'check'      => 'Check Probe',
                 'suite'      => 'Check Suite Probe',
                 'host'       => 'Host Probe',
                 'satcluster' => 'Satellite Cluster Probe',
                 'satnode'    => 'Satellite Node Probe',
                 'url'        => 'URL Probe' );
    $r = \%hash;
  }
  elsif ($paramName eq 'HOST_STATE') {

    $label = 'Host State';

    my %hash = (      'UP'      => 'UP',
                      'DOWN'    => 'DOWN',
                      'UNKNOWN' => 'UNKNOWN');
    $r = \%hash;
  }
  elsif ($paramName eq 'SERVICE_STATE') {

    $label = 'Service State';

    my %hash = (      'WARNING'     => 'WARNING',
                      'OK'          => 'OK',
                      'CRITICAL'    => 'CRITICAL',
                      'UNKNOWN'     => 'UNKNOWN');
    $r = \%hash;
  }
  elsif ($paramName eq 'PROBE_ID') {

    # set up in case we need to pick a host probe id

    $label = 'Host Id';

    my $records = $ndb->select_host_probes_by_customer_id($cust_val);
    my %r=map { $_->{RECID} => $_->{HOST_NAME} } @$records;
    $r = \%r;
  }
  elsif ($paramName eq 'HOST_ID') {

    # we need to pick a service probe id

    $label = 'Service Id';

    my $records = $ndb->select_service_probes_by_host_probe_id($value);
    my %r=map { $_->{RECID} => $_->{DESCRIPTION} } @$records;
    $r = \%r;
}

  elsif ($paramName eq 'NETSAINT_ID') {

    $label = 'Satellite Id';

    my $records = $ndb->select_sat_clusters_by_customer_id($cust_val);
    my %r=map { $_->{RECID} => $_->{DESCRIPTION} } @$records;
    $r = \%r;
  }
  elsif ($paramName eq 'CONTACT_METHOD_ID') {

    $label = 'Contact Method Id';

    my $records= $ndb->select_contact_methods_by_customer_id($cust_val);
    my %r = map { $_->{RECID} => $_->{METHOD_NAME} } @$records;
    $r = \%r;
  }
  elsif ($paramName eq 'CONTACT_GROUP_ID') {

    $label = 'Contact Group Id';

    my $records= $ndb->select_contact_groups('CUSTOMER_ID' => $cust_val);
    my %r = map { $_->{RECID} => $_->{CONTACT_GROUP_NAME} } @$records;
    $r = \%r;
  }
  else {
    print <<EOS;
    <script language="javascript">
      self.close();
      self.opener.alert ("Sorry, no help available for $paramName");
    </script>
EOS
  }
  print <<EOHTML;
    <table borders="0" cellspacing="0" cellpadding="0" cols="$NUM_COLUMNS" width="90%">
      <tr><td colspan="$NUM_COLUMNS">$g_blackVerdana3<b>Choose a $label:</b></font></td></tr>
EOHTML

  my @values = sort {lc ($r->{$a}) cmp lc ($r->{$b}) } keys(%$r);

  #make it pretty!

  my $size   = scalar(@values);
  if ($size < ($NUM_COLUMNS * 2 - 1)) {$NUM_COLUMNS = 1};

  my $num_rows = int($size / $NUM_COLUMNS);
  $num_rows++ if ($size % $NUM_COLUMNS) > 0;

  my ($row, $column);

  for ($row=0; $row < $num_rows; $row++) { 
    print "<tr>\n";
    for ($column=0; $column < $NUM_COLUMNS; $column++) {

      my $indx = $row + ($column * $num_rows);
      last if $indx >= $size;

      my $key  = $values[$indx];
      my $value=$r->{$key};

      print  "<td> $g_blackVerdana1 <input type=\"radio\" name=\"v\" value=\"$key\"";
      if ($fieldValue eq $key) {
        print " CHECKED"
      }
      print ">$value ($key) </font> </td>\n";
    }
    print "</tr>\n";
  }

  print <<EOHTML;
  </table>
  <table>
      <tr>
        <td>
          <input type="submit" name="it" value="$submit_label">
        </td>
        <td>
          <input type="button" value="Never Mind!" onClick="self.close()">
        </td>
EOHTML

  if ($paramName eq 'PROBE_ID') {
    print <<EOHTML;
        <td colspan="2">
          <input type="submit" name="it" value="Let's pick a service id for this host!"  
          onClick="serviceClicked()">
        </td>
EOHTML
  }

  print <<EOHTML;
      </tr>
    </table>
EOHTML
}
  print <<EOHTML;
  </form>
EOHTML
}
# end of sub validDataSelectForm 
#----------------------------------------------------------------------------#

##########################
sub delete_redirect_data {
##########################
  my $rid = shift();
#$  $ndb->create_archive_master( CUSTOMER_ID => 1, 
#                               ACTIVITY_CODE => 'DEL', 
#                               TABLE_NAME => 'redirect_email_targets', 
#                               KEY_COL_1 => 'redirect_id' );
  $ndb->delete_redirect_email_targets( REDIRECT_ID => $rid );
#$  $ndb->delete_archive_master( CUSTOMER_ID => 1, 
#                               ACTIVITY_CODE => 'DEL', 
#                               TABLE_NAME => 'redirect_email_targets', 
#                               KEY_COL_1 => 'redirect_id' );
#$  $ndb->create_archive_master( CUSTOMER_ID => 1, 
#                               ACTIVITY_CODE => 'DEL', 
#                               TABLE_NAME => 'redirect_method_targets', 
#                               KEY_COL_1 => 'redirect_id' );
  $ndb->delete_redirect_method_targets( REDIRECT_ID => $rid );
#$  $ndb->delete_archive_master( CUSTOMER_ID => 1, 
#                               ACTIVITY_CODE => 'DEL', 
#                               TABLE_NAME => 'redirect_method_targets', 
#                               KEY_COL_1 => 'redirect_id' );
#$  $ndb->create_archive_master( CUSTOMER_ID => 1, 
#                               ACTIVITY_CODE => 'DEL', 
#                               TABLE_NAME => 'redirect_group_targets', 
#                              KEY_COL_1 => 'redirect_id' );
  $ndb->delete_redirect_group_targets( REDIRECT_ID => $rid );
#$  $ndb->delete_archive_master( CUSTOMER_ID => 1, 
#                               ACTIVITY_CODE => 'DEL', 
#                               TABLE_NAME => 'redirect_group_targets', 
#                               KEY_COL_1 => 'redirect_id' );
#$  $ndb->create_archive_master( CUSTOMER_ID => 1, 
#                               ACTIVITY_CODE => 'DEL', 
#                               TABLE_NAME => 'redirect_criteria', 
#                               KEY_COL_1 => 'redirect_id' );
  $ndb->delete_redirect_criteria( REDIRECT_ID => $rid );
#$  $ndb->delete_archive_master( CUSTOMER_ID => 1, 
#                               ACTIVITY_CODE => 'DEL', 
#                               TABLE_NAME => 'redirect_criteria', 
#                               KEY_COL_1 => 'redirect_id' );
}
