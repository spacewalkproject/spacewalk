package NOCpulse::Probe::Shell::test::TestWindowsService;

use strict;

use Error ':try';
use Carp;
use NOCpulse::Probe::Shell::AbstractShell;
use NOCpulse::Probe::Shell::WindowsService;

use base qw(Test::Unit::TestCase);

# Grab any stray sigpipes
$SIG{'PIPE'} = sub { Carp::croak "Global sigpipe received\n"; };

my $HOST = 'eng-nt-server';

sub test_connect {
    my $self = shift;

    my $shell;

    $shell = NOCpulse::Probe::Shell::WindowsService->new(ip_0    => $HOST,
                                                         port_0  => '4545',
                                                         timeout => '5');
    $self->assert($shell->connect, "Cannot connect to windows service: ", $shell->stderr);
    $self->assert($shell->host_service_version, "No host service version set");

    $shell = NOCpulse::Probe::Shell::WindowsService->new(ip      => $HOST,
                                                         port    => '4545',
                                                         timeout => '5');
    $self->assert($shell->connect, "Cannot connect to windows service with ip/port: ",
                  $shell->stderr);
}

sub test_bad_command {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::WindowsService->new(ip_0    => $HOST,
                                                            port_0  => '4545',
                                                            timeout => '5');
    $self->assert($shell->connect, "Cannot connect to windows service: ", $shell->stderr);
    $shell->run('what is this anyway');
    $self->assert($shell->command_status == -1, 'Command status not -1: ',
                  $shell->command_status);
    $self->assert(length($shell->stderr) > 0, 'Stderr is empty with bad command: ',
                  $shell->stderr);
    $self->assert(length($shell->stdout) == 0, 'Stdout is not empty with bad command: ',
                  $shell->stdout);
}

sub test_perflist {
    my $self = shift;
    my $shell = NOCpulse::Probe::Shell::WindowsService->new(ip_0    => $HOST,
                                                            port_0  => '4545',
                                                            timeout => '15');
    $self->assert($shell->connect, "Cannot connect to windows service: ", $shell->stderr);
    my $command = 'run PerfList.exe';
    $shell->run($command);
    $self->assert_shell_ok($shell);
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
}

1;
