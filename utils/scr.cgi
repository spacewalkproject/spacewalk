#!/usr/bin/perl

###########################################################################
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Copyright 2009  Colin Coe <colin.coe@gmail.com>
#
# Portions of code reused from the Satellite/Spacewalk documentation,
# various sources on the Internet and from code produced by Murray Barton.
#
# for more description see
# https://www.redhat.com/archives/spacewalk-devel/2009-December/msg00010.html
#
###########################################################################

use strict;
use warnings;
use CGI;
use Data::Dumper;
use Frontier::Client;
use POSIX 'strftime';
use Switch;

$|=1;

my $cgi = new CGI;
my ($sat_host, $sat_user, $sat_passwd) = ('127.0.0.1', 'admin', 'password');

# i.e. 7 critical errata will cause the critical errata column to be yellow
my %Thresholds = (
	'red_crit' => 10,
	'yel_crit' => 5,
	'red_imp'  => 15,
	'yel_imp'  => 7,
	'red_mod'  => 20,
	'yel_mod'  => 10,
	'red_low'  => 25,
	'yel_low'  => 12,
	'red_bug'  => 20,
	'yel_bug'  => 10,
);

# These are the multiplier values
my %Formula = (
	'crit' => 20,
	'imp'  => 15,
	'mod'  => 10,
	'low'  => 5,
	'bug'  => 3,
	'enh'  => 1,
);

my %Errata;

# These are the counters for the errata types
my (%cc, %ic, %mc, %lc, %bc, %ec);

# Start html...
my $onclick = <<'end_java_script';
function are_you_sure (message) {
    return confirm( message );
}

end_java_script

print $cgi->header();
print $cgi->start_html(
    -title   => 'System Currency Report',
    -fgcolor => "#000000",
    -bgcolor => "#FFFFFF",
    -script  => $onclick,
);

my ($count, $data) = (0, "");
my $return = processForm();
if ($return) {
	printForm();
	print $data;
        print "<p>$count hosts examined</p>\n";
}
print $cgi->end_html(), "\n";

exit;

sub printForm {

    $cgi->delete('_host_name');  # clear the old stuff
    my %colours = ( 0 => "#FFFFF2", 1 => "#EEFFFA", );

    print $cgi->start_form();
    print $cgi->b("<font color=\"blue\" size=\"+2\">System Currency Report</font>"),
          $cgi->table( { border => 0 },
              $cgi->Tr(
                  $cgi->td("Host regexp: "),
                  $cgi->td(
                      $cgi->textfield(
                          -name      => '_host_name',
                          -size      => 16,
                          -maxlength => 16,
                      ),
                  ),
                  $cgi->td("(empty for all hosts)"),
                  $cgi->td($cgi->submit( -name => '_do_search', -value => 'Search' ),
                  ),

              ),
          ),
          $cgi->end_table();
    print <<__END_OF_HTML;
<hr>
<h2>Notes</h2>
<h3>Formula</h3>
<table border=1>
    <tr>
        <th>Security (Critical)</th>
        <td>Count * $Formula{'crit'}</td>
    </tr>
    <tr>
        <th>Security (Important)</th>
        <td>Count * $Formula{'imp'}</td>
    </tr>
    <tr>
        <th>Security (Moderate)</th>
        <td>Count * $Formula{'mod'}</td>
    </tr>
    <tr>
        <th>Security (Low)</th>
        <td>Count * $Formula{'low'}</td>
    </tr>
    <tr>
        <th>Bug</th>
        <td>Count * $Formula{'bug'}</td>
    </tr>
    <tr>
        <th>Enhancement
        <td>Count * $Formula{'enh'}</td>
    </tr>
</table>
<h3>Thresholds</h3>
<table border=1>
    <tr>
        <th></th>
        <th bgcolor=\"red\">Red</th>
        <th bgcolor=\"yellow\">Yellow</th>
    </tr>
    <tr>
        <th>Security (Critical)</th>
        <td>greater than $Thresholds{'red_crit'}</td>
        <td>greater than $Thresholds{'yel_crit'}</td>
    </tr>
    <tr>
        <th>Security (Important)</th>
        <td>greater than $Thresholds{'red_imp'}</td>
        <td>greater than $Thresholds{'yel_imp'}</td>
    </tr>
    <tr>
        <th>Security (Moderate)</th>
        <td>greater than $Thresholds{'red_mod'}</td>
        <td>greater than $Thresholds{'yel_mod'}</td>
    </tr>
    <tr>
        <th>Security (Low)</th>
        <td>greater than $Thresholds{'red_low'}</td>
        <td>greater than $Thresholds{'yel_low'}</td>
    </tr>
    <tr>
        <th>Bug</th>
        <td>greater than $Thresholds{'red_bug'}</td>
        <td>greater than $Thresholds{'yel_bug'}</td>
    </tr>
</table>
<ul>
</ul>
__END_OF_HTML


    # Finish the html form.
    print $cgi->end_form();

    return 0;
}

sub processForm {
    readData($cgi->param('_host_name')) if ($cgi->param('_do_search') eq 'Search');

    return 1;
}

# Get the data from the Satellite/Spacewalk server and return it in a CSV list
sub getData($) {
   my $search = shift;
   my $client = new Frontier::Client(url => "http://$sat_host/rpc/api", debug => 0);
   my $session = $client->call('auth.login', $sat_user, $sat_passwd);

   my (%Systems, @out, $line);

   my $systems = $client->call('system.listUserSystems', $session);
   for my $sys (sort { $a->{'name'} cmp $b->{'name'} } @$systems) {
      next unless $sys->{'name'} =~ m/$search/;
      my $errata  = $client->call('system.getRelevantErrata', $session, $sys->{'id'});
      my $details = $client->call('system.getSubscribedBaseChannel', $session, $sys->{'id'});
      $line = "$sys->{'id'}|$sys->{'name'}|$details->{'name'}|";
      if (scalar @$errata) {
         for my $err (@$errata) {
            $line .= ",$err->{'advisory_name'}|$err->{'advisory_synopsis'}|"
         }
      }
      push @out, $line;
   }

   # Lets play nicely and logout when we're finished
   $client->call('auth.logout', $session);
   return @out;
}

# Process the data returned from getData and produce/return HTML code
sub readData() {
    my $search = shift;
    my @in = getData($search);
    $data = "
<hr>
<p>
<table border=1>
<tr>
<th>Hosts</th>
<th>Base Channel</th>
<th>Security<br>(Critical)</th>
<th>Security<br>(Important)</th>
<th>Security<br>(Moderate)</th>
<th>Security<br>(Low)</th>
<th>Bug Fix</th>
<th>Enhancement</th>
<th>Overall<br>Score</th>";

    for my $line (@in) {
        $count++;
        my $colour = 'white';
        my ($host, $errata) = (split(',', $line, 2));
        my $hostname = (split(/\|/, $host))[1];
        my @details      = (split(/\|/, $host));
        my %colour = ('crit' => 'white', 'imp' => 'white', 'mod' => 'white', 'low' => 'white', 'bug' => 'white' );
        $cc{$hostname} = 0;
        $ic{$hostname} = 0;
        $mc{$hostname} = 0;
        $lc{$hostname} = 0;
        $bc{$hostname} = 0;
        $ec{$hostname} = 0;
        for my $err ($errata) {
            for my $e (split(/,/, $err)) {
                $Errata{(split(/\|/, $e))[0]} = (split(/\|/, $e))[1];
                switch (substr($e,0,4)) {
                    case('RHSA') {
                        switch (substr((split(/\|/, $e))[1],0,3)) {
                            case('Cri') { $cc{$hostname}++; }
                            case('Imp') { $ic{$hostname}++; }
                            case('Mod') { $mc{$hostname}++; }
                            case('Low') { $lc{$hostname}++; }
                        }
                    }
                    case('RHBA') { $bc{$hostname}++; }
                    case('RHEA') { $ec{$hostname}++; }
                }
            }
        }
        $data .= "<tr>";
        $data .= $cgi->td($hostname);
        $data .= $cgi->td({-bgcolor=>$colour},(split(/\|/, $host))[2]);

        $colour{'crit'} = 'yellow' if ($cc{$hostname} >= $Thresholds{'yel_crit'});
        $colour{'crit'} = 'red'    if ($cc{$hostname} >= $Thresholds{'red_crit'});
        $data .= $cgi->td({-bgcolor=>$colour{'crit'}},$cc{$hostname});

        $colour{'imp'} = 'yellow' if ($ic{$hostname} >= $Thresholds{'yel_imp'});
        $colour{'imp'} = 'red'    if ($ic{$hostname} >= $Thresholds{'red_imp'});
        $data .= $cgi->td({-bgcolor=>$colour{'imp'}},$ic{$hostname});

        $colour{'mod'} = 'yellow' if ($mc{$hostname} >= $Thresholds{'yel_mod'});
        $colour{'mod'} = 'red'    if ($mc{$hostname} >= $Thresholds{'red_mod'});
        $data .= $cgi->td({-bgcolor=>$colour{'mod'}},$mc{$hostname});

        $colour{'low'} = 'yellow' if ($lc{$hostname} >= $Thresholds{'yel_low'});
        $colour{'low'} = 'red'    if ($lc{$hostname} >= $Thresholds{'red_low'});
        $data .= $cgi->td({-bgcolor=>$colour{'low'}},$lc{$hostname});

        $colour{'bug'} = 'yellow' if ($bc{$hostname} >= $Thresholds{'yel_bug'});
        $colour{'bug'} = 'red'    if ($bc{$hostname} >= $Thresholds{'red_bug'});
        $data .= $cgi->td({-bgcolor=>$colour{'bug'}},$bc{$hostname});

        $data .= $cgi->td($ec{$hostname});
        $data .= $cgi->td($cc{$hostname} * $Formula{'crit'} + $ic{$hostname} * $Formula{'imp'} + $mc{$hostname} * $Formula{'mod'} + $lc{$hostname} * $Formula{'low'} + $bc{$hostname} * $Formula{'bug'} + $ec{$hostname} * $Formula{'enh'});
        $data .= "</tr>";
    }
    $data .= $cgi->end_table();
}

__END__
