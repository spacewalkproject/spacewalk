package NOCpulse::Probe::Config::test::TestProbeRecord;

use strict;
use NOCpulse::Config;
use Storable;
use NOCpulse::Probe::Config::ProbeRecord;

use base qw(Test::Unit::TestCase);

sub load {
    my $self = shift;
    my $config = NOCpulse::Config->new();
    my $file = $config->get('netsaint', 'probeRecordDatabase');
    return Storable::retrieve($file);
}

sub test_init {
    my $self = shift;

    my $probe_rec_hash = $self->load();

    $self->assert(defined($probe_rec_hash) && scalar(keys %$probe_rec_hash) > 0, 'No probe records');

    foreach my $probe_rec (values %$probe_rec_hash) {
        my $probe = NOCpulse::Probe::Config::ProbeRecord->new($probe_rec);
        $self->assert(qr/$probe_rec->{RECID}/, $probe->recid);
        last;
    }
}

1;
