
package NOCpulse::SCDB;

use strict;
use CGI;
use Apache2::Const 'OK';
use Apache2::Log ();
use NOCpulse::Database;

# Keep in synch with MessageQueue/StateChangeQueue.pm
my $PROTOCOL_VERSION = '1.0';

##########################################
# CGI "fn" code table
##########################################

my $code_table = {};

$code_table->{'insert'} =
sub
{
    my $q = shift;
    my $odb = shift;

    my $oid = $q->param('oid');
    my $t = $q->param('t');
    my $state = $q->param('state');
    my $desc = substr($q->param('desc'), 0, 3950);

    my $v = $state." ".$desc;

    if( $oid and $t and ( $t =~ /^[\d\.]+$/ ) )
    {
	my $rc = $odb->insert($oid, $t, $v);
	if( $rc )
	{
	    return "$oid $t ok\n";
	}
	else
	{
	    return "$oid $t retry\n";
	}
    }
    else
    {
	return "$oid $t fatal\n";
    }

    return "ok";
};

$code_table->{'upload'} =
sub
{
    my $q = shift;
    my $odb = shift;

    my $data = $q->param('data');

    my $oid;
    my $l = [];

    my @lines = split "\n", $data;
    my $line;
    foreach $line (@lines)
    {
	if( $line =~ /^BEGIN.(.*)$/)
	{
	    $oid = $1;
	}
	elsif( $line eq 'END' )
	{
	    $odb->insert_list($oid, $l);
	    $l = [];
	}
	else
	{
	    my ($t, $v) = split /\s+/, $line;
	    push @{$l}, $t;
	    push @{$l}, $v;
	}
    }
    return "ok";
    
};

$code_table->{'batch_insert'} =
sub
{
    my $q = shift;
    my $odb = shift;

    my $data = $q->param('data');

    my $result = "";

    my $version = $q->param('version');
    if ($version ne $PROTOCOL_VERSION) {
        print STDERR scalar(localtime),
          ": SCDB version mismatch: Expecting ",
            $PROTOCOL_VERSION, " but got $version\n";
    }

    my @lines = split "\n", $data;
    my $line;
    foreach $line (@lines)
    {
	my ($oid, $t, @values) = split /\s+/, $line;
	my $v = substr(join(" ", @values), 0, 3950);
	
	if( $oid and $t and ( $t =~ /^[\d\.]+$/ ) )
	{
	    my $rc = $odb->insert($oid, $t, $v);
	    if( $rc )
	    {
		$result .= "$oid $t ok\n";
	    }
	    else
	    {
		$result .= "$oid $t retry\n";
	    }
	}
	else 
	{
	    $result .= "$oid $t fatal\n";
	}
    }

    return $result;
};

$code_table->{'fetch'} =
sub
{
    my $q = shift;
    my $odb = shift;

    my $oid   = $q->param('oid');
    my $start = $q->param('start');
    my $end   = $q->param('end');

    my $text = "";

    my $ts = $odb->fetch($oid, $start, $end, 1);
    
    $text .= "BEGIN $oid\n";
    my ($t, $v);
    while ( scalar @{$ts} > 0 )
    {
	$t = shift @{$ts};
	$v = shift @{$ts};
	$v =~ s/[%\n\cM]/"%" . sprintf("%02X",ord($&))/ge;
	$text .= "$t $v\n";
    }
    $text .= "END\n";

    return $text;
};


$code_table->{'batch_fetch'} =
    sub
{
    my $q = shift;
    my $odb = shift;
    
    my @oids  = $q->param('oid');
    my $start = $q->param('start');
    my $end   = $q->param('end');

    my $text = "";
    
    my $oid;
    foreach $oid (@oids)
    {
	my $ts = $odb->fetch($oid, $start, $end, 1);
	
	$text .= "BEGIN $oid\n";
	my ($t, $v);
	while ( scalar @{$ts} > 0 )
	{
	    $t = shift @{$ts};
	    $v = shift @{$ts};
	    $v =~ s/[%\n\cM]/"%" . sprintf("%02X",ord($&))/ge;
	    $text .= "$t $v\n";
	}
	$text .= "END\n";
    }
    
    return $text;
};

$code_table->{'last'} =
sub
{
    my $q = shift;
    my $odb = shift;
    
    my $oid = $q->param('oid');
    
    my ($t, $v) = $odb->last($oid);

    if( defined $t and defined $v )
    {
	$v =~ s/[%\n\cM]/"%" . sprintf("%02X",ord($&))/ge;
	return "$oid $t $v\n";
    }
    else
    {
	return "$oid\n";
    }
};


$code_table->{'batch_last'} =
sub
{
    my $q = shift;
    my $odb = shift;
    
    my @oids = $q->param('oid');
    
    my $content = "";
    
    my $oid;
    foreach $oid (@oids)
    {
	my ($t, $v) = $odb->last($oid);
	if( defined $t and defined $v )
	{
	    $v =~ s/[%\n\cM]/"%" . sprintf("%02X",ord($&))/ge;
	    $content .= "$oid $t $v\n";
	}
	else
	{
	    $content .= "$oid\n";
	}
    }
    
    return $content;
};

$code_table->{'delete'} =
sub
{
    my $q = shift;
    my $odb = shift;

    my $oid = $q->param('oid');
    my $t = $q->param('t');
    
    return $odb->delete($oid, $t);
};

$code_table->{'size'} =
    sub
{
    my $q = shift;
    my $odb = shift;
    
    my $oid = $q->param('oid');
    
    my $s = $odb->size($oid);

    return "$oid $s";
};

###################################################
# mod_perl handler()
###################################################

sub handler
{
    my $r = shift;

    my $q;
    if ($r->method() eq 'POST') {
        my $buffer = '';
        while ($r->read(my $b, 1024)) {
            $buffer .= $b;
        }
        $q = CGI->new($buffer);
    } else {
        $q = CGI->new($r->args());
    }
    
    my $content;
    my $err;
    my $code = $code_table->{$q->param('fn')};
    
    if( defined $code )
    {
	my $odb = NOCpulse::Database->new(type => "state_change");
	$content = eval { &{$code}($q, $odb); };
	$err = $@ || undef; # the || undef is because $@ is empty string if no error
    }
    else
    {
	$err = "undefined function \"".$q->param('fn')."\"";
    }

    if( defined $err )
    {
	$r->log_error($err);
    }
    
    # $r->log()->info($q->args());
    $r->content_type('text/html');
    $r->print($content);

    return OK;
}


1;
