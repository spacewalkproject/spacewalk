package NOCpulse::Probe::DataSource::test::TestNetstatOutput;

use strict;

use Data::Dumper;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Probe::Utils::IPAddressRange;
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::Config::ProbeRecord;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new();
    $self->{factory}->canned(1);
}

sub test_linux {
    my $self = shift;

    my $dummy_linux = 
"
tcp        0      0 192.168.0.72:4545       172.16.101.193:2967     TIME_WAIT   
lpqtcp        0      0 192.168.0.72:3541       10.255.254.42:1521      ESTABLISHED 
";

    my $real_linux = 
"
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 192.168.0.72:4545       172.16.101.193:2967     TIME_WAIT   
tcp        0      0 192.168.0.72:80         172.16.101.193:2944     TIME_WAIT   
tcp        0      1 127.0.0.1:4638          0.0.0.0:*               CLOSE       
tcp        0      1 127.0.0.1:4637          0.0.0.0:*               CLOSE       
lpqtcp        0      0 192.168.0.72:3541       10.255.254.42:1521      ESTABLISHED 
tcp        0      1 127.0.0.1:1214          0.0.0.0:*               CLOSE       
tcp        0      1 127.0.0.1:1213          0.0.0.0:*               CLOSE       
tcp        0      1 127.0.0.1:1193          0.0.0.0:*               CLOSE       
tcp        0      1 127.0.0.1:1192          0.0.0.0:*               CLOSE       
tcp        0      1 127.0.0.1:1167          0.0.0.0:*               CLOSE       
tcp        0      1 127.0.0.1:1166          0.0.0.0:*               CLOSE       
tcp        0      1 127.0.0.1:1159          0.0.0.0:*               CLOSE       
tcp        0      1 127.0.0.1:1158          0.0.0.0:*               CLOSE       
tcp        0      0 192.168.0.72:3179       172.16.101.101:22       ESTABLISHED 
tcp        0      0 192.168.0.72:1772       192.168.0.111:1521      ESTABLISHED 
tcp        0      0 192.168.0.72:4185       10.255.254.42:1521      ESTABLISHED 
tcp        0      0 192.168.0.72:2920       172.16.101.193:22       ESTABLISHED 
tcp        0      0 192.168.0.72:2903       172.16.101.193:22       ESTABLISHED 
tcp        0      0 192.168.0.72:1260       192.168.11.43:1521      ESTABLISHED 
tcp        0      0 192.168.0.72:4752       192.168.0.111:1521      ESTABLISHED 
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      
tcp        0      0 192.168.0.72:1442       172.16.101.193:22       ESTABLISHED 
tcp        0      0 192.168.0.72:1441       172.16.101.193:22       ESTABLISHED 
tcp        0      0 192.168.0.72:6000       192.168.0.60:32784      ESTABLISHED 
tcp        0      0 0.0.0.0:1026            0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:1025            0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:6000            0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:4545            0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:788             0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:515             0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:21              0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:113             0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:958             0.0.0.0:*               LISTEN      
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      
";
    $self->{factory}->canned_results($dummy_linux, $real_linux);

    my $netstat;
    my @entries;
    my $entry;
    my @filtered;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(
        { recid => 123, os_name => PROBE_LINUX() });
    my $data_source = $self->{factory}->unix_command(probe_record => $probe_rec);

    $data_source->shell_os_name(LINUX);
    $netstat = $data_source->netstat_tcp();
    @entries = @{$netstat->entries};
    $self->assert(scalar(@entries) == 2, "Wrong entry count: ", scalar(@entries));
    $entry = @entries[0];
    $self->assert(qr/192\.168\.0\.72/, $entry->local_ip->ip);
    $self->assert(qr/4545/, $entry->local_port);
    $self->assert(qr/172\.16\.101\.193/, $entry->remote_ip->ip);
    $self->assert(qr/2967/, $entry->remote_port);
    $self->assert(qr/TIME_WAIT/, $entry->state);

    $entry = @entries[1];
    $self->assert(qr/192\.168\.0\.72/, $entry->local_ip->ip);
    $self->assert(qr/3541/, $entry->local_port);
    $self->assert(qr/10\.255\.254\.42/, $entry->remote_ip->ip);
    $self->assert(qr/1521/, $entry->remote_port);
    $self->assert(qr/ESTABLISHED/, $entry->state);

    $netstat = $data_source->netstat_tcp();
    foreach my $entry ($netstat->entries) {
        $self->assert($entry->local_ip, "No local IP");
    }
}

sub test_solaris {
    my $self = shift;

    my $dummy_solaris = 
"      *.22                 *.*                0      0 24576      0 LISTEN
192.168.0.60.22      192.168.0.127.1063   16445      0 24820      0 ESTABLISHED
";

    my $real_solaris = 
"TCP: IPv4
   Local Address        Remote Address    Swind Send-Q Rwind Recv-Q  State
-------------------- -------------------- ----- ------ ----- ------ -------
      *.*                  *.*                0      0 24576      0 IDLE
      *.22                 *.*                0      0 24576      0 LISTEN
      *.22                 *.*                0      0 24576      0 LISTEN
192.168.0.60.22      192.168.0.127.1063   16445      0 24820      0 ESTABLISHED
192.168.0.60.80      172.16.100.54.3396   31856      0 24616      0 TIME_WAIT
192.168.0.60.8070    192.168.0.96.37249   34368      0 24616      0 TIME_WAIT
192.168.0.60.4545    172.16.100.54.3402   31856      0 24616      0 TIME_WAIT
192.168.0.60.8070    192.168.0.96.37250   14480      0 24616      0 TIME_WAIT
192.168.0.60.8070    192.168.0.96.37251   11584      0 24616      0 TIME_WAIT
192.168.0.60.80      172.16.100.18.35431   5840      0 24616      0 TIME_WAIT
192.168.0.60.80      172.16.100.18.35432   5840      0 24616      0 TIME_WAIT
192.168.0.60.80      172.16.100.18.35433   5840      0 24616      0 TIME_WAIT
      *.*                  *.*                0      0 24576      0 IDLE

TCP: IPv6
   Local Address                     Remote Address                 Swind Send-Q Rwind Recv-Q   State      If 
--------------------------------- --------------------------------- ----- ------ ----- ------ ----------- -----
      *.*                               *.*                             0      0 24576      0 IDLE             
      *.22                              *.*                             0      0 24576      0 LISTEN           
      *.30                              *.*                             0      0 24576      0 LISTEN           
      *.25                              *.*                             0      0 24576      0 LISTEN           

Active UNIX domain sockets
Address  Type          Vnode     Conn  Local Addr      Remote Addr
3000623d0f0 stream-ord 00000000 00000000                               
3000623d2a0 stream-ord 00000000 00000000                               
300016fe008 stream-ord 00000000 00000000                 (socketpair)  
300016fe878 stream-ord 00000000 00000000                 (socketpair)  
300016ff7a8 stream-ord 300016e70b8 00000000 /tmp/.X11-unix/X1                
";

    $self->{factory}->canned_results($dummy_solaris, $real_solaris);

    my $netstat;
    my @entries;
    my $entry;
    my @filtered;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(
        { recid => 123, os_name => PROBE_LINUX() });
    my $data_source = $self->{factory}->unix_command(probe_record => $probe_rec);

    $probe_rec->os_name(PROBE_SOLARIS);
    $data_source->shell_os_name(SOLARIS);
    $netstat = $data_source->netstat_tcp();

    @entries = @{$netstat->entries};
    $self->assert(scalar(@entries) == 2, "Wrong entry count: ", scalar(@entries));

    $entry = @entries[0];
    $self->assert(qr/\*\.22\.\*\.\*/, $entry->local_ip->ip);
    $self->assert(!defined($entry->local_port), "Local port defined: ", $entry->local_port);
    $self->assert(qr/\*\.\*\.\*\.\*/, $entry->remote_ip->ip);
    $self->assert(!defined($entry->remote_port), "Remote port defined: ", $entry->remote_port);
    $self->assert(qr/LISTEN/, $entry->state);

    $entry = @entries[1];
    $self->assert(qr/192\.168\.0\.60/, $entry->local_ip->ip);
    $self->assert(qr/22/, $entry->local_port);
    $self->assert(qr/192\.168\.0\.127/, $entry->remote_ip->ip);
    $self->assert(qr/1063/, $entry->remote_port);
    $self->assert(qr/ESTABLISHED/, $entry->state);

    $netstat = $data_source->netstat_tcp();

    my $lip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => '192.168.0.60');

    @filtered = $netstat->filtered_entries(undef, [$lip], undef, undef);
    $self->assert(scalar(@filtered) == 9, "Filter by local IP not 9: ", scalar(@filtered));

    @filtered = $netstat->filtered_entries(8070, [$lip], undef, undef);
    $self->assert(scalar(@filtered) == 3, "Filter by local IP/port not 3: ", scalar(@filtered));

    @filtered = $netstat->filtered_entries(4545, [$lip], undef, undef);
    $self->assert(scalar(@filtered) == 1, "Filter by local IP/port not 1: ", scalar(@filtered));

    my $rip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => '172.16.100.18');

    @filtered = $netstat->filtered_entries(undef, undef, undef, [$rip]);
    $self->assert(scalar(@filtered) == 3, "Filter by remote IP not 3: ", scalar(@filtered));

    @filtered = $netstat->filtered_entries(undef, undef, 35431, [$rip]);
    $self->assert(scalar(@filtered) == 1, "Filter by remote IP/port not 1: ", scalar(@filtered));

    @filtered = $netstat->filtered_entries(80, [$lip], 35431, [$rip]);
    $self->assert(scalar(@filtered) == 1, "Filter by local and remote IP/port not 1: ",
                  scalar(@filtered));
}

1;
