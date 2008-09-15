
package NOCpulse::Scheduler;

use strict;
use Time::localtime;
use NOCpulse::Scheduler::MessageDictionary;
use NOCpulse::Debuggable;
use NOCpulse::Scheduler::Event::ProbeEvent;

use vars qw(@ISA);
@ISA = qw(NOCpulse::Debuggable);

sub new
{
    my $class = shift;
    my %args  = @_;

    my $self = {};
    bless $self, $class;

    my $debug = $args{'Debug'} || $self->defaultDebugObject;
    
    $self->debugobject($debug);

    $self->{md} = NOCpulse::Scheduler::MessageDictionary->new( Debug => $debug );
    
    $self->flush();
    
    return $self;
}

sub flush
{
    my $self = shift;
    
    $self->{md}->flush();
    
    $self->{events_by_id} = {};
    $self->{run} = {};

    # Hash by probe ID of ready-to-run events
    $self->{ready} = {};
    # Priority-sorted list of ready-to-run events
    $self->{ready_list} = [];
}

sub format_event_time
{
   my ($self, $event) = @_;
   my $time = localtime($event->time_to_execute);
   return sprintf("%02d/%02d %02d:%02d:%02d",
		  $time->mon+1, $time->mday, $time->hour, $time->min, $time->sec);
}

sub dump_internal_state
{
   my $self = shift;
   my %all_ids = ();
   my @ready_dump = ();
   my $i = 1;
   foreach my $evt (@{$self->{ready_list}}) {
      push(@ready_dump, sprintf("%3d. %6d: %s", $i, $evt->id, $self->format_event_time($evt)));
      $all_ids{$evt->id} = 1;
      ++$i;
   }
   my @run_dump = ();
   foreach my $id (keys %{$self->{run}}) {
      push(@run_dump, sprintf("%3d. %6d", $i, $id));
      $all_ids{$id} = 1;
      ++$i;
   }
   $self->dprint(1, "Scheduler ready-to-run queue:\n\t".join("\n\t", @ready_dump)."\n");
   if (scalar(@run_dump) > 0) {
      $self->dprint(1, "Scheduler currently running:\n\t".join("\n\t", @run_dump)."\n");
   } else {
      $self->dprint(1, "Nothing currently running\n");
   }
   foreach my $id (keys %{$self->{events_by_id}}) {
      if (! exists($all_ids{$id})) {
	 $self->dprint(1, "**** Event $id is neither running nor ready to run\n");
      }
   }
}

sub sort_ready_queue
{
   my $self = shift;
   $self->{ready_list} = [sort { $a->cmp($b) } @{$self->{ready_list}}];
}

# Returns the index at which a target event should be inserted in the list.
sub find_ready_pos
{
   my ($self, $targetEvent) = @_;
   my @ready_list = @{$self->{ready_list}};

   my $low = 0;
   my $high = scalar(@ready_list);

   while ($low < $high) {
      use integer;
      my $cur = ($low + $high) / 2;

      if ($ready_list[$cur]->cmp($targetEvent) < 0) {
	 $low = $cur + 1; # Try higher
      } else {
	 $high = $cur;    # Try lower
      }
   }
   return $low;
}

sub add_to_ready
{
    my $self = shift;
    my $event = shift;

    $self->{ready}->{$event->id()} = $event;

    my $index = $self->find_ready_pos($event);
    splice(@{$self->{ready_list}}, $index, 0, $event);
}

sub extract_from_ready
{
    my $self = shift;
    my $now = shift;

    $self->dprint(4, "Scheduler::extract_from_ready(@_) begin\n");
    
    my $highest_priority_event = $self->{ready_list}->[0];

    if( defined $highest_priority_event and
	$highest_priority_event->is_ready($now) )
    {
        delete $self->{ready}->{$highest_priority_event->id};
        shift(@{$self->{ready_list}});
        return $highest_priority_event;
    }

    return undef;

}


sub reset
{
    my $self = shift;
    my $events = shift;

    my $label = 'Scheduler::reset';
    my $log_level = 4;
    $self->dprint($log_level, "$label(@_)\n");

    # For logging:
    my @added = ();
    my @updated = ();
    my @removed = ();

    my $disowned = {};
    my $event;
    foreach $event (values %{$self->{events_by_id}})
    {
	$disowned->{$event->id()} = $event;
    }
    
    foreach $event (@{$events})
    {
	if( $self->{events_by_id}->{$event->id()} )
	{
	    $self->dprint($log_level, "$label already knew about ".$event->id()."\n");

	    # Reset the time. Note this can make the ready list unsorted.
	    my $old_event = $self->{events_by_id}->{$event->id()};
	    $old_event->time_to_execute($event->time_to_execute());

            # suck in any new subscriptions
	    my $subscriptions = $event->subscriptions();
	    if( defined $subscriptions )
	    {
		$old_event->subscribe_to(@{$subscriptions});
	    }
	    $self->{md}->register_event($old_event);
	    
	    my $msgs = $event->read_out_msgs();
	    $self->{md}->add_msgs($msgs);

	    delete $disowned->{$event->id()};
	    push(@updated, $event->id());
	}
	else
	{
	    $self->dprint($log_level, "$label adding new event ".$event->id()."\n");
	    $self->add_event($event);
	    push(@added, $event->id);
	}
	
    }

    my $stepchild;
    foreach $stepchild (values %{$disowned})
    {
	$self->dprint($log_level, "$label disowning event ".$stepchild->id()."\n");
	$self->disown_event($stepchild);
	push(@removed, $stepchild->id);
    }

    # Execution times may have changed, so recreate and re-sort the ready list by time.
    $self->{ready_list} = [values %{$self->{ready}}];
    $self->sort_ready_queue;

    if (scalar(@updated) > 0 && scalar(@added) > 0) {
       # Don't print this at startup
       $self->dprint(1, "Added events: ", join(', ', @added), "\n");
    }
    if (scalar(@removed) > 0) {
       $self->dprint(1, "Removed events: ", join(', ', @removed), "\n");
    }

    $self->dprint($log_level, "$label exiting\n");
    
}

sub disown_event
{
    my $self = shift;
    my $event = shift;

    my $id = $event->id();
    
    delete $self->{run}->{$id};
    delete $self->{ready}->{$id};
    delete $self->{events_by_id}->{$id};

    $event->screw_off_and_die();
}

sub add_event
{
    my $self = shift;
    my $event = shift;

    # assert: the event isn't in run, ready, or events_by_id
    #         how to handle time_to_execute in that case ?

    $self->{events_by_id}->{$event->id()} = $event;

    $self->{ready}->{$event->id()} = $event;
    
    $self->{md}->register_event($event);
    
    my $msgs = $event->read_out_msgs();
    $self->{md}->add_msgs($msgs);
    
}

sub event_done
{
    my $self = shift;
    my $event = shift;

    if( $self->{run}->{$event->id()} )
    {
	# assert: the event is not in the ready queue

	delete $self->{run}->{$event->id()};
	my $msgs = $event->read_out_msgs();
	$self->{md}->add_msgs($msgs);
	
	my $old_event = $self->{events_by_id}->{$event->id()};
	if (defined($old_event)) {
	   # Event is defined unless it's for a deleted probe.
	   $old_event->time_to_execute($event->time_to_execute());
	   $self->add_to_ready($old_event);
	}
    }
    else
    {
	# Event was disowned.

	if( $self->{ready}->{$event->id()} )
	{
	    # The event was added again at some point after
	    # it was disowned. This should be impossible...
	    $self->dump(0, "Scheduler::event_done: UNEXPECTED event disowned and re-added:",
			$event, "\n");
	}

    }
}

sub next_event
{
    my $self = shift;
    my $label = "Scheduler::next_event";
    
    $self->dprint(4, "$label(@_)\n");
    
    my $now = time();

    my $rv = undef;
    my $e = $self->extract_from_ready($now);
    
    if( defined $e )
    {
	if( $self->{run}->{$e->id()}  )
	{
	    $self->dprint(2, "$label got event that's already running\n");
	}
	else
	{
	    $e->clear_in_msgs();
	    my $msgs = $self->{md}->msgs_for_event($e);
	    $e->write_in_msgs($msgs);
	    $self->{run}->{$e->id()} = $e;
	    $self->dprint(2, "$label returning event ".$e->id()."\n");
	    $rv = $e;
	}
    }
    else
    {
	$self->dprint(2, "$label returning no event\n");
    }

    $self->dprint(4, "$label returning $rv\n");
    return $rv;
}


1;
