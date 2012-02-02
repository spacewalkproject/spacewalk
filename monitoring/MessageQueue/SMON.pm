package NOCpulse::SMON;

use strict;
use URI;
use NOCpulse::Gritch;
use NOCpulse::Debuggable;
use NOCpulse::Config;
use NOCpulse::PersistentConnection;

@NOCpulse::SMON::ISA = qw ( NOCpulse::Debuggable  );

sub new
{
    my $class = shift;
    my %args = @_;
    
    my $self = {};
    bless $self, $class;

    my $cfg = $args{'Config'};
    my $debug = $args{'Debug'};
    my $gritcher = $args{'Gritcher'};
    my $debuglevel = $args{'DebugLevel'};
    my $loglevel = $args{'LogLevel'};

    if ($debuglevel)
    {
	my $debugstream = $debug->addstream(LEVEL => $debuglevel);
	$gritcher->recipient($debugstream);
    }
    
    my $logfile  = $cfg->get('queues', 'logfile');
    $self->logfile($logfile);

    my $logbasename = $logfile; $logbasename =~ s,^.*/,,;
    my $archive     = $cfg->get('netsaint', 'archiveDir');
    my $log         = $debug->addstream(LEVEL  => $loglevel,
					FILE   => $logfile,
					APPEND => 1);
    
    $log->linenumbers(1);
    $log->timestamps(1);
    $log->autoflush(1);

    $self->gritcher($gritcher);
    $self->debugobject($debug);

    my $polling_interval = $cfg->get('queues', 'polling_interval') || 5;
    $self->polling_interval($polling_interval);

    my $url = $cfg->get('queues', 'eventHandler');
    die "Could not retrieve value queues -> eventHandler from config.\n" unless ($url);
    my $uri = new URI($url);
    my $smon_host = $uri->host();
    my $url_path = $uri->path();

    $self->connection(new NOCpulse::PersistentConnection( Host => $smon_host, Debug => $debug) );

    $self->url_path($url_path);

    $self->{'queues'} = [];
    
    return $self;
}

sub url_path
{
   my $self = shift;
   my $url_path = shift;

   if( defined $url_path )
   {
      $self->{'url_path'} = $url_path;
   }
   else
   {
      return $self->{'url_path'};
   }
}


sub polling_interval
{
    my $self = shift;
    my $pi = shift;

    if( defined $pi )
    {
	$self->{'polling_interval'} = $pi;
    }
    else
    {
	return $self->{'polling_interval'};
    }
}

sub connection
{
    my $self = shift;
    my $c = shift;

    if( defined $c )
    {
	$self->{'connection'} = $c;
    }
    else
    {
	return $self->{'connection'};
    }
}

sub logfile
{
    my $self = shift;
    my $f = shift;

    if( defined $f )
    {
	$self->{'logfile'} = $f;
    }
    else
    {
	return $self->{'logfile'};
    }
}


sub gritcher
{
    my $self = shift;
    my $g = shift;
    
    if( defined $g )
    {
	$self->{'gritcher'} = $g;
    }
    else
    {
	return $self->{'gritcher'};
    }
}

sub addQueue
{
    my $self = shift;
    my $q = shift;

    push @{$self->{'queues'}}, $q;
}

sub heartbeat
{
    my $self = shift;
    
    my $now = time();
    utime $now, $now, $self->logfile();
}

sub go
{
    my $self = shift;
    
    while(1)
    {
	$self->dprint(1, "looking for queue entries\n");

	my $q;
	foreach $q (@{$self->{'queues'}})
	{
	    $q->dequeue($self);
	    $self->heartbeat();
	}

	sleep $self->polling_interval();
    }
}

1;
