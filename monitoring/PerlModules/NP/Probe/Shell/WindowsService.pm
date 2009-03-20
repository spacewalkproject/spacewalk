package NOCpulse::Probe::Shell::WindowsService;

use strict;

use IO::Socket;
use IO::Select;
use Net::SSLeay qw(die_now die_if_ssl_error);
Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms(); # Important!
Net::SSLeay::randomize();

use NOCpulse::Log::Logger;
use NOCpulse::Config;
use NOCpulse::Probe::Error;

use base qw(NOCpulse::Probe::Shell::AbstractShell);

use Class::MethodMaker
  get_set =>
  [qw(
      host
      port
      host_service_version
      _connected_socket
      _ssl
      _ssl_context
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


# Sets up default args.
sub init {
    my ($self, %in_args) = @_;
    
    # Convert template-style cruft.
    my %args = $self->_transfer_args(\%in_args,
                                     {ip_0    => 'host',
                                      ip      => 'host',
                                      port_0  => 'port',
                                      timeout => 'timeout_seconds'});
    $args{write_timeout_seconds} = 5;

    $self->SUPER::init(%args);
}

# Sets up SSL connection.
sub connect {
    my $self = shift;
    
    my $config = new NOCpulse::Config;
    my $privateKey = $config->get('netsaint', 'satPemKeyFile');
    my $certFile = $config->get('netsaint', 'satPemCertFile');

    $Log->log(2, "host ", $self->host, ", port ", $self->port, "\n");

    my $sock = IO::Socket::INET->new(PeerAddr => $self->host,
                                     PeerPort => $self->port,
                                     Type     => SOCK_STREAM,
                                     Proto    => "TCP",
                                     Timeout  => $self->timeout_seconds);
    unless ($sock) {
        throw NOCpulse::Probe::Shell::ConnectError(
            sprintf($self->_message_catalog->winsvc('connect_failed'),
                    $self->host, $self->port));
    }  
    
    $sock->sockopt(SO_LINGER, 0);
    
    # SSLify the socket
    my $ctx = Net::SSLeay::CTX_v3_new() or 
      throw NOCpulse::Probe::Shell::WindowsService::SSLError(
          $self->_message_catalog->winsvc('ssl_ctx'), $!);
    
    Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL);
    my $msg = $self->_message_catalog->winsvc('ssl_ctx_opt');
    if (Net::SSLeay::print_errs($msg)) {
        throw NOCpulse::Probe::Shell::WindowsService::SSLError($msg, $!);
    }
    
    Net::SSLeay::CTX_use_RSAPrivateKey_file ($ctx, $privateKey, &Net::SSLeay::FILETYPE_PEM);
    $msg = $self->_message_catalog->winsvc('ssl_private_key');
    if (Net::SSLeay::print_errs($msg)) {
        throw NOCpulse::Probe::Shell::WindowsService::SSLError($msg, $!);
    }

    Net::SSLeay::CTX_use_certificate_file($ctx, $certFile, &Net::SSLeay::FILETYPE_PEM);
    $msg = $self->_message_catalog->winsvc('ssl_cert');
    if (Net::SSLeay::print_errs($msg)) {
        throw NOCpulse::Probe::Shell::WindowsService::SSLError($msg, $!);
    }
    
    my $ssl = Net::SSLeay::new($ctx) or
      throw NOCpulse::Probe::Shell::WindowsService::SSLError(
          $self->_message_catalog->winsvc('ssl_new'), $!);
    
    Net::SSLeay::set_fd($ssl, fileno($sock)); # Must use fileno
    my $rc = Net::SSLeay::connect($ssl);
    if ($rc != 1) {
        if ($Log->loggable(2)) {
            Net::SSLeay::print_errs($self->_message_catalog->winsvc('ssl_connect'));
        }
        my @errors = ();
        my $msgfmt = $self->_message_catalog->winsvc('ssl_error_string');
        while (my $err = Net::SSLeay::ERR_get_error()) {
            push(@errors, sprintf($msgfmt, Net::SSLeay::ERR_error_string($err), $err));
        }
        $self->stderr(join('; ', @errors));
        my $msg = sprintf($self->_message_catalog->winsvc('ssl_connect'), $self->stderr, $rc);
        throw NOCpulse::Probe::Shell::WindowsService::SSLError($msg, $rc);
    }
    
    $self->_connected_socket($sock);
    $self->_ssl($ssl);
    $self->_ssl_context($ctx);
    
    # The service always sends a version announcement or "ERROR" on connect.
    my $welcome = $self->_read_one_line();
    $self->handle_read_errors();
    if ($welcome =~ /ERROR\:\s(.*)/) {
        $self->stderr($1);
        $self->connected(0);
        my $msg = sprintf($1,
                          $self->host, $self->port);
        throw NOCpulse::Probe::Shell::ConnectError($msg);
    }
    
    $self->connected(1);

    # Get the current package version for the server. 
    $self->write_command("pkgver");
    my $ver = $self->_read_one_line();
    $self->handle_read_errors();
    $ver =~ s/^\D*//i;
    chomp $ver;
    $self->host_service_version($ver);
    $Log->log(3, "package version: $ver\n");

    return $self->connected;
}

# Closes SSL connection.
sub disconnect {
    my $self = shift;
    
    return unless $self->connected;
    
    $Log->log(2, "Disconnecting\n");
    
    $self->connected(0);
    
    my $sock = $self->_connected_socket;
    if (defined($sock)) {
        # Tear down the connection.
        $sock->shutdown(2);
        $sock->close;
    }
    
    # Clean up SSL.
    my $ssl = $self->_ssl;
    my $ctx = $self->_ssl_context;
    defined($ssl) and Net::SSLeay::free($ssl);
    defined($ctx) and Net::SSLeay::CTX_free($ctx);
}

# Initializes the end-of-data marker.
sub end_marker_init {
    my $self = shift;
    my $marker = "__END_OF_DATA__";
    $self->end_marker($marker);
    $self->end_marker_regex(qr/$marker/);
}

# Writes a command to the SSL connection.
sub write_command {
    my ($self, $command) = @_;

    my $sel = new IO::Select($self->_connected_socket);
    
    # SIGPIPE will occur if the connection closes on the server side
    # between the call to can_write and write. Trigger on the return
    # value from the call to write instead.
    local $SIG{'PIPE'} = 'IGNORE';
    
    # Make sure the socket is writeable.
    my @writeable = $sel->can_write($self->write_timeout_seconds);
    my $written = 0;
    if (scalar(@writeable) > 0) {
        $written = Net::SSLeay::write($self->_ssl, $command);
    }
    unless ($written > 0) {
        $self->connection_broken(1);
        $self->disconnect;
        $Log->log(2, "Connection broken trying to write command '$command'\n");
        throw NOCpulse::Probe::Shell::LostConnectionError(
            $self->_message_catalog->winsvc('lost_connection'));
    }
}

# Reads from the SSL connection.
sub read_result {
    my $self = shift;

    $Log->log(3, "entered\n");
    
    my $marker_regex = $self->end_marker_regex;
    my $got;
    my @responses = ();
    while (1) {
        $got = $self->_read_one_line();
        last unless defined($got);
        last if ($self->timed_out or $self->connection_broken);

        if ($marker_regex && $got =~ /$marker_regex/) {
            $got =~ s/$marker_regex//;
            last;
        }

        if ($got =~ /^ERROR/) {
            $self->stderr($got);
            $self->command_status(-1);
        }

        push(@responses, $got);

	if ($got =~ /^ACCEPT-/) {
	    last;
	}
    }

    unless ($self->stderr) {
        $self->stdout(join('', @responses));
    }

    if ($Log->loggable(4)) {
        $Log->log(4, "stdout >>>", $self->stdout, "<<<\nstderr >>>", $self->stderr, "<<<\n");
    } elsif ($Log->loggable(3)) {
        $Log->log(3, "exited, stdout has ", length($self->stdout), " characters, stderr >>>",
                  $self->stderr, "<<<\n");
    }

    return $self->stdout;
}

# Reads a single chunk from the SSL connection.
sub _read_one_line {
    my $self = shift;
    
    $self->timed_out(1);
    my $got;
    
    # Make sure the socket is readable.
    my $readable = new IO::Select($self->_connected_socket);
    my @ready = $readable->can_read($self->timeout_seconds);
    if (@ready) {
        $self->timed_out(0);
        $got = Net::SSLeay::read($self->_ssl);
        defined($got) or $self->connection_broken(1);
    }
    return $got;
}

1;
