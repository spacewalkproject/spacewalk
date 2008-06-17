package NOCpulse::Probe::test::TestSchedule;

use strict;

use Time::HiRes qw(gettimeofday tv_interval);
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::Schedule;

use base qw(Test::Unit::TestCase);

sub test_schedule {
    my $self = shift;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new
      ({recid => 88, 
        probe_type => 'HostProbe', 
        check_interval => 5,
        retry_interval => 5,
       });
    my $command = NOCpulse::Probe::Config::Command->new(command_id => 70);
    my $result = NOCpulse::Probe::Result->new(probe_record   => $probe_rec,
                                              command_record => $command);
    my $msg =  'foo are no good';
    $result->item_critical('foo', undef, message => $msg);
    $result->finish();

    my $start_timestamp = [gettimeofday];
    $start_timestamp->[0] -= 400;
    my $scheduled_start = $start_timestamp->[0] - 120;
    my $sched = NOCpulse::Probe::Schedule->new($result, $start_timestamp, $scheduled_start);

    $self->assert($sched->last_run_time == $start_timestamp->[0], "Start time mismatch");
    my $diff = $sched->next_run_time - $start_timestamp->[0];
    $self->assert($diff >= 300, "Next run mismatch: Diff $diff instead of 300");
    $self->assert($sched->latency == 120, "Latency not 120: ", $sched->latency);
    $self->assert(qr/CRITICAL/, $sched->raw_status);
    $self->assert(qr/DOWN/, $sched->status);
    $self->assert(qr/$msg/, $sched->status_message);
}

1;
