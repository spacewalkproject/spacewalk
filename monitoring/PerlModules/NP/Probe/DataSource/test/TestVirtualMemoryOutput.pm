package NOCpulse::Probe::DataSource::test::TestVirtualMemoryOutput;

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

sub test_virtual {
    my $self = shift;

    my $linux =
"             total       used       free     shared    buffers     cached
Mem:        255920     247888       8032      68088       5216      42800
-/+ buffers/cache:     199872      56048
Swap:       136544      84496      52048
Total:      392464     332756      59708
";
    my $irix_1 = 
" # path       pri    pswap     free  maxswap    vswap
 1 /dev/swap    0  128.00m  122.94m  128.00m    0.00k
";
    my $irix_2 = 
"Main memory size: 64 Mbytes
";
    my $irix_3 = 
"# irix.nocpulse.net load avg: 0.20, interval: 1 sec, Mon Jun 17 14:53:46 2002
 queue |      memory |     system       |  disks  |      cpu
run swp|    free page| scall ctxsw  intr|  rd   wr|usr sys idl  wt
  1   0    37888    0    218    69  1214    0    1  34   1  65   0
";
    my $solaris_1 = 
"        # swapfile             dev  swaplo blocks   free
        # /dev/dsk/c0t0d0s1   32,1      16 2101536 2101536
        # /dev/dsk/c0t1d0s1   32,9      16 2101536 2099488
";
    my $solaris_2 =
"Memory size: 1024 Megabytes
";
    my $solaris_3 =
" procs     memory            page            disk          faults      cpu
 r b w   swap  free  re  mf pi po fr de sr m1 m1 m1 m3   in   sy   cs us sy id
 0 0 0 2420216 420488 32 288 21 0  0  0  0  2  1  1  0  372  696  187  7  5 88
 0 0 0 2310176 323736 0   5  0  0  0  0  0  0  0  0  0  358  547  210 31  1 68
";

    $self->{factory}->canned_results($linux,
                                     $irix_1, $irix_2, $irix_3,
                                     $solaris_1, $solaris_2, $solaris_3);

    my $virtual;
    my $os;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(
        { recid => 123, os_name => PROBE_LINUX() });
    my $data_source = $self->{factory}->unix_command(probe_record => $probe_rec);
    
    $os = LINUX;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $virtual = $data_source->virtual_memory();
    $self->check_virtual($virtual, $os, 332756, 59708, 392464);

    $os = IRIX;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $virtual = $data_source->virtual_memory();
    # Total: (64 * 1024) + (128 * 1024)) = 196608
    # Free: (122.94 * 1024.0) + 37888 = 163778.56
    $self->check_virtual($virtual, $os, 32829.44, 163778.56, 196608);

    $os = SOLARIS;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $virtual = $data_source->virtual_memory();
    # Total: (1024 * 1024) + (2101536.0 / 2.0) + (2101536.0 / 2.0) = 3150112
    # Free: (2101536.0 / 2.0) + (2099488.0 / 2.0) + 323736 = 2424248
    $self->check_virtual($virtual, $os, 725864, 2424248, 3150112);
}

sub check_virtual {
    my ($self, $virtual, $os, $used, $free, $total) = @_;

    $self->assert($virtual->found, "$os virtual memory not found");
    $self->assert($virtual->used == $used,
                  "$os mismatched used: ", $virtual->used, " instead of ", $used);
    $self->assert($virtual->free == $free,
                  "$os mismatched free: ", $virtual->free, " instead of ", $free);
    $self->assert($virtual->total == $total,
                  "$os mismatched total: ", $virtual->total, " instead of ", $total);
}

1;
