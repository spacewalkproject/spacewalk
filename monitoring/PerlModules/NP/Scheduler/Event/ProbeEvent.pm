package NOCpulse::Scheduler::Event::ProbeEvent;

use strict;

use NOCpulse::Scheduler::Event;
use vars qw(@ISA);
@ISA = qw(NOCpulse::Scheduler::Event);

use Error;
use NOCpulse::NPRecords;
use NOCpulse::Probe::MessageCatalog;
use NOCpulse::Log::LogManager;
use NOCpulse::Probe::Schedule;
use NOCpulse::Probe::ProbeRunner;
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::PriorState;

sub perl_module { shift->_elem('perl_module', @_); }

sub run {
    my $self = shift;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(ProbeRecord->Called($self->id));
    my $runner = NOCpulse::Probe::ProbeRunner->new($probe_rec, undef, $self->perl_module);

    my $logmgr = NOCpulse::Log::LogManager->instance();
    if ($logmgr->level('NOCpulse::Dispatcher::Kernel') >= 2) {
        $logmgr->ensure_level(ref($runner), 1)
    }

    my $schedule = $runner->run();

    $self->time_to_execute($schedule->next_run_time);

    return $self;
}

sub handle_timeout
{
    my $self = shift();
    $self->SUPER::handle_timeout();
    $self->fill_probe_state(NOCpulse::Probe::MessageCatalog->instance->event('timed_out'));
    return $self;
}

sub handle_failure
{
    my ($self, $stderr, $gritcher) = @_;

    $self->SUPER::handle_failure($stderr, $gritcher);
    $self->fill_probe_state(NOCpulse::Probe::MessageCatalog->instance->event('failed'));

    my $truncatedStdErr = substr($stderr, 0, 1400);
    $gritcher->gritch("Probe ".$self->id." code failed: $truncatedStdErr",
                      "Probe ".$self->id." code caused a Perl error: $truncatedStdErr\n");
    return $self;
}

sub fill_probe_state {
    my ($self, $message) = @_;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(ProbeRecord->Called($self->id));
    my $result = NOCpulse::Probe::Result->new(probe_record => $probe_rec);

    my $prior_state = NOCpulse::Probe::PriorState->instance();
    my ($memory, $schedule) = $prior_state->load_result($result);

    # Not everybody has a prior state (e.g. failure on first execution)
    if ($schedule) {
      $schedule->next_run_time($self->time_to_execute);
      $schedule->status_message($message);
      $schedule->status($result->UNKNOWN);
      $schedule->raw_status($result->UNKNOWN);

      $prior_state->save_result($memory, $schedule, $result);
    }
}

1;

__END__
