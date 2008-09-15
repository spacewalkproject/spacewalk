
package NOCpulse::Scheduler::Message;

use strict;
use NOCpulse::Scheduler::Event;

sub new
{
    my $class = shift;
    my $recipients = shift;
    my $content = shift;
    my $via = shift;
    
    my $self = {};
    bless $self, $class;

    $self->{recipients} = $recipients;
    $self->{content} = $content;
    $self->{via} = $via;
    
    return $self;
}

sub recipients
{
    my $self = shift;
    my $recipients = shift;

    if( defined $recipients )
    {
	$self->{recipients} = $recipients;
    }
    else
    {
	return $self->{recipients};
    }
}

sub content
{
    my $self = shift;
    my $content = shift;
    
    if( defined $content )
    {
	$self->{content} = $content;
    }
    else
    {
	return $self->{content};
    }
}

sub via
{
    my $self = shift;
    my $via = shift;

    if( defined $via )
    {
	$self->{via} = $via;
    }
    else
    {
	return $self->{via};
    }
}

1;
