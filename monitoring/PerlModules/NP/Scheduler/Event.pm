
package NOCpulse::Scheduler::Event;

use strict;
use NOCpulse::Scheduler::Message;

use NOCpulse::Debuggable;
use vars qw(@ISA);
@ISA = qw(NOCpulse::Debuggable);


##########################################################
# Global variables
#

my $DEFAULT_INTERVAL = 60;  # Default execution interval


##########################################################
# Accessor methods
#
sub time_to_execute    { shift->_elem('time_to_execute',    @_); }
sub execution_interval { shift->_elem('execution_interval', @_); }
sub last_execution     { shift->_elem('last_execution',     @_); }

sub new
{
    my $class = shift;
    my $id = shift;
    
    my $self = {};
    bless $self, $class;

    $self->{id} = $id;
    $self->clear_in_msgs();
    $self->clear_out_msgs();
    
    $self->{subscriptions} = {};

    return $self;
}

sub id
{
    my $self = shift;

    return $self->{id};
    
}

sub subscribe_to
{
    my $self = shift;
    my @subscriptions = @_;

    my $s;
    foreach $s (@subscriptions)
    {
	$self->{subscriptions}->{$s} = 1;
    }
}

sub subscriptions
{
    my $self = shift;
    
    return [ keys %{$self->{subscriptions}} ];
}

sub clear_in_msgs
{
    my $self = shift;

    $self->{in_msgs} = [];
}

sub write_in_msgs
{
    my $self = shift;
    my $msgs = shift;

    if( defined $msgs )
    {
	push @{$self->{in_msgs}}, @{$msgs};
    }
}

sub read_in_msgs
{
    my $self = shift;

    my $msgs = $self->{in_msgs};
    $self->clear_in_msgs();

    return $msgs;
}

sub read_in_msgs_grouped
{
    my $self = shift;

    # group messages by "via", which is the
    # channel they were sent through

    my $msgs = $self->read_in_msgs();
    
    my $grouped = {};
    my $msg;
    foreach $msg (@{$msgs})
    {
	my $v = $msg->via();
	if( not defined $grouped->{$v} )
	{
	    $grouped->{$v} = [];
	}
	$self->dprint(5, "adding message ".$msg->content()." to group $v\n");
	push @{$grouped->{$v}}, $msg;
    }
    
    return $grouped;
}

sub clear_out_msgs
{
    my $self = shift;

    $self->{out_msgs} = [];
}

sub write_out_msgs
{
    my $self = shift;
    my $msgs = shift;

    if( defined $msgs )
    {
	push @{$self->{out_msgs}}, @{$msgs};
    }
}

sub read_out_msgs
{
    my $self = shift;

    my $msgs = $self->{out_msgs};
    $self->clear_out_msgs();
    
    return $msgs;
}

sub run
{
    my $self = shift;

    # This subroutine runs the job encapsulated by the event object.

    # This space is reserved for creating subclasses whose
    # run behavior is interesting (e.g. forking, etc).

    $self->dprint(2, "running event ".$self->id()."\n");
    
    $self->time_to_execute(time() + 10);

    my $in_msgs_grouped = $self->read_in_msgs_grouped();
    my $channel;
    foreach $channel (keys %{$in_msgs_grouped})
    {
	if( defined $in_msgs_grouped->{$channel} )
	{
	    my $im;
	    foreach $im (@{$in_msgs_grouped->{$channel}})
	    {
		$self->dprint(2, "message via channel $channel: ".$im->content()."\n");
	    }
	}
    }

    my $m1 = new NOCpulse::Scheduler::Message([$self->id()], "hello world, time is ".gmtime(time()));
    my $m2 = new NOCpulse::Scheduler::Message(["fox"], "shared broadcast to fox at ".gmtime(time()));
    $self->write_out_msgs([$m1, $m2]);
    
    return $self;
    
}



sub handle_timeout
{
    my $self = shift;

    # This subroutine runs if the run() method is timed out by
    # the caller (generally, the scheduler).

    # This space is reserved for creating subclasses whose timeout-handling
    # behavior is interesting (e.g. reporting errors, rescheduling, etc).  
    # Default behavior is to schedule this event for re-execution after 
    # $self->execution_interval seconds (defaults to $DEFAULT_INTERVAL).

    # print "running event ".$self->id()."\n";

    my $interval    = $self->execution_interval || $DEFAULT_INTERVAL;
    $self->time_to_execute(time() + $interval);
    
    return $self;
    
}

sub handle_failure
{
    my ($self, $stderr, $gritcher) = @_;

    # This subroutine runs if the run() method gets no return value,
    # meaning the child's process failed. As with handle_timeout,
    # subclasses can override for error reporting and so on.

    my $interval    = $self->execution_interval || $DEFAULT_INTERVAL;
    $self->time_to_execute(time() + $interval);
    
    return $self;

}

sub cmp
{
    my $self = shift;
    my $other = shift;
    
    return ( $self->time_to_execute() <=> $other->time_to_execute() );
}

sub is_ready
{
    my $self = shift;
    my $t = shift;
    
    return ( $t >= $self->time_to_execute() );
}


sub screw_off_and_die
{
    my $self = shift;

    # clean up after yourself
}

# Accessor implementation (stolen from LWP::MemberMixin,
# by Martijn Koster and Gisle Aas)
sub _elem {
  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}

1;
