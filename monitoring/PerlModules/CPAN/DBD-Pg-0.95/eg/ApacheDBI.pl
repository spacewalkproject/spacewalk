#!/usr/local/bin/perl

# $Id: ApacheDBI.pl,v 1.1.1.1 2001-01-12 20:41:07 dparker Exp $

# don't forget to create in postgres the user who is running 
# the httpd, eg 'createuser nobody' !
#
# demo script, tested with:
#  - PostgreSQL-6.5.2
#  - apache_1.3.9
#  - mod_perl-1.21
#  - perl5.005_03
#  - DBI-1.13

use CGI;
use DBI;
use strict;

my $query = new CGI;

print  $query->header,
       $query->start_html(-title=>'A Simple Example'),
       $query->startform,
       "<CENTER><H3>Testing Module DBI</H3></CENTER>",
       "<P><CENTER><TABLE CELLPADDING=4 CELLSPACING=2 BORDER=1>",
       "<TR><TD>Enter the data source: </TD>",
           "<TD>", $query->textfield(-name=>'data_source', -size=>40, -default=>'dbi:Pg:dbname=template1'), "</TD>",
       "</TR>",
       "<TR><TD>Enter the user name: </TD>",
           "<TD>", $query->textfield(-name=>'username'), "</TD>",
       "</TR>",
       "<TR><TD>Enter the password: </TD>",
           "<TD>", $query->textfield(-name=>'auth'), "</TD>",
       "</TR>",
       "<TR><TD>Enter the select command: </TD>",
           "<TD>", $query->textfield(-name=>'cmd', -size=>40), "</TD>",
       "</TR>",
       "</TABLE></CENTER><P>",
       "<CENTER>", $query->submit(-value=>'Submit'), "</CENTER>",
       $query->endform;

if ($query->param) {

    my $data_source = $query->param('data_source');
    my $username    = $query->param('username');
    my $auth        = $query->param('auth');
    my $cmd         = $query->param('cmd');
    my $dbh         = DBI->connect($data_source, $username, $auth);
    if ($dbh) {
        my $sth = $dbh->prepare($cmd);
        my $ret = $sth->execute;
        if ($ret) {
            my($i, $ary_ref);
            print "<P><CENTER><TABLE CELLPADDING=4 CELLSPACING=2 BORDER=1>\n";
            while ($ary_ref = $sth->fetchrow_arrayref) {
                print "<TR><TD>", join("</TD><TD>", @$ary_ref), "</TD></TR>\n";
            }
            print "</TABLE></CENTER><P>\n";
            $sth->finish;
        } else {
            print "<CENTER><H2>", $DBI::errstr, "</H2></CENTER>\n";
        }
        $dbh->disconnect;
    } else {
        print "<CENTER><H2>", $DBI::errstr, "</H2></CENTER>\n";
    }
}

print $query->end_html;

