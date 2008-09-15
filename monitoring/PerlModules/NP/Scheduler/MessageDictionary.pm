
package NOCpulse::Scheduler::MessageDictionary;

use strict;
use NOCpulse::Scheduler::Message;

use NOCpulse::Debuggable;
use vars qw(@ISA);
@ISA = qw(NOCpulse::Debuggable);

sub new
{
    my $class = shift;
    my %args = @_;
    
    my $self = {};
    bless $self, $class;

    my $debug = $args{'Debug'} || $self->defaultDebugObject;
    
    $self->debugobject($debug);
    
    $self->flush();

    return $self;
}

sub flush
{
    my $self = shift;
    
    $self->{poboxes} = {};
    $self->{channel_to_subscribers} = {};
}


sub add_msgs
{
    my $self = shift;
    my $msgs = shift;

    $self->dprint(4, "add_msgs start\n");

    my $msg;
    foreach $msg (@{$msgs})
    {
	$self->dprint(4, "delivering message ".$msg->content()."\n");

	my $rs = $msg->recipients();
	my $recipient;
	foreach $recipient (@{$rs})
	{
	    $self->dprint(4, "... to recipient $recipient\n");

	    my $msg_copy = NOCpulse::Scheduler::Message->new($msg->recipients(), $msg->content(), $recipient);
    
	    # This test will work only for single-layer channels
	    # In other words, a channel cannot subscribe to a channel
	    
	    if( defined $self->{poboxes}->{$recipient} )
	    {
		$self->dprint(4, "direct to pobox $recipient\n");
		
		# assume $recipient is a pobox (event id)
		push @{$self->{poboxes}->{$recipient}}, $msg_copy;
	    }
	    else
	    {
		$self->dprint(4, "to all subscribers of channel $recipient\n");

		# assume $recipient is a channel identifier
		
		my $pobox_ids = $self->{channel_to_subscribers}->{$recipient};
		if( defined $pobox_ids )
		{
		    my $pobox;
		    foreach $pobox (keys %{$pobox_ids})
		    {
			$self->dprint(4, "to pobox $pobox through channel $recipient\n");
			
			push @{$self->{poboxes}->{$pobox}}, $msg_copy;
		    }
		}
		    
	    }
	}
	
    }
    
    $self->dprint(4, "add_msg end\n");
    
    my $channel;
    foreach $channel (keys %{$self->{channel_to_subscribers}} )
    {
	$self->dprint(6, "listing subscribers to $channel\n");
	my $subscriber;
	foreach $subscriber (keys %{$self->{channel_to_subscribers}->{$channel}})
	{
	    $self->dprint(6, "\tsubscriber $subscriber\n");
	}
    }

    my $p;
    foreach $p (keys %{$self->{poboxes}}) {

	$self->dprint(6, "pobox ".$p."\n");
	my $m;
	foreach $m (@{$self->{poboxes}->{$p}}) {
	    $self->dprint(6, "\tmessage: ".$m->content."\n");
	}
    }

}

sub msgs_for_event
{
    my $self = shift;
    my $event = shift;

    $self->dprint(4, "msgs_for_event ".$event->id()."\n");

    my $p;
    foreach $p (keys %{$self->{poboxes}}) {

	$self->dprint(4, "pobox ".$p."\n");
	my $m;
	foreach $m (@{$self->{poboxes}->{$p}}) {
	    $self->dprint(4, "\tmessage: ".$m->content."\n");
	}  
    }
    
    my $msgs = $self->{poboxes}->{$event->id()};
    $self->{poboxes}->{$event->id()} = [];

    return $msgs;
}

sub register_event
{
    my $self = shift;
    my $event = shift;

    $self->dprint(4, "register_event on event ".$event->id()."\n");
    
    if( not defined $self->{poboxes}->{$event->id()} )
    {
	$self->dprint(4, "creating new pobox\n");
	$self->{poboxes}->{$event->id()} = [];
    }

    # BUG:
    # Make sure the event isn't subscribed to any channels
    # that are not in @{$channels}.  This situation will occur
    # after a Scheduler.reset() is called, and some
    # event unsubscribes from a channel.
    
    my $channels = $event->subscriptions();

    my $channel;
    foreach $channel (@{$channels})
    {
	$self->dprint(4, "subscribing event ".$event->id()." to channel $channel\n");

	if( not defined $self->{channel_to_subscribers}->{$channel} )
	{
	    $self->{channel_to_subscribers}->{$channel} = {};
	}

	$self->{channel_to_subscribers}->{$channel}->{$event->id()} = 1;
	
    }

}

1;
