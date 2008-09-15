package NOCpulse::Probe::test::TestTransaction;

use strict;

use NOCpulse::Config;
use NOCpulse::Debug;
use NOCpulse::Gritch;
use NOCpulse::NotificationQueue;
use NOCpulse::StateChange;
use NOCpulse::StateChangeQueue;
use NOCpulse::TimeSeriesQueue;
use NOCpulse::Probe::Transaction;
use NOCpulse::Probe::Result;

use base qw(Test::Unit::TestCase);

my $GROUP_ID   = 13040;
my $GROUP_NAME = 'rmcchesney-email';
my $CUST_ID    = 30;
my $PROBE_ID   = 10;

sub dummy_queue_dir {
    my ($self, $queue) = @_;

    $queue->directory('/tmp/TESTQUEUE-'.$queue->id);
    mkdir $queue->directory, 0777;
    $self->{$queue->id} = $queue;
}

sub tear_down {
    my $self = shift;

    foreach my $q (qw(notif sc_db ts_db)) {
        next unless exists $self->{$q};
        unlink $self->{$q}->filename;
        unlink $self->{$q}->filename.'.lock';
        rmdir  $self->{$q}->directory;
    }
}

sub test_notify {
    my $self = shift;

    my $result = $self->result();
    $result->finish();
    my $trans = NOCpulse::Probe::Transaction->new();
    $trans->prepare_notification($result);
    $self->dummy_queue_dir($trans->notification_queue);
    $trans->commit($result);

    my ($hydrated, $dehydrated_keys) = $self->{notif}->entries();
    $self->assert(@$hydrated == 1, "More than one entry: ", join(', ', @$hydrated));
    my $entry = $hydrated->[0];
    $self->assert(qr/Notification/, ref($entry));
    $self->assert(qr/$CUST_ID/,    $entry->customerId);
    $self->assert(qr/$GROUP_ID/,   $entry->groupId);
    $self->assert(qr/$GROUP_NAME/, $entry->groupName);
}

sub test_state_change {
    my $self = shift;

    my $result = $self->result();
    my $trans = NOCpulse::Probe::Transaction->new();
    my $msg = "Weather's here, wish you were beautiful";
    $result->detail_text($msg);
    $result->finish();
    $trans->prepare_state_change($result);
    $self->dummy_queue_dir($trans->state_change_queue);
    $trans->commit($result);

    my ($hydrated, $dehydrated_keys) = $self->{sc_db}->entries();
    $self->assert(@$hydrated == 1, "More than one entry: ", join(', ', @$hydrated));
    my $entry = $hydrated->[0];
    $self->assert(qr/StateChange/, ref($entry));
    $self->assert(qr/$msg/, $entry->desc);
    $self->assert(qr/OK/,   $entry->state);
}

sub test_time_series {
    my $self = shift;

    my $result = $self->result();
    my $trans = NOCpulse::Probe::Transaction->new();
    my @n = qw(a b c);
    my @v = qw(100 200 300);
    foreach my $i (0..2) {
        $result->metric_value($n[$i], $v[$i]);
    }
    $result->finish();
    $trans->prepare_time_series($result);
    $self->dummy_queue_dir($trans->time_series_queue);
    $trans->commit($result);

    my ($hydrated, $dehydrated_keys) = $self->{ts_db}->entries();
    $self->assert(@$hydrated == 3, "Expecting three entries, got ", join(', ', @$hydrated));
    my $i = 0;
    foreach my $entry (sort { $a->oid cmp $b->oid } @$hydrated) {
        $self->assert(qr/TimeSeriesDatapoint/, ref($entry));
        $self->assert(qr/$CUST_ID-$PROBE_ID-$n[$i]/, $entry->oid);
        $self->assert(qr/$v[$i]/, $entry->v);
        $i++;
    }
}

sub result {
    my $self = shift;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new
      ({recid               => $PROBE_ID, 
        probe_type          => 'ServiceProbe',
        customer_id         => $CUST_ID,
        contact_groups      => [ $GROUP_ID ],
        contact_group_names => [ $GROUP_NAME ],
       });
    my %metrics =
      (
       a => NOCpulse::Probe::Config::CommandMetric->new(command_class => 'module',
                                                        metric_id => 'a'),
       b => NOCpulse::Probe::Config::CommandMetric->new(command_class => 'module',
                                                        metric_id => 'b'),
       c => NOCpulse::Probe::Config::CommandMetric->new(command_class => 'module',
                                                        metric_id => 'c'),
       );

    my $command = NOCpulse::Probe::Config::Command->new(command_id => 70, metrics => \%metrics);
    my $result = NOCpulse::Probe::Result->new(probe_record   => $probe_rec,
                                              command_record => $command);
    return $result;
}

1;
