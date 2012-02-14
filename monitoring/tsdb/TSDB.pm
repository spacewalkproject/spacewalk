
package NOCpulse::TSDB;

use strict;
use CGI;
use Apache2::Const 'OK';
use Apache2::Log ();

use NOCpulse::Database;

use NOCpulse::TSDB::LocalQueue::File;


# Keep in synch with MessageQueue/TimeSeriesQueue.pm
my $PROTOCOL_VERSION = '1.0';

my $INITIALIZED = 0;
my $LOCAL_QUEUE_FILE;


sub init {
    return if $INITIALIZED;

    my $cfg        = NOCpulse::Config->new();
    my $queue_dir  = $cfg->get('TSDBLocalQueue', 'local_queue_dir');
    my $rotate_kb  = $cfg->get('TSDBLocalQueue', 'handler_rotate_size_kb') || 500;
    my $log_config = $cfg->get('TSDBLocalQueue', 'handler_log_config');
    my $logfile    = $cfg->get('TSDBLocalQueue', 'handler_log_file');

    if ($log_config) {
        NOCpulse::Log::LogManager->instance->add_configuration(eval($log_config));
        NOCpulse::Log::LogManager->instance->stream(FILE       => $logfile,
                                                    TIMESTAMPS => 1,
                                                    APPEND     => 1);
    }
    $LOCAL_QUEUE_FILE = NOCpulse::TSDB::LocalQueue::File->new(
        directory      => $queue_dir,
        rotate_size_kb => $rotate_kb);
    $LOCAL_QUEUE_FILE->create();
    $INITIALIZED = 1;
}

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
    my $t   = $q->param('t');
    my $v   = $q->param('v');

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
	    # check $rc !!!
	    my $rc = $odb->insert_list($oid, $l);
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

    my $result = "";

    my $version = $q->param('version');
    if ($version ne $PROTOCOL_VERSION) {
        print STDERR scalar(localtime),
          ": TSDB version mismatch: Expecting ",
            $PROTOCOL_VERSION, " but got $version\n";
    }

    my $data = $q->param('data');
    my @lines = split "\n", $data;
    my $line;
    foreach $line (@lines)
    {
	my ($oid, $t, $v) = split /\s+/, $line;

	if ($oid and $t and ($t =~ /^[\d\.]+$/)) {
            if ($LOCAL_QUEUE_FILE->append($oid, $t, $v)) {
		$result .= "$oid $t ok\n";
	    } else {
		$result .= "$oid $t retry\n";
	    }
	} else {
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

    my $ts = $odb->fetch($oid, $start, $end, 0);
    if( not $ts )
    {
	return undef;
    }

    $text .= "BEGIN $oid\n";
    my ($t, $v);
    while (scalar @{$ts} > 0)
    {
	$t = shift @{$ts};
	$v = shift @{$ts};
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
	my $ts = $odb->fetch($oid, $start, $end, 0);
	if( defined $ts )
	{
	    $text .= "BEGIN $oid\n";
	    my ($t, $v);
	    while (scalar @{$ts} > 0)
	    {
		$t = shift @{$ts};
		$v = shift @{$ts};
		$text .= "$t $v\n";
	    }
	    $text .= "END\n";
	}
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

    my $rc = $odb->delete($oid, $t);
    if( $rc )
    {
	return "$oid $t ok\n";
    }
    else
    {
	return "$oid $t fatal\n";
    }
};

$code_table->{'size'} =
sub
{
    my $q = shift;
    my $odb = shift;

    my $oid = $q->param('oid');

    my $s = $odb->size($oid);

    if( $s )
    {
	return "$oid $s\n";
    }
    else
    {
	return "$oid\n";
    }
};


#######################################
# mod_perl handler()
#######################################

sub handler
{
    my $r = shift;

    init();

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
	my $odb = NOCpulse::Database->new(type => "time_series_data");
	$content = eval { &{$code}($q, $odb); };
	$err = $@ || undef; # the || undef is because $@ is empty string if no error
    }
    else
    {
	$err = "undefined function \"".$q->param('fn')."\"";
    }

    if( defined $err )
    {
	$r->log_error("TSDB err: $err");
    }

    $r->log()->info('Sat ', $q->param('satcluster') . ' ' . $q->param('fn'));
    $r->content_type('text/html');
    $r->print($content);

    return OK;
}


1;
