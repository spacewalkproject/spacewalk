#!/usr/bin/perl

use strict;
use NOCpulse::Debug;
use NOCpulse::TelAlert;
use Getopt::Long;

$|=1;
select((select(STDERR), $|=1)[0]);

#
# Sample command to run this script:
# ./SQLtest.pl --debug=3 --CUSTOMER_ID=2 --delredir=446 | more
#


#- We need to rollback db changes when we die in case AutoCommit is set to 0.
#- If AutoCommit is set to 1, we cannot rollback db changes.
$SIG{__DIE__} = \&die;


#
# Pick up command line options
#
my @optspec = qw (debug:i CUSTOMER_ID:i delredir:i);
my %optctl;
&GetOptions(\%optctl, @optspec);
my $debugLevel  = $optctl{'debug'};        #- Debug level
my $CUSTOMER_ID = $optctl{'CUSTOMER_ID'};  #- ID of customer to create an alert for
my $delredir    = $optctl{'delredir'};     #- Recid ID of redirect to delete from database


#- Create debug object and a stream
my $debug   = new NOCpulse::Debug;
my $literal = $debug->addstream( CONTEXT => 'literal', LEVEL => $debugLevel );
$debug->dprint (1, "Created debug & stream objects\n");


#- Create our Telalert object
my $telalert = new NOCpulse::TelAlert;
$debug->dprint (1, "Connecting to DB\n");
$telalert->connect( PrintError => 0, RaiseError => 0, AutoCommit => 0 );


#- Let's try a telalert command
my $tacmd   = "-show";
my $results = $telalert->taexec($tacmd);
$debug->dprint (1, "Telalert command results:\n$results");


#- Write to TA trail log file
my $msg  = "$0 is Writing to trail file";
$results = $telalert->writetrail($msg);
$debug->dprint (1, "Wrote to Telalert trail file the message:\n     $msg\n");


#- Try to clear a ticket
my $ticket_id  = "12345";
$results = $telalert->clearticket($ticket_id);
$debug->dprint (1, "Attempted to clear Telalert ticket with ID $ticket_id\nResults:$results\n");


#- Show a list of available Telalert servers
my @telalertHosts = $telalert->getServers;
foreach (@telalertHosts) { $debug->dprint (1, "Telalert Server listed in DB: $_\n") }


#- Disconnect from the DB and reconnect
$debug->dprint (1, "Disconnecting from DB\n");
$telalert->disconnect;
$debug->dprint (1, "Reconnecting to DB\n");
$telalert->connect( {'PrintError'=>0, 'RaiseError'=>0, 'AutoCommit'=>0} );

#- Show the current list of pager types in DB
my %pagertypes = $telalert->getPagerTypes;
my @values     = sort { lc ($pagertypes{$a}) cmp lc ($pagertypes{$b}) } keys %pagertypes;
foreach (@values) { $debug->dprint (3, "Telalert Pager Type in DB: $pagertypes{$_}\n") }


#- Show the current list of alerts in DB
my @alerts = $telalert->getAlerts;
foreach (@alerts) {
    my $alertID    = $$_[0];
    my $ticket_id  = $$_[1];
    my $alertOwner = $$_[6];
    $debug->dprint (3, "Telalert Alert($alertID) Ticket $ticket_id is currently owned by host $alertOwner\n");
}


#- Show the details of alerts in DB
my $alertID       = 558;
my @details       = $telalert->getAlertValues($alertID);
my $customer      = $details[15];
my $submitted     = $details[0];
$debug->dprint (1, "Telalert Alert $alertID (submitted on $submitted) belongs to customer $customer\n");


#- Read the Telalert config file
my @configFile = $telalert->getTAConfig;
$debug->dprint (4, "Telalert Config File:\n", join '', @configFile, "\n");


#- Extract the Tetalert Host IP Address
my $ip = $telalert->getMyIP;
$debug->dprint (1, "My Tetalert Host IP Address=", $ip, "\n");
die "Can't determine IP address:$@\n" if (!$ip);


#- Determing the Telalert Server's recid in the "telalerts" DB table
my $server_recid = $telalert->getTelalertServerID;
die "Can't determine Telalert Server's recid:$@\n" if (!$server_recid);
$debug->dprint (1, "My Tetalert Server recid=", $server_recid, "\n");


#- Create a Telalert ticket
my $ticket_id = $telalert->newticketid($server_recid);
die "Can't create a new Telalert ticket id:$@\n" if (!$ticket_id);
$debug->dprint (1, "New Tetalert Alert Ticket ID=", $ticket_id, "\n");


#- Get the list of ALL Telalert destinations
my %dests = $telalert->getDests;
die "Can't get list of all Telalert destinations:$@\n" if (!%dests);
$debug->dprint (3, "List of all Telalert destinations:\n");
foreach (sort keys %dests) { $debug->dprint (3, "Details for destination name $_: $dests{$_}\n") }


#- Get a list of all redirects for a company (e.g., NOCpulse has CUSTOMER_ID=1)
my $row_ref;
my @redirs = $telalert->getRedirs($CUSTOMER_ID);
die "Can't get list of all redirects for customer id $CUSTOMER_ID:$@\n" if (!@redirs);
foreach $row_ref (@redirs) {
    my @redirect = @$row_ref;
    my $redirid  = shift @redirect;
    $debug->dprint (3, "Details for redirect ID $redirid: @redirect\n");
}


#- Get details for an individual redirect
my $redirid = 421;
my ($hostpat, $svcpat, $msgpat, $caseins, $optype, $emails, $expire, $expireseconds, $customer) =
    $telalert->getRedirValues($redirid);
my @details = ($hostpat, $svcpat, $msgpat, $caseins, $optype, $emails, $expire, $expireseconds, $customer);
die "Can't get details for redirect id $redirid:$@\n" if (!$expire);
$debug->dprint (3, "Details for individual redirect ID $redirid: @details\n");


#- Get list of selected destinations for an individual redirect
my @selected_dests = $telalert->getSelectedDests($CUSTOMER_ID, $redirid);
die "Can't get list of selected destinations for individual redirect $redirid:$@\n" if (!@selected_dests);
$debug->dprint (3, "Selected destinations for individual redirect ID $redirid: @selected_dests\n");


#- Time to save a new alert into the "current_alerts" DB table
#- Order of expected values:
$debug->dprint (1, "About to save a new alert with ticket $ticket_id\n");
$telalert->putStates($server_recid,
                     $server_recid,
                     "-i 1_fpaturzo_phone -ticket $ticket_id -ticketmask xxssssssssssssssssssssss",
                     "This is the message to be sent at UNIX time $^T",
                     $ticket_id, 'fpaturzo_phone',
                     0,
                     10,
                     'UP',
                     1000,
                     'WARNING',
                     $CUSTOMER_ID);

die "Can't save alert for ticket id $ticket_id:$@\n" if ($@);
$debug->dprint (1, "Saved a new alert with ticket $ticket_id\n");


#- Delete a redir?
if ($delredir) {
    $telalert->deleteRedir($delredir);
    $debug->dprint (1, "Deleting redirect $delredir\n");

    # Now show the new list of redirects
    my $row_ref;
    my @redirs = $telalert->getRedirs($CUSTOMER_ID);
    die "Can't get list of all redirects for customer id $CUSTOMER_ID:$@\n" if (!@redirs);
    $debug->dprint (1, "Updated list of redirects for CUSTOMER_ID $CUSTOMER_ID:\n");
    foreach $row_ref (@redirs) {
        my @redirect = @$row_ref;
        my $redirid  = shift @redirect;
        $debug->dprint (3, "Details for redirect ID $redirid: @redirect\n");
    }
}


#- Commit all changes
$telalert->{dbh}->commit;
$telalert->{dbh}->disconnect;


###################
sub die {

    my (@params) = @_;

    print "@_";
    if ($telalert->{dbh}) {
        $telalert->{dbh}->rollback;
        $telalert->{dbh}->disconnect;
    }

    exit 1;
}
