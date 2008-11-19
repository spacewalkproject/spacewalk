
package NOCpulse::SCDB::Accessor;

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
	$self->{host} = $args{'host'} || 'scdb.nocpulse.com';
	$self->{port} = $args{'port'} || 7979;
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
    
    my $v = $args{'desc'};
    $v =~ s/[^-_a-zA-Z0-9]/"%" . sprintf("%02X",ord($&))/ge;
    
    my $content = "fn=insert&oid=".$args{'oid'}. "&t=".$args{'t'}."&state=".$args{'state'}."&desc=".$v;
    
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
	my $v = $datum->[2]." ".$datum->[3];
	#$v =~ s/[%\n\cM]/"%" . sprintf("%02X",ord($&))/ge;
	$text_data .= $datum->[0]." ".$datum->[1]." $v\n";
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

sub last
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
    
    my $content = "fn=last&oid=".$args{'oid'};
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );

	# shouldn't be splitting !!
	# also, we should be unescaping !!
	my ($oid_again, $t, $state, @vals) = split /\s+/, $response->content;
	
	$results->{'time'} = $t;
	$results->{'state'} = $state;
	$results->{'description'} = join(" ", @vals);
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
    
    my $content = "fn=fetch&oid=".$args{'oid'}."&start=".$args{'start'}."&end=".$args{'end'};
    
    $request->content($content);
    
    my $response = $self->{ua}->request($request);
    
    if ($response->is_success)
    {
	print $response->content if ( $self->{verbose} );
	
	if( $args{'raw'} == 1 )
	{
	    ${$results} = $response->content();
        }
        else
	{
	    $results->{times}  = [];
	    $results->{states} = [];
	    $results->{descriptions} = [];
	    
	    my @lines = split "\n", $response->content();
	    my $line;
	    foreach $line (@lines)
	    {
		next if ( $line =~ /^BEGIN/ );
		last if ( $line =~ /^END/ );
		
		my $i = index $line, " ";
		my $j = index $line, " ", ($i + 1);
		
		if( ( $i != -1 ) and ( $j != -1 ) )
		{
		    my $t = substr $line, 0, $i;
		    my $state = substr $line, ($i + 1), ($j - $i);
		    my $desc = substr $line, ($j + 1);
		    
		    push @{$results->{times}}, $t;
		    push @{$results->{states}}, $state;
		    push @{$results->{descriptions}}, $desc;
		    
		    # we should be unescaping the description !!
		    
		}
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

1;

