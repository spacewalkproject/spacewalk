package NOCpulse::Probe::DataSource::test::TestWindowsCommand;

use strict;

use Error ':try';
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::DataSource::WindowsCommand;
use NOCpulse::Probe::Shell::CannedWindowsService;
use NOCpulse::Probe::Config::ProbeRecord;

use base qw(Test::Unit::TestCase);

my $HOST = 'eng-nt-server.nocpulse.net';

sub set_up {
    my $self = shift;

    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new({recid => 111, auto_update => 1});
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new(probe_record => $probe_rec);
}

sub test_connect {
    my $self = shift;

    my $cmd = $self->{factory}->windows_command(ip_0    => $HOST,
                                                port_0  => '4545',
                                                timeout => '5',
                                                auto_connect => 0);
    $cmd->connect();
    $self->assert($cmd->connected, "Cannot connect to windows command: ", $cmd->errors);
    $cmd->disconnect();
}

sub test_perf_list {
    my $self = shift;

    my $cmd = $self->{factory}->windows_command(ip_0    => $HOST,
                                                port_0  => '4545',
                                                timeout => '5');
    $self->assert($cmd->connected, "Autoconnect not working");

    $cmd->perf_list('Process', 1);

    $self->assert($cmd->results, "No results from perf_list; errors: ", $cmd->errors);

    $cmd->disconnect();
}

sub test_perf_data {
    my $self = shift;

    my $cmd = $self->{factory}->windows_command(ip_0    => $HOST,
                                                port_0  => '4545',
                                                timeout => '5');
    $self->assert($cmd->connected, "Autoconnect not working");

    my $data = $cmd->perf_data('Process', 'Elapsed Time', 'nocpd');

    $self->assert($cmd->results, "No results from perf_data; errors: ", $cmd->errors);
    $self->assert($data, "Data value not parsed from perf_data");

    $cmd->disconnect();
}

sub test_event_reader {
    my $self = shift;

    my $cmd = $self->{factory}->windows_command(ip_0    => $HOST,
                                                port_0  => '4545',
                                                timeout => '5');
    $self->assert($cmd->connected, "Autoconnect not working");

    my @events = $cmd->event_reader(log => 'System', eventtype => 'Warning');


    $self->assert($cmd->results,"No results from event_reader; errors: ", $cmd->errors);
    $self->assert(scalar(@events), "No events parsed");

    $cmd->disconnect();
}

1;
