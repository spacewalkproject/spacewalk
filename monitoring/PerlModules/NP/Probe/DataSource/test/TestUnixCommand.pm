package NOCpulse::Probe::DataSource::test::TestUnixCommand;

use strict;

use Error ':try';
use NOCpulse::Probe::Error;
use NOCpulse::Probe::DataSource::UnixCommand;
use NOCpulse::Probe::DataSource::CannedUnixCommand;
use NOCpulse::Probe::DataSource::Factory;

use base qw(Test::Unit::TestCase);

$Error::DEBUG = 1;

sub set_up {
    my $self = shift;
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new();
}

sub test_local {
    my $self = shift;
    my $data_source = $self->ok_shellscript([], 'ls -l /opt/home/nocpulse/etc');
    $self->assert(qr/SatCluster.ini/, $data_source->results);
}

sub test_local_canned {
    my $self = shift;
    $self->{factory}->canned(1);
    my @canned = ('foo bar baz', 'blat foop');
    $self->{factory}->canned_results(@canned);

    my $data_source = $self->{factory}->unix_command(auto_connect => 1);
    $self->assert(qr/Canned/, ref($data_source));

    $data_source->execute('ls -l /opt/home/nocpulse/etc');
    $self->assert(qr/^$canned[0]$/, $data_source->results);

    $data_source->disconnect();
}

sub test_local_failure {
    my $self = shift;
    $self->bad_shellscript([], 'cat /asdf/ghjk');
}

sub test_local_auto_failure {
    my $self = shift;
    my $caught;
    try {
        $self->bad_shellscript([], 'cat /asdf/ghjk', 1);
    } catch NOCpulse::Probe::Error with {
        $caught = shift;
    };
    $self->assert($caught, "Die-on-failure did not");
}

sub test_local_unconnected {
    my $self = shift;
    $self->not_connected();
}

sub test_remote {
    my $self = shift;
    my $data_source = $self->ok_shellscript([shell   => 'SSHRemoteCommandShell',
                                             sshuser => 'nocpulse',
                                             sshhost => 'rudder.nplab.redhat.com',
                                             sshport => '4545'],
                                            'ls -l /opt/home/nocpulse/ssh/bin');
    $self->assert(qr/nocpulsed/, $data_source->results);
}

sub test_remote_login_failure {
    my $self = shift;
    my $caught;
    try {
        $self->bad_shellscript([shell   => 'SSHRemoteCommandShell',
                                sshuser => 'foo',
                                sshhost => 'rudder.nplab.redhat.com',
                                sshport => '4545'],
                               'does not matter');
    } catch NOCpulse::Probe::Shell::ConnectError with {
        $caught = shift;
    };
    $self->assert($caught, "Did not catch bad user");
    $self->assert(qr/Permission denied/, $caught->text);
}

sub test_remote_unconnected {
    my $self = shift;
    $self->not_connected();
}

sub ok_shellscript {
    my ($self, $args, $script) = @_;

    my $data_source = $self->{factory}->unix_command(@$args);
    $data_source->connect();
    $self->assert($data_source->connected, "Not connected");
    $data_source->execute($script);
    $self->assert(!$data_source->failed, "$script failed: ", $data_source->errors);
    $self->assert(length($data_source->results) > 0, 'Zero-length results');
    $data_source->disconnect();
    return $data_source;
}

sub bad_shellscript {
    my ($self, $args, $script, $auto_die) = @_;

    my $data_source = $self->{factory}->unix_command(@$args, auto_connect => 0);
    $data_source->die_on_failure($auto_die);
    $data_source->connect();
    $data_source->execute($script);
    $self->assert($data_source->failed, 'Did not fail: ', $data_source->errors);
    $self->assert(length($data_source->results) == 0, 
                  "Have results from failure: '".$data_source->results, "'");
    $self->assert($data_source->shell->command_status != 0, 'Exit code is zero');
    $data_source->disconnect();
    return $data_source;
}

sub not_connected {
    my $self = shift;
    my $data_source = $self->{factory}->unix_command(auto_connect => 0);
    my $caught = 0;
    try {
        $data_source->execute('this will fail badly');
    } catch NOCpulse::Probe::Shell::NotConnectedError with {
        $caught = 1;
    };
    $self->assert($caught, 'Did not catch exception: ' . $data_source->errors);
    return $data_source;
}

1;
