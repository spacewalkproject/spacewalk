package NOCpulse::Probe::DataSource::test::TestPsOutput;

use strict;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Probe::DataSource::UnixCommand;
use NOCpulse::Probe::DataSource::CannedUnixCommand;
use NOCpulse::Probe::DataSource::PsOutput;
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::Config::ProbeRecord;
use Data::Dumper;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;

    # Create a data factory
    $self->{'factory'} = NOCpulse::Probe::DataSource::Factory->new();
    $self->{'factory'}->canned(1);

}

sub test_uncanned {
    my $self = shift;

    $self->set_os(PROBE_LINUX);

    my $factory = $self->{'factory'};
    $factory->canned(0);

    my $data_source = $factory->unix_command();
    my $ps_output = $data_source->ps();

    my $proc = $ps_output->process_by_pid(1);
    $self->assert(qr/init/, $proc->args);

}


# OS-specific tests

sub test_ps_linux {
    my $self = shift;

    $self->set_os(PROBE_LINUX);
    $self->{'factory'}->canned_results($self->do_test_data());
    $self->go_man_go($self->do_test_cfg());
}

sub test_ps_solaris {
    my $self = shift;

    $self->set_os(PROBE_SOLARIS);
    $self->{'factory'}->canned_results($self->do_test_data());
    $self->go_man_go($self->do_test_cfg());
}

sub test_ps_irix {
    my $self = shift;

    $self->set_os(PROBE_IRIX);
    $self->{'factory'}->canned_results($self->do_test_data());
    $self->go_man_go($self->do_test_cfg());
}

sub test_ps_bsd {
    my $self = shift;

    $self->set_os(PROBE_BSD);
    $self->{'factory'}->canned_results($self->do_test_data());
    $self->go_man_go($self->do_test_cfg());
}

sub test_ps_satellite {
    my $self = shift;

    $self->set_os(PROBE_SATELLITE);
    $self->{'factory'}->canned_results($self->do_test_data());
    $self->go_man_go($self->do_test_cfg());
}




# The actual test code
sub go_man_go {
    my $self = shift;
    my $cfg  = shift;

    my $factory = $self->{'factory'};
    my $data_source = $factory->unix_command();

    # Set the OS that would come from uname to match up
    $data_source->shell_os_name(os_configured_to_uname($factory->probe_record->os_name));

    my $ps_output = $data_source->ps();

    $self->assert(defined($ps_output), "No 'ps' output");

    # Find a particular process (process 1)
    my $proc = $ps_output->process_by_pid(1);
    $self->assert(defined($proc), "Couldn't find PID 1");
    $self->assert(qr/init/, $proc->args);

    # Find the process group leader for a particular process
    my $pgleader = $ps_output->pgleader_by_pid($cfg->{'pgbypid_child'});
    $self->assert(defined($pgleader), 
	"Couldn't find pg leader for pid $cfg->{'pgbypid_child'}");
    $self->assert($pgleader->pid == $cfg->{'pgbypid_leader'}, sprintf(
	"Found wrong pg leader for %d (found %d, should be %d)",
	$cfg->{'pgbypid_child'}, $pgleader->pid, $cfg->{'pgbypid_leader'}));

    # - EDGE CASE:  Find process group leader for pid 1 (should be 1)
    my $initleader = $ps_output->pgleader_by_pid(1);
    $self->assert($initleader->pid == 1, sprintf(
        "Found wrong pg leader for %d (found %d, should be %d)",
        1, $initleader->pid, 1));

    # - EDGE CASE:  Find process group leader for pid 0 (should be 0)
    $initleader = $ps_output->pgleader_by_pid(0);
    if (defined($initleader)) {
        $self->assert($initleader->pid == 0, sprintf(
            "Found wrong pg leader for %d (found %d, should be %d)",
            0, $initleader->pid, 0));
    }


    # Find processes matching a pattern
    my @procs = $ps_output->processes_by_match($cfg->{'pmatch_pattern'});
    $self->assert(scalar(@procs) == $cfg->{'pmatch_count'}, sprintf(
	"Found wrong number of %s processes (found %d, expected %d)", 
	$cfg->{'pmatch_pattern'}, scalar(@procs), $cfg->{'pmatch_count'}));

    # Find process group leaders matching a pattern
    my @pgleaders = 
	$ps_output->pgleaders_by_match($cfg->{'pmatch_pattern'});
    $self->assert(scalar(@pgleaders) == 1, sprintf(
	"Found wrong number of %s processes (found %d, expected %d)",
	$cfg->{'pmatch_pattern'}, scalar(@pgleaders), 1));
    $self->assert($pgleaders[0]->pid() == $cfg->{'pgmatch_leader'},
	sprintf("Found wrong pg leader for /%s/ (%d, should be %d)",
	    $cfg->{'pmatch_pattern'}, $pgleaders[0]->pid(),
	    $cfg->{'pgmatch_leader'}));

    # Check sample values for all process fields
    $proc = $ps_output->process_by_pid($cfg->{'pid'});
    $self->assert($proc->pid == $cfg->{'pid'}, sprintf(
	"pid field check failed: got %s, expected %s",
	$proc->pid, $cfg->{'pid'}));
    $self->assert($proc->ppid == $cfg->{'ppid'}, sprintf(
	"ppid field check failed: got %s, expected %s",
	$proc->ppid, $cfg->{'ppid'}));
    $self->assert($proc->vsz == $cfg->{'vsz'}, sprintf(
	"vsz field check failed: got %s, expected %s",
	$proc->vsz, $cfg->{'vsz'}));
    $self->assert($proc->rss == $cfg->{'rss'}, sprintf(
	"rss field check failed: got %s, expected %s",
	$proc->rss, $cfg->{'rss'}));
    $self->assert($proc->cpu eq $cfg->{'cpu'}, sprintf(
	"cpu field check failed: got %s, expected %s",
	$proc->cpu, $cfg->{'cpu'}));
    $self->assert($proc->threads == $cfg->{'threads'}, sprintf(
	"threads field check failed: got %s, expected %s",
	$proc->threads, $cfg->{'threads'}));
    $self->assert($proc->args eq $cfg->{'args'}, sprintf(
	"args field check failed: got %s, expected %s",
	$proc->args, $cfg->{'args'}));

}



# Utility functions


sub set_os {
    my $self    = shift;
    my $os_name = shift;
    my $proberec = NOCpulse::Probe::Config::ProbeRecord->new( {
			    os_name => $os_name,
			    });

    $self->{'factory'}->probe_record($proberec);
    $self->{os} = $os_name;
}




sub do_test_cfg {
  my $self = shift;
  my $os   = $self->{os};

  if ($os eq PROBE_LINUX or $os eq PROBE_SATELLITE) {
    return {
	'pgbypid_child'  => 30109,
	'pgbypid_leader' => 18287,
	'pmatch_pattern' => 'kernel.pl',
	'pmatch_count'   => 11,
	'pgmatch_leader' => 18287,
        'pid'            => 30093,
        'ppid'           => 30092,
        'vsz'            => 5196,
        'rss'            => 4228,
        'cpu'            => '0',
        'threads'        => undef,
        'state'          => 'S',
        'args'           => 'perl /etc/rc.d/np.d/step SputLite status',
    };
  } elsif ($os eq PROBE_SOLARIS) {
    return {
	'pgbypid_child'  => 220,
	'pgbypid_leader' => 217,
	'pmatch_pattern' => '/usr/local/sbin/sshd',
	'pmatch_count'   => 2,
	'pgmatch_leader' => 126,
        'pid'            => 757,
        'ppid'           => 126,
        'vsz'            => 2680,
        'rss'            => 1776,
        'cpu'            => '1000',
        'threads'        => 1,
        'state'          => 'S',
        'args'           => '/usr/local/sbin/sshd',
    };
  } elsif ($os eq PROBE_IRIX) {
    return {
	'pgbypid_child'  => 4635297,
	'pgbypid_leader' => 81056,
	'pmatch_pattern' => '/usr/local/sbin/sshd',
	'pmatch_count'   => 2,
	'pgmatch_leader' => 81056,
        'pid'            => 844,
        'ppid'           => 828,
        'vsz'            => 20928,
        'rss'            => 113,
        'cpu'            => '0',
        'threads'        => undef,
        'state'          => 'S',
        'args'           => '/usr/bin/X11/xdm',
    };
  } elsif ($os eq PROBE_BSD) {
    return {
	'pgbypid_child'  => 85996,
	'pgbypid_leader' => 190,
	'pmatch_pattern' => 'apache',
	'pmatch_count'   => 6,
	'pgmatch_leader' => 234,
        'pid'            => 85952,
        'ppid'           => 85951,
        'vsz'            => 1508,
        'rss'            => 1200,
        'cpu'            => '260',
        'threads'        => undef,
        'state'          => 'S',
        'args'           => 'tcsh',
    };
  }
}





sub do_test_data {
    my $self = shift;
    my $os   = $self->{os};

    if ($os eq PROBE_LINUX or $os eq PROBE_SATELLITE) {
      return

# Linux (lab-22.lab.nocpulse.net 2.2.19 #1 SMP Sat Oct 20 01:44:31 GMT 2001 i686 unknown)
' PID  PPID   VSZ  RSS     TIME S COMMAND
    1     0  1120  480 00:00:30 S init [3]
    2     1     0    0 00:00:00 S [kflushd]
    3     1     0    0 00:02:19 S [kupdate]
    4     1     0    0 00:00:00 S [kswapd]
    5     1     0    0 00:00:00 S [keventd]
    6     1     0    0 00:00:00 S [mdrecoveryd]
    7     1     0    0 00:00:00 S [scsi_eh_0]
    8     1     0    0 00:00:00 S [scsi_eh_1]
  589     1  1172  596 00:00:07 S /usr/sbin/sshd -f /etc/ssh/sshd_config
  604     1  1172  552 00:00:02 S syslogd -m 0
  615     1  1296  648 00:00:00 S klogd
  639     1  1152  540 00:00:02 S crond
  658     1  1092  412 00:00:00 S /sbin/mingetty tty1
  659     1  1092  412 00:00:00 S /sbin/mingetty tty2
  660     1  1140  476 00:00:00 S /sbin/getty ttyS0 DT9600 vt100
  661     1  4936 3988 00:00:00 S perl /home/config/provsrv
 1391     1  1260  608 00:00:00 S /sbin/pump -i eth0
 2601     1  9444 7792 06:49:25 S /usr/local/bin/disk_check -l /var/log -D -c /etc/disk_check.conf -A fast -p -s -N
 2611     1  7500 6080 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=SpreadServer --user=spread -- /usr/bin/spread -c /etc/spread.conf -n localhost
 2615  2611  2364 1084 00:02:09 S /usr/bin/spread -c /etc/spread.conf -n localhost
 2625     1  7500 6080 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=ClustCfgServices --user=root -- /etc/rc.d/np.d/clustcfgsvcsd
 2629  2625  6088 4876 00:00:41 S perl /etc/rc.d/np.d/clustcfgsvcsd
 2639     1  8572 7392 00:05:41 S perl /opt/home/nocpulse/bin/gogo.pl --fname=SpreadBridge --user=nocpulse -- /usr/local/bin/spbridge --mode client
 2658     1  7496 6076 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=SuperSput --user=root -- /opt/home/nocpulse/bin/supersput.pl
 2662  2658  5804 4588 00:01:25 S perl /opt/home/nocpulse/bin/supersput.pl
 3020   589  2316 1140 00:00:00 S /usr/sbin/sshd -f /etc/ssh/sshd_config
 3023  3020  1928  844 00:00:00 S su
 3032  3023  2796 1840 00:00:00 S -sh
16429     1  7496 6076 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=PPPnet --user=root -- /etc/ppp/dialdaemon.pl
16433 16429  3240 2324 00:01:00 S perl /etc/ppp/dialdaemon.pl
18253     1  7504 6084 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=SputLite --user=root --hbfile=/opt/home/nocpulse/var/commands/heartbeat --hbfreq=120 -- /opt/home/nocpulse/bin/execute_commands
18254 18253 14680 12976 00:01:47S  perl /opt/home/nocpulse/bin/execute_commands
18268     1  7504 6084 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=Dequeuer --user=nocpulse --hbfile=/opt/home/nocpulse/var/dequeue.log --hbfreq=60 -- /opt/home/nocpulse/bin/dequeue
18269 18268 31664 29952 00:11:05S  perl /opt/home/nocpulse/bin/dequeue
18287     1  8564 7384 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=Dispatcher --user=nocpulse --hbfile=/opt/home/nocpulse/var/kernel.log --hbfreq=300 --hbcheck=600 -- /opt/home/nocpulse/bin/kernel.pl --loglevel 1
18306     1  7500 6080 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=TrapReceiver --user=root -- /opt/home/nocpulse/bin/trapReceiver
18307 18306  6424 4992 00:00:00 S perl /opt/home/nocpulse/bin/trapReceiver
29255 18287 20852 19332 00:00:55S  perl /opt/home/nocpulse/bin/kernel.pl --loglevel 1
30064 29255     0    0 00:00:00 S [kernel.pl <defunct>]
30082 29255 21284 19792 00:00:00 S /opt/home/nocpulse/bin/kernel.pl (event 12648)   
30083 29255 21348 20096 00:00:00 S /opt/home/nocpulse/bin/kernel.pl (event 12698)   
30089 29255 21276 19780 00:00:00 S /opt/home/nocpulse/bin/kernel.pl (event 3551)    
30090   639  1164  556 00:00:00 S CROND
30092 30090  1468  652 00:00:00 S /bin/sh -c /etc/rc.d/np.d/step SputLite status || /etc/rc.d/np.d/step SputLite start
30093 30092  5196 4228 00:00:00 S perl /etc/rc.d/np.d/step SputLite status
30098 29255 21284 19784 00:00:00 S /opt/home/nocpulse/bin/kernel.pl (event 19967)   
30102 29255 21292 19792 00:00:00 S /opt/home/nocpulse/bin/kernel.pl (event 21911)   
30106 30082 21284 19792 00:00:00 S /opt/home/nocpulse/bin/kernel.pl (event 12648)   
30107 30090  1092  396 00:00:00 S /usr/sbin/sendmail -FCronDaemon -odi -oem root
30108 30093  5204 4216 00:00:00 S perl /etc/rc.d/np.d/step SputLite status
30109 30102 21308 19792 00:00:00 S /opt/home/nocpulse/bin/kernel.pl (event 21911)   
30110  3032  2340  688 00:00:00 S /bin/ps -o pid,ppid,vsz,rss,time,args -ewwww
30111  2639  8572 7392 00:00:00 S perl /opt/home/nocpulse/bin/gogo.pl --fname=SpreadBridge --user=nocpulse -- /usr/local/bin/spbridge --mode client
30112 30098 21300 19784 00:00:00 S /opt/home/nocpulse/bin/kernel.pl (event 19967)
';

    } elsif ($os eq PROBE_SOLARIS) {

        return

# Solaris (SunOS freddy 5.8 Generic_108528-11 sun4u sparc SUNW,UltraSPARC-IIi-cEngine)
' PID  PPID  VSZ  RSS        TIME NLWP S COMMAND
    0     0    0    0        0:13    1 S sched
    1     0  792  376        9:35    1 S /etc/init -
    2     0    0    0        0:00    1 S pageout
    3     0    0    0    04:55:10    1 S fsflush
  217     1 1752 1256        0:00    1 S /usr/lib/saf/sac -t 300
  218     1 1792 1296        0:00    1 S /usr/lib/saf/ttymon -g -h -p freddy console login:  -T sun -d /dev/console -l c
  130     1 2224 1248        0:00    1 S /usr/sbin/rpcbind
   49     1 1536 1120        0:01   10 S /usr/lib/sysevent/syseventd
   51     1 1320  776        0:01    5 S /usr/lib/sysevent/syseventconfd
   57     1 2192 1744        0:01    5 S /usr/lib/picl/picld
  126     1 2632 1208        0:07    1 S /usr/local/sbin/sshd
  150     1 1880 1168        0:00    1 S /usr/lib/nfs/lockd
  151     1 2488 1712        0:00    4 S /usr/lib/nfs/statd
  177     1 1968 1392        0:00    1 S /usr/sbin/cron
  167     1 3376 1768        0:01    9 S /usr/sbin/syslogd
  220   217 1768 1336        0:00    1 S /usr/lib/saf/ttymon
  197     1 1016  736        0:00    1 S /usr/lib/utmpd
  176     1 2144 1176        0:01    1 S /usr/lib/inet/xntpd
  191     1 3168 1840        0:00    1 S /usr/lib/sendmail -bd -q15m
  204     1 2768 2304        1:34    1 S /usr/lib/snmp/snmpdx -y -c /etc/snmp/conf
  211     1 3664 2736        0:00    5 S /usr/lib/dmi/snmpXdmid -s freddy
  210     1 3032 2096        0:00    5 S /usr/lib/dmi/dmispd
  227   204 2424 2176        5:19   12 S mibiisa -r -p 32786
  759   757 1032  872        0:00    1 S -sh
  547     1 2632 1680       23:55    1 S /opt/NOCpulse/ssh/bin/nocpulsed -q -f /opt/NOCpulse/ssh/etc/sshd_config
  858   759 1904 1080        0:00    1 S /bin/ps -o pid,ppid,vsz,rss,time,nlwp,args -e
  757   126 2680 1776        0:01    1 S /usr/local/sbin/sshd
';


    } elsif ($os eq PROBE_IRIX) {

        return

# Irix (IRIX irix 6.5 10120732 IP22)
'      PID       PPID VSZ    RSS          TIME S COMMAND
         1          0   1668 96           1:51 S /etc/init
       598          1   3620 898          1:01 S /usr/sbin/ggd
       303          1   2020 135         29:21 S /usr/etc/peer_snmpd /etc/peer_snmpd_config /etc/peer_nov
       307          1   1916 105          0:35 S /usr/etc/peer_encaps -c /etc/peer_encaps_config
       310          1   3072 156          1:47 S /usr/etc/snmpd -p 1161
        31          1   1676 76           0:00 S /sbin/xlv_plexd -m 4 -w 1
       657          1   1604 58           0:00 S /usr/sbin/startmidi -v -n Software Synth -d internal
       363          1   2684 209          4:55 S /usr/lib/sendmail -bd -q15m
       101          1   1620 106          1:52 S /usr/etc/syslogd
       398          1   1772 141          5:01 S /sbin/cron
       109          1   5000 364          3:10 S /usr/etc/eventmond -silence -start -p 45 -g on
       411          1   1980 95           0:00 S /usr/lib/lpsched
       717          1   3740 236         38:24 S /usr/etc/pmcd
   4633136    4635297   1696 111          0:00 S /bin/ps -o pid,ppid,vsz,rss,time,args -e
       445          1   6764 391          0:15 S /usr/etc/espdbd --big-tables --skip-networking --basedir=/usr/etc --datadir=/va
       764          1   1692 65           0:00 S rfindd
       769          1   1880 129          0:00 S /usr/etc/rtmond -a localhost
   2566204          1   2872 278       1:51:36 S /opt/NOCpulse/ssh/bin/nocpulsed -q -f /opt/NOCpulse/ssh/etc/sshd_config
       181          1   1700 113          2:55 S /usr/etc/routed -h -Prdisc_interval=45 -q
       193          1   2320 161          0:06 S /usr/etc/rpcbind
       195          1   2660 261         45:20 S /usr/etc/nsd -a nis_security=local
       197          1      0 0            0:01 S bio3d
       204          1   1740 100          1:51 S /usr/etc/inetd
       207          1   1788 121          2:20 S /usr/lib/saf/sac -t 30
       213        207   1844 136          1:26 S /usr/lib/saf/listen tcp
       217          1   1576 52           0:00 S /usr/etc/snetd
       222          1   2216 119          0:34 S /usr/etc/timed -M -G timelords -P /var/adm/timetrim
   4635297    4635628    572 76           0:00 S -csh
       828          1   4624 177          0:00 S /usr/bin/X11/xdm
     81056          1   3040 237       1:42:53 S /usr/local/sbin/sshd
       841        828  23508 414          0:03 S /usr/bin/X11/Xsgi -bs -nobitscale -c -pseudomap 4sight -solidroot sgilightblue 
       844        828  20928 113          0:00 S /usr/bin/X11/xdm
   4635628      81056   3212 401          0:05 S /usr/local/sbin/sshd
       861          1   1576 65           0:00 S /sbin/getty ttyd1 console
       876        844  33852 223          0:03 S /usr/Cadmin/bin/clogin -f -g
';


    } elsif ($os eq PROBE_BSD) {

        return

# FreeBSD (FreeBSD lab-3.lab.nocpulse.net 4.3-RELEASE FreeBSD 4.3-RELEASE #1: Fri May  4 03:18:47 PDT 2001     nocops@lab-3.lab.nocpulse.net:/usr/src/sys/compile/NOCPULSE  i386)
' PID  PPID   VSZ  RSS      TIME STAT COMMAND
    0     0     0    0   0:03.23 DLs   (swapper)
    1     0   528  312   0:00.08 Is   /sbin/init --
    2     0     0    0   0:07.91 DL    (pagedaemon)
    3     0     0    0   0:00.00 DL    (vmdaemon)
    4     0     0    0   0:35.47 DL    (bufdaemon)
    5     0     0    0  17:33.75 DL    (syncer)
   28     1   208   92   0:00.00 Ss    adjkerntz -i
  149     1   928  640   0:23.25 Ss    syslogd -s
  153     1   932  552   0:00.00 Is    /usr/sbin/portmap
  158     1   500  284   0:00.00 Ss    mountd -r
  160     1   360  180   0:00.00 Ss    nfsd: master (nfsd)
  162   160   352  172   0:00.00 Ss    nfsd: server (nfsd)
  163   160   352  172   0:00.00 Ss    nfsd: server (nfsd)
  164   160   352  172   0:00.00 Ss    nfsd: server (nfsd)
  165   160   352  172   0:00.00 Ss    nfsd: server (nfsd)
  168     1 263068  596   0:00.00 Ss   rpc.statd
  187     1   984  744   0:18.46 Ss    /usr/sbin/cron
  190     1  2008 1512   0:08.86 Ss    /usr/sbin/sshd
  234     1  5392 4628   2:00.75 I     /opt/apache/bin/httpd -f /opt/apache/conf/httpd.conf.scdb
  239   234  5404 4620   0:00.00 I     /opt/apache/bin/httpd -f /opt/apache/conf/httpd.conf.scdb
  240   234  5404 4620   0:00.01 I     /opt/apache/bin/httpd -f /opt/apache/conf/httpd.conf.scdb
  241   234  5404 4620   0:00.00 I     /opt/apache/bin/httpd -f /opt/apache/conf/httpd.conf.scdb
  242   234  5404 4620   0:00.00 I     /opt/apache/bin/httpd -f /opt/apache/conf/httpd.conf.scdb
  243   234  5404 4620   0:00.00 I     /opt/apache/bin/httpd -f /opt/apache/conf/httpd.conf.scdb
  244     1  4900 3820  26:23.54 Ss    /usr/local/bin/disk_check -l /var/log/disk_check -D -c /etc/disk_check.conf -A fast -p
53060     1  1200  980   8:05.63 Ss    /opt/NOCpulse/ssh/bin/nocpulsed -f /opt/NOCpulse/ssh/etc/sshd_config
85951   190  2252 1868   0:00.48 Ss    sshd: nocops@ttyp0 (sshd)
85952 85951  1508 1200   0:00.26 Ss    tcsh
85996 85952   424  240   0:00.00 R     /bin/ps -axwwww -o pid,ppid,vsz,rss,time,command
  255     1   936  652   0:00.00 IWs+  /usr/libexec/getty Pc ttyv0
  256     1   936  652   0:00.00 IWs+  /usr/libexec/getty Pc ttyv1
  257     1   936  652   0:00.00 IWs+  /usr/libexec/getty Pc ttyv2
  258     1   936  652   0:00.00 IWs+  /usr/libexec/getty Pc ttyv3
  259     1   936  652   0:00.00 IWs+  /usr/libexec/getty Pc ttyv4
  260     1   936  652   0:00.00 IWs+  /usr/libexec/getty Pc ttyv5
  261     1   936  652   0:00.00 IWs+  /usr/libexec/getty Pc ttyv6
  262     1   936  652   0:00.00 IWs+  /usr/libexec/getty Pc ttyv7
';

    };

}



1;
