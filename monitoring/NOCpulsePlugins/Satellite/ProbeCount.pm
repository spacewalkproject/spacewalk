package Satellite::ProbeCount;

use strict;

use Storable;

use NOCpulse::Config;
use NOCpulse::NPRecords;

sub run {
    my %args = @_;

    my $result = $args{result};

    my $probe_count = ProbeRecord->InstanceCount();

    if ($probe_count == 0) {
        # Only happens running from the command line; the kernel
        # normally loads the file.
        my $hashRef = Storable::retrieve(NOCpulse::Config->new->get('netsaint',
                                                                    'probeRecordDatabase'));
        ProbeRecord->Absorb([values %{$hashRef}], 'RECID');
        $probe_count = ProbeRecord->InstanceCount();
    }

    $result->metric_value('probes', $probe_count, '%d');
}

1;
