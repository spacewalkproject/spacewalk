# Net::SSLeay.pm - Perl module for using Eric Young's implementation of SSL
#
# Copyright (c) 1996-1999 Sampo Kellomaki <sampo@iki.fi>, All Rights Reserved.
# Version 1.04, 31.3.1999
# 30.7.1999, Tracking OpenSSL-0.9.3a changes, --Sampo
# 31.7.1999, version 1.05 --Sampo
#
# The distribution and use of this module are subject to the conditions
# listed in COPYRIGHT file at the root of Eric Young's SSLeay-0.9.0
# distribution (i.e. free, but mandatory attribution and NO WARRANTY).

package Net::SSLeay;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use Socket;

require Exporter;
require DynaLoader;
require AutoLoader;

# 0=no warns, 1=only errors, 2=ciphers, 3=progress, 4=dump data
$Net::SSLeay::trace = 1;

# 2 = insist on v2 SSL protocol, 3 = insist on v3 SSL, undef = guess (v23)
#$Net::SSLeay::ssl_version = 3; 

# Number of seconds to sleep after sending message and before half
# closing connection. Useful with antiquated broken servers.
$Net::SSLeay::slowly = 0;

# RANDOM NUMBER INITIALIZATION
#
# Edit to your taste. Using /dev/random would be more secure, but may
# block if randomness is not available, thus the default is
# /dev/urandom. $how_random determines how many bits of randomness to take
# from the device. You should take enough (read SSLeay/doc/rand), but
# beware that randomness is limited resource so you should not waste
# it either or you may end up with randomness depletion (situation where
# /dev/random would block and /dev/urandom starts to return predictable
# numbers).

$Net::SSLeay::random_device = '/dev/urandom';
$Net::SSLeay::how_random = 512;

$VERSION = '1.05';
@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw(
	AT_MD5_WITH_RSA_ENCRYPTION
	CB_ACCEPT_EXIT
	CB_ACCEPT_LOOP
	CB_CONNECT_EXIT
	CB_CONNECT_LOOP
	CK_DES_192_EDE3_CBC_WITH_MD5
	CK_DES_192_EDE3_CBC_WITH_SHA
	CK_DES_64_CBC_WITH_MD5
	CK_DES_64_CBC_WITH_SHA
	CK_DES_64_CFB64_WITH_MD5_1
	CK_IDEA_128_CBC_WITH_MD5
	CK_NULL
	CK_NULL_WITH_MD5
	CK_RC2_128_CBC_EXPORT40_WITH_MD5
	CK_RC2_128_CBC_WITH_MD5
	CK_RC4_128_EXPORT40_WITH_MD5
	CK_RC4_128_WITH_MD5
	CLIENT_VERSION
	CT_X509_CERTIFICATE
	FILETYPE_ASN1
	FILETYPE_PEM
	F_CLIENT_CERTIFICATE
	F_CLIENT_HELLO
	F_CLIENT_MASTER_KEY
	F_D2I_SSL_SESSION
	F_GET_CLIENT_FINISHED
	F_GET_CLIENT_HELLO
	F_GET_CLIENT_MASTER_KEY
	F_GET_SERVER_FINISHED
	F_GET_SERVER_HELLO
	F_GET_SERVER_VERIFY
	F_I2D_SSL_SESSION
	F_READ_N
	F_REQUEST_CERTIFICATE
	F_SERVER_HELLO
	F_SSL_ACCEPT
	F_SSL_CERT_NEW
	F_SSL_CONNECT
	F_SSL_ENC_DES_CBC_INIT
	F_SSL_ENC_DES_CFB_INIT
	F_SSL_ENC_DES_EDE3_CBC_INIT
	F_SSL_ENC_IDEA_CBC_INIT
	F_SSL_ENC_NULL_INIT
	F_SSL_ENC_RC2_CBC_INIT
	F_SSL_ENC_RC4_INIT
	F_SSL_GET_NEW_SESSION
	F_SSL_MAKE_CIPHER_LIST
	F_SSL_NEW
	F_SSL_READ
	F_SSL_RSA_PRIVATE_DECRYPT
	F_SSL_RSA_PUBLIC_ENCRYPT
	F_SSL_SESSION_NEW
	F_SSL_SESSION_PRINT_FP
	F_SSL_SET_CERTIFICATE
	F_SSL_SET_FD
	F_SSL_SET_RFD
	F_SSL_SET_WFD
	F_SSL_STARTUP
	F_SSL_USE_CERTIFICATE
	F_SSL_USE_CERTIFICATE_ASN1
	F_SSL_USE_CERTIFICATE_FILE
	F_SSL_USE_PRIVATEKEY
	F_SSL_USE_PRIVATEKEY_ASN1
	F_SSL_USE_PRIVATEKEY_FILE
	F_SSL_USE_RSAPRIVATEKEY
	F_SSL_USE_RSAPRIVATEKEY_ASN1
	F_SSL_USE_RSAPRIVATEKEY_FILE
	F_WRITE_PENDING
	MAX_MASTER_KEY_LENGTH_IN_BITS
	MAX_RECORD_LENGTH_2_BYTE_HEADER
	MAX_RECORD_LENGTH_3_BYTE_HEADER
	MAX_SSL_SESSION_ID_LENGTH_IN_BYTES
	MIN_RSA_MODULUS_LENGTH_IN_BYTES
	MT_CLIENT_CERTIFICATE
	MT_CLIENT_FINISHED
	MT_CLIENT_HELLO
	MT_CLIENT_MASTER_KEY
	MT_ERROR
	MT_REQUEST_CERTIFICATE
	MT_SERVER_FINISHED
	MT_SERVER_HELLO
	MT_SERVER_VERIFY
	NOTHING
	PE_BAD_CERTIFICATE
	PE_NO_CERTIFICATE
	PE_NO_CIPHER
	PE_UNSUPPORTED_CERTIFICATE_TYPE
	READING
	RWERR_BAD_MAC_DECODE
	RWERR_BAD_WRITE_RETRY
	RWERR_INTERNAL_ERROR
	R_BAD_AUTHENTICATION_TYPE
	R_BAD_CHECKSUM
	R_BAD_MAC_DECODE
	R_BAD_RESPONSE_ARGUMENT
	R_BAD_SSL_FILETYPE
	R_BAD_SSL_SESSION_ID_LENGTH
	R_BAD_STATE
	R_BAD_WRITE_RETRY
	R_CHALLENGE_IS_DIFFERENT
	R_CIPHER_CODE_TOO_LONG
	R_CIPHER_TABLE_SRC_ERROR
	R_CONECTION_ID_IS_DIFFERENT
	R_INVALID_CHALLENGE_LENGTH
	R_NO_CERTIFICATE_SET
	R_NO_CERTIFICATE_SPECIFIED
	R_NO_CIPHER_LIST
	R_NO_CIPHER_MATCH
	R_NO_CIPHER_WE_TRUST
	R_NO_PRIVATEKEY
	R_NO_PUBLICKEY
	R_NO_READ_METHOD_SET
	R_NO_WRITE_METHOD_SET
	R_NULL_SSL_CTX
	R_PEER_DID_NOT_RETURN_A_CERTIFICATE
	R_PEER_ERROR
	R_PEER_ERROR_CERTIFICATE
	R_PEER_ERROR_NO_CIPHER
	R_PEER_ERROR_UNSUPPORTED_CERTIFICATE_TYPE
	R_PERR_ERROR_NO_CERTIFICATE
	R_PUBLIC_KEY_ENCRYPT_ERROR
	R_PUBLIC_KEY_IS_NOT_RSA
	R_PUBLIC_KEY_NO_RSA
	R_READ_WRONG_PACKET_TYPE
	R_REVERSE_KEY_ARG_LENGTH_IS_WRONG
	R_REVERSE_MASTER_KEY_LENGTH_IS_WRONG
	R_REVERSE_SSL_SESSION_ID_LENGTH_IS_WRONG
	R_SHORT_READ
	R_SSL_SESSION_ID_IS_DIFFERENT
	R_UNABLE_TO_EXTRACT_PUBLIC_KEY
	R_UNDEFINED_INIT_STATE
	R_UNKNOWN_REMOTE_ERROR_TYPE
	R_UNKNOWN_STATE
	R_UNSUPORTED_CIPHER
	R_WRONG_PUBLIC_KEY_TYPE
	R_X509_LIB
	SERVER_VERSION
	SESSION
	SESSION_ASN1_VERSION
	ST_ACCEPT
	ST_BEFORE
	ST_CLIENT_START_ENCRYPTION
	ST_CONNECT
	ST_GET_CLIENT_FINISHED_A
	ST_GET_CLIENT_FINISHED_B
	ST_GET_CLIENT_HELLO_A
	ST_GET_CLIENT_HELLO_B
	ST_GET_CLIENT_MASTER_KEY_A
	ST_GET_CLIENT_MASTER_KEY_B
	ST_GET_SERVER_FINISHED_A
	ST_GET_SERVER_FINISHED_B
	ST_GET_SERVER_HELLO_A
	ST_GET_SERVER_HELLO_B
	ST_GET_SERVER_VERIFY_A
	ST_GET_SERVER_VERIFY_B
	ST_INIT
	ST_OK
	ST_READ_BODY
	ST_READ_HEADER
	ST_SEND_CLIENT_CERTIFICATE_A
	ST_SEND_CLIENT_CERTIFICATE_B
	ST_SEND_CLIENT_CERTIFICATE_C
	ST_SEND_CLIENT_CERTIFICATE_D
	ST_SEND_CLIENT_FINISHED_A
	ST_SEND_CLIENT_FINISHED_B
	ST_SEND_CLIENT_HELLO_A
	ST_SEND_CLIENT_HELLO_B
	ST_SEND_CLIENT_MASTER_KEY_A
	ST_SEND_CLIENT_MASTER_KEY_B
	ST_SEND_REQUEST_CERTIFICATE_A
	ST_SEND_REQUEST_CERTIFICATE_B
	ST_SEND_REQUEST_CERTIFICATE_C
	ST_SEND_REQUEST_CERTIFICATE_D
	ST_SEND_SERVER_FINISHED_A
	ST_SEND_SERVER_FINISHED_B
	ST_SEND_SERVER_HELLO_A
	ST_SEND_SERVER_HELLO_B
	ST_SEND_SERVER_VERIFY_A
	ST_SEND_SERVER_VERIFY_B
	ST_SERVER_START_ENCRYPTION
	ST_X509_GET_CLIENT_CERTIFICATE
	ST_X509_GET_SERVER_CERTIFICATE
	TXT_DES_192_EDE3_CBC_WITH_MD5
	TXT_DES_192_EDE3_CBC_WITH_SHA
	TXT_DES_64_CBC_WITH_MD5
	TXT_DES_64_CBC_WITH_SHA
	TXT_DES_64_CFB64_WITH_MD5_1
	TXT_IDEA_128_CBC_WITH_MD5
	TXT_NULL
	TXT_NULL_WITH_MD5
	TXT_RC2_128_CBC_EXPORT40_WITH_MD5
	TXT_RC2_128_CBC_WITH_MD5
	TXT_RC4_128_EXPORT40_WITH_MD5
	TXT_RC4_128_WITH_MD5
	VERIFY_CLIENT_ONCE
	VERIFY_FAIL_IF_NO_PEER_CERT
	VERIFY_NONE
	VERIFY_PEER
	WRITING
	X509_LOOKUP
	CTX_new
	CTX_v2_new
	CTX_v3_new
	CTX_v23_new
	CTX_free
	new
	free
	accept
	clear
	connect
	set_fd
	set_rfd
	set_wfd
	get_fd
	read
	write
	use_RSAPrivateKey
	use_RSAPrivateKey_ASN1
	use_RSAPrivateKey_file
	CTX_use_RSAPrivateKey_file
	use_PrivateKey
	use_PrivateKey_ASN1
	use_PrivateKey_file
	use_certificate
	use_certificate_ASN1
	use_certificate_file
	CTX_use_certificate_file
	load_error_strings
	ERR_load_SSL_strings
	state_string
	rstate_string
	state_string_long
	rstate_string_long
	get_time
	set_time
	get_timeout
	set_timeout
	copy_session_id
	set_read_ahead
	get_read_ahead
	pending
	get_cipher_list
	set_cipher_list
	get_cipher
	get_shared_ciphers
	get_peer_certificate
	set_verify
	flush_sessions
	set_bio
	get_rbio
	get_wbio
	SESSION_new
	SESSION_print
	SESSION_free
	i2d_SSL_SESSION
	set_session
	add_session
	remove_session
	d2i_SSL_SESSION
	BIO_f_ssl
	ERR_get_error
	ERR_error_string
	err
	clear_error
	X509_get_issuer_name
	X509_get_subject_name
        X509_NAME_oneline
	die_if_ssl_error
	die_now
	print_errs
	set_server_cert_and_key
        make_form
        make_headers
	do_https
	get_https
        post_https
        sslcat
	ssl_read_CRLF
	ssl_read_all
	ssl_read_until
	ssl_write_CRLF
        ssl_write_all
        dump_peer_certificate
);

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
		croak "Your vendor has not defined SSLeay macro $constname";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

bootstrap Net::SSLeay $VERSION;

# Preloaded methods go here.

### Print SSLeay error stack

sub print_errs {
    my ($msg) = @_;
    my ($count, $err) = (0,0);
    my ($errs, $e);
    while ($err = ERR_get_error()) {
        $count ++;
	$e = "$msg $$: $count - " . ERR_error_string($err) . "\n";
	$errs .= $e;
	warn $e if $Net::SSLeay::trace;
    }
    return $errs;
}

# Death is conditional to SSLeay errors existing, i.e. this function checks
# for errors and only dies in affirmative.
# usage: Net::SSLeay::write($ssl, "foo") or die_if_ssl_error("SSL write ($!)");

sub die_if_ssl_error {
    my ($msg) = @_;    
    die "$$: $msg\n" if print_errs($msg);
}

# Unconditional death. Used to print SSLeay errors before dying.
# usage: Net::SSLeay:connect($ssl) or die_now("Failed SSL connect ($!)");

sub die_now {
    my ($msg) = @_;    
    print_errs($msg);
    die "$$: $msg\n";
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Documentation. Use `perl-root/pod/pod2html SSLeay.pm` to output html

=head1 NAME

Net::SSLeay - Perl extension for using OpenSSL

=head1 SYNOPSIS

  use Net::SSLeay, qw(get_https post_https sslcat make_headers make_form);

  ($page) = get_https('www.bacus.pt', 443, '/');                 # 1

  ($page, $response, %reply_headers)
	 = get_https('www.bacus.pt', 443, '/',                   # 2
	 	make_headers(
			'User-Agent' => 'Cryptozilla/5.0b1',
			'Referer'    => 'https://www.bacus.pt'
		));

  ($page, $result, %headers) =                                   # 2b
         = get_https('www.bacus.pt', 443, '/protected.html',
	      make_headers('Authorization' =>
			   'Basic ' . MIME::Base64::encode("$user:$pass"))
	      );

  ($page, $response, %reply_headers)
	 = post_https('www.bacus.pt', 443, '/foo.cgi', '',       # 3
		make_form(
			'OK'   => '1',
			'name' => 'Sampo'
		));

  $reply = sslcat($host, $port, $request);                       # 4

  $Net::SSLeay::trace = 2;  # 0=no debugging, 1=ciphers, 2=trace, 3=dump data

=head1 DESCRIPTION

This module offers some high level convinience functions for accessing
web pages on SSL servers, a sslcat() function for writing your own
clients, and finally access to the SSL api of SSLeay package so you
can write servers or clients for more complicated applications.

For high level functions it is most convinient to import them to your
main namespace as indicated in the synopsis. Case 1 demonstrates
typical invocation of get_https() to fetch an HTML page from secure
server. The first argument provides host name or ip in dotted decimal
notation of the remote server to contact. Second argument is the TCP
port at the remote end (your own port is picked arbitrarily from high
numbered ports as usual for TCP). The third argument is the URL of the
page without the host name part. If in doubt consult HTTP
specifications at <http://www.w3c.org>

Case 2 demonstrates full fledged use of get_https. As can be seen,
get_https parses the response and response headers and returns them as
a list, which can be captured in a hash for later reference. Also a
fourth argument to get_https is used to insert some additional headers
in the request. make_headers is a function that will convert a list or
hash to such headers. By default get_https supplies Host (make virtual
hosting easy) and Accept (reportedly needed by IIS) headers.

Case 2b demonstrates how to get password protected page. Refer to
HTTP protocol specifications for further details (e.g. RFC2617).

Case 3 invokes post_https to submit a HTML/CGI form to secure
server. First four arguments are equal to get_https (note that empty
string ('') is passed as header argument). The fifth argument is the
contents of the form formatted according to CGI specification. In this
case the helper function make_https() is used to do the formatting,
but you could pass any string. The post_https() automatically adds
Content-Type and Content-Length headers to the request.

Case 4 shows the fundamental sslcat() function (inspired in spirit by
netcat utility :-). Its your swiss army knife that allows you to
easily contact servers, send some data, and then get the response. You
are responsible for formatting the data and parsing the response -
sslcat() is just a transport.

The $trace global variable can be used to control the verbosity of high
level functions. Level 0 guarantees silence, level 1 (the default)
only emits error messages.

=head2 Convenience routines

To be used with Low level API

    Net::SSLeay::randomize($rn_seed_file,$additional_seed);
    Net::SSLeay::set_server_cert_and_key($ctx, $cert_path, $key_path);
    $cert = Net::SSLeay::dump_peer_certificate($ssl);
    Net::SSLeay::ssl_write_all($ssl, $message) or die "ssl write failure";
    $got = Net::SSLeay::ssl_read_all($ssl) or die "ssl read failure";

    $got = Net::SSLeay::ssl_read_CRLF($ssl [, $max_length]);
    $got = Net::SSLeay::ssl_read_until($ssl [, $delimit [, $max_length]]);
    Net::SSLeay::ssl_write_CRLF($ssl, $message);

randomize() seeds the eay PRNG with /dev/urandom (see top of SSLeay.pm
for how to change or configure this) and optionally with user provided
data. It is very important to properly seed your random numbers, so
do not forget to call this. The high level API functions automatically
call randomize() so it is not needed with them.

set_server_cert_and_key() takes two file names as arguments and sets
the server certificate and private key to those.

dump_peer_certificate() allows you to get plaintext description of the
certificate the peer (usually server) presented to us.

ssl_read_all() and ssl_write_all() provide true blocking semantics for
these operations (see limitation, below, for explanation). These are
much preferred to the low level API equivalents (which implement BSD
blocking semantics). The message argument to ssl_write_all() can be
reference. This is helpful to avoid unnecessary copy when writing
something big, e.g:

    $data = 'A' x 1000000000;
    Net::SSLeay::ssl_write_all($ssl, \$data) or die "ssl write failed";

ssl_read_CRLF() uses ssl_read_all() to read in a line terminated with a
carriage return followed by a linefeed (CRLF).  The CRLF is included in
the returned scalar.

ssl_read_until() uses ssl_read_all() to read from the SSL input
stream until it encounters a programmer specified delimiter.
If the delimiter is undefined, $/ is used.  If $/ is undefined,
\n is used.  One can optionally set a maximum length of bytes to read
from the SSL input stream.

ssl_write_CRLF() writes $message and appends CRLF to the SSL output stream.

=head2 Low level API

In addition to the high level functions outlined above, this module
contains straight forward access to SSL part of OpenSSL C api. Only the SSL
subpart of OpenSSL is implemented (if anyone wants to implement other
parts, feel free to submit patches).

See ssl.h header from OpenSSL C distribution for list of low lever
SSLeay functions to call (to check if some function has been
implemented see directly in SSLeay.xs). The module strips SSLeay names
of the initial "SSL_", generally you should use Net::SSLeay:: in
place. For example:

In C:

	#include <ssl.h>
	
	err = SSL_set_verify (ssl, SSL_VERIFY_CLIENT_ONCE,
				   &your_call_back_here);
	
In perl:

	use Net::SSLeay;

	$err = Net::SSLeay::set_verify ($ssl,
					&Net::SSLeay::VERIFY_CLIENT_ONCE,
					\&your_call_back_here);

If the function does not start by SSL_ you should use the full
function name, e.g.:

	$err = &Net::SSLeay::ERR_get_error;

Following new functions behave in perlish way:

	$got = Net::SSLeay::read($ssl);
                                    # Performs SSL_read, but returns $got
                                    # resized according to data received.
                                    # Returns undef on failure.

	Net::SSLeay::write($ssl, $foo) || die;
                                    # Performs SSL_write, but automatically
                                    # figures out the size of $foo

In order to use the low level API you should start your programs with
the following encantation:

	use Net::SSLeay qw(die_now die_if_ssl_error);
	Net::SSLeay::load_error_strings();
	Net::SSLeay::SSLeay_add_ssl_algorithms();   # Important!
        Net::SSLeay::randomize();

die_now() and die_if_ssl_error() are used to conveniently print SSLeay error
stack when something goes wrong, thusly:

	Net::SSLeay:connect($ssl) or die_now("Failed SSL connect ($!)");
	Net::SSLeay::write($ssl, "foo") or die_if_ssl_error("SSL write ($!)");

You can also use Net::SSLeay::print_errs() to dump the error stack without
exiting the program. As can be seen, your code becomes much more readable
if you import the error reporting functions to your main name space.

I can not emphasize enough the need to check error returns. Use these
functions even in most simple programs, they will reduce debugging
time greatly. Do not ask questions in mailing list without having
first sprinkled these in your code.

=head2 Sockets

Perl uses file handles for all I/O. While SSLeay has quite flexible BIO
mechanism and perl has evolved PerlIO mechanism, this module still
sticks to using file descriptors. Thus to attach SSLeay to socket you
should use fileno() to extract the underlying file descriptor:

    Net::SSLeay::set_fd($ssl, fileno(S));   # Must use fileno

You should also use "$|=1;" to eliminate STDIO buffering so you do not
get confused if you use perl I/O functions to manipulate your socket
handle.

If you need to select(2) on the socket, go right ahead, but be warned
that SSLeay does some internal buffering so SSL_read does not always
return data even if socket selected for reading (just keep on
selecting and trying to read). Net::SSLeay.pm is no different from the
C language OpenSSL in this respect.

=head2 Callbacks

WARNING: as of 1.04 the callbacks have changed and have not been tested.

At this moment the implementation of verify_callback is crippeled in
the sense that at any given time there can be only one call back which
is shared by all SSL contexts, sessions and connections. This is
due to having to keep the reference to the perl call back in a
static variable so that the callback C glue can find it. To remove
this restriction would require either a more complex data structure
(like a hash?) in XSUB to map the call backs to their owners or,
cleaner, adding a context pointer in the SSL structure. This context would
then be passed to the C callback, which in our case would be the glue
to look up the proper Perl function from the context and call it.

---- inaccurate ----
The verify call back looks like this in C:

	int (*callback)(int ok,X509 *subj_cert,X509 *issuer_cert,
                        int depth,int errorcode,char *arg,STACK *cert_chain)

The corresponding Perl function should be something like this:

	sub verify {
	    my ($ok, $subj_cert, $issuer_cert, $depth, $errorcode,
		$arg, $chain) = @_;
	    print "Verifying certificate...\n";
		...
	    return $ok;
	}

It is used like this:

	Net::SSLeay::set_verify ($ssl, Net::SSLeay::VERIFY_PEER, \&verify);

No other callbacks are implemented. You do not need to use any
callback for simple (i.e. normal) cases where the SSLeay built-in
verify mechanism satisfies your needs.
---- end inaccurate ----

If you want to use callback stuff, see examples/callback.pl! Its the
only one I am able to make work reliably.

=head2 X509 and RAND stuff

This module largely lacks interface to the X509 and RAND routines, but
as I was lazy and needed them, the following kludges are implemented:

    $x509_name = Net::SSLeay::X509_get_subject_name($x509_cert);
    $x509_name = Net::SSLeay::X509_get_issuer_name($x509_cert);
    print Net::SSLeay::X509_NAME_oneline($x509_name);
    Net::SSLeay::RAND_seed($buf);   # Perlishly figures out buf size
    Net::SSLeay::RAND_cleanup();
    Net::SSLeay::RAND_load_file($file_name, $how_many_bytes);
    Net::SSLeay::RAND_write_file($file_name);

Actually you should consider using the following helper functions:

    print Net::SSLeay::dump_peer_certificate($ssl);
    Net::SSLeay::randomize();

=head1 EXAMPLES

One very good example is to look at the implementation of sslcat() in the
SSLeay.pm file.

Following is a simple SSLeay client (with too little error checking :-(

    #!/usr/local/bin/perl
    use Socket;
    use Net::SSLeay qw(die_now die_if_ssl_error) ;
    Net::SSLeay::load_error_strings();
    Net::SSLeay::SSLeay_add_ssl_algorithms();
    Net::SSLeay::randomize();

    ($dest_serv, $port, $msg) = @ARGV;      # Read command line
    $port = getservbyname ($port, 'tcp') unless $port =~ /^\d+$/;
    $dest_ip = gethostbyname ($dest_serv);
    $dest_serv_params  = sockaddr_in($port, $dest_ip);
    
    socket  (S, &AF_INET, &SOCK_STREAM, 0)  or die "socket: $!";
    connect (S, $dest_serv_params)          or die "connect: $!";
    select  (S); $| = 1; select (STDOUT);   # Eliminate STDIO buffering
    
    # The network connection is now open, lets fire up SSL    

    $ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
    Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL)
         and die_if_ssl_error("ssl ctx set options");
    $ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
    Net::SSLeay::set_fd($ssl, fileno(S));   # Must use fileno
    $res = Net::SSLeay::connect($ssl) and die_if_ssl_error("ssl connect");
    print "Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";
    
    # Exchange data
    
    $res = Net::SSLeay::write($ssl, $msg);  # Perl knows how long $msg is
    die_if_ssl_error("ssl write");
    shutdown S, 1;  # Half close --> No more output, sends EOF to server
    $got = Net::SSLeay::read($ssl);         # Perl returns undef on failure
    die_if_ssl_error("ssl read");
    print $got;
	    
    Net::SSLeay::free ($ssl);               # Tear down connection
    Net::SSLeay::CTX_free ($ctx);
    close S;

Following is a simple SSLeay echo server (non forking):

    #!/usr/local/bin/perl -w
    use Socket;
    use Net::SSLeay qw(die_now die_if_ssl_error);
    Net::SSLeay::load_error_strings();
    Net::SSLeay::SSLeay_add_ssl_algorithms();
    Net::SSLeay::randomize();
 
    $our_ip = "\0\0\0\0"; # Bind to all interfaces
    $port = 1235;							 
    $sockaddr_template = 'S n a4 x8';
    $our_serv_params = pack ($sockaddr_template, &AF_INET, $port, $our_ip);

    socket (S, &AF_INET, &SOCK_STREAM, 0)  or die "socket: $!";
    bind (S, $our_serv_params)             or die "bind:   $!";
    listen (S, 5)                          or die "listen: $!";
    $ctx = Net::SSLeay::CTX_new ()         or die_now("CTX_new ($ctx): $!");
    Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL)
         and die_if_ssl_error("ssl ctx set options");

    # Following will ask password unless private key is not encrypted
    Net::SSLeay::CTX_use_RSAPrivateKey_file ($ctx, 'plain-rsa.pem',
                                             &Net::SSLeay::FILETYPE_PEM);
    die_if_ssl_error("private key");
    Net::SSLeay::CTX_use_certificate_file ($ctx, 'plain-cert.pem',
 				           &Net::SSLeay::FILETYPE_PEM);
    die_if_ssl_error("certificate");
    
    while (1) {    
        print "Accepting connections...\n";
        ($addr = accept (NS, S))           or die "accept: $!";
        select (NS); $| = 1; select (STDOUT);  # Piping hot!
    
        ($af,$client_port,$client_ip) = unpack($sockaddr_template,$addr);
        @inetaddr = unpack('C4',$client_ip);
        print "$af connection from " .
	    join ('.', @inetaddr) . ":$client_port\n";
    
	# We now have a network connection, lets fire up SSLeay...

        $ssl = Net::SSLeay::new($ctx)      or die_now("SSL_new ($ssl): $!");
        Net::SSLeay::set_fd($ssl, fileno(NS));
    
        $err = Net::SSLeay::accept($ssl) and die_if_ssl_error('ssl accept');
        print "Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";
    
        # Connected. Exchange some data.
    
        $got = Net::SSLeay::read($ssl);     # Returns undef on fail
        die_if_ssl_error("ssl read");
        print "Got `$got' (" . length ($got) . " chars)\n";
        
        Net::SSLeay::write ($ssl, uc ($got)) or die "write: $!";
        die_if_ssl_error("ssl write");
    
        Net::SSLeay::free ($ssl);           # Tear down connection
        close NS;
    }

Yet another echo server. This one runs from /etc/inetd.conf so it avoids
all the socket code overhead. Only caveat is opening rsa key file -
it had better be without any encryption or else it will not know where
to ask for the password. Note how STDIN and STDOUT are wired to SSL.

    #!/usr/local/bin/perl
    # /etc/inetd.conf
    #    ssltst stream tcp nowait root /path/to/server.pl server.pl
    # /etc/services
    #    ssltst		1234/tcp

    use Net::SSLeay qw(die_now die_if_ssl_error);
    Net::SSLeay::load_error_strings();
    Net::SSLeay::SSLeay_add_ssl_algorithms();
    Net::SSLeay::randomize();

    chdir '/key/dir' or die "chdir: $!";
    $| = 1;  # Piping hot!
    open LOG, ">>/dev/console" or die "Can't open log file $!";
    select LOG; print "server.pl started\n";
    
    $ctx = Net::SSLeay::CTX_new()     or die_now "CTX_new ($ctx) ($!)";
    $ssl = Net::SSLeay::new($ctx)     or die_now "new ($ssl) ($!)";
    Net::SSLeay::set_options($ssl, &Net::SSLeay::OP_ALL)
         and die_if_ssl_error("ssl set options");

    # We get already open network connection from inetd, now we just
    # need to attach SSLeay to STDIN and STDOUT
    Net::SSLeay::set_rfd($ssl, fileno(STDIN));
    Net::SSLeay::set_wfd($ssl, fileno(STDOUT));

    Net::SSLeay::use_RSAPrivateKey_file ($ssl, 'plain-rsa.pem',
                                         &Net::SSLeay::FILETYPE_PEM);
    die_if_ssl_error("private key");
    Net::SSLeay::use_certificate_file ($ssl, 'plain-cert.pem',
	 			       &Net::SSLeay::FILETYPE_PEM);
    die_if_ssl_error("certificate");

    Net::SSLeay::accept($ssl) and die_if_ssl_err("ssl accept: $!");
    print "Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";
    
    $got = Net::SSLeay::read($ssl);
    die_if_ssl_error("ssl read");
    print "Got `$got' (" . length ($got) . " chars)\n";

    Net::SSLeay::write ($ssl, uc($got)) or die "write: $!";
    die_if_ssl_error("ssl write");

    Net::SSLeay::free ($ssl);         # Tear down the connection
    Net::SSLeay::CTX_free ($ctx);
    close LOG;

There are also a number of example/test programs in the examples directory:

    sslecho.pl   -  A simple server, not unlike the one above
    minicli.pl   -  Implements a client using low level SSLeay routines
    sslcat.pl    -  Demonstrates using high level sslcat utility function
    get_page.pl  -  Is a utility for getting html pages from secure servers
    callback.pl  -  Demonstrates certificate verification and callback usage
    stdio_bulk.pl       - Does SSL over Unix pipes
    ssl-inetd-serv.pl   - SSL server that can be invoked from inetd.conf
    httpd-proxy-snif.pl - Utility that allows you to see how a browser
                          sends https request to given server and what reply
                          it gets back (very educative :-)
    makecert.pl  -  Creates a self signed cert (does not use this module)

=head1 LIMITATIONS

Net::SSLeay::read uses internal buffer of 32KB, thus no single read
will return more. In practice one read returns much less, usually
as much as fits in one network packet. To work around this,
you should use a loop like this:

    $reply = '';
    do {
	$got = Net::SSLeay::read($ssl);
	last if print_errs('SSL_read');
	$reply .= $got;
    } while ($got);

Although there is no built in limit in Net::SSLeay::write, the network
packet size limitation applies here as well, thus use:

    $written = 0;
    do {
	$written .= Net::SSLeay::write($ssl, substr($message, $written));
	last if print_errs('SSL_write');
    } while ($written < length($message));

Or alternatively you can just use the following convinence functions:

    Net::SSLeay::ssl_write_all($ssl, $message) or die "ssl write failure";
    $got = Net::SSLeay::ssl_read_all($ssl) or die "ssl read failure";

=head1 KNOWN BUGS AND CAVEATS

Autoloader emits

    Argument "xxx" isn't numeric in entersub at blib/lib/Net/SSLeay.pm'

warning if die_if_ssl_error is made autoloadable. If you figure out why,
drop me a line.

Callback set using SSL_set_verify() does not appear to work. This may
well be eay problem (e.g. see ssl/ssl_lib.c line 1029). Try using
SSL_CTX_set_verify() instead and do not be surprised if even this stops
working in future versions.

Callback and certificate verification stuff is generally too little tested.

Random numbers are not initialized randomly enough, especially if you
do not have /dev/random and/or /dev/urandom.

If you are using the low level API functions to communicate with other
SSL implementations, you would do well to call

    Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL)
         and die_if_ssl_error("ssl ctx set options");

to cope with some well know bugs in some other SSL
implementations. The high level API functions always set all known
compatibility options.

Sometimes sslcat (and the high level https functions that build on it)
is too fast in signaling the EOF to legacy https servers. This causes
the server to return empty page. To work around this problem you can
set global variable

    $Net::SSLeay::slowly = 1;   # Add sleep so broken servers can keep up

=head1 DIAGNOSTICS

"Random number generator not seeded!!!"
  This warning indicates that randomize() was not able to read
  /dev/random or /dev/urandom, possibly because your system does not
  have them or they are differently named. You can still use SSL, but
  the encryption will not be as strong.

"open_tcp_connection: destination host not found:`server' (port 123) ($!)"
  Name lookup for host named `server' failed.

"open_tcp_connection: failed `server', 123 ($!)"
  The name was resolved, but establising the TCP connection failed.

"msg 123: 1 - error:140770F8:SSL routines:SSL23_GET_SERVER_HELLO:unknown proto"
  SSLeay error string. First (123) number is PID, second number (1) indicates
  the position of the error message in SSLeay error stack. You often see
  a pile of these messages as errors cascade.

"msg 123: 1 - error:02001002::lib(2) :func(1) :reason(2)"
  The same as above, but you didn't call load_error_strings() so SSLeay
  couldn't verbosely explain the error. You can still find out what it
  means with this command:

     /usr/local/ssl/bin/ssleay errstr 02001002

=head1 VERSION

This man page documents version 1.04, released on 31.7.1999. This version
had some API changes over 1.03 but is still provisory. Expect to see
version 1.05 to get up to full speed of OpenSSL-0.9.3a and beyound.

There are currently two perl modules for using OpenSSL C
library: Net::SSLeay (maintaned by me) and SSLeay (maintained by OpenSSL
team). This module is the Net::SSLeay variant.

At the time of making this release, Eric's module was still quite
scetchy and could not be used for real work, thus I felt motivated to
make this maintenance release. This module is not planned to evolve to
contain any further functionality, i.e. I will concentrate on just
making a simple SSL connection over TCP socket. Presumably Eric's own
module will offer full SSLeay API one day.

This module uses OpenSSL-0.9.3a. It does not work with any earlier version
and there is no guarantee that it will work with later versions either,
though as long as C API does not change, it should. This module
requires perl5.005 (or better?) though I believe it would build with
any perl5.002 or newer.

=head1 AUTHOR

Sampo Kellomaki <sampo@iki.fi>

Please send bug reports to the above address. General questions should be
sent either to me or to the mailing list (subscribe by sending mail
to openssl-users-request@openssl.org or using web interface at
http://www.openssl.org/support/).

=head1 COPYRIGHT

Copyright (c) 1996-1999 Sampo Kellomaki <sampo@iki.fi>, All Rights Reserved.

Distribution and use of this module is under the same terms as the
OpenSSL package itself (i.e. free, but mandatory attribution; NO
WARRANTY). Please consult COPYRIGHT file in the root of the SSLeay
distribution.

While the source distribution of this perl module does not contain
Eric's or OpenSSL's code, if you use this module you will use OpenSSL
library. Please give Eric and OpenSSL team credit (as required by
their licenses).

And remember, you, and nobody else but you, are responsible for
auditing this module and OpenSSL library for security problems,
backdoors, and general suitability for your application.

=head1 SEE ALSO

  Net_SSLeay/examples                      - Example servers and a clients
  <http://www.bacus.pt/Net_SSLeay/index.html>  - Net::SSLeay.pm home
  <http://www.openssl.org/>                - OpenSSL source, documentation, etc
  openssl-users-request@openssl.org        - General OpenSSL mailing list
  <http://home.netscape.com/newsref/std/SSL.html>  - SSL Draft specification
  <http://www.w3c.org>                     - HTTP specifications
  <http://www.ietf.org/rfc/rfc2617.txt>    - How to send password

=cut

# ';

###
### Open TCP stream to given host and port, looking up the details
### from system databases or DNS.
###

sub open_tcp_connection {
    my ($dest_serv, $port) = @_;
    my ($errs);
    $port = getservbyname  ($port, 'tcp') unless $port =~ /^\d+$/;
    my $dest_serv_ip = gethostbyname ($dest_serv);
    unless (defined($dest_serv_ip)) {
	$errs = "$0 $$: open_tcp_connection: destination host not found:"
            . " `$dest_serv' (port $port) ($!)\n";
	warn $errs if $trace;
        return wantarray ? (0, $errs) : 0;
    }
    my $sin = sockaddr_in($port, $dest_serv_ip);
    
    printf STDERR "Opening connection to $dest_serv:$port (%x)\n",
    $dest_serv_ip if $trace>2;
    
    my $proto = getprotobyname('tcp');
    if (socket (SSLCAT_S, &PF_INET, &SOCK_STREAM, $proto)) {
        warn "next connect\n" if $trace>3;
        if (connect (SSLCAT_S, $sin)) {
            my $old_out = select (SSLCAT_S); $| = 1; select ($old_out);
            warn "connected to $dest_serv, $port\n" if $trace>3;
            return wantarray ? (1, undef) : 1; # Success
        }
    }
    $errs = "$0 $$: open_tcp_connection: failed `$dest_serv', $port ($!)\n";
    warn $errs if $trace;
    close SSLCAT_S;
    return wantarray ? (0, $errs) : 0; # Fail
}

###
### read and write helpers that block
###

sub ssl_read_all {
    my ($ssl,$how_much) = @_;
    $how_much = 2000000000 unless $how_much;
    my ($reply, $got, $errs);
    do {
	$got = Net::SSLeay::read($ssl,$how_much);
	last if $errs = print_errs('SSL_read');
	$how_much -= length($got);
	$vm = (split ' ', `cat /proc/$$/stat`)[22] if $trace>2;  # Linux Only?
	warn "  got " . length($got) . ':'
	    . length($reply) . " bytes (VM=$vm).\n" if $trace == 3;
	warn "  got `$got' (" . length($got) . ':'
	    . length($reply) . " bytes, VM=$vm)\n" if $trace>3;
	$reply .= $got;
	#$reply = $got;  # *** DEBUG
    } while (defined($got) && $how_much > 0);
    return wantarray ? ($reply, $errs) : $reply;
}

sub ssl_write_all {
    my $ssl = $_[0];    
    my ($data_ref, $errs);
    if (ref $_[1]) {
	$data_ref = $_[1];
    } else {
	$data_ref = \$_[1];
    }
    my ($wrote, $written, $to_write) = (0,0, length($$data_ref));
    $vm = (split ' ', `cat /proc/$$/stat`)[22] if $trace>2;  # Linux Only?
    warn "  write_all VM at entry=$vm\n" if $trace>2;
    do {
	#sleep 1; # *** DEBUG
	warn "partial `$$data_ref'\n" if $trace>3;
	$wrote = write_partial($ssl, $written, $to_write, $$data_ref);
	$written += $wrote;
	$to_write -= $wrote;
	$vm = (split ' ', `cat /proc/$$/stat`)[22] if $trace>2;  # Linux Only?
	warn "  written so far $wrote:$written bytes (VM=$vm)\n" if $trace>2;
	return (wantarray ? (undef, $errs) : undef)
	    if $errs = print_errs('SSL_write');
    } while ($to_write);
    return wantarray ? ($written, $errs) : $written;
}

### from patch by Clinton Wong <clintdw@netcom.com>

# ssl_read_until($ssl [, $delimit [, $max_length]])
#  if $delimit missing, use $/ if it exists, otherwise use \n
#  read until delimiter reached, up to $max_length chars if defined

sub ssl_read_until {
    my ($ssl,$delimit, $max_length) = @_;

    # guess the delimit string if missing
    if ( ! defined $delimit ) {           
      if ( defined $/ && length $/  ) { $delimit = $/ }
      else { $delimit = "\n" }      # Note: \n,$/ value depends on the platform
    }
    my $length_delimit = length $delimit;

    my ($reply, $got);
    do {
        $got = Net::SSLeay::read($ssl,1);
        last if print_errs('SSL_read');
        $vm = (split ' ', `cat /proc/$$/stat`)[22] if $trace>1;  # Linux Only?
        warn "  got " . length($got) . ':'
            . length($reply) . " bytes (VM=$vm).\n" if $trace == 2;
        warn "  got `$got' (" . length($got) . ':'
            . length($reply) . " bytes, VM=$vm)\n" if $trace>2;
        $reply .= $got;
    } while (defined($got) &&
              ( $length_delimit==0 || substr($reply, length($reply)-
                $length_delimit) ne $delimit
              ) &&
              (!defined $max_length || length $reply < $max_length)
            );
    return $reply;
}

# ssl_read_CRLF($ssl [, $max_length])
sub ssl_read_CRLF { ssl_read_until($_[0], chr(13).chr(10), $_[1]) }

# ssl_write_CRLF($ssl, $message) writes $message and appends CRLF
sub ssl_write_CRLF { 
  # the next line uses less memory but might use more network packets
  return ssl_write_all($_[0], $_[1]) + ssl_write_all($_[0], chr(13).chr(10));

  # the next few lines do the same thing at the expense of memory, with
  # the chance that it will use less packets, since CRLF is in the original
  # message and won't be sent separately.

  #my $data_ref;
  #if (ref $_[1]) { $data_ref = $_[1] }
  # else { $data_ref = \$_[1] }
  #my $message = $$data_ref .  chr(13).chr(10);
  #return ssl_write_all($_[0], \$message);
}

### Quickly print out with whom we're talking

sub dump_peer_certificate {
    my ($ssl) = @_;
    my $cert = get_peer_certificate($ssl);
    return if print_errs('get_peer_certificate');
    return "Subject Name: "
	. X509_NAME_oneline(X509_get_subject_name($cert)) . "\n"
        . "Issuer  Name: "
	. X509_NAME_oneline(X509_get_issuer_name($cert))  . "\n";
}

### Arrange some randomness for eay PRNG

sub randomize {
    my ($rn_seed_file, $seed) = @_;

    RAND_seed(rand() + $$);  # Stir it with time and pid
    
    unless (-r $rn_seed_file || -r $Net::SSLeay::random_device || $seed) {
	warn "Random number generator not seeded!!!\n" if $trace;
    }
    
    RAND_load_file($rn_seed_file, -s _) if -r $rn_seed_file;
    RAND_seed($seed) if $seed;
    RAND_load_file($Net::SSLeay::random_device, $Net::SSLeay::how_random/8)
	if -r $Net::SSLeay::random_device;
}

###
### Basic request - response primitive (don't use for https)
###

sub sslcat { # address, port, message --> returns reply
    my ($dest_serv, $port, $out_message) = @_;
    my ($ctx, $ssl, $got, $errs, $written);

    ($got, $errs) = open_tcp_connection($dest_serv, $port, \$errs);
    return (wantarray ? (undef, $errs) : undef) unless $got;
	    
    ### Do SSL negotiation stuff
	    
    warn "Creating SSL $ssl_version context...\n" if $trace>2;
    load_error_strings();         # Some bloat, but I'm after ease of use
    SSLeay_add_ssl_algorithms();  # and debuggability.
    randomize('/etc/passwd');
    
    if    ($ssl_version == 2) { $ctx = CTX_v2_new(); }
    elsif ($ssl_version == 3) { $ctx = CTX_v3_new(); }
    else                      { $ctx = CTX_new(); }

    goto cleanup2 if $errs = print_errs('CTX_new') or !$ctx;

    CTX_set_options($ctx, &OP_ALL);
    goto cleanup2 if $errs = print_errs('CTX_set_options');
    
    warn "Creating SSL connection (context was '$ctx')...\n" if $trace>2;
    $ssl = new($ctx);
    goto cleanup if $errs = print_errs('SSL_new') or !$ssl;
    
    warn "Setting fd (ctx $ctx, con $ssl)...\n" if $trace>2;
    set_fd($ssl, fileno(SSLCAT_S));
    goto cleanup if $errs = print_errs('set_fd');
    
    warn "Entering SSL negotiation phase...\n" if $trace>2;
    
    $got = Net::SSLeay::connect($ssl);
    warn "SSLeay connect returned $got\n" if $trace>2;
    goto cleanup if $errs = print_errs('SSL_connect');
    
    if ($trace>1) {	    
	warn "Cipher `" . get_cipher($ssl) . "'\n";
	print_errs('get_ciper');
	warn dump_peer_certificate($ssl);
    }
    
    ### Connected. Exchange some data (doing repeated tries if necessary).
        
    warn "sslcat $$: sending " . length($out_message) . " bytes...\n"
	if $trace==3;
    warn "sslcat $$: sending `$out_message' (" . length($out_message)
	. " bytes)...\n" if $trace>3;
    ($written, $errs) = ssl_write_all($ssl, $out_message);
    goto cleanup unless $written;
    
    sleep $slowly if $slowly;  # Closing too soon can abort broken servers
    shutdown SSLCAT_S, 1;  # Half close --> No more output, send EOF to server
    
    warn "waiting for reply...\n" if $trace>2;
    ($got, $errs) = ssl_read_all($ssl);
    warn "Got " . length($got) . " bytes.\n" if $trace==3;
    warn "Got `$got' (" . length($got) . " bytes)\n" if $trace>3;

cleanup:	    
    free ($ssl);
    $errs .= print_errs('SSL_free');
cleanup2:
    CTX_free ($ctx);
    $errs .= print_errs('CTX_free');
    close SSLCAT_S;    
    return wantarray ? ($got, $errs) : $got;
}

###
### Basic request - response primitive, this is different from sslcat
###                 because this does not shutdown the connection.
###

sub https_cat { # address, port, message --> returns reply
    my ($dest_serv, $port, $out_message) = @_;
    my ($ctx, $ssl, $got, $errs, $written);

    ($got, $errs) = open_tcp_connection($dest_serv, $port, \$errs);
    return (wantarray ? (undef, $errs) : undef) unless $got;
	    
    ### Do SSL negotiation stuff
	    
    warn "Creating SSL $ssl_version context...\n" if $trace>2;
    load_error_strings();         # Some bloat, but I'm after ease of use
    SSLeay_add_ssl_algorithms();  # and debuggability.
    randomize('/etc/passwd');
    
    if    ($ssl_version == 2) { $ctx = CTX_v2_new(); }
    elsif ($ssl_version == 3) { $ctx = CTX_v3_new(); }
    else                      { $ctx = CTX_new(); }

    goto cleanup2 if $errs = print_errs('CTX_new') or !$ctx;

    CTX_set_options($ctx, &OP_ALL);
    goto cleanup2 if $errs = print_errs('CTX_set_options');
    
    warn "Creating SSL connection (context was '$ctx')...\n" if $trace>2;
    $ssl = new($ctx);
    goto cleanup if $errs = print_errs('SSL_new') or !$ssl;
    
    warn "Setting fd (ctx $ctx, con $ssl)...\n" if $trace>2;
    set_fd($ssl, fileno(SSLCAT_S));
    goto cleanup if $errs = print_errs('set_fd');
    
    warn "Entering SSL negotiation phase...\n" if $trace>2;
    
    $got = Net::SSLeay::connect($ssl);
    warn "SSLeay connect returned $got\n" if $trace>2;
    goto cleanup if $errs = print_errs('SSL_connect');
    
    if ($trace>1) {	    
	warn "Cipher `" . get_cipher($ssl) . "'\n";
	print_errs('get_ciper');
	warn dump_peer_certificate($ssl);
    }
    
    ### Connected. Exchange some data (doing repeated tries if necessary).
        
    warn "sslcat $$: sending " . length($out_message) . " bytes...\n"
	if $trace==3;
    warn "sslcat $$: sending `$out_message' (" . length($out_message)
	. " bytes)...\n" if $trace>3;
    ($written, $errs) = ssl_write_all($ssl, $out_message);
    goto cleanup unless $written;
    
    warn "waiting for reply...\n" if $trace>2;
    ($got, $errs) = ssl_read_all($ssl);
    warn "Got " . length($got) . " bytes.\n" if $trace==3;
    warn "Got `$got' (" . length($got) . " bytes)\n" if $trace>3;

cleanup:	    
    free ($ssl);
    $errs .= print_errs('SSL_free');
cleanup2:
    CTX_free ($ctx);
    $errs .= print_errs('CTX_free');
    close SSLCAT_S;    
    return wantarray ? ($got, $errs) : $got;
}

###
### Easy set up of private key and certificate
###

sub set_server_cert_and_key {
    my ($ctx, $cert_path, $key_path) = @_;    
    my $errs = '';
    # Following will ask password unless private key is not encrypted
    CTX_use_RSAPrivateKey_file ($ctx, $key_path, &FILETYPE_PEM);
    $errs .= print_errs("private key `$key_path' ($!)");
    CTX_use_certificate_file ($ctx, $cert_path, &FILETYPE_PEM);
    $errs .= print_errs("certificate `$cert_path' ($!)");
    return wantarray ? (undef, $errs) : ($errs eq '');
}

###
### Easy https manipulation routines
###

sub make_form {
    my (@fields) = @_;
    my $form;
    while (@fields) {
	my ($name, $data) = (shift(@fields), shift(@fields));
	$data =~ s/([^\w\-.\@\$ ])/sprintf("%%%2.2x",ord($1))/gse;
    	$data =~ tr[ ][+];
	$form .= "$name=$data&";
    }
    chop $form;
    return $form;
}

sub make_headers {
    my (@headers) = @_;
    my $headers;
    while (@headers) {
	$headers .= shift(@headers) . ': ' . shift(@headers) . "\r\n";
    }
    return $headers;
}

# ($page, $respone_or_err, %headers) = do_https(...);

sub do_https {
    my ($site, $port, $path, $method, $headers, $content, $mime_type) = @_;
    my ($response, $page, $errs, $http, $h,$v);

    if ($content) {
	$mime_type = "application/x-www-form-urlencoded" unless $mime_type;
	my $len = length($content);
	$content = "Content-Type: $mime_type\r\n"
	    . "Content-Length: $len\r\n\r\n$content";
    } else {
	$content = "\r\n\r\n";
    }
    my $req = "$method $path HTTP/1.0\r\nHost: $site:$port\r\n"
      . $headers . "Accept: */*\r\n$content";    

    ($http, $errs) = https_cat($site, $port, $req);    
    return (undef, "HTTP/1.0 900 NET OR SSL ERROR\r\n\r\n$errs") if $errs;
    
    ($headers, $page) = split /\s?\n\s?\n/, $http, 2;
    ($response, $headers) = split /\s?\n/, $headers, 2;
    return ($page, $response,
	    map( { ($h,$v)=/^(\S+)\:\s*(.*)$/; (uc($h),$v); }
		split(/\s?\n/, $headers)
		)
	    );
}

sub get_https {
    my ($site, $port, $path, $headers, $content, $mime) = @_;
    return do_https($site, $port, $path, 'GET', $headers, $content, $mime);
}

sub post_https {
    my ($site, $port, $path, $headers, $post_str, $mime) = @_;
    return do_https($site, $port, $path, 'POST', $headers, $post_str, $mime);
}

1;
__END__
