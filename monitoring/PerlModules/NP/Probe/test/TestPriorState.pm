package NOCpulse::Probe::test::TestPriorState;

use strict;

use Error ':try';
use Time::HiRes qw(gettimeofday);
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::ItemStatus;
use NOCpulse::Probe::PriorState;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::Schedule;

use base qw(Test::Unit::TestCase);

sub set_up {
    NOCpulse::Probe::PriorState->instance->probe_state_directory('/tmp');
}

sub test_save_load {
    my $self = shift;

    my $probe_id = 10;

    my $prior_state = NOCpulse::Probe::PriorState->instance();
    my $filename = $prior_state->filename($probe_id);
    $self->assert(qr/tmp\/state.$probe_id/, $filename);
    my $arrayref = [qw(foo bar baz)];
    $prior_state->save([$arrayref], ["stuff"], $probe_id);

    my $read_back = $prior_state->load($probe_id);
    unlink $filename;

    $self->assert(defined($read_back), "No data read back");
    $self->assert(qr/ARRAY/, ref($read_back));
    $self->assert(scalar(@$read_back) == scalar(@$arrayref), 
                  "Wrong length: ", scalar(@{$read_back}), " instead of ", scalar(@$arrayref));
    for (my $i = 0; $i < @{$read_back}; ++$i) {
        $self->assert(qr/$arrayref->[$i]/, $read_back->[$i]);
    }
}

sub save_test_result {
    my ($self, $probe_id) = @_;

    my $prior_state = NOCpulse::Probe::PriorState->instance();
    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new({recid => $probe_id});
    my $cmd_rec = NOCpulse::Probe::Config::Command->new();
    my $result = NOCpulse::Probe::Result->new(probe_record  => $probe_rec,
                                             command_record => $cmd_rec);
    $result->item_ok      ('a', 1);
    $result->item_warning ('b', 2);
    $result->item_unknown ('c', 3);
    $result->item_critical('d', 4);

    my $memory = { foo => 'bar', baz => 'blat' };
    my $ts = [gettimeofday];
    my $schedule = NOCpulse::Probe::Schedule->new($result, $ts, $ts->[0]);
    $prior_state->save_result($memory, $schedule, $result);

    return ($memory, $schedule, $result);
}

sub test_save_results {
    my $self = shift;

    my $id = 20;

    $self->save_test_result($id);

    my $prior_state = NOCpulse::Probe::PriorState->instance();

    my $read_back = $prior_state->load($id);
    unlink $prior_state->filename($id);

    $self->assert(defined($read_back), "No data read back");
    $self->assert(qr/HASH/, ref($read_back));
    $self->assert(qr/HASH/, ref($read_back->{memory}));
    $self->assert(qr/NOCpulse::Probe::Schedule/, ref($read_back->{schedule}));
    $self->assert(qr/ARRAY/, ref($read_back->{items}));
    $self->assert(qr/HASH/, ref($read_back->{items}->[0]));
}

sub test_save_load_results {
    my $self = shift;

    my $id = 99;
    my ($memory, $schedule, $result) = $self->save_test_result($id);

    my $prior_state = NOCpulse::Probe::PriorState->instance();
    my ($new_memory, $new_schedule) = $prior_state->load_result($result);
    unlink $prior_state->filename($id);

    while (my ($key, $value) = each %$new_memory) {
        $self->assert($value eq $memory->{$key}, "No memory match for $key");
    }

    $self->assert($schedule->deep_equal($new_schedule), "Schedule mismatch");

    while (my ($name, $item) = each %{$result->prior_item_named}) {
        $self->assert($item->deep_equal($result->item_named($name)), "No item match for $name");
    }
}

sub test_load_bogus_results {
    my $self = shift;

    my $probe_id = 66;

    my $prior_state = NOCpulse::Probe::PriorState->instance();
    my $arrayref = [qw(foo bar baz)];
    $prior_state->save([$arrayref], ["stuff"], $probe_id);

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new({recid => $probe_id});
    my $cmd_rec = NOCpulse::Probe::Config::Command->new();
    my $result = NOCpulse::Probe::Result->new(probe_record  => $probe_rec,
                                             command_record => $cmd_rec);

    my $caught;
    try {
        my $stuff = $prior_state->load_result($result);
    } catch NOCpulse::Probe::Error with {
        $caught = shift;
    };
    $self->assert($caught, "Did not catch error with bogus file contents");
    unlink $prior_state->filename($probe_id);
}

sub test_iterator {
    my $self = shift;

    my $prior_state = NOCpulse::Probe::PriorState->instance();
    my $arrayref = [qw(foo bar baz)];

    my %found_ids = (int(rand 1000) => 'a', int(rand 1000) => 'b', int(rand 1000) => 'c');
    my @ids = keys %found_ids;
    foreach my $i (@ids) {
        $prior_state->save([$arrayref], ["stuff"], $i);
    }

    my $iter = $prior_state->iterator();
    while (my $id = $prior_state->next_id($iter)) {
        $self->assert(exists $found_ids{$id}, "Found unknown ID $id\n");
        $found_ids{$id} = 'FOUND';
    }
    my @not_found = grep !/^FOUND$/, values %found_ids;
    $self->assert(@not_found == 0, "Some state files not found: ", join(', ', @not_found));

    foreach my $i (@ids) {
        unlink $prior_state->filename($i);
    }
}

1;
