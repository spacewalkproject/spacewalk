package NOCpulse::Probe::DataSource::test::TestUnixHelpers;

use strict;

use Data::Dumper;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Probe::DataSource::UnixCommand;
use NOCpulse::Probe::DataSource::CannedUnixCommand;
use NOCpulse::Probe::DataSource::DfOutput;
use NOCpulse::Probe::DataSource::IostatOutput;
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::Config::ProbeRecord;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new();
    $self->{factory}->canned(1);
}

sub test_df {
    my $self = shift;
    my $run1 = 
"Filesystem           1k-blocks      Used Available Use% Mounted on
/dev/md0               2063440    295048   1663576  15% /
/dev/md1               4688332    173400   4276776   4% /home
";
    my $run2 = 
"Filesystem            kbytes    used   avail capacity  Mounted on
/dev/md/dsk/d10      2056211  387786 1606739    20%    /
/dev/md/dsk/d60      4131866 1044394 3046154    26%    /usr
/proc                      0       0       0     0%    /proc
fd                         0       0       0     0%    /dev/fd
mnttab                     0       0       0     0%    /etc/mnttab
/dev/md/dsk/d30       248287    9607  213852     5%    /var
swap                 2303120      24 2303096     1%    /var/run
swap                 2304016     920 2303096     1%    /tmp
/dev/md/dsk/d50      9912728 6658213 3155388    68%    /export
canyon:/u1/oracle/product
                     249292492 130330640 118961852    53%    /ora_product
canyon:/u1/eng       249292492 130330640 118961852    53%    /mnt/canyon_eng
";
    # Irix style
    my $run3 = 
"/dev/md0      ext2     2063440    294008   1664616  15% /foo
";

    # HP-UX style
    my $run4 =
"Filesystem          1024-blocks  Used  Available Capacity Mounted on
/dev/vg00/lvol5       24416     2280    22136    10%   /home
/dev/vg00/lvol6       1420736   819728   601008    58%   /opt
/dev/vg00/lvol4       203424    12152   191272     6%   /tmp
/dev/vg00/lvol7       2229008  1285104   943904    58%   /usr
/dev/vg00/lvol8       4676696   395496  4281200     9%   /var
/dev/vg00/lvol1       269032    18528   250504     7%   /stand
/dev/vg00/lvol3       203768    68712   135056    34%   /
";


    $self->{factory}->canned_results($run1, $run2, $run3, $run4);

    my $data_source = $self->{factory}->unix_command();

    my $df_output;
    my $fs;
    my $df;

    $df_output = $data_source->df();

    $fs = '/dev/md0';
    $df = $df_output->for_filesystem($fs);
    $self->assert(defined($df), "df(1) did not parse $fs: ",
                  join(', ', $df_output->for_filesystem_keys));
    $self->assert(qr/^2063440$/, $df->blocks);
    $self->assert(qr/^295048$/, $df->used);
    $self->assert(qr/^1663576$/, $df->available);
    $self->assert(qr/^15$/, $df->percent_used);
    $self->assert(qr/^\/$/, $df->mount_point);

    $df->convert_to_megabytes();
    $self->assert(qr/^295$/, $df->used);
    $self->assert(qr/^1663$/, $df->available);

    $fs = '/dev/md1';
    $df = $df_output->for_filesystem($fs);
    $self->assert(defined($df), "df(1) did not parse $fs: ",
                  join(', ', $df_output->for_filesystem_keys));
    $self->assert(qr/^4688332$/, $df->blocks);
    $self->assert(qr/^173400$/, $df->used);
    $self->assert(qr/^4276776$/, $df->available);
    $self->assert(qr/^4$/, $df->percent_used);
    $self->assert(qr/^\/home$/, $df->mount_point);


    $df_output = $data_source->df();

    $fs = 'canyon:/u1/oracle/product';
    $df = $df_output->for_filesystem($fs);
    $self->assert(defined($df), "df(2) did not parse $fs: ",
                  join(', ', $df_output->for_filesystem_keys));
    my $mount = $df->mount_point;
    $self->assert(qr/^\/ora_product$/, $df->mount_point);

    $fs = 'canyon:/u1/oracle/product';
    $df = $df_output->for_filesystem($fs);
    $self->assert(defined($df), "df(2) did not parse $fs: ",
                  join(', ', $df_output->for_filesystem_keys));
    $self->assert(qr/^249292492$/, $df->blocks);
    $self->assert(qr/^130330640$/, $df->used);
    $self->assert(qr/^118961852$/, $df->available);
    $self->assert(qr/^53$/, $df->percent_used);
    $self->assert(qr/^\/ora_product$/, $df->mount_point);


    $df_output = $data_source->df();

    $fs = '/dev/md0';
    $df = $df_output->for_filesystem($fs);
    $self->assert(defined($df), "df(3) did not parse $fs: ",
                  join(', ', $df_output->for_filesystem_keys));
    $self->assert(qr/^2063440$/, $df->blocks);
    $self->assert(qr/^294008$/, $df->used);
    $self->assert(qr/^1664616$/, $df->available);
    $self->assert(qr/^15$/, $df->percent_used);
    $self->assert(qr/^\/foo$/, $df->mount_point);

    $df_output = $data_source->df();

    $fs = '/dev/vg00/lvol5';
    $df = $df_output->for_filesystem($fs);
    $self->assert(defined($df), "df(4) did not parse $fs: ",
                  join(', ', $df_output->for_filesystem_keys));
    $self->assert(qr/^24416$/, $df->blocks);
    $self->assert(qr/^2280$/, $df->used);
    $self->assert(qr/^22136$/, $df->available);
    $self->assert(qr/^10$/, $df->percent_used);
    $self->assert(qr/^\/home$/, $df->mount_point);

}

sub test_inodes {
    my $self = shift;
    my $linux = 
"Filesystem            Inodes   IUsed   IFree IUse% Mounted on
/dev/hda3             193152   76367  116785   40% /
";
    my $solaris = 
"Filesystem             iused   ifree  %iused  Mounted on
/dev/md/dsk/d10        37848  300648    11%   /
";
    my $bsd = 
"Filesystem   512-blocks     Used    Avail Capacity iused   ifree  %iused  Mounted on
/dev/ad0s1a    17393808  1227178 14775126     8%   86762 2087700     4%   /
";
    my $irix =
"Filesystem             Type  blocks     use     avail  %use   iuse  ifree %iuse  Mounted
/dev/root               xfs  3921816  3875136    46680  99   56533   94235  38   /
";
    my $msg = 'Command failed with status 1: /bin/df: asdf: No such file or directory';

    $self->{factory}->canned_results( $linux, undef, $solaris, $bsd, $irix);
    $self->{factory}->canned_statuses(0,      1,     0,        0,    0);
    $self->{factory}->canned_errors(  undef,  $msg,  undef,   undef, undef);
    
    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(
        { recid => 123, os_name => PROBE_LINUX() });
    my $data_source = $self->{factory}->unix_command(probe_record => $probe_rec);
    my $os;

    $os = LINUX;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $self->check_inodes($os, $data_source->inodes('/'), 76367, 116785, 193152);

    my $ret = $data_source->inodes('asdf');
    $self->assert(!$ret, "Got a result for bogus fs: $ret");
    $self->assert($data_source->command_status ==1, "Status not one: ",
                  $data_source->command_status);
    $self->assert($data_source->errors, "No errors");
    $self->assert(!$data_source->results, "Have results");

    $os = SOLARIS;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $self->check_inodes($os, $data_source->inodes('/'), 37848, 300648, 338496);

    $os = BSD;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $self->check_inodes($os, $data_source->inodes('/'), 86762, 2087700, 2174462);

    $os = IRIX;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);
    $self->check_inodes($os, $data_source->inodes('/'), 56533, 94235, 150768);
}

sub check_inodes {
    my ($self, $os, $used, $free, $total, $exp_used, $exp_free, $exp_total)  = @_;
    $self->assert($used == $exp_used, "$os used mismatch: got $used, expected $exp_used");
    $self->assert($free == $exp_free, "$os free mismatch: got $free, expected $exp_free");
    $self->assert($total == $exp_total, "$os total mismatch: got $total, expected $exp_total");
}

sub test_ping {
    my $self = shift;

    my $run1 = 
"PING spinner.nocpulse.net (192.168.0.60) from 192.168.0.72 : 56(84) bytes of data.
64 bytes from 192.168.0.60: icmp_seq=0 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=1 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=2 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=3 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=4 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=5 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=6 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=7 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=8 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=9 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=10 ttl=255 time=0.4 ms

--- spinner.nocpulse.net ping statistics ---
11 packets transmitted, 11 packets received, 0% packet loss
round-trip min/avg/max = 0.4/0.4/0.5 ms
";

    my $run2 = 
"PING spinner.nocpulse.net (192.168.0.60) from 192.168.0.72 : 56(84) bytes of data.
64 bytes from 192.168.0.60: icmp_seq=0 ttl=255 time=100 ms
64 bytes from 192.168.0.60: icmp_seq=1 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=1 ttl=255 time=0.4 ms
64 bytes from 192.168.0.60: icmp_seq=1 ttl=255 time=0.4 msec
64 bytes from 192.168.0.60: icmp_seq=1 ttl=255 time=400 usec

--- spinner.nocpulse.net ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.4/0.4/0.5 ms
";

    $self->{factory}->canned_results($run1, $run2);
    my $data_source = $self->{factory}->unix_command();

    my @pings;

    @pings = $data_source->ping("1.2.3.4", 10);
    $self->assert(scalar(@pings) == 10, "Wrong number of times: ", scalar(@pings));
    foreach my $ping (@pings) {
        $self->assert($ping == 0.4, "Ping value not .4: ", $ping);
    }

    @pings = $data_source->ping("1.2.3.4", 4);
    $self->assert(scalar(@pings) == 4, "Wrong number of times: ", scalar(@pings));
    foreach my $ping (@pings) {
        $self->assert($ping == 0.4, "Ping value not .4: ", $ping);
    }
}

sub test_interface_traffic {
    my $self = shift;

    my $linux = 
"Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
    lo:    6084     104    0    0    0     0          0         0     6084     104    0    0    0     0       0          0
  eth0:1195668513 32384086    0    0    0     0          0         0 887520285 30738814    0    0    0 833234       0          0
vmnet1:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0
";

    my $solaris = 
"pipe_cache:
buf_size 496 align 32 chunk_size 512 slab_size 8192 alloc 6090700 alloc_fail 0 
free 6090720 depot_alloc 1689 depot_free 1718 depot_contention 0 global_alloc 93 
global_free 0 buf_constructed 84 buf_avail 87 buf_inuse 9 
buf_total 96 buf_max 96 slab_create 6 slab_destroy 0 vmem_source 11 
hash_size 64 hash_lookup_depth 0 hash_rescale 0 full_magazines 27 
empty_magazines 1 magazine_size 3 

lo0:
ipackets 494637 opackets 494637 

hme0:
ipackets 27782262 ierrors 0 opackets 31574454 oerrors 0 collisions 0 
defer 0 framing 0 crc 0 sqe 0 code_violations 0 len_errors 0 
ifspeed 100000000 buff 0 oflo 0 uflo 0 missed 0 tx_late_collisions 0 
retry_error 0 first_collisions 0 nocarrier 0 nocanput 0 
allocbfail 0 runt 0 jabber 0 babble 0 tmd_error 0 tx_late_error 0 
rx_late_error 0 slv_parity_error 0 tx_parity_error 0 rx_parity_error 0 
slv_error_ack 0 tx_error_ack 0 rx_error_ack 0 tx_tag_error 0 
rx_tag_error 0 eop_error 0 no_tmds 0 no_tbufs 0 no_rbufs 0 
rx_late_collisions 0 rbytes 2361200816 obytes 2793491976 multircv 0 multixmt 0 
brdcstrcv 1696691 brdcstxmt 4416 norcvbuf 0 noxmtbuf 0   newfree 0 
ipackets64 27782262 opackets64 31574454 rbytes64 6656168112 obytes64 19973361160 align_errors 0 
fcs_errors 0   sqe_errors 0 defer_xmts 0 ex_collisions 0 
macxmt_errors 0 carrier_errors 0 toolong_errors 0 macrcv_errors 0 
link_duplex 0 inits 6 rxinits 0 txinits 0 dmarh_inits 0 
dmaxh_inits 0 link_down_cnt 0 phy_failures 0 xcvr_vendor 24605 
asic_rev 193 link_up 1 
";

my $bsd = 
"Name  Mtu   Network       Address            Ipkts Ierrs     Ibytes    Opkts Oerrs     Obytes  Coll
fxp0  1500  <Link>      00.90.27.77.79.01 40886390     0 3989375019 19586914     0 2295793721     0
fxp0  1500  172.16        lab-26          40886390     0 3989375019 19586914     0 2295793721     0
tun0* 1500  <Link>                               0     0          0        0     0          0     0
sl0*  552   <Link>                               0     0          0        0     0          0     0
ppp0* 1500  <Link>                               0     0          0        0     0          0     0
lo0   16384 <Link>                             429     0      20970      429     0      20970     0
lo0   16384 127           localhost            429     0      20970      429     0      20970     0
";

    # Two tries on each source, once for real and once with bogus interface
    $self->{factory}->canned_results($linux, $linux, $solaris, $solaris, $bsd, $bsd);

    my $traffic;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(
        { recid => 123, os_name => PROBE_LINUX() });
    my $data_source = $self->{factory}->unix_command(probe_record => $probe_rec);

    $probe_rec->os_name(PROBE_LINUX);
    $data_source->shell_os_name(LINUX);
    $traffic = $data_source->interface_traffic('eth0');
    $self->assert($traffic->found_interface, "Linux interface not found");
    $self->assert($traffic->bytes_in == 1195668513,
                  "Linux mismatched in: ", $traffic->bytes_in);
    $self->assert($traffic->bytes_out == 887520285,
                  "Linux mismatched out: ", $traffic->bytes_out);
    $traffic = $data_source->interface_traffic('foo');
    $self->assert(!$traffic->found_interface, "Linux bad interface found");

    $probe_rec->os_name(PROBE_SOLARIS);
    $data_source->shell_os_name(SOLARIS);
    $traffic = $data_source->interface_traffic('hme0');
    $self->assert($traffic->found_interface, "Solaris interface not found");
    $self->assert($traffic->bytes_in == 2361200816,
                  "Solaris mismatched in: ", $traffic->bytes_in);
    $self->assert($traffic->bytes_out == 2793491976,
                  "Solaris mismatched out: ", $traffic->bytes_out);
    $traffic = $data_source->interface_traffic('foo');
    $self->assert(!$traffic->found_interface, "Solaris bad interface found");

    $probe_rec->os_name(PROBE_BSD);
    $data_source->shell_os_name(BSD);
    $traffic = $data_source->interface_traffic('fxp0');
    $self->assert($traffic->found_interface, "BSD interface not found");
    $self->assert($traffic->bytes_in == 3989375019,
                  "BSD mismatched in: ", $traffic->bytes_in);
    $self->assert($traffic->bytes_out == 2295793721,
                  "BSD mismatched out: ", $traffic->bytes_out);
    $traffic = $data_source->interface_traffic('foo');
    $self->assert(!$traffic->found_interface, "BSD bad interface found");
}

sub test_iostat {
    my $self = shift;

    my $linux = 
"Linux 2.2.14-VA.2.1 (mcchesney.nocpulse.net) 	06/07/02
Disks:         tps    Kb_read/s    Kb_wrtn/s    Kb_read    Kb_wrtn
hdisk0        1.72         0.27         2.28     777242    6338348
hdisk1        0.00         0.00         0.00          0          0
hdisk2        0.00         0.00         0.00          0          0
hdisk3        0.00         0.00         0.00          0          0
Total:        1.72         0.27         2.28     777242    6338348

";

    my $solaris = "
                  extended device statistics                   
device       r/i    w/i   kr/i   kw/i wait actv  svc_t  %w  %b 
md10      474405.0 3045303.0 5471763.0 20576798.0  0.0  0.0   30.0   1   2 
md11      237203.0 3044285.0 2739555.0 20554596.5  0.0  0.0   17.2   0   1 
md12      237202.0 3044286.0 2732208.0 20556061.0  0.0  0.0   22.2   0   1 
md30      5901.0 109725.0 84815.0 580699.0  0.0  0.0   38.3   0   0 
md31      2950.0 109680.0 42637.5 580155.5  0.0  0.0   19.3   0   0 
md32      2951.0 109680.0 42177.5 580231.5  0.0  0.0   24.8   0   0 
md50      2617357.0 1564350.0 21867530.0 12170792.0  0.0  0.0   22.9   0   1 
md51      1308679.0 1551252.0 10954046.0 11419050.0  0.0  0.0   19.5   0   1 
md52      1308678.0 1551252.0 10913484.0 11413898.0  0.0  0.0   22.7   0   1 
md60      333495.0 722701.0 3973679.0 5496477.0  0.0  0.0   41.0   0   1 
md61      166747.0 721601.0 1979792.0 5471858.0  0.0  0.0   24.5   0   0 
md62      166748.0 721600.0 1993887.0 5469398.0  0.0  0.0   31.4   0   0 
sd0       1715655.0 7057114.0 15716097.0 38840915.5  0.0  0.1   19.4   0   2 
sd1       1715652.0 7057109.0 15681803.5 38835748.0  0.0  0.1   25.0   0   3 
sd15         0.0    0.0    0.0    0.0  0.0  0.0    0.0   0   0 
nfs1      4724.0    0.0 35324.3    0.0  0.0  0.0  214.2   0   0 
nfs2         0.0    0.0    0.0    0.0  0.0  0.0    0.0   0   0 
";

    $self->{factory}->canned_results($linux, $linux, $linux, $solaris, $solaris);

    my $iostat;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(
        { recid => 123, os_name => PROBE_LINUX() });
    my $data_source = $self->{factory}->unix_command(probe_record => $probe_rec);

    $data_source->shell_os_name(LINUX);
    $iostat = $data_source->iostat('hdisk0');
    $self->assert($iostat->found_disk, "Linux disk not found");
    $self->assert($iostat->kbytes_read == 777242,
                  "Linux mismatched read: ", $iostat->kbytes_read);
    $self->assert($iostat->kbytes_written == 6338348,
                  "Linux mismatched write: ", $iostat->kbytes_written);

    $iostat = $data_source->iostat('0');
    $self->assert($iostat->found_disk, "Linux disk zero not found");
    $self->assert($iostat->kbytes_read == 777242,
                  "Linux mismatched read: ", $iostat->kbytes_read);
    $self->assert($iostat->kbytes_written == 6338348,
                  "Linux mismatched write: ", $iostat->kbytes_written);

    $iostat = $data_source->iostat('foo');
    $self->assert(!$iostat->found_disk, "Linux bad disk found");

    $probe_rec->os_name(PROBE_SOLARIS);
    $data_source->shell_os_name(SOLARIS);
    $iostat = $data_source->iostat('md51');
    $self->assert($iostat->found_disk, "Solaris disk not found");
    $self->assert($iostat->kbytes_read == 10954046.0,
                  "Solaris mismatched read: ", $iostat->kbytes_read);
    $self->assert($iostat->kbytes_written == 11419050,
                  "Solaris mismatched out: ", $iostat->kbytes_written);
    $iostat = $data_source->iostat('foo');
    $self->assert(!$iostat->found_disk, "Solaris bad disk found");
}

sub test_dig {
    my $self = shift;

    my $np = "
; <<>> DiG 8.2 <<>> \@192.168.0.201 www.nocpulse.com 
; (1 server found)
;; res options: init recurs defnam dnsrch
;; got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 2
;; QUERY SECTION:
;;	www.nocpulse.com, type = A, class = IN

;; ANSWER SECTION:
www.nocpulse.com.	4H IN A		216.136.199.13

;; AUTHORITY SECTION:
nocpulse.com.		4H IN NS	ns1.nocpulse.com.
nocpulse.com.		4H IN NS	ns2.nocpulse.com.

;; ADDITIONAL SECTION:
ns1.nocpulse.com.	4H IN A		63.121.136.31
ns2.nocpulse.com.	4H IN A		63.121.136.36

;; Total query time: 54 msec
;; FROM: mcchesney.nocpulse.net to SERVER: 192.168.0.201
;; WHEN: Thu Jun 13 16:20:53 2002
;; MSG SIZE  sent: 34  rcvd: 118

";
    my $yahoo = "
; <<>> DiG 8.2 <<>> \@192.168.0.201 yahoo.com 
; (1 server found)
;; res options: init recurs defnam dnsrch
;; got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 5, ADDITIONAL: 5
;; QUERY SECTION:
;;	yahoo.com, type = A, class = IN

;; ANSWER SECTION:
yahoo.com.		11m48s IN A	66.218.71.113
yahoo.com.		2h18m28s IN A	66.218.71.112

;; AUTHORITY SECTION:
yahoo.com.		2h18m28s IN NS	ns1.yahoo.com.
yahoo.com.		2h18m28s IN NS	ns2.yahoo.com.
yahoo.com.		2h18m28s IN NS	ns3.yahoo.com.
yahoo.com.		2h18m28s IN NS	ns4.yahoo.com.
yahoo.com.		2h18m28s IN NS	ns5.yahoo.com.

;; ADDITIONAL SECTION:
ns1.yahoo.com.		11h2m4s IN A	66.218.71.63
ns2.yahoo.com.		22h20s IN A	209.132.1.28
ns3.yahoo.com.		19h42m55s IN A	217.12.4.104
ns4.yahoo.com.		17h27m19s IN A	63.250.206.138
ns5.yahoo.com.		11h2m4s IN A	64.58.77.85

;; Total query time: 7 msec
;; FROM: mcchesney.nocpulse.net to SERVER: 192.168.0.201
;; WHEN: Thu Jun 13 16:21:15 2002
;; MSG SIZE  sent: 27  rcvd: 229

";
    my $fred = "
; <<>> DiG 8.2 <<>> \@fletch.nocpulse.net fred 
; (1 server found)
;; res options: init recurs defnam dnsrch
;; got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 6
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0
;; QUERY SECTION:
;;	fred, type = A, class = IN

;; AUTHORITY SECTION:
.			2h54m45s IN SOA  A.ROOT-SERVERS.NET. NSTLD.VERISIGN-GRS.COM. (
					2002061301	; serial
					30M		; refresh
					15M		; retry
					1W		; expiry
					1D )		; minimum


;; Total query time: 118 msec
;; FROM: mcchesney.nocpulse.net to SERVER: fletch.nocpulse.net  192.168.0.201
;; WHEN: Thu Jun 13 19:09:47 2002
;; MSG SIZE  sent: 22  rcvd: 97

";

    $self->{factory}->canned_results($np, $yahoo, $fred);
    my $data_source = $self->{factory}->unix_command();

    my $dig;

    $dig = $data_source->dig('fletch.nocpulse.net', 'www.nocpulse.com');
    $self->assert($dig->hits, "No hits");

    $self->assert(qr/54/, $dig->total_time);
    $self->assert(qr/msec/, $dig->time_units);

    my @hits = @{$dig->hits};
    $self->assert(scalar(@hits) == 1, "Wrong hit count: ", scalar(@hits), " instead of 1\n");
    $self->assert($hits[0]->name eq 'www.nocpulse.com.', "Wrong name: ", @hits[0]->name);
    $self->assert($hits[0]->ip eq '216.136.199.13', "Wrong ip: ", @hits[0]->ip);
    $self->assert($hits[0]->dns_info eq '4H IN A', "Wrong dns info: ", @hits[0]->dns_info);


    $dig = $data_source->dig('fletch.nocpulse.net', 'yahoo.com');
    $self->assert($dig->hits, "No hits");

    $self->assert(qr/7/, $dig->total_time);
    $self->assert(qr/msec/, $dig->time_units);

    my @hits = @{$dig->hits};
    $self->assert(scalar(@hits) == 2, "Wrong hit count: ", scalar(@hits), " instead of 2\n");
    $self->assert($hits[0]->name eq 'yahoo.com.', "Wrong name 1: ", $hits[0]->name);
    $self->assert($hits[0]->ip eq '66.218.71.113', "Wrong ip 1: ", $hits[0]->ip);
    $self->assert($hits[0]->dns_info eq '11m48s IN A', "Wrong dns info 1: ", $hits[0]->dns_info);

    $self->assert($hits[1]->name eq 'yahoo.com.', "Wrong name 2: ", $hits[1]->name);
    $self->assert($hits[1]->ip eq '66.218.71.112', "Wrong ip 2: ", $hits[1]->ip);
    $self->assert($hits[1]->dns_info eq '2h18m28s IN A', "Wrong dns info 2: ", $hits[1]->dns_info);


    $dig = $data_source->dig('fletch.nocpulse.net', 'fred');
    $self->assert($dig->hits_count == 0, "Have hits: ", $dig->hits_count);
}

sub test_page_scans {
    my $self = shift;

    my $solaris = "
 procs     memory            page            disk          faults      cpu
 r b w   swap  free  re  mf pi po fr de sr s0 s6 -- --   in   sy   cs us sy id
 0 0 0 934920 685352 10  49  0  0  0  0  0  1  0  0  0  308  597  343  1  1 98
 0 0 0 1125552 727304 0  13  0  0  0  0  0  0  0  0  0  314  227  267  0  1 99
 0 0 0 1125552 727304 0   0  0  0  0  0  1  0  0  0  0  306  121  254  0  0 100
 0 0 0 1125552 727304 0   0  0  0  0  0  4 26  0  0  0  412  108  247  0  7 93
";

   my $hpux = "
         procs           memory                   page                              faults       cpu
    r     b     w      avm    free   re   at    pi   po    fr   de    sr     in     sy    cs  us sy id
    2     0     0    16058  127605    2    4     0    0     0    0     0    104    165    34   1  0 99
    2     0     0    16058  127605    2    1     0    0     0    0     0    107    129    26   0  0 100
    2     0     0    16058  127559    2    0     0    0     0    0     2    107    113    25   0  0 100
    2     0     0    16058  127559    1    0     0    0     0    0     3    106    102    24   0  0 100
";

    $self->{factory}->canned_results($solaris, $hpux);

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new(
        { recid => 123, os_name => PROBE_SOLARIS() });
    my $data_source = $self->{factory}->unix_command(probe_record => $probe_rec);
    my $os;

    $os = SOLARIS;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);

    my $page_scans;

    $page_scans = $data_source->page_scans();
    $self->assert($page_scans == 1, "Page scan mismatch for $page_scans value in $os");

    $os = HPUX;
    $probe_rec->os_name(os_uname_to_configured($os));
    $data_source->shell_os_name($os);

    $page_scans = $data_source->page_scans();
    $self->assert($page_scans == 2, "Page scan mismatch for $page_scans value in $os");

}



1;
