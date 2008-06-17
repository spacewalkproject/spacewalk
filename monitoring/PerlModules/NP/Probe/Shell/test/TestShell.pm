package NOCpulse::Probe::Shell::test::TestShell;

use strict;

use Error ':try';
use Carp;

use NOCpulse::Probe::Shell::AbstractShell;
use NOCpulse::Probe::Shell::Local;
use NOCpulse::Probe::Shell::SSH;

use base qw(Test::Unit::TestCase);

# Grab any stray sigpipes
$SIG{'PIPE'} = sub { Carp::croak "Global sigpipe received\n"; };

sub test_local {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::Local->new;
    $self->assert($shell->connect, "Cannot connect locally: ", $shell->stderr);
    $shell->run("ls -1 /");
    $self->assert_shell_ok($shell);
    
    $shell->run('cat /blat/foop');
    $self->assert(length($shell->stderr) > 0, 'Stderr is empty with cat /blat/foop');
    
    $shell->run('cat $HOME/etc/SatCluster.ini');
    $self->assert_shell_ok($shell);
}

sub test_bad_exec {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::Local->new(shell_command => '/not/even/there');
    my $caught = 0;
    try {
        $shell->connect;
    } catch NOCpulse::Probe::Shell::ExecFailedError with {
        $caught = 1;
    };
    $self->assert($caught, "Connected with bad command: ", $shell->stderr);
}

sub test_write_without_connect {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::Local->new;
    my $caught = 0;
    try {
        $shell->run('echo 1');
    } catch NOCpulse::Probe::Shell::NotConnectedError with {
        $caught = 1;
    };
    $self->assert($caught, "No exception thrown for writing to unconnected shell");
    
    $self->assert($shell->connect, "Cannot connect locally: ", $shell->stderr);
    $shell->run("ls -1 /");
    $self->assert_shell_ok($shell);
    $shell->disconnect;
    $caught = 0;
    try {
        $shell->run('echo 1');
    } catch NOCpulse::Probe::Shell::NotConnectedError with {
        $caught = 1;
    };
    $self->assert($caught, "No exception thrown for writing to disconnected shell");
}

sub test_ssh_cmds {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::SSH->new(sshuser => 'nocpulse',
                                                 sshhost => 'rudder.nocpulse.net',
                                                 sshport => '4545',
                                                 timeout_seconds => '10');
    $self->assert($shell->connect, "Cannot connect remotely: ", $shell->stderr);
    
    $shell->run("ls -1 /");
    $self->assert_shell_ok($shell);
    
    $shell->run('cat FOO.bar');
    $self->assert(qr/cat: FOO.bar: No such file or directory/, $shell->stderr);
    $self->assert($shell->command_status == 1, 'Command status not 1: ', $shell->command_status);
    
    $shell->disconnect;
    $self->assert($shell->exit_code == 0, 'Non-zero exit code: ', $shell->exit_code);
}

sub try_bad_connect {
    my ($self, $shell, $context) = @_;

    my $caught = 0;
    try {
        $shell->connect();
        $shell->run("echo hola\n");
    } catch NOCpulse::Probe::Shell::ConnectError with {
        $caught = 1;
    } catch NOCpulse::Probe::Shell::LostConnectionError with {
        $caught = 1;
    };
    $self->assert($caught, "$context: ", $shell->stderr);
}

sub test_ssh_bad_user {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::SSH->new(sshuser => 'whodat',
                                                 sshhost => 'rudder.nocpulse.net',
                                                 sshport => '4545',
                                                 timeout_seconds => '10');
    $self->try_bad_connect($shell, "Connected with bad user");
}

sub test_ssh_bad_host {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::SSH->new(sshuser => 'nocpulse',
                                                 sshhost => 'thereisnohost',
                                                 sshport => '4545',
                                                 timeout_seconds => '10');
    $self->try_bad_connect($shell, "Connected with bad host");
}

sub test_ssh_bad_port {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::SSH->new(sshuser => 'nocpulse',
                                                 sshhost => 'rudder.nocpulse.net',
                                                 sshport => '12345',
                                                 timeout_seconds => '10');
    $self->try_bad_connect($shell, "Connected with bad port");
}

sub test_timeout {
    my $self = shift;
    my $shell =  NOCpulse::Probe::Shell::Local->new(timeout_seconds => '1');
    $self->assert($shell->connect, "Cannot connect locally: ", $shell->stderr);
    my $caught = 0;
    try {
        $shell->run('sleep 2');
    } catch NOCpulse::Probe::Shell::TimedOutError with {
        $caught = 1;
    };
    $self->assert($caught, 'Shell did not time out');
    $self->assert(! $shell->connection_broken, 'Shell connection broken');
    $self->assert($shell->failed, 'Shell did not fail');
}

sub test_die {
    my $self = shift;
    my $shell =  NOCpulse::Probe::Shell::Local->new(timeout_seconds => '10');
    $self->assert($shell->connect, "Cannot connect locally: ", $shell->stderr);
    my $caught = 0;
    try {
        $shell->run('kill -TERM $$');
    } catch NOCpulse::Probe::Shell::LostConnectionError with {
        $caught = 1;
    };
    $self->assert($caught, 'Shell did not lose its connection');
    $self->assert(! $shell->connected, 'Shell is still connected');
    $self->assert($shell->killed_by_signal == 15,
                  'Killed by signal '.$shell->killed_by_signal.' instead of 13');
    $self->assert(! $shell->timed_out, 'Shell timed out');
}

sub assert_shell_ok {
    my ($self, $shell) = @_;
    $self->assert(length($shell->stderr) == 0, 'Stderr not empty: ', $shell->stderr);
    $self->assert($shell->command_status == 0, 'Command status ', $shell->command_status,
                  " for ", $shell->last_command);
    $self->assert(! $shell->timed_out, 'Command timed out');
    $self->assert(! $shell->connection_broken, 'Shell connection was broken');
    $self->assert(! $shell->failed, 'Shell failed');
    $self->assert(length($shell->stdout) > 0, 'Stdout is empty');
    my $marker_regex = $shell->end_marker_regex;
    $self->assert($shell->stdout !~ /$marker_regex/, 'Stdout still has end marker: ',
                  $shell->stdout);
}

1;
