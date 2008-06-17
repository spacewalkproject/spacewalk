#!/usr/bin/perl

use strict;

use CGI;
use NOCpulse::Config;
use NOCpulse::SCDB::Accessor;
use NOCpulse::TSDB::Accessor;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use URI::Escape;


sub insert_sc_db
{
    my $scdba = shift;
    my $query = shift;
    
    my $oid   = $query->param('oid');
    my $t     = $query->param('t');
    my $state = $query->param('state');
    my $desc  = substr($query->param('desc'),0,4000);

    my $rc = $scdba->insert('t' => $t,
                            'state' => $state,
                            'oid' => $oid,
                            'desc' => $desc);
    
    if( not $rc )
    {
        die "error inserting into scdb";
    }
    
}


sub insert_ts_db
{
    my $tsdba = shift;
    my $query = shift;

    my $rc;

    my $data  = $query->param('data');

    if (defined($data)) {

      # New-style insert -- batch upload
      my(@data, $line);
      foreach $line (split(/\n/, $data)) {
        push(@data, [split(/\s+/, $line)]);
      }
    
      $rc = $tsdba->batch_insert(data => \@data);

    } else {
      
      # Old-style insert -- single datapoint
      my $fn    = $query->param('fn');
      my $oid   = uri_unescape($query->param('oid'));
      my $t     = $query->param('t');
      my $value = $query->param('v');
      $rc = $tsdba->insert('t' => $t, 'v' => $value, 'oid' => $oid);
      $rc = 0;
    }

    if ( not $rc )
    {
        die "error inserting into tsdb";
    }

}


############################################
# main
############################################

my $query = new CGI;
my $q = $query->param('queuename');

eval
{
    my $cfg = new NOCpulse::Config;
    
    $query->delete('queuename');
    
    if( $q eq 'sc_db' )
    {
        my $scdb_url = $cfg->get('sc_db', 'url');
        my $scdba = NOCpulse::SCDB::Accessor->new(url => $scdb_url, verbose => 0);
        insert_sc_db($scdba, $query);
    }
    elsif( $q eq 'ts_db' )
    {
        my $tsdb_url = $cfg->get('ts_db', 'url');
        my $tsdba = NOCpulse::TSDB::Accessor->new(url => $tsdb_url, verbose => 0);
        insert_ts_db($tsdba, $query);
    }
    elsif( $q eq 'notif' or $q eq 'commands')
    {
        my $url;
        if ($q eq 'commands')
        {
            $url = $cfg->get('CommandQueue', 'url');
        } else 
        {
            $url = $cfg->get($q, 'url');
        }

        my $params = $query->query_string();
        my $ua = LWP::UserAgent->new;
        my $request = HTTP::Request->new('POST', $url);
        $request->content_type('application/x-www-form-urlencoded');
        $request->content($params);
        
        my $response = $ua->request($request);
        my $code     = $response->code;
        my $message  = $response->message;

        if ( not $response->is_success )
        {
            die "$q error: $code $message\n", $response->content;
        }
        print $query->header( -status => "$code $message");
        $response->content;
        
    }
    else
    {
        die "unknown queue: $q";
    }
};

my $error = $@;

if( $error )
{
    print STDERR "eventHandler error: $error querystring = ".$query->query_string()."\n";
    print $query->header( -status => "500 $error");
    print "<html><body><h2>500 $error</h2></body></html>\n";
}
else
{
    print $query->header();
    print "OK";
}
