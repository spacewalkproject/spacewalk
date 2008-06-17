package NOCpulse::Probe::DataSource::test::TestInetSocket;

use strict;

use Error qw(:try);

use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::DataSource::InetSocket;

use base qw(Test::Unit::TestCase);

sub set_up {
    my $self = shift;
    $self->{factory} = NOCpulse::Probe::DataSource::Factory->new();
}

sub test_http {
    my $self = shift;
    my $data_source = $self->{factory}->inet_socket(host => 'mcchesney.nocpulse.net',
                                                    port => 80,
                                                    protocol => 'tcp',
                                                    timeout_seconds => 5);
    $data_source->execute(send => 'GET / HTTP/1.0\n\n',
                          expect => '<HTML>');
    $self->assert($data_source->found_expected_content, "Expect not found in ",
                  $data_source->results);
    $self->assert($data_source->results =~ '<HTML>', "Expect not actually present");
}

# If the protocol does not have a natural end point and
# the expect string is not found, the check will actaully time
# out but report that the expect string was missing.
sub test_timeout_expect {
    my $self = shift;
    my $data_source = $self->{factory}->inet_socket(host => 'mail.nocpulse.net',
                                                    port => 25,
                                                    protocol => 'tcp',
                                                    timeout_seconds => 1);
    $data_source->execute(expect => 'not here', quit => 'QUIT\n');
    $self->assert(!$data_source->found_expected_content, "Expect found in ",
                  $data_source->results);
}

sub test_errors {
    my $self = shift;
    my %CONNECT_ARGS = 
      (
       host => 'mcchesney.nocpulse.net',
       port => 80,
       protocol => 'tcp',
       timeout_seconds => 5
      );
    my $sock;
    my %args;

    %args = %CONNECT_ARGS;
    $args{host} = 'not_a_host';
    $self->try_bad('host', %args);

    %args = %CONNECT_ARGS;
    $args{port} = 12345;
    $self->try_bad('port', %args);

    %args = %CONNECT_ARGS;
    $args{protocol} = 'saywhat';
    try {
        my $sock = $self->{factory}->inet_socket(%args);
        $sock->execute(send => 'foo bar baz\n');
        $self->fail("No connect error with bad protocol");
    } catch NOCpulse::Probe::InternalError with {
    };
}

sub test_send_timeout {
    my $self = shift;
    my %args =
      (
       host => 'mcchesney.nocpulse.net',
       port => 80,
       protocol => 'tcp',
       timeout_seconds => 1,
      );
    try {
        my $sock = $self->{factory}->inet_socket(%args);
        $sock->execute(send => 'GET /cgi-bin/timeout.cgi?howlong=2\n', expect => 'Slept');
        $self->fail("Did not time out");
    } catch NOCpulse::Probe::DataSource::TimedOutError with {
    };
}

sub test_connect_timeout {
    my $self = shift;
    my %args = 
      (
       host => '1.2.3.4',
       port => 1234,
       protocol => 'tcp',
       timeout_seconds => 1,
      );
    try {
        my $sock = $self->{factory}->inet_socket(%args);
        $self->fail("Did not time out on connect");
    } catch NOCpulse::Probe::DataSource::ConnectError with {
    };
}

sub try_bad {
    my ($self, $context, %args) = @_;

    try {
        my $sock = $self->{factory}->inet_socket(%args);
        $sock->execute(send => 'foo bar baz\n');
        $self->fail("No connect error with bad $context");
    } catch NOCpulse::Probe::DataSource::ConnectError with {
    };
}


1;
