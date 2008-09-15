package NOCpulse::Probe::DataSource::test::TestSwapOutput;

use strict;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::DataSource::Factory;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new();
    $self->{factory}->canned(1);
}

sub test_swap {
    my $self = shift;

    my $linux = "
             total       used       free     shared    buffers     cached
Mem:        255920     247888       8032      68088       5216      42800
-/+ buffers/cache:     199872      56048
Swap:       136544      84496      52048
";
    my $bsd = "
Device          1K-blocks     Used    Avail Capacity  Type
/dev/ad0s1b       1048448      448  1048000     0%    Interleaved
/dev/ad0s2b           500      100      400     0%    Interleaved
";
    my $irix = "
total: 5.06m allocated + 28.37m add'l reserved = 33.43m bytes used, 153.81m bytes available
";
    my $solaris = "
total: 1059840k bytes allocated + 142792k reserved = 1202632k used, 2181928k available
";

    $self->{factory}->canned_results($linux, $bsd, $irix, $solaris);

    my $swap;
    my $os;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(
        { recid => 123, os_name => PROBE_LINUX() });
    my $data_source = $self->{factory}->unix_command(probe_record => $probe_rec);
    
    $os = LINUX;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $swap = $data_source->swap();
    $self->check_swap($swap, $os, 84496, 52048, 136544);

    $os = BSD;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $swap = $data_source->swap();
    $self->check_swap($swap, $os,
                      448 * 1024 + 100 * 1024,
                      1048000 * 1024 + 400 * 1024,
                      1048448 * 1024 + 500 * 1024);

    $os = IRIX;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $swap = $data_source->swap();
    $self->check_swap($swap, $os,
                      33.43  * 1024 * 1024,
                      153.81 * 1024 * 1024,
                      187.24 * 1024 * 1024);

    $os = SOLARIS;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $swap = $data_source->swap();
    $self->check_swap($swap, $os,
                      1202632 * 1024,
                      2181928 * 1024,
                      3384560 * 1024);
}

sub check_swap {
    my ($self, $swap, $os, $used, $free, $total) = @_;

    $self->assert($swap->found, "$os swap not found");
    $self->assert($swap->used == $used,
                  "$os mismatched used: ", $swap->used, " instead of ", $used);
    $self->assert($swap->free == $free,
                  "$os mismatched free: ", $swap->free, " instead of ", $free);
    $self->assert($swap->total == $total,
                  "$os mismatched total: ", $swap->total, " instead of ", $total);
}

1;
