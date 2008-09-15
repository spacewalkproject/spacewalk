package NOCpulse::EventHandler;

use strict;
use Apache2::Request ();
use Apache2::RequestIO ();
use NOCpulse::Config;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use URI::Escape;
use Apache2::Log ();
use vars qw($timeout %KeyToId);

$timeout = 4; 
%KeyToId;  # This persists globally in apache and as such is a cache. In this case there's 
	# a (I think) small chance of a reentrancy race. see bug #133581 for details

sub do_scdb
{
    my $cfg = shift;
    my $param = shift;
    my $r = shift;

    my $scdb_url = $cfg->get('sc_db', 'url');

    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new('POST', $scdb_url);

    my $oid   = $param->{'oid'};
    my $t     = $param->{'t'};
    my $state = $param->{'state'};

    my $desc  = $param->{'desc'};
    $desc =~ s/[^-_a-zA-Z0-9]/"%" . sprintf("%02X",ord($&))/ge;

    my $content = "version=" . $param->{'version'};
    $content .= "&fn=insert&oid=".$oid. "&t=".$t."&state=".$state."&desc=".$desc;

    $request->content($content);

    my $response = $ua->request($request);
    if ($response->is_success)
    {
	$r->print($response->content);
	return 0;
    }
    else
    {
        report_error($r, "sc_db", $scdb_url, $response);
	return 500;
    }
}

sub do_tsdb
{
    my $cfg = shift;
    my $param = shift;
    my $r = shift;

    my $tsdb_url = $cfg->get('ts_db', 'url');

    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new('POST', $tsdb_url);

    my $content = '';
    if ($r->method() eq 'POST') {
        while ($r->read(my $b, 1024)) {
            $content .= $b;
        }
    } else {
        $content = $r->args();
    }


    if (defined($param->{'data'})) {
	# New-style insert -- batch upload
	$request->content($content);
	my $response = $ua->request($request);
	if ($response->is_success) {
	    $r->print($response->content);
	    return 0;
	} else {
            report_error($r, "ts_db", $tsdb_url, $response);
	    return 500;
	}
    } else {
	# Old-style insert -- single datapoint
	my $fn    = $param->{'fn'};
	my $oid   = uri_unescape($param->{'oid'});
	my $t     = $param->{'t'};
	my $value = $param->{'v'};
	
        $content .= "fn=insert&oid=".$oid. "&t=".$t."&v=".$value;
	
	$request->content($content);
	
	my $response = $ua->request($request);
	
	if ($response->is_success) {
	    $r->print($response->content);
	    return 0;
	} else {
            report_error($r, "ts_db", $tsdb_url, $response);
	    return 500;
	}
    }
}

sub do_default
{
    my $cfg = shift;
    my $param = shift;
    my $r = shift;
    my $q = shift;

    my $url;
    if ($q eq 'commands') {
	$url = $cfg->get('CommandQueue', 'url');
    } else {
	$url = $cfg->get($q, 'url');
    }

    my $params = '';
    if ($r->method() eq 'POST') {
        while ($r->read(my $b, 1024)) {
            $params .= $b;
        }
    } else {
        $params = $r->args();
    }

    for my $p ( 'clusterId', 'satcluster' ) {
        if (defined $param->{$p}) {
            $params =~ s!(^|&)$p=.*?($|&)!$1$p=$param->{$p}$2!;
        }
    }

    my $ua = LWP::UserAgent->new;
    my $request = HTTP::Request->new('POST', $url);
    $request->content_type('application/x-www-form-urlencoded');
    $request->content($params);

    my $response = $ua->request($request);

    if (not $response->is_success) {
        report_error($r, $q, $url, $response);
	return 500;
    } else {
	$r->print($response->content);
	return $response->code;
    }
}

sub report_error
{
    my ($r, $queue_name, $url, $response) = @_;

    my $msg = "$queue_name: Cannot POST to $url: " .
      $response->status_line . "\n" . $response->content();
    $r->log_error($msg);
    $r->print($msg);
}

sub clusterIdFromKey
{
	my $key = shift();
	if (exists($KeyToId{$key})) {
		return $KeyToId{$key}
	} else {
		my $ua = LWP::UserAgent->new;
		$ua->agent("SatIDXL8r/1.0 ");
		my $req = HTTP::Request->new(GET => "http://localhost/cgi-bin/translate_key.cgi?scout_shared_key=$key");
		$req->content_type('application/x-www-form-urlencoded');
	
		# alarm around this else apache can hang
		my $res;
		eval {
			local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
			alarm $timeout;
			$res = $ua->request($req);
			alarm 0;
		};
		
		if ($res->is_success) {
			my $id = $res->content;
			chomp($id);
			$KeyToId{$key} = $id;
			return $id;
		} else {
			return "NULL";
		}
	}
}



sub handler
{
    my $r = shift;

    my $query = new Apache2::Request($r);
    my %param = %{ $query->param() };
    my $q = $param{'queuename'};

    #check to see which param we need to translate
    if ($param{'clusterId'}) {
	#this is from the notif system
	$param{'clusterId'} = clusterIdFromKey($param{'clusterId'});
    }
	
    if ($query->param('satcluster')) {
	# Rewrite satcluster from shared key to actual from all others
	$param{'satcluster'} = clusterIdFromKey($param{'satcluster'});
    }

    my $cfg = new NOCpulse::Config;

    delete $param{'queuename'};

    $r->content_type('text/html');

    if( $q eq 'sc_db' )
    {
	return do_scdb($cfg, \%param, $r);
    }
    elsif( $q eq 'ts_db' )
    {
	return do_tsdb($cfg, \%param, $r);
    }
    elsif( $q eq 'notif' or $q eq 'commands')
    {
	return do_default($cfg, \%param, $r, $q);
    }
    else
    {
        $r->log_error("Unknown queue: $q\n");
        $r->print("Unknown queue: $q\n");
        return 500;
    }
}

1;
