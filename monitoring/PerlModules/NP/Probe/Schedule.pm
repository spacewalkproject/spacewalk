package NOCpulse::Probe::Schedule;

use strict;

use Time::HiRes qw(gettimeofday tv_interval);
use POSIX qw(strftime);
use NOCpulse::Log::Logger;
use NOCpulse::Probe::ItemStatus;

use Class::MethodMaker
  get_set => 
  [qw(
      probe_id
      last_run_time
      next_run_time
      last_run_duration
      latency
      raw_status
      status
      status_message
      last_status_change
     )],
  new_with_init => 'new',
;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


sub init {
    my ($self, $result, $start_timestamp, $scheduled_start_time) = @_;

    $self->probe_id($result->probe_record->recid);

    $self->raw_status($result->overall_status());
    $self->status($result->translated_host_status());
    $self->status_message($result->detail_text);

    $result->status_changed() and $self->last_status_change($start_timestamp->[0]);

    $self->last_run_time($start_timestamp->[0]);

    $self->latency($start_timestamp->[0] - $scheduled_start_time);
    $self->latency(0) if $self->latency < 0;

    my $now = time();
    my $run_after_minutes = $result->probe_record->check_interval;
    if ($self->raw_status ne NOCpulse::Probe::ItemStatus::OK) {
        $run_after_minutes = $result->probe_record->retry_interval;
    }

    $self->next_run_time($now + ($run_after_minutes * 60));

    my $stop_timestamp = [gettimeofday];
    $self->last_run_duration(tv_interval($start_timestamp, $stop_timestamp));

    $Log->log(2, '', $self->to_string(), "\n");
}

sub to_string {
    my $self = shift;

    my $fmt = '%a %b %d %y %H:%M:%S';

    my @msg = ();
    push(@msg, "Status      '" . $self->status . "'");
    push(@msg, "Raw status  '" . $self->raw_status . "'");
    push(@msg, "Message     '" . $self->status_message . "'");
    push(@msg, "Last run    " . strftime($fmt, gmtime $self->last_run_time));
    push(@msg, "Next run    " . strftime($fmt, gmtime $self->next_run_time));
    push(@msg, "Run took    " . $self->last_run_duration . ' seconds');
    push(@msg, "Latency     " . $self->latency . ' seconds');

    return "\n\t" . join("\n\t", @msg);
}

sub deep_equal {
    my ($self, $other) = @_;

    return $self->raw_status eq $other->raw_status
      and $self->status eq $other->status
      and $self->status_message eq $other->status_message
      and $self->last_run_time == $other->last_run_time
      and $self->last_run_duration == $other->last_run_duration
      and $self->latency == $other->latency;
}

1;

__END__
