package NOCpulse::Probe::Utils::test::TestWindowsUpdate;

use strict;

use Error ':try';
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::DataSource::WindowsCommand;
use NOCpulse::Probe::Shell::WindowsService;
use NOCpulse::Probe::Utils::WindowsUpdate;
use NOCpulse::Probe::Utils::test::MockLWPAgent;
use NOCpulse::Probe::Shell::CannedWindowsService;
use NOCpulse::Probe::Config::ProbeRecord;

use base qw(Test::Unit::TestCase);

my $HOST = 'eng-nt-server';

sub init_mock_service {
    my $self = shift;

    eval {
        my $shell = NOCpulse::Probe::Shell::CannedWindowsService->new();
        my $cmd = NOCpulse::Probe::DataSource::WindowsCommand->new(shell => $shell);
        my $ua = NOCpulse::Probe::Utils::test::MockLWPAgent->new();
        $self->{updater} =
          NOCpulse::Probe::Utils::WindowsUpdate->new(windows_command   => $cmd,
                                                     auto_update       => 1,
                                                     installed_version => '2.2.1',
                                                     user_agent        => $ua);
    };
    if ($@) {
        $self->fail("Caught $@\n");
    }
}

sub test_version_compare {
    my $self = shift;

    $self->init_mock_service();
    $self->assert($self->{updater}->update_needed, "Update claimed to be unneeded vs. v2.2");
    $self->{updater}->installed_version('100.1.1');
    $self->assert(!$self->{updater}->update_needed, "Update claimed to be needed vs. v100");
}

sub test_fake_update {
    my $self = shift;

    $self->init_mock_service();
    $self->{updater}->windows_command->shell->results('ACCEPT', 'All done');

    my @responses = ();
    my $resp;

    $resp = HTTP::Response->new(200);
    $resp->content_length(10);
    push(@responses, $resp);

    $resp = HTTP::Response->new(200);
    $resp->content('1234567890');
    push(@responses, $resp);

    $self->{updater}->user_agent->responses(@responses);
    $self->{updater}->user_agent->data(undef, '1234567890');

    $self->{updater}->update_if_needed();
}

sub test_update_not_needed {
    my $self = shift;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new({recid => 111, auto_update => 1});
    my $factory = NOCpulse::Probe::DataSource::Factory->new(probe_record => $probe_rec);

    my $cmd = $factory->windows_command(ip_0    => $HOST,
                                        port_0  => '4545',
                                        timeout => '5');
    $self->assert($cmd->connected, "Cannot connect to windows command: ", $cmd->errors);

    $cmd->perf_list();

    $self->assert($cmd->results, "No results from reading event log; errors: ", $cmd->errors);
}

1;
