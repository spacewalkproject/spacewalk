package Unix::test::TestProcess;

use strict;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::Config::Command;
use NOCpulse::Probe::Result;

use lib qw(. .. ../.. /var/lib/nocpulse/libexec);

use Unix::Process;

my $PIDFILE = "/tmp/booga";
my $CLASS   = "Unix::Process";

use strict;
use base qw(Test::Unit::TestCase);

sub set_up {
  my $self = shift;

  $self->{prec} = NOCpulse::Probe::Config::ProbeRecord->new({
                    recid     => 12345,
                    host_name => 'HOSTNAME_HERE',
                    os_name   => PROBE_LINUX,
                  });

  $self->{factory} = NOCpulse::Probe::DataSource::Factory->new(
                       probe_record  => $self->{prec},
                       shell_os_name => LINUX,
                     );

  local * PID;
  open(PID, '>', $PIDFILE) or die "Couldn't create $PIDFILE: $!";
  print PID "1\nbooga booga booga\n";
  close(PID);
}

sub tear_down {
  unlink($PIDFILE);
}

sub test_by_pidfile {
    my $self = shift;

    my $result = $self->doit({pidFile => $PIDFILE});

    my $vsz = $result->{'item_named'}->{'vsz'}->{'value'};
    $self->assert($vsz > 0, "Bad result (got null or zero vsz '$vsz')");


}

sub test_by_commandName {
    my $self = shift;

    $self->{factory}->canned(1);

    $self->{factory}->canned_results(&fish_lips());

    my $result = $self->doit({commandName => 'syslogd'});

    my $vsz = $result->{'item_named'}->{'vsz'}->{'value'};
    $self->assert($vsz == 1172,
                    "Bad result (expected vsz of 1172, got '$vsz')");

}



# The actual test

sub doit {
    my $self   = shift;
    my $params = shift;

    my @metric_ids = qw(nchildren vsz physical_mem_used cpu_time_rt nthreads);
    my %metrics = ();
    foreach my $metric_id (@metric_ids) {
        $metrics{$metric_id} =
          NOCpulse::Probe::Config::CommandMetric->new(command_class => $CLASS,
                                                      metric_id     => $metric_id);
    }
    my $cmd = NOCpulse::Probe::Config::Command->new(command_class => $CLASS,
                                                    metrics       => \%metrics);

    my $result  = NOCpulse::Probe::Result->new(
                    probe_record   => $self->{prec},
                    command_record => $cmd,
                  );

    my %probe_args = ( 
        params              => $params,
        result              => $result,
        memory              => {},
        data_source_factory => $self->{factory},
      );

    my $runsub = UNIVERSAL::can($CLASS, 'run');
    $self->assert(defined($runsub), 
                    "Class $CLASS has no subroutine named 'run'");

    &$runsub(%probe_args);

    return $result;

}


sub fish_lips {

# Linux (lab-22.lab.nocpulse.net 2.2.19 #1 SMP Sat Oct 20 01:44:31 GMT 2001 i686 unknown)
return
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
 2611     1  7500 6080 00:00:00 S perl /usr/bin/gogo.pl --fname=SpreadServer --user=spread -- /usr/bin/spread -c /etc/spread.conf -n localhost
 2615  2611  2364 1084 00:02:09 S /usr/bin/spread -c /etc/spread.conf -n localhost
 2625     1  7500 6080 00:00:00 S perl /usr/bin/gogo.pl --fname=ClustCfgServices --user=root -- /etc/rc.d/np.d/clustcfgsvcsd
 2629  2625  6088 4876 00:00:41 S perl /etc/rc.d/np.d/clustcfgsvcsd
 2639     1  8572 7392 00:05:41 S perl /usr/bin/gogo.pl --fname=SpreadBridge --user=nocpulse -- /usr/local/bin/spbridge --mode client
 2658     1  7496 6076 00:00:00 S perl /home/nocpulse/bin/gogo.pl --fname=SuperSput --user=root -- /usr/bin/supersput.pl
 2662  2658  5804 4588 00:01:25 S perl /usr/bin/supersput.pl
 3020   589  2316 1140 00:00:00 S /usr/sbin/sshd -f /etc/ssh/sshd_config
 3023  3020  1928  844 00:00:00 S su
 3032  3023  2796 1840 00:00:00 S -sh
16429     1  7496 6076 00:00:00 S perl /usr/bin/gogo.pl --fname=PPPnet --user=root -- /etc/ppp/dialdaemon.pl
16433 16429  3240 2324 00:01:00 S perl /etc/ppp/dialdaemon.pl
18253     1  7504 6084 00:00:00 S perl /usr/bin/gogo.pl --fname=SputLite --user=root --hbfile=/var/log/nocpulse/commands/heartbeat --hbfreq=120 -- /usr/bin/execute_commands
18254 18253 14680 12976 00:01:47S  perl /usr/bin/execute_commands
18268     1  7504 6084 00:00:00 S perl /usr/bin/gogo.pl --fname=Dequeuer --user=nocpulse --hbfile=/var/log/nocpulse/dequeue.log --hbfreq=60 -- /usr/bin/dequeue
18269 18268 31664 29952 00:11:05S  perl /usr/bin/dequeue
18287     1  8564 7384 00:00:00 S perl /usr/bin/gogo.pl --fname=Dispatcher --user=nocpulse --hbfile=/var/log/nocpulse/kernel.log --hbfreq=300 --hbcheck=600 -- /usr/bin/kernel.pl --loglevel 1
18306     1  7500 6080 00:00:00 S perl /usr/bin/gogo.pl --fname=TrapReceiver --user=root -- /usr/bin/trapReceiver
18307 18306  6424 4992 00:00:00 S perl /usr/bin/trapReceiver
29255 18287 20852 19332 00:00:55S  perl /usr/bin/kernel.pl --loglevel 1
30064 29255     0    0 00:00:00 S [kernel.pl <defunct>]
30082 29255 21284 19792 00:00:00 S /usr/bin/kernel.pl (event 12648)   
30083 29255 21348 20096 00:00:00 S /usr/bin/kernel.pl (event 12698)   
30089 29255 21276 19780 00:00:00 S /usr/bin/kernel.pl (event 3551)    
30090   639  1164  556 00:00:00 S CROND
30092 30090  1468  652 00:00:00 S /bin/sh -c /etc/rc.d/np.d/step SputLite status || /etc/rc.d/np.d/step SputLite start
30093 30092  5196 4228 00:00:00 S perl /etc/rc.d/np.d/step SputLite status
30098 29255 21284 19784 00:00:00 S /usr/bin/kernel.pl (event 19967)   
30102 29255 21292 19792 00:00:00 S /usr/bin/kernel.pl (event 21911)   
30106 30082 21284 19792 00:00:00 S /usr/bin/kernel.pl (event 12648)   
30107 30090  1092  396 00:00:00 S /usr/sbin/sendmail -FCronDaemon -odi -oem root
30108 30093  5204 4216 00:00:00 S perl /etc/rc.d/np.d/step SputLite status
30109 30102 21308 19792 00:00:00 S /usr/bin/kernel.pl (event 21911)   
30110  3032  2340  688 00:00:00 S /bin/ps -o pid,ppid,vsz,rss,time,args -ewwww
30111  2639  8572 7392 00:00:00 S perl /usr/bin/gogo.pl --fname=SpreadBridge --user=nocpulse -- /usr/local/bin/spbridge --mode client
30112 30098 21300 19784 00:00:00 S /usr/bin/kernel.pl (event 19967)
';
}


1;
