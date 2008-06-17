package NOCpulse::Probe::DataSource::InetSocket;

use strict;

use Error qw(:try);

use IO::Socket;
use Time::HiRes qw(gettimeofday tv_interval);

use NOCpulse::Log::Logger;

use base qw(NOCpulse::Probe::DataSource::AbstractDataSource);

use Class::MethodMaker
  get_set => 
  [qw(
      protocol
      service
      host
      port
      read_bytes
      timeout_seconds
      latency
      found_expected_content
      inet_socket
      _start_time
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, %in_args) = @_;

    my %own_args = ();

    $self->datasource_arg('protocol',        undef, \%in_args, \%own_args);
    $self->datasource_arg('service',         undef, \%in_args, \%own_args);
    $self->datasource_arg('host',            undef, \%in_args, \%own_args);
    $self->datasource_arg('port',            undef, \%in_args, \%own_args);
    $self->datasource_arg('timeout_seconds', undef, \%in_args, \%own_args);
    $self->datasource_arg('read_bytes',      undef, \%in_args, \%own_args);

    $own_args{protocol}        ||= 'tcp';
    $own_args{timeout_seconds} ||= 10;
    $own_args{read_bytes}      ||= 1024;

    $self->SUPER::init(%own_args);

    unless (lc($self->protocol) eq 'tcp' || lc($self->protocol) eq 'udp') {
        my $msg = sprintf($self->_message_catalog->socket('bad_proto'), 
                          $self->protocol);
        throw NOCpulse::Probe::InternalError($msg);
    }

    if ($self->auto_connect) {
        $self->connect();
    }

    return $self;
}

sub connect {
    my $self = shift;

    $self->_start_time([gettimeofday]);

    #BZ 165759: IP addresses with leading zeros in any octets need
    #to be fixed so requests work correctly
    my $host = $self->host;
    my @octets = split(/\./, $host);
    foreach my $octet (@octets) {
        $octet =~ s/^0*//;
        $octet = 0 unless $octet;
    }
    $host = join('.', @octets);

    my $sock = IO::Socket::INET->new(PeerAddr => $host,
                                     PeerPort => $self->port,
                                     Proto    => $self->protocol,
                                     Timeout  => $self->timeout_seconds);
    $sock or throw NOCpulse::Probe::DataSource::ConnectError($@);
    $self->inet_socket($sock);
}

sub disconnect {
    my $self = shift;

    $self->inet_socket->close() if $self->inet_socket;
}

sub execute {
    my ($self, %args) = @_;

    my $send          = $args{send};
    my $pause_seconds = $args{pause};
    my $expect        = $args{expect};
    my $quit          = $args{quit};

    # If there's no checking being done, don't bother sending or reading.
    unless ($expect) {
        $self->finish(undef, undef, 1, $quit);
        return;
    }

    if ($send) {
        $Log->log(2, "Send: >>>$send<<<\n");
        $send = $self->expand_escapes($send);
        $self->inet_socket->send($send);
        if ($@) {
            throw NOCpulse::Probe::DataSource::ExecuteError($@);
        }
        sleep($pause_seconds) if $pause_seconds;
    }

    my $got_expect = 0;
    my $response;

    # Escape regex chars in the expect string.
    $expect =~ s/\+/\\\+/isg;
    $expect =~ s/\?/\\\?/isg;
    $expect =~ s/\{/\\\{/isg;
    $expect =~ s/\}/\\\}/isg;
    $expect =~ s/\*/\\\*/isg;

    local $SIG{'ALRM'} = sub { 
        $self->timed_out(1);
        my $msg = sprintf($self->_message_catalog->socket('timed_out'),
                          uc($self->protocol), $self->port, $self->timeout_seconds);
        throw NOCpulse::Probe::DataSource::TimedOutError($msg);
    };
    alarm($self->timeout_seconds);

    # Read until we either match the pattern, have no
    # more to read, or time out.
    try {
        while (1) {
            my $got;
            $self->inet_socket->recv($got, $self->read_bytes);
            $Log->log(4, "Got: >>>$got<<<\n");
            length($got) or last;
            $response .= $got;
            if ($expect && $response =~ /$expect/) {
                $got_expect = 1;
                last;
            }
        }
        alarm(0);

        $Log->log(2, "Complete response: >>>$response<<<\n");

        $self->finish($response, $@, $got_expect, $quit);

    } catch NOCpulse::Probe::DataSource::TimedOutError with {
        alarm(0);
        my $err = shift;
        if ($expect && $response && !$self->found_expected_content) {
            $Log->log_method(2, "send", 
                             "timed out looking for expect string $expect in $response\n");
            $self->finish($response, $self->errors, 0);
            $self->results($response);
        } else {
            $Log->log_method(2, "send", "timed out: $err\n");
            throw $err;
        }

    } otherwise {
        alarm(0);
        my $err = shift;
        $Log->log_method(2, "send", "failed: $err\n");
        throw $err;
    };
}

sub finish {
    my ($self, $response, $errors, $got_expect, $quit) = @_;

    $self->results($response);
    $self->errors($errors);
    $self->found_expected_content($got_expect);

    $self->inet_socket->send($quit) if $quit;

    my $end_time = [gettimeofday];
    my $elapsed = tv_interval($self->_start_time, $end_time);
    $self->latency($elapsed);
}

sub expand_escapes {
    my ($self, $str)  = @_;

    # Do Perl-like interpolated string expansion
    $str =~ s/\\n/\n/g;                      # Newlines
    $str =~ s/\\t/\t/g;                      # Tabs
    $str =~ s/\\r/\r/g;                      # Carriage returns
    $str =~ s/\\f/\f/g;                      # Form feeds
    $str =~ s/\\b/\b/g;                      # Backspaces
    $str =~ s/\\a/\a/g;                      # Audible bells
    $str =~ s/\\e/\e/g;                      # Escapes
    $str =~ s/\\c(.)/chr(ord(uc($1))-64)/eg; # Arbitrary control chars
    $str =~ s/\\0(\d\d)/chr(oct($1))/eg;     # Arbitrary octal chars
    $str =~ s/\\x(\d\d)/chr(hex($1))/eg;     # Arbitrary hex chars

    return $str;
}

1;
