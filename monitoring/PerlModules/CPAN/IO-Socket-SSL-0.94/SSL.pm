#!/usr/bin/perl -w
#
# IO::Socket::SSL: 
#    a drop-in replacement for IO::Socket::INET that encapsulates
#    data passed over a network with SSL.
#
# Current Code Shepherd: Peter Behroozi, <behrooz at fas.harvard.edu>
#
# The original version of this module was written by 
# Marko Asplund, <aspa at kronodoc.fi>, who drew from
# Crypt::SSLeay (Net::SSL) by Gisle Aas.
#

package IO::Socket::SSL;

use IO::Socket;
use Net::SSLeay 1.08;
use Carp;
use strict;
use vars qw(@ISA $VERSION $DEBUG $ERROR $GLOBAL_CONTEXT_ARGS);

BEGIN {
    # Declare @ISA, $VERSION, $GLOBAL_CONTEXT_ARGS
    @ISA = qw(IO::Socket::INET);
    $VERSION = '0.94';
    $GLOBAL_CONTEXT_ARGS = {};

    #Make $DEBUG another name for $Net::SSLeay::trace
    *DEBUG = \$Net::SSLeay::trace;

    # Do Net::SSLeay initialization
    &Net::SSLeay::load_error_strings();
    &Net::SSLeay::SSLeay_add_ssl_algorithms();
    &Net::SSLeay::randomize();
}

sub import { foreach (@_) { @ISA=qw(IO::Socket::INET), next if /inet4/i;
			    @ISA=qw(IO::Socket::INET6), next if /inet6/i;
			    $DEBUG=$1 if /debug(\d)/; }}

# You might be expecting to find a new() subroutine here, but that is
# not how IO::Socket::INET works.  All configuration gets performed in
# the calls to configure() and either connect() or accept().

#Call to configure occurs when a new socket is made using
#IO::Socket::INET.  Returns false (empty list) on failure.
sub configure {
    my ($self, $arg_hash) = @_;
    return IO::Socket::SSL->error("Undefined IO::Socket::SSL object") unless($self);

    $self->configure_SSL($arg_hash)
	|| return;

    return ($self->SUPER::configure($arg_hash)
	|| $self->error("IO::Socket::INET configuration failed"));
}

sub configure_SSL {
    my ($self, $arg_hash) = @_;

    my $is_server = $arg_hash->{'SSL_server'} || $arg_hash->{'Listen'} || 0;
    my %default_args =
	('SSL_server'    => $is_server,
	 'SSL_key_file'  => $is_server ? 'certs/server-key.pem'  : 'certs/client-key.pem',
	 'SSL_cert_file' => $is_server ? 'certs/server-cert.pem' : 'certs/client-cert.pem',
	 'SSL_ca_file'   => 'certs/my-ca.pem',
	 'SSL_ca_path'   => 'ca/',
	 'SSL_use_cert'  => $is_server,
	 'SSL_verify_mode' => &Net::SSLeay::VERIFY_NONE(),
	 'SSL_verify_callback' => 0,
	 'SSL_check_crl' => 0,
	 'SSL_version' => 'sslv23',
	 'SSL_cipher_list' => 'ALL:!LOW:!EXP');

    #Replace nonexistant entries with defaults
    $arg_hash = { %default_args, %$GLOBAL_CONTEXT_ARGS, %$arg_hash };

    #Avoid passing undef arguments to Net::SSLeay
    !defined($arg_hash->{$_}) and ($arg_hash->{$_} = '') foreach (keys %$arg_hash);

    ${*$self}{'_SSL_arguments'}=$arg_hash;
    ${*$self}{'_SSL_ctx'} = new IO::Socket::SSL::SSL_Context($arg_hash) || return;
    ${*$self}{'_SSL_opened'}=1 if ($is_server);

    return $self;
}


#Call to connect occurs when a new client socket is made using
#IO::Socket::INET
sub connect {
    my $self = shift;
    return IO::Socket::SSL->error("Undefined IO::Socket::SSL object") unless($self);

    my $socket = $self->SUPER::connect(@_)
	|| return $self->error("IO::Socket::INET connect attempt failed");

    return $self->connect_SSL($socket) || $self->fatal_ssl_error;
}


sub connect_SSL {
    my ($self, $socket) = @_;
    my $arg_hash = ${*$self}{'_SSL_arguments'};
    ${*$self}{'_SSL_opened'}=1;

    my $fileno = ${*$self}{'_SSL_fileno'} = $socket->fileno();
    return $self->error("Socket has no fileno") unless (defined $fileno);

    my $ctx = ${*$self}{'_SSL_ctx'};  # Reference to real context
    my $ssl = ${*$self}{'_SSL_object'} = &Net::SSLeay::new($$ctx)
	|| return $self->error("SSL structure creation failed");

    &Net::SSLeay::set_fd($ssl, $fileno)
	|| return $self->error("SSL filehandle association failed");

    &Net::SSLeay::set_cipher_list($ssl, $arg_hash->{'SSL_cipher_list'})
	|| return $self->error("Failed to set SSL cipher list");

    if (&Net::SSLeay::connect($ssl)<1) {
	return $self->error("SSL connect attempt failed");
    }

    tie *{$self}, "IO::Socket::SSL::SSL_HANDLE", $self;

    return $self;
}


#Call to accept occurs when a new client connects to a server using
#IO::Socket::SSL
sub accept {
    my $self = shift;
    my $class = shift || 'IO::Socket::SSL';
    return IO::Socket::SSL->error("Undefined IO::Socket::SSL object") unless($self);
    my $arg_hash = ${*$self}{'_SSL_arguments'};

    my $socket = $self->SUPER::accept($class)
	|| return $self->error("IO::Socket::INET accept failed");

    return ($socket->accept_SSL(${*$self}{'_SSL_ctx'}, $arg_hash)
	    || $self->error($ERROR) || $socket->fatal_ssl_error);
}

sub accept_SSL {
    my ($socket, $ctx, $arg_hash) = @_;
    ${*$socket}{'_SSL_arguments'} = { %$arg_hash, SSL_server => 0 };
    ${*$socket}{'_SSL_ctx'} = $ctx;
    ${*$socket}{'_SSL_opened'}=1;

    my $fileno = ${*$socket}{'_SSL_fileno'} = fileno($socket);
    return $socket->error("Socket has no fileno") unless (defined $fileno);

    my $ssl = ${*$socket}{'_SSL_object'} = &Net::SSLeay::new($$ctx)
	|| return $socket->error("SSL structure creation failed");

    &Net::SSLeay::set_fd($ssl, $fileno)
	|| return $socket->error("SSL filehandle association failed");

    &Net::SSLeay::set_cipher_list($ssl, $arg_hash->{'SSL_cipher_list'})
	|| return $socket->error("Failed to set SSL cipher list");

    if (&Net::SSLeay::accept($ssl)<1) {
	return $socket->error("SSL accept failed");
    }

    tie *{$socket}, "IO::Socket::SSL::SSL_HANDLE", $socket;

    return $socket;
}


####### I/O subroutines ########################
sub generic_read {
    my ($self, $read_func, undef, $length, $offset) = @_;
    my $ssl = $self->get_ssl_object || return;

    my $data = $read_func->($ssl, $length);
    return $self->error("SSL read error") unless (defined $data);

    my $buffer=\$_[2];
    $length = length($data);
    $$buffer ||= '';
    $offset ||= 0;
    if ($offset>length($$buffer)) {
	$$buffer.="\0" x ($offset-length($$buffer));  #mimic behavior of read
    }

    substr($$buffer, $offset, length($$buffer), $data);
    return $length;
}

sub read {
    my $self = shift;
    return $self->generic_read(\&Net::SSLeay::read, @_);
}

sub peek {
    my $self = shift;
    if ($Net::SSLeay::VERSION >= 1.19 && &Net::SSLeay::OPENSSL_VERSION_NUMBER >= 0x0090601f) {
	return $self->generic_read(\&Net::SSLeay::peek, @_);
    } else {
	return $self->error("SSL_peek not supported for Net::SSLeay < v1.19 or OpenSSL < 0.9.6a");
    }
}

sub write {
    my ($self, undef, $length, $offset) = @_;
    my $ssl = $self->get_ssl_object || return;

    my $buffer = \$_[1];
    my $buf_len = length($$buffer);
    $length ||= $buf_len;
    $offset ||= 0;
    return $self->error("Invalid offset for SSL write") if ($offset>$buf_len);
    return 0 if ($offset==$buf_len);


    my $written = &Net::SSLeay::ssl_write_all
	($ssl, \substr($$buffer, $offset, $length));

    return $self->error("SSL write error") if ($written<0);
    return $written;
}

sub print {
    my $self = shift;
    my $ssl = $self->get_ssl_object || return;

    unless ($\ or $,) {
	foreach my $msg (@_) {
	    next unless defined $msg;
	    defined(&Net::SSLeay::write($ssl, $msg))
		|| return $self->error("SSL print error");
	}
    } else {
	defined(&Net::SSLeay::write($ssl, join(($, or ''), @_, ($\ or ''))))
	    || return $self->error("SSL print error");
    }
    return 1;
}

sub printf {
    my ($self,$format) = (shift,shift);
    local $\;
    return $self->print(sprintf($format, @_));
}

sub getc {
    my $self = shift;
    my $buffer;
    return $self->read($buffer, 1, 0) ? $buffer : ();
}

sub readline {
    my $self = shift;
    my $ssl = $self->get_ssl_object || return;

    if (wantarray) {
	return split (/^/, Net::SSLeay::ssl_read_all($ssl));
    }
    my $line = Net::SSLeay::ssl_read_until($ssl);
    return defined($line) ? $line : $self->error("SSL read error");
}

sub close {
    my $self = shift;
    my $close_args = (ref($_[0]) eq 'HASH') ? $_[0] : {@_};
    return IO::Socket::SSL->error("Undefined SSL object") unless($self);
    return $self->error("SSL object already closed") unless (${*$self}{'_SSL_opened'});

    if (my $ssl = ${*$self}{'_SSL_object'}) {
	$close_args->{'SSL_no_shutdown'} or &Net::SSLeay::shutdown($ssl);
	&Net::SSLeay::free($ssl);
	delete ${*$self}{'_SSL_object'};
    }

    if ($close_args->{'SSL_ctx_free'}) {
	my $ctx = ${*$self}{'_SSL_ctx'};
	delete ${*$self}{'_SSL_ctx'};
	$ctx->DESTROY();
    }

    if ($Net::SSLeay::VERSION>=1.18 and ${*$self}{'_SSL_certificate'}) {
	&Net::SSLeay::X509_free(${*$self}{'_SSL_certificate'});
    }

    my $arg_hash = ${*$self}{'_SSL_arguments'};
    untie(*$self) if (!$arg_hash->{'SSL_server'} 
		      and !$close_args->{_SSL_in_DESTROY});

    ${*$self}{'_SSL_opened'}=0;
    $self->SUPER::close unless ($close_args->{_SSL_in_DESTROY});
}

sub kill_socket {
    my $self = shift;
    shutdown($self, 2);
    $self->close(SSL_no_shutdown => 1) if (${*$self}{'_SSL_opened'});
    delete(${*$self}{'_SSL_ctx'});
    return;
}

sub fileno {
    my $self = shift;
    return ${*$self}{'_SSL_fileno'} || $self->SUPER::fileno();
}


####### IO::Socket::SSL specific functions #######
# get_ssl_object is for internal use ONLY!
sub get_ssl_object {
    my $self = shift;
    my $ssl = ${*$self}{'_SSL_object'};
    return IO::Socket::SSL->error("Undefined SSL object") unless($ssl);
    return $ssl;
}

sub pending {
    my $ssl = shift()->get_ssl_object || return;
    return &Net::SSLeay::pending($ssl);
}

sub start_SSL {
    my ($class,$socket) = (shift,shift);
    return $class->error("Not a socket") unless(ref($socket));
    my $arg_hash = (ref($_[0]) eq 'HASH') ? $_[0] : {@_};
    my $original_class = ref($socket);

    bless $socket, $class;
    $socket->configure_SSL($arg_hash) or bless($socket, $original_class) && return;
    $arg_hash = ${*$socket}{'_SSL_arguments'};

    my $result = ($arg_hash->{'SSL_server'} ?
		  $socket->accept_SSL(${*$socket}{'_SSL_ctx'}, $arg_hash)
		  : $socket->connect_SSL($socket));

    return $result ? $socket : bless($socket, $original_class) && ();
}

sub dump_peer_certificate {
    my $ssl = shift()->get_ssl_object || return;
    return &Net::SSLeay::dump_peer_certificate($ssl);
}

sub peer_certificate {
    my ($self, $field) = @_;
    my $ssl = $self->get_ssl_object || return;

    my $cert = ${*$self}{'_SSL_certificate'} ||= &Net::SSLeay::get_peer_certificate($ssl) ||
	return $self->error("Could not retrieve peer certificate");

    my $name = ($field eq "issuer" or $field eq "authority") ?
	Net::SSLeay::X509_get_issuer_name($cert) :
	Net::SSLeay::X509_get_subject_name($cert);

    return $self->error("Could not retrieve peer certificate $field") unless ($name);
    return &Net::SSLeay::X509_NAME_oneline($name);
}

sub get_cipher {
    my $ssl = shift()->get_ssl_object || return;
    return &Net::SSLeay::get_cipher($ssl);
}

sub errstr {
    my $self = shift;
    return ((ref($self) ? ${*$self}{'_SSL_last_err'} : $ERROR) or '');
}

sub fatal_ssl_error {
    my $self = shift;
    my $error_trap = ${*$self}{'_SSL_arguments'}->{'SSL_error_trap'};
    if (defined $error_trap and ref($error_trap) eq 'CODE') {
	$error_trap->($self, $self->errstr()."\n".$self->get_ssleay_error());
    } else { $self->kill_socket; }
    return;
}

sub get_ssleay_error {
    #Net::SSLeay will print out the errors itself unless we explicitly
    #undefine $Net::SSLeay::trace while running print_errs()
    local $Net::SSLeay::trace;
    return &Net::SSLeay::print_errs('SSL error: ') || '';
}

sub error {
    my ($self, $error, $destroy_socket) = @_;
    foreach ($error) {
	if (/ print / || / write / || / read /) {
	    my $ssl = ${*$self}{'_SSL_object'};
	    my $ssl_error = &Net::SSLeay::get_error($ssl, -1);
	    if ($ssl_error == &Net::SSLeay::ERROR_WANT_READ()) {
		$error.="\nSSL wants a read first!";
	    } elsif ($ssl_error == &Net::SSLeay::ERROR_WANT_WRITE()) {
		$error.="\nSSL wants a write first!";
	    } else {
		$error.=&Net::SSLeay::ERR_error_string
		    (&Net::SSLeay::ERR_get_error());
	    }
	}
    }
    carp $error."\n".$self->get_ssleay_error() if $DEBUG;
    ${*$self}{'_SSL_last_err'} = $error if (ref($self));
    $ERROR = $error;
    return;
}


sub DESTROY {
    my $self = shift || return;
    $self->close(_SSL_in_DESTROY => 1) if (${*$self}{'_SSL_opened'});
    delete(${*$self}{'_SSL_ctx'});
}


#######Extra Backwards Compatibility Functionality#######
sub socket_to_SSL { IO::Socket::SSL->start_SSL(@_); }
sub socketToSSL { IO::Socket::SSL->start_SSL(@_); }
sub sysread { &IO::Socket::SSL::read; }
sub syswrite { &IO::Socket::SSL::write; }
sub issuer_name { return(shift()->peer_certificate("issuer")) }
sub subject_name { return(shift()->peer_certificate("subject")) }
sub get_peer_certificate { return shift() }

sub context_init {
    return($GLOBAL_CONTEXT_ARGS = (ref($_[0]) eq 'HASH') ? $_[0] : {@_});
}

sub opened {
    my $self = shift;
    return ${*$self}{'_SSL_opened'};
}

sub want_read {
    my $self = shift;
    return scalar($self->errstr() =~ /SSL wants a read first!/);
}

sub want_write {
    my $self = shift;
    return scalar($self->errstr() =~ /SSL wants a write first!/);
}


#Redundant IO::Handle functionality
sub getline { return(scalar shift->readline()) }
sub getlines { if (wantarray()) { return(shift->readline()) }
	       else { croak("Use of getlines() not allowed in scalar context\n");  }}

#Useless IO::Handle functionality
sub truncate { croak("Use of truncate() not allowed with SSL\n") }
sub stat { croak("Use of stat() not allowed with SSL\n") }
sub ungetc { croak("Use of ungetc() not supported with this version of IO::Socket::SSL") }
sub setbuf { croak("Use of setbuf() not allowed with SSL\n") }
sub setvbuf { croak("Use of setvbuf() not allowed with SSL\n") }
sub fdopen { croak("Use of fdopen() not allowed with SSL\n") }


package IO::Socket::SSL::SSL_HANDLE;

sub TIEHANDLE {
    my ($class, $handle) = @_;
    bless \$handle, $class;
}
sub PRINT {
    my $handle = shift;
    return ${$handle}->print(@_);
}
sub PRINTF {
    my $handle = shift;
    return ${$handle}->printf(@_);
}
sub WRITE {
    my $handle = shift;
    return ${$handle}->write(@_);
}
sub READLINE {
    my $handle = shift;
    return ${$handle}->readline(@_);
}
sub GETC {
    my $handle = shift;
    return ${$handle}->getc(@_);
}
sub READ {
    my $handle = shift;
    return ${$handle}->read(@_);
}
sub CLOSE {                          #<---- Do not change this function!
    my $ssl = ${$_[0]};
    local @_;
    return $ssl->close();
}
sub FILENO {
    my $handle = shift;
    return ${$handle}->fileno(@_);
}

package IO::Socket::SSL::SSL_Context;

sub new {
    my ($class, $arg_hash) = @_;

    my $ctx = $arg_hash->{'SSL_reuse_ctx'};
    if ($ctx) {
	return $ctx if ($ctx = ${*$ctx}{'_SSL_ctx'});
    }

    foreach ($arg_hash->{'SSL_version'}) {
	$ctx = /^sslv2$/i ? &Net::SSLeay::CTX_v2_new() :
	       /^sslv3$/i ? &Net::SSLeay::CTX_v3_new() :
	       /^tlsv1$/i ? &Net::SSLeay::CTX_tlsv1_new() :
	                    &Net::SSLeay::CTX_new();
    }

    $ctx || return IO::Socket::SSL->error("Context-init failed");

    &Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL());

    my ($verify_mode, $verify_cb) = @{$arg_hash}{'SSL_verify_mode','SSL_verify_callback'};
    unless ($verify_mode == &Net::SSLeay::VERIFY_NONE())
    {
	&Net::SSLeay::CTX_load_verify_locations
	    ($ctx, @{$arg_hash}{'SSL_ca_file','SSL_ca_path'}) ||
	    return IO::Socket::SSL->error("Invalid certificate authority locations");
    }

    if ($arg_hash->{'SSL_check_crl'}) {
	if (&Net::SSLeay::OPENSSL_VERSION_NUMBER >= 0x0090702f) 
	{
	    &Net::SSLeay::X509_STORE_CTX_set_flags
		(&Net::SSLeay::CTX_get_cert_store($ctx),
		 &Net::SSLeay::X509_V_FLAG_CRL_CHECK);
	} else {
	    return IO::Socket::SSL->error("CRL not supported for OpenSSL versions less than 0.9.7b");
	}
    }

    if ($arg_hash->{'SSL_server'} || $arg_hash->{'SSL_use_cert'}) {
	my $filetype = &Net::SSLeay::FILETYPE_PEM();

	if ($arg_hash->{'SSL_passwd_cb'}) {
	    if ($Net::SSLeay::VERSION < 1.16) {
		return IO::Socket::SSL->error("Password callbacks are not supported for Net::SSLeay < v1.16");
	    } else {
		&Net::SSLeay::CTX_set_default_passwd_cb
		    ($ctx, $arg_hash->{'SSL_passwd_cb'});
	    }
	}

	&Net::SSLeay::CTX_use_PrivateKey_file
	    ($ctx, $arg_hash->{'SSL_key_file'}, $filetype)
	    || return IO::Socket::SSL->error("Failed to open Private Key");

	&Net::SSLeay::CTX_use_certificate_file
	    ($ctx, $arg_hash->{'SSL_cert_file'}, $filetype)
	    || return IO::Socket::SSL->error("Failed to open Certificate");
    }

    my $verify_callback = $verify_cb && 
	sub {
	    my ($ok, $ctx_store) = @_;
	    my ($cert, $error);
	    if ($ctx_store) {
		$cert = &Net::SSLeay::X509_STORE_CTX_get_current_cert($ctx_store);
		$error = &Net::SSLeay::X509_STORE_CTX_get_error($ctx_store);
		$cert &&= &Net::SSLeay::X509_NAME_oneline(&Net::SSLeay::X509_get_issuer_name($cert)).
		    &Net::SSLeay::X509_NAME_oneline(&Net::SSLeay::X509_get_subject_name($cert));
		$error &&= &Net::SSLeay::ERR_error_string($error);
	    }
	    return $verify_cb->($ok, $ctx_store, $cert, $error);
	};

    &Net::SSLeay::CTX_set_verify($ctx, $verify_mode, $verify_callback);

    return bless \$ctx, $class;
}


sub DESTROY {
    my $self = shift;
    $$self and &Net::SSLeay::CTX_free($$self);
    $$self = undef;
}


'True Value';


=head1 NAME

IO::Socket::SSL -- Nearly transparent SSL encapsulation for IO::Socket::INET.

=head1 SYNOPSIS

    use IO::Socket::SSL;

    my $client = new IO::Socket::SSL("www.example.com:https");

    if (defined $client) {
        print $client "GET / HTTP/1.0\r\n\r\n";
        print <$client>;
        close $client;
    } else {
        warn "I encountered a problem: ",
          &IO::Socket::SSL::errstr();
    }


=head1 DESCRIPTION

This module is a true drop-in replacement for IO::Socket::INET that uses
SSL to encrypt data before it is transferred to a remote server or
client.  IO::Socket::SSL supports all the extra features that one needs
to write a full-featured SSL client or server application: multiple SSL contexts,
cipher selection, certificate verification, and SSL version selection.  As an
extra bonus, it works perfectly with mod_perl.

If you have never used SSL before, you should read the appendix labelled 'Using SSL'
before attempting to use this module.

If you have used this module before, read on, as versions 0.93 and above
have several changes from the previous IO::Socket::SSL versions (especially
see the note about return values).


=head1 METHODS

IO::Socket::SSL inherits its methods from IO::Socket::INET, overriding them
as necessary.  If there is an SSL error, the method or operation will return an
empty list (false in all contexts).  The methods that have changed from the 
perspective of the user are re-documented here:

=over 4

=item B<new(...)>

Creates a new IO::Socket::SSL object.  You may use all the friendly options
that came bundled with IO::Socket::INET, plus (optionally) the ones that follow:

=over 2

=item SSL_version

Sets the version of the SSL protocol used to transmit data.  The default is SSLv2/3,
which auto-negotiates between SSLv2 and SSLv3.  You may specify 'SSLv2', 'SSLv3', or
'TLSv1' (case-insensitive) if you do not want this behavior.

=item SSL_cipher_list

If you do not care for the default list of ciphers ('ALL:!LOW:!EXP'), then look in
the OpenSSL documentation (L<http://www.openssl.org/docs/apps/ciphers.html#CIPHER_STRINGS>),
and specify a different set with this option.

=item SSL_use_cert

If this is set, it forces IO::Socket::SSL to use a certificate and key, even if
you are setting up an SSL client.  If this is set to 0 (the default), then you will
only need a certificate and key if you are setting up a server.

=item SSL_key_file

If your RSA private key is not in default place (F<certs/server-key.pem> for servers,
F<certs/client-key.pem> for clients), then this is the option that you would use to
specify a different location.  Keys should be PEM formatted, and if they are
encrypted, you will be prompted to enter a password before the socket is formed
(unless you specified the SSL_passwd_cb option).

=item SSL_cert_file

If your SSL certificate is not in the default place (F<certs/server-cert.pem> for servers,
F<certs/client-cert.pem> for clients), then you should use this option to specify the 
location of your certificate.  Note that a key and certificate are only required for an
SSL server, so you do not need to bother with these trifling options should you be
setting up an unauthenticated client.

=item SSL_passwd_cb

If your private key is encrypted, you might not want the default password prompt from
Net::SSLeay.  This option takes a reference to a subroutine that should return the
password required to decrypt your private key.  Note that Net::SSLeay >= 1.16 is
required for this to work.

=item SSL_ca_file

If you want to verify that the peer certificate has been signed by a reputable
certificate authority, then you should use this option to locate the file
containing the certificateZ<>(s) of the reputable certificate authorities if it is
not already in the file F<certs/my-ca.pem>.

=item SSL_ca_path

If you are unusually friendly with the OpenSSL documentation, you might have set
yourself up a directory containing several trusted certificates as separate files
as well as an index of the certificates.  If you want to use that directory for
validation purposes, and that directory is not F<ca/>, then use this option to
point IO::Socket::SSL to the right place to look.

=item SSL_verify_mode

This option sets the verification mode for the peer certificate.  The default
(0x00) does no authentication.  You may combine 0x01 (verify peer), 0x02 (fail
verification if no peer certificate exists; ignored for clients), and 0x04 
(verify client once) to change the default.

=item SSL_verify_callback

If you want to verify certificates yourself, you can pass a sub reference along
with this parameter to do so.  When the callback is called, it will be passed:
1) a true/false value that indicates what OpenSSL thinks of the certificate,
2) a C-style memory address of the certificate store,
3) a string containing the certificate's issuer attributes and owner attributes, and
4) a string containing any errors encountered (0 if no errors).
The function should return 1 or 0, depending on whether it thinks the certificate
is valid or invalid.  The default is to let OpenSSL do all of the busy work.

=item SSL_check_crl

If you want to verify that the peer certificate has not been revoked by the
signing authority, set this value to true.  OpenSSL will search for the CRL
in your SSL_ca_path.  See the Net::SSLeay documentation for more details.
Note that this functionality appears to be broken with OpenSSL < 0.9.7b,
so its use with lower versions will result in an error.

=item SSL_reuse_ctx

If you have already set the above options (SSL_use_cert through SSL_verify_mode;
this does not include SSL_cipher_list yet) for a previous instance of
IO::Socket::SSL, then you can reuse the SSL context of that instance by passing
it as the value for the SSL_reuse_ctx parameter.  If you pass any context-related options,
they will be ignored.  Note that, contrary to versions of IO::Socket::SSL below v0.90,
a global SSL context will not be implicitly used.

=item SSL_error_trap

When using the accept() or connect() methods, it may be the case that the
actual socket connection works by the SSL negotiation fails, as in the case of
an HTTP client connecting to an HTTPS server.  Passing a subroutine ref attached
to this parameter allows you to gain control of this socket instead of having it
be forcibly closed.  The subroutine, if called, will be passed two parameters: 
a reference to the socket on which the SSL negotiation failed and and the full
text of the error message.

=back

=item B<close(...)>

There are a number of nasty traps that lie in wait if you are not careful about using
close().  The first of these will bite you if you have been using shutdown() on your
sockets.  Since the SSL protocol mandates that a SSL "close notify" message be
sent before the socket is closed, a shutdown() that closes the socket's write channel
will cause the close call to hang.  For a similar reason, if you try to close a
copy of a socket (as in a forking server) you will affect the original socket as well.
To get around these problems, call close with an object-oriented syntax 
(e.g. $socket->close(SSL_no_shutdown => 1))
and one or more of the following parameters:

=over 2

=item SSL_no_shutdown

If set to a true value, this option will make close() not use the SSL_shutdown() call
on the socket in question so that the close operation can complete without problems
if you have used shutdown() or are working on a copy of a socket.

=item SSL_ctx_free

If you want to make sure that the SSL context of the socket is destroyed when
you close it, set this option to a true value.

=back

=item B<peek()>

This function has exactly the same syntax as sysread(), and performs nearly the same
task (reading data from the socket) but will not advance the read position so
that successive calls to peek() with the same arguments will return the same results.
This function requires Net::SSLeay v1.19 or higher and OpenSSL 0.9.6a or later to work.


=item B<pending()>

This function will let you know how many bytes of data are immediately ready for reading
from the socket.  This is especially handy if you are doing reads on a blocking socket
or just want to know if new data has been sent over the socket.


=item B<get_cipher()>

Returns the string form of the cipher that the IO::Socket::SSL object is using.

=item B<dump_peer_certificate()>

Returns a parsable string with select fields from the peer SSL certificate.  This
method directly returns the result of the dump_peer_certificate() method of Net::SSLeay.

=item B<peer_certificate($field)>

If a peer certificate exists, this function can retrieve values from it.  Right now, the
only fields it can return are "authority" and "owner" (or "issuer" and "subject" if
you want to use OpenSSL names), corresponding to the certificate authority that signed the
peer certificate and the owner of the peer certificate.  This function returns a string
with all the information about the particular field in one parsable line.

=item B<errstr()>

Returns the last error (in string form) that occurred.  If you do not have a real
object to perform this method on, call &IO::Socket::SSL::errstr() instead.
For read and write errors on non-blocking sockets, this method may include the string 
C<SSL wants a read first!> or C<SSL wants a write first!> meaning that the other side
is expecting to read from or write to the socket and wants to be satisfied before you
get to do anything.

=item B<< IO::Socket::SSL->start_SSL($socket, ... ) >>

This will convert a glob reference or a socket that you provide to an IO::Socket::SSL
object.  You may also pass parameters to specify context or connection options as with
a call to new().  If you are using this function on an accept()ed socket, you must
set the parameter "SSL_server" to 1, i.e. IO::Socket::SSL->start_SSL($socket, SSL_server => 1).
If you have a class that inherits from IO::Socket::SSL and you want the $socket to be blessed
into your own class instead, use MyClass->start_SSL($socket) to achieve the desired effect.
Note that if start_SSL() fails in SSL negotiation, $socket will remain blessed in its original class.

=back

The following methods are unsupported (not to mention futile!) and IO::Socket::SSL
will emit a large CROAK() if you are silly enough to use them:

=over 4

=item truncate

=item stat

=item ungetc

=item setbuf

=item setvbuf

=item fdopen

=back


=head1 RETURN VALUES

A few changes have gone into IO::Socket::SSL v0.93 and later with respect to
return values.  The behavior on success remains unchanged, but for I<all> functions,
the return value on error is now an empty list.  Therefore, the return value will be
false in all contexts, but those who have been using the return values as arguments
to subroutines (like C<mysub(new IO::Socket::SSL(...), ...)>) may run into problems.
The moral of the story: I<always> check the return values of these functions before
using them in any way that you consider meaningful.


=head1 IPv6

Support for IPv6 with IO::Socket::SSL is highly experimental, as none of the author's
machines use IPv6 and hence he cannot test IO::Socket::SSL with them.  However, if
you consider yourself sufficiently ready for bug-reporting, pass the 'inet6' option
to IO::Socket::SSL when calling it (i.e. C<use IO::Socket::SSL qw(inet6);>).  You will
need IO::Socket::INET6 to use this option.  If you absolutely do not want to use this
(or want a quick change back to IPv4), pass the 'inet4' option instead.


=head1 DEBUGGING

If you are having problems using IO::Socket::SSL despite the fact that can recite backwards
the section of this documentation labelled 'Using SSL', you should try enabling debugging.  To
specify the debug level, pass 'debug#' (where # is a number from 0 to 4) to IO::Socket::SSL
when calling it:

=over 4

=item use IO::Socket::SSL qw(debug0);

#No debugging (default).

=item use IO::Socket::SSL qw(debug1);

#Only print out errors.

=item use IO::Socket::SSL qw(debug2);

#Print out errors and cipher negotiation.

=item use IO::Socket::SSL qw(debug3);

#Print out progress, ciphers, and errors.

=item use IO::Socket::SSL qw(debug4);

#Print out everything, including data.

=back

You can also set $IO::Socket::SSL::DEBUG to 0-4, but that's a bit of a mouthful,
isn't it?

=head1 EXAMPLES

See the 'example' directory.

=head1 BUGS

I have never shipped a module with a known bug, and IO::Socket::SSL is no
different.  If you feel that you have found a bug in the module and you are
using the latest versions of Net::SSLeay and OpenSSL, send an email immediately to 
<behrooz at fas.harvard.edu> with a subject of 'IO::Socket::SSL Bug'.  I am 
I<not responsible> for problems in your code, so make sure that an example
actually works before sending it. It is merely acceptable if you send me a bug 
report, it is better if you send a small chunk of code that points it out,
and it is best if you send a patch--if the patch is good, you might see a release the 
next day on CPAN. Otherwise, it could take weeks . . . 


=head1 LIMITATIONS

IO::Socket::SSL uses Net::SSLeay as the shiny interface to OpenSSL, which is
the shiny interface to the ugliness of SSL.  As a result, you will need both Net::SSLeay
and OpenSSL on your computer before using this module.

=head1 DEPRECATIONS

The following functions are deprecated and are only retained for compatibility:

=over 2

=item context_init() 

(use the SSL_reuse_ctx option if you want to re-use a context)


=item socketToSSL() and socket_to_SSL()

(use IO::Socket::SSL->start_SSL() instead)


=item get_peer_certificate() and friends 

(use the peer_certificate() function instead)


=item want_read() and want_write()

(search for the appropriate string in errstr())


=back

The following classes have been removed:

=over 2

=item SSL_SSL

(not that you should have been directly accessing this anyway):

=item X509_Certificate 

(but get_peer_certificate() will still Do The Right Thing)

=back

=head1 SEE ALSO

IO::Socket::INET, IO::Socket::INET6, Net::SSLeay.

=head1 AUTHORS

Peter Behroozi, <behrooz at fas.harvard.edu> (Note the lack of an "i" at the end of "behrooz")

Marko Asplund, <aspa at kronodoc.fi>, was the original author of IO::Socket::SSL.

=head1 COPYRIGHT

The rewrite of this module is Copyright (C) 2002-2003 Peter Behroozi.

This module is Copyright (C) 1999-2002 Marko Asplund.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


=head1 Appendix: Using SSL

If you are unfamiliar with the way OpenSSL works, a good reference may be found in
both the book "Network Security with OpenSSL" (Oreilly & Assoc.) and the web site 
L<http://www.tldp.org/HOWTO/SSL-Certificates-HOWTO/>.  Read on for a quick overview.

=head2 The Long of It (Detail)

The usual reason for using SSL is to keep your data safe.  This means that not only
do you have to encrypt the data while it is being transported over a network, but
you also have to make sure that the right person gets the data.  To accomplish this
with SSL, you have to use certificates.  A certificate closely resembles a 
Government-issued ID (at least in places where you can trust them).  The ID contains some sort of
identifying information such as a name and address, and is usually stamped with a seal
of Government Approval.  Theoretically, this means that you may trust the information on
the card and do business with the owner of the card.  The same ideas apply to SSL certificates,
which have some identifying information and are "stamped" [most people refer to this as
I<signing> instead] by someone (a Certificate Authority) who you trust will adequately 
verify the identifying information.  In this case, because of some clever number theory,
it is extremely difficult to falsify the stamping process.  Another useful consequence
of number theory is that the certificate is linked to the encryption process, so you may
encrypt data (using information on the certificate) that only the certificate owner can
decrypt.

What does this mean for you?  It means that at least one person in the party has to
have an ID to get drinks :-).  Seriously, it means that one of the people communicating
has to have a certificate to ensure that your data is safe.  For client/server
interactions, the server must B<always> have a certificate.  If the server wants to
verify that the client is safe, then the client must also have a personal certificate.
To verify that a certificate is safe, one compares the stamped "seal" [commonly called
an I<encrypted digest/hash/signature>] on the certificate with the official "seal" of
the Certificate Authority to make sure that they are the same.  To do this, you will
need the [unfortunately named] certificate of the Certificate Authority.  With all these
in hand, you can set up a SSL connection and be reasonably confident that no-one is
reading your data.

=head2 The Short of It (Summary)

For servers, you will need to generate a cryptographic private key and a certificate
request.  You will need to send the certificate request to a Certificate Authority to
get a real certificate back, after which you can start serving people.  For clients,
you will not need anything unless the server wants validation, in which case you will
also need a private key and a real certificate.  For more information about how to
get these, see L<http://www.modssl.org/docs/2.8/ssl_faq.html#ToC24>.
