
package NOCpulse::TSDB::Accessor;

use strict;
use LWP::UserAgent;
use URI::Escape;

my $BADCHARS = '^-_a-zA-Z0-9';

sub new
{
    my $class = shift;
    my %args = @_;

    my $self = {};
    bless $self, $class;

    if( defined $args{'url'} )
    {
	$self->{url} = $args{'url'};
    }
    else
    {
	$self->{host} = $args{'host'} || 'tsdb.nocpulse.net';
	$self->{port} = $args{'port'} || 80;
    }
    $self->{verbose} = $args{'verbose'} || 0;
    $self->{ua} = LWP::UserAgent->new;

    return $self;
}

sub insert
{
    my $self = shift;
    my %args = @_;

    my $request;
    
    if( defined $self->{'url'} )
    {
	$request = HTTP::Request->new('POST', $self->{'url'} . "/db");
    }
    else
    {
	$request = HTTP::Request->new('POST', "http://".$self->{host}.":".$self->{port}."/db");
    }
    
    my $content = "fn=insert&oid=".$args{'oid'}. "&t=".$args{'t'}."&v=".$args{'v'};
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );
    }
    else
    {
	$! = $response->status_line;
	return 0;
    }

    return 1;
}

sub size
{
    my $self = shift;
    my %args = @_;

    my $request;
    
    if( defined $self->{'url'} )
    {
	$request = HTTP::Request->new('POST', $self->{'url'} . "/db");
    }
    else
    {
	$request = HTTP::Request->new('POST', "http://".$self->{host}.":".$self->{port}."/db");
    }
    
    my $content = "fn=size&oid=".$args{'oid'};
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );
	my ($oid, $size) = split(" ", $response->content());
	${$args{'result'}} = $size;
    }
    else
    {
	$! = $response->status_line;
	return 0;
    }

    return 1;
    
}

sub upload
{
    my $self = shift;
    my %args = @_;

    my $request;
    
    if( defined $self->{'url'} )
    {
	$request = HTTP::Request->new('POST', $self->{'url'} . "/db");
    }
    else
    {
	$request = HTTP::Request->new('POST', "http://".$self->{host}.":".$self->{port}."/db");
    }

    my $data = $args{'data'};

    my $content = "fn=upload&data=".uri_escape($data, $BADCHARS);
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );
    }
    else
    {
	$! = $response->status_line;
	return 0;
    }

    return 1;
}


sub batch_insert
{
    my $self = shift;
    my %args = @_;

    my $request;

    if( defined $self->{'url'} )
    {
	$request = HTTP::Request->new('POST', $self->{'url'} . "/db");
    }
    else
    {
	$request = HTTP::Request->new('POST', "http://".$self->{host}.":".$self->{port}."/db");
    }

    my $text_data = "";
    my $datum;
    foreach $datum (@{$args{'data'}})
    {
	$text_data .= $datum->[0]." ".$datum->[1]." ".$datum->[2]."\n";
    }
    
    my $content = "fn=batch_insert&data=$text_data";
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );
    }
    else
    {
	$! = $response->status_line;
	return 0;
    }

    return 1;
}

sub copy
{
    my $self = shift;
    my %args = @_;

    my $request;
    
    if( defined $self->{'url'} )
    {
	$request = HTTP::Request->new('POST', $self->{'url'} . "/db");
    }
    else
    {
	$request = HTTP::Request->new('POST', "http://".$self->{host}.":".$self->{port}."/db");
    }

    my $content = uri_escape("fn=copy".
			     "&from_oid=".$args{'from_oid'}.
			     "&to_oid=".$args{'to_oid'}.
			     "&start=".$args{'start'}.
			     "&end=".$args{'end'}, $BADCHARS);
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );
    }
    else
    {
	$! = $response->status_line;
	return 0;
    }

    return 1;
}

sub delete
{
    my $self = shift;
    my %args = @_;

    my $request;
    
    if( defined $self->{'url'} )
    {
	$request = HTTP::Request->new('POST', $self->{'url'} . "/db");
    }
    else
    {
	$request = HTTP::Request->new('POST', "http://".$self->{host}.":".$self->{port}."/db");
    }
    
    my $content = "fn=delete".
	"&oid=".$args{'oid'}.
	    "&t=".$args{'t'};
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );
    }
    else
    {
	$! = $response->status_line;
	return 0;
    }

    return 1;
}

sub fetch
{
    my $self = shift;
    my %args = @_;

    my $results = $args{'results'}; # a hash ref
   
    my $request;

    if( defined $self->{'url'} )
    {
	$request = HTTP::Request->new('POST', $self->{'url'} . "/db");
    }
    else
    {
	$request = HTTP::Request->new('POST', "http://".$self->{host}.":".$self->{port}."/db");
    }
    
    my $content = "fn=fetch&oid=".$args{'oid'}.
	"&start=".$args{'start'}."&end=".$args{'end'};
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );

	if( $args{'raw'} == 1 )
	{
	    ${$results} = $response->content;
	}
	else
	{
	    $results->{times}  = [];
	    $results->{values} = [];
	    my @lines = split "\n", $response->content();
	    
	    shift @lines;
	    
	    my $line;
	    foreach $line (@lines)
	    {
		last if $line eq 'END';
		
		my ($t, $v) = split /\s+/, $line;
		push @{$results->{times}}, $t;
		push @{$results->{values}}, $v;
	    }
	}
    }
    else
    {
	$! = $response->status_line;
	return 0;
    }

    return 1;
}

sub batch_fetch
{
    my $self = shift;
    my %args = @_;
    
    my $results = $args{'results'}; # a hash ref
    
    $results->{times}  = [];
    $results->{values} = [];
    
    my $request;

    if( defined $self->{'url'} )
    {
	$request = HTTP::Request->new('POST', $self->{'url'} . "/db");
    }
    else
    {
	$request = HTTP::Request->new('POST', "http://".$self->{host}.":".$self->{port}."/db");
    }
    
    my $content = "fn=batchfetch&".
	(join("&",( map {"oid=".$_} @{$args{'oids'}})));
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );

	# PARSE !!!!
	my @lines = split "\n", $response->content();
	my $line;
	foreach $line (@lines)
	{
	    my ($t, $v) = split /\s+/, $line;
	    push @{$results->{times}}, $t;
	    push @{$results->{values}}, $v;
	}
    }
    else
    {
	$! = $response->status_line;
	return 0;
    }

    return 1;
}

1;

