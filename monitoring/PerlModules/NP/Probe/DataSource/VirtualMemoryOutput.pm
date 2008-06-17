package NOCpulse::Probe::DataSource::VirtualMemoryOutput;

use strict;

use NOCpulse::Probe::Config::UnixOS ':constants';
use NOCpulse::Log::Logger;

use Class::MethodMaker
  get_set =>
  [qw(
      found
      used
      free
      total
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub linux {
    my ($self, $unix_command) = @_;

    my $binary = '/usr/bin/free';
    $unix_command->ensure_program_installed($binary);
    $unix_command->execute("$binary -t");

    my @lines = split(/\n/, $unix_command->results);
    foreach my $line (@lines) {
        #              total       used       free     shared    buffers     cached
        # Mem:        255920     242120      13800      81288       5272      46168
        # -/+ buffers/cache:     190680      65240
        # Swap:       136544      90636      45908
        # Total:      392464     332756      59708
        if ($line =~ /^Total:\s+(\d+)\s+(\d+)\s+(\d+)$/) {
            $self->total($1);
            $self->used($2);
            $self->free($3);
            $self->found(1);
        }
    }
}

sub solaris {            
    my ($self, $unix_command) = @_;

    my @lines;

    my $binary = '/usr/sbin/swap';
    $unix_command->ensure_program_installed($binary);
    $unix_command->execute("$binary -l");

    @lines = split(/\n/, $unix_command->results);

    my ($swap_total_kb, $swap_free_kb);
    foreach my $line (@lines) {
        # swapfile             dev  swaplo blocks   free
        # /dev/dsk/c0t0d0s1   32,1      16 2101536 2101536
        # /dev/dsk/c0t1d0s1   32,9      16 2101536 2099488
        if ($line =~ /\S+\s+\d+,\d+\s+\d+\s+(\d+)\s+(\d+)/) {
            $swap_total_kb += $1 / 2;
            $swap_free_kb  += $2 / 2;
        }
    }
    if ($swap_total_kb > 0) {
        my $physical_total_kb = $unix_command->physical_memory_kb();
        if ($physical_total_kb) {
            my $binary = '/bin/vmstat';
            $unix_command->ensure_program_installed($binary);
            $unix_command->execute("$binary 1 2");

            @lines = split(/\n/, $unix_command->results);
            # procs     memory            page            disk          faults      cpu
            # r b w   swap  free  re  mf pi po fr de sr m1 m1 m1 m3   in   sy   cs us sy id
            # 0 0 0 2420240 420512 32 288 21 0  0  0  0  2  1  1  0  372  696  187  7  5 88
            # 0 0 0 2440368 430240 0   5  0  0  0  0  0  0  0  0  0  312  298  161  2  0 98
            if ($lines[3] =~ /^\s\d+\s\d+\s\d+\s(\d+)\s+(\d+)/) {
                my $avail_swap_kb = $1;
                my $free_list_kb = $2;
                $self->total($physical_total_kb + $swap_total_kb);
                $self->free($swap_free_kb + $free_list_kb);
                $self->used($self->total - $self->free);
                $self->found(1);
            }
        }
    }
}

sub irix {            
    my ($self, $unix_command) = @_;

    my @lines;

    my $binary = '/sbin/swap';
    $unix_command->ensure_program_installed($binary);
    $unix_command->execute("$binary -ln");

    @lines = split(/\n/, $unix_command->results);

    my ($swap_total_kb, $swap_free_kb);
    foreach my $line (@lines) {
        # # path       pri    pswap     free  maxswap    vswap
        # 1 /dev/swap    0  128.00m  122.94m  128.00m    0.00k
        if ($line =~ /\s+\d+\s+\S+\s+\d+\s+([\d.]+)(\w)\s+([\d.]+)(\w)/) {
            $swap_total_kb = convert_to_kb($1, $2);
            $swap_free_kb  = convert_to_kb($3, $4);
        }
    }
    if ($swap_total_kb > 0) {
        my $physical_total_kb = $unix_command->physical_memory_kb();
        if ($physical_total_kb) {
            my $binary = '/usr/sbin/pmkstat';
            $unix_command->ensure_program_installed($binary);
            $unix_command->execute("$binary -s1 -t1");

            @lines = split(/\n/, $unix_command->results);
            # # irix.nocpulse.net load avg: 0.02, interval: 1 sec, Mon Jun 17 15:05:26 2002
            #  queue |      memory |     system       |  disks  |      cpu
            # run swp|    free page| scall ctxsw  intr|  rd   wr|usr sys idl  wt
            #   0   0    37896    0     17     5  1183    0    0   0   1  99   0
            if ($lines[3] =~ /^\s+\d+\s+\d+\s+(\d+)/) {
                my $free_list_kb = $1;
                $self->total($physical_total_kb + $swap_total_kb);
                $self->free($swap_free_kb + $free_list_kb);
                $self->used($self->total - $self->free);
                $self->found(1);
            }
        }
    }
}

sub init {
    my ($self, $unix_command, $shell_os_name) = @_;

    $self->found(0);

    my %os_command = (LINUX()   => \&linux, 
                      SOLARIS() => \&solaris, 
                      IRIX()    => \&irix,
                      IRIX64()  => \&irix);
    my $sub = $os_command{$shell_os_name};
    if ($sub) {
        &$sub($self, $unix_command);
    } else {
        $unix_command->unsupported_os();
    }
}

sub convert_to_kb {
    my ($value, $units) = @_;

    if ($units eq 'm') {
        $value *= 1024;
    } elsif ($units eq 'k') {
        # OK as is
    } else {
        $value /= 1024;
    }
    return $value;
}

1;
