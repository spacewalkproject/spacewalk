package NOCpulse::Scheduler::Event::PluginEvent;

use strict;
use vars qw(@ISA);

use NOCpulse::Probe::MessageCatalog;
use NOCpulse::Scheduler::Event;
@ISA=qw(NOCpulse::Scheduler::Event);
use NOCpulse::PlugFrame::Plugin;
use Data::Dumper;

my $TIMEOUT_MESSAGE = NOCpulse::Probe::MessageCatalog->instance->event('timed_out');
my $FAILURE_MESSAGE = NOCpulse::Probe::MessageCatalog->instance->event('failed');

sub CodeFailureMessage {
   return $FAILURE_MESSAGE;
}

sub run
{
	my $self = shift();
	my $inboundMessages = $self->read_in_msgs_grouped;
	#print "BEFORE PROBE:\n";
	#print Dumper($self);
	my ($nextExecTime,$outboundMessages) = ScheduledPlugin->newInitialized($self->id,$inboundMessages)->run;
	$self->time_to_execute($nextExecTime);
	#print "EVENT GOT MESSAGES:\n";
	#print Dumper($outboundMessages);
	$self->write_out_msgs($outboundMessages);
	#print "AFTER PROBE AND WRITE:\n";
	#print Dumper($self);
	return $self;
}

sub handle_timeout
{
	my $self = shift();
	$self->SUPER::handle_timeout();
	$self->fill_probe_state($TIMEOUT_MESSAGE);
	return $self;
}

sub handle_failure
{
	my ($self, $stderr, $gritcher) = @_;

	$self->SUPER::handle_failure($stderr, $gritcher);
	$self->fill_probe_state($FAILURE_MESSAGE);

	my $truncatedStdErr = substr($stderr, 0, 1400);
	$gritcher->gritch("Probe ".$self->id." code failed: $truncatedStdErr",
			  "Probe ".$self->id." code caused a Perl error: $truncatedStdErr\n");
	return $self;
}

sub fill_probe_state
{
	my ($self, $message) = @_;

	my $state = ProbeState->newInitializedNamed($self->id);
	# Plugin will have left an accurate lastExecTime and 
	# lastLatency, but we need to update a few things to be
	# entirely accurate...
	$state->set_nextRunTime($self->time_to_execute);
	$state->set_lastStatusMessage($message);
	$state->set_lastStatus('UNKNOWN');
	$state->set_lastTranslatedStatus('UNKNOWN');

	# CRUCIAL to avoid stomping all over the state file!
	ProbeState->ReleaseInstances;
}
