#
#
# a class for implementing a IO::Socket::INET type interface
# to SSL-sockets (aspa@kronodoc.fi).
#
# this implementation draws from Crypt::SSLeay (Net::SSL)
# by Gisle Aas.
# 
#
# $Id: SSL.pm,v 1.2 2002-02-23 00:38:59 dfaraldo Exp $.
#

#
# prerequisites: 
#  - Net_SSLeay-1.03 (CPAN).
#  - OpenSSL v0.9.1c (ftp://ftp.openssl.org/).
#

# Notes:
# ------
# * IO::Socket::INET interface used by LWP::Protocol::http (see
#   LWP::Protocol::http::request (LWP v5.43)):
# * Net::SSL interface used by LWP::Protocol (see
#   LWP::Protocol::https (LWP v5.43)):
#   - $sock->get_peer_certificate, $sock->get_cipher,
#     $cert->subject_name, $cert->issuer_name.
# * LWP::Protocol::https disables warnings.
#
# TODO:
# -----
# - error handling: a server side view.
#
#

package IO::Socket::SSL;

use 5.005;
use strict;
use Carp;
use English;
use POSIX qw(getcwd);

use Net::SSLeay;
use IO::Socket;


$IO::Socket::SSL::VERSION = '0.80';
@IO::Socket::SSL::ISA = qw(IO::Socket::INET);


Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
Net::SSLeay::randomize();

$IO::Socket::SSL::SSL_Context_obj = 0;
$IO::Socket::SSL::DEBUG = 0;

if($IO::Socket::SSL::DEBUG) {
  print STDERR "\nusing **SSL_NetSSLeay.pm: v$IO::Socket::SSL::VERSION\n";
}

#
# ***** set default values for key and cert files etc.
#
my $DEFAULT_SERVER_KEY_FILE = "certs/server-key.pem";
my $DEFAULT_SERVER_CERT_FILE = "certs/server-cert.pem";
my $DEFAULT_CLIENT_KEY_FILE = "certs/client-key.pem";
my $DEFAULT_CLIENT_CERT_FILE = "certs/client-cert.pem";
my $DEFAULT_CA_FILE = "certs/my-ca.pem";
my $DEFAULT_CA_PATH = getcwd() . "/certs";
my $DEFAULT_IS_SERVER = 0;
my $DEFAULT_USE_CERT = 0;
# &Net::SSLeay::VERIFY_NONE, &Net::SSLeay::VERIFY_PEER();
my $DEFAULT_VERIFY_MODE = &Net::SSLeay::VERIFY_PEER();
my $DEFAULT_CIPHER_LIST = "ALL:!LOW:!EXP";
my $DEFAULT_SSL_VERSION = undef;

#
# ******************** IO::Socket::SSL class ********************
#

# class attributes:
# -----------------
# - SSL_Context_obj
# - DEBUG
# - _SSL_SSL_obj
# - _arguments
#
# private methods:
# ----------------
# - _init_SSL, _unsupported, _unimplemented,
#   _myerror, _get_SSL_err_str.


sub context_init {
  my $args = shift;
  my ($ctx);

  if ( ! defined ($ctx = SSL_Context->new($args)) ) {
    return $ctx;
  }
  $IO::Socket::SSL::SSL_Context_obj = $ctx;

  return 1;
}


# object creation call stack:
# - new IO::Socket::SSL
# -- new IO::Socket::INET
# --- new IO::Socket
# ---- new IO::Handle
# ---- IO::Socket::SSL::configure
# ----- IO::Socket::INET::configure
# ------ listen/connect

sub new {
  my $class = shift || "IO::Socket::SSL";

  my $self;
  if( !($self = $class->SUPER::new(@_)) ) {
    return undef;
  }
  ${*$self}{'_fileno'} = fileno($self);

  bless $self, $class;
  my $tiedhandle = tie *{$self}, $class, $self;

  return $tiedhandle;
}


# ***** configure
#
# return values: IO::Socket::SSL or undef.
#
sub configure {
  my ($self, $args) = @_;

  my ($r, $k, $v, $ctx_obj, $ctx_created, $ssl_obj);

  # set instance attributes.
  ${*$self}{'_SSL_SSL_obj'} = undef;
  ${*$self}{'_EOF'} = 0;

  $ctx_obj = $IO::Socket::SSL::SSL_Context_obj;

  # SSL_Context::new sets up SSL context. it's run only once.
  if(! $ctx_obj ) { 
    # implicitly create SSL context. argument logic:
    # on an implicit context creation per connection arguments
    # are used also as global SSL context arguments!
    if( ! defined ($ctx_obj = SSL_Context->new($args)) ) {
      # context initialization failed. fatal.
      return undef;
    } else {
      # a valid context was returned. save it.
      $IO::Socket::SSL::SSL_Context_obj = $ctx_obj;
    }
  }

  # save SSL configuration arguments from $args and save
  # them in ${*$self} for connect and accept.
  ${*$self}{'_arguments'} = $args;

  # call superclass's (IO::Socket::INET) configure to setup
  # connection. superclass's configure calls connect and
  # accept methods among others.
  if( !($r = $self->SUPER::configure($args)) ) {
    my $err_str = "\$fh->SUPER::configure() failed: $!.";
    return $self->_myerror("configure: '$err_str'.");
  }

  return $self;
}

# ***** connect
#
# return values: IO::Socket::SSL or undef.
#
sub connect {
  my $self = shift;
  my ($s, $r, $ssl_obj);

  my $args = ${*$self}{'_arguments'};

  if( !($s = $self->SUPER::connect(@_)) ) {
    return $s;
  }

  # create the SSL object.
  if( ! ($ssl_obj = SSL_SSL->new($s, $args)) ) {
    return undef;
  }
  ${*$s}{'_SSL_SSL_obj'} = $ssl_obj;

  my $ssl = $ssl_obj->get_ssl_handle();
  if ( ($r = Net::SSLeay::connect($ssl)) <= 0 ) { # ssl/s23_clnt.c
    my $err_str = $self->_get_SSL_err_str();    
    return $self->_myerror("SSL_connect: '$err_str'.");
  }
  ${*$self}{'_opened'} = 1;

  return $self;
}

# ***** accept
#
# return values: IO::Socket::SSL or undef.
#
sub accept {
  my $self = shift;
  my $class = shift || "IO::Socket::SSL";
  my ($newsock, $r, $ssl_obj);

  my $args = ${*$self}{'_arguments'};

  if( ! ($newsock = IO::Socket::accept($self, 'IO::Socket::INET')) ) {
    return $self->_myerror("accept failed: '$!'.\n");
  }
  my $fileno = fileno($newsock);
  ${*$newsock}{'_fileno'} = $fileno;

  # create the SSL object.
  if( ! ($ssl_obj = SSL_SSL->new($newsock, $args)) ) {
    return undef;
  }
  ${*$newsock}{'_SSL_SSL_obj'} = $ssl_obj;

  my $ssl = $ssl_obj->get_ssl_handle();
  if( ($r = Net::SSLeay::accept($ssl)) <= 0 ) { # ssl/s23_srvr.c
    my $err_str = $self->_get_SSL_err_str();
    return $self->_myerror("SSL_accept: '$err_str'.");
  }

  # make $newsock a IO::Socket::SSL object and tie it.
  bless $newsock, $class;
  my $tiedhandle = tie *{$newsock}, $class, $newsock;


  print STDERR "accept: self: $self, newsock: $newsock, fileno: $fileno.\n"
    if $IO::Socket::SSL::DEBUG;
  ${*$newsock}{'_opened'} = 1;
  return $newsock;
}


# ***** alias sysread and syswrite.
*read = \&sysread;
*write = \&syswrite;


# ***** syswrite

sub syswrite {
  if( (@_ < 2) || (@_ > 4) ) {
    croak '$fh->syswrite(BUF [, LEN [, OFFSET]])';
   }

  my $self = shift;
  my $buf = shift;
  my $arg_len = shift || length $buf;
  my $offset = shift || 0;

  my $ssl_obj = ${*$self}{'_SSL_SSL_obj'};
  my $ssl = $ssl_obj->get_ssl_handle();

  my ($res, $len, $real_len, $wbufref);


  # obtain a buffer ref to write buffer.
  $wbufref = \substr("$buf", $offset, $arg_len);

  # argument length is not allowed to be greater than buffer length.
  if( $arg_len > ($real_len = length($$wbufref)) ) {
    $len = $real_len;
  } else {
    $len = $arg_len; 
  }
  
  # see Net_SSLeay-1.03/SSLeay.xs,
  # openssl-0.9.1c/ssl/ssl_lib.c and bio_ssl.c.
  if( ($res = Net::SSLeay::write($ssl, $$wbufref)) < 0 ) {
    my $err_str = $self->_get_SSL_err_str();
    return $self->_myerror("SSL_write: '$err_str'.");
  }

  return $res;
}


# ***** sysread

sub sysread {
  if( (@_ != 3) && (@_ != 4) ) {
    croak '$fh->sysread(BUF, LEN [, OFFSET])';
  }
  
  my $self = $_[0];
  my $max_len = $_[2];
  my $offset = $_[3] || 0;

  my $int_buf;

  my $ssl_obj = ${*$self}{'_SSL_SSL_obj'};
  my $ssl = $ssl_obj->get_ssl_handle();

  # see Net_SSLeay-1.03/SSLeay.xs,
  # openssl-0.9.1c/ssl/ssl_lib.c and bio_ssl.c.
  if( ! defined ($int_buf = Net::SSLeay::read($ssl, $max_len)) ) {
    my $err_str = $self->_get_SSL_err_str();
    return $self->_myerror("SSL_read: '$err_str'.");
  }
  my $read_len = length($int_buf);

  # EOF handling: we've had an EOF if Net::SSLeay::read() returns 0.
  if( $read_len == 0 ) {
    # N.B.: perl sysread() semantics seem to require that
    # the buffer is set to "" when an EOF is encountered.
    $_[1] = "";
    return 0;
  }

  if(!defined($_[1])) { $_[1] = ""; } # initialize uninitialized buffer.
  my $buffer_len = length($_[1]);
  my $start = ($offset >= 0) ? $offset : $buffer_len + $offset;
  my $elen = $buffer_len - $start;

  # IO::Scalar might be handy with buffer handling.
  if ( ($start >= 0) && ($start <= $buffer_len) ) {
    substr($_[1], $start, $elen) = "$int_buf";
  } else {
    croak '$fh->sysread(): offset outside of buffer.' .
      " ('$_[1]' : $start / $buffer_len / $read_len).";
  }

  return $read_len;
}

# ***** readline

sub readline {
  my $self = shift;
      
  my $ssl_obj = ${*$self}{'_SSL_SSL_obj'};
  my $ssl = $ssl_obj->get_ssl_handle();

  if (wantarray()) { # list context
    my (@got, $got);
    while ($got = Net::SSLeay::ssl_read_until($ssl)) { push @got, $got; }
    return @got;
  }
  else { # scalar or void context
    my $got = Net::SSLeay::ssl_read_until($ssl);
    return ($got eq '')?undef:$got;
  }
}


# ***** print

sub print {
  if( ! @_ ) {
    croak 'usage: $fh->print([ARGS])';
  }

  my $field_separator = (defined $,) ? $, : '';
  my $record_separator = (defined $\) ? $\ : '';

  my $self = shift;
  my $str = join($field_separator, @_, $record_separator);

  #print STDERR "print: str: '$str'\n" if $IO::Socket::SSL::DEBUG;
  return $self->syswrite($str, length($str));
}


# ***** printf

sub printf {
  if( (@_ < 2) ) {
    croak 'usage: $fh->printf(FMT,[ARGS])';
  }

  my $self = shift;
  my $fmt = shift;

  my $str = sprintf($fmt, @_);   # sprintf return values?
  return $self->syswrite($str, length($str));
}


# ***** close

sub close {
  my $self = shift;

  print STDERR "close: $self.\n" if $IO::Socket::SSL::DEBUG;
  # NB: the next two lines seem to result in SIGSEGV with perl v5.6.0
  #     on my linux system.
  my $prev = untie(*$self);
  return $self->SUPER::close();
  ${*$self}{'_opened'} = 0;
  return 1;
}

sub opened {
  my $self = shift;
  return ${*$self}{'_opened'};
}

# **** FILENO

sub FILENO {
  my $self = shift;
  my $fileno = ${*$self}{'_fileno'};

  return $fileno;
}


# ***** socketToSSL

# support for startTLS.
sub socketToSSL {
  my $sock = shift;
  my $r;

  if(!$sock) {
    croak 'usage: IO::Socket::SSL::socketToSSL(socket)';
  }

  # transform IO::Socket::INET to IO::Socket::SSL.

  # create an SSL object.
  my $ssl_obj;
  if( ! ($ssl_obj = SSL_SSL->new($sock, {})) ) {
    return undef; # can't create SSL_SSL.
  }
  $ {*$sock} {'_SSL_SSL_obj'} = $ssl_obj;

  my $ssl = $ssl_obj->get_ssl_handle();
  if ( ($r = Net::SSLeay::connect($ssl)) <= 0 ) { # ssl/s23_clnt.c
    my $err_str = IO::Socket::SSL::_get_SSL_err_str();
    return undef; # SSL_connect failed.
  }

  bless $sock, "IO::Socket::SSL";
  my $tiedhandle = tie *{$sock}, "IO::Socket::SSL", $sock;
  
  return $tiedhandle;
}

# ***** get_verify_mode

sub get_verify_mode {
  my $self = shift;

  # get verify mode from SSL_SSL!

  my $ctx_obj = $IO::Socket::SSL::SSL_Context_obj;
  my $ctx = $ctx_obj->get_context_handle;

  # Net::SSLeay does not implement this function, yet.
  #my $mode = &Net::SSLeay::CTX_get_verify_mode($ctx);
  #return $mode;
  return undef;
}

# ***** get_cipher

sub get_cipher {
  my $self = shift;

  my $ssl_obj = ${*$self}{'_SSL_SSL_obj'};
  my $ssl = $ssl_obj->get_ssl_handle();

  my $cipher_str = Net::SSLeay::get_cipher($ssl);

  return $cipher_str;
}


# ***** get_peer_certificate

sub get_peer_certificate {
  my $self = shift;

  my $ssl_obj = ${*$self}{'_SSL_SSL_obj'};
  my $ssl = $ssl_obj->get_ssl_handle();

  my ($cert, $cert_obj);

  if(!($cert = Net::SSLeay::get_peer_certificate($ssl))) {
    my $err_str = $self->_get_SSL_err_str();    
    return $self->_myerror("get_peer_certificate: '$err_str'.");    
  }

  $cert_obj = X509_Certificate->new();
  $cert_obj->{'_cert_handle'} = $cert;

  return $cert_obj;
}


sub DESTROY {
  my $self = shift;

  print STDERR "IO::Socket::SSL::DESTROY: '$self'.\n"
      if $IO::Socket::SSL::DEBUG;

}

# ***** define filehandle tying interface.
sub TIEHANDLE { return $_[1]; }
*PRINT = \&print;
*PRINTF = \&printf;
*WRITE = \&write;
*READLINE = \&readline;
*GETC = \&getc;
*READ = \&read;
*CLOSE = \&close;


# ***** unsupported methods.

sub getc { shift->_unsupported("getc"); }
sub eof { shift->_unsupported("eof"); }
sub truncate { shift->_unsupported("truncate"); }
sub stat { shift->_unsupported("stat"); }
sub ungetc { shift->_unsupported("ungetc"); }
sub setbuf { shift->_unsupported("setbuf"); }
sub setvbuf { shift->_unsupported("setvbuf"); }


# ***** unimplemented methods.

sub getline { shift->_unimplemented("getline"); }
sub getlines { shift->_unimplemented("getlines"); }
sub fdopen { shift->_unimplemented("fdopen"); }
sub untaint { shift->_unimplemented("untaint"); }


# ***** utility methods

sub _myerror {
  my $fh = shift;
  $fh = ref($fh) ? $fh : 0;

  my $errstr = join("", "fh: '$fh'. error message: '", @_, "'");

  carp $errstr if $IO::Socket::SSL::DEBUG;
  if($fh && defined fileno($fh)) {
    #$fh->close();
  }
  return undef;
}

sub _unsupported {
  my($self, $meth) = @_;
  die "'$meth' not supported by IO::Socket::SSL sockets";
}

sub _unimplemented {
  my($self, $meth) = @_;
  die "'$meth' not implemented for IO::Socket::SSL sockets";
}

sub _get_SSL_err_str {
  my $err = Net::SSLeay::ERR_get_error();    
  my $err_str = Net::SSLeay::ERR_error_string($err);
  return $err_str;
}

1;

#
# ******************** SSL_SSL class ********************
#

package SSL_SSL;

# class attributes:
# - _SSL_ssl_handle.

@SSL_SSL::ISA = ();

# ***** new
#
# return values: SSL-ref or undef.
#
sub new {
  my $class = shift;
  my $s = shift;
  my $args = shift;

  my $self = {};
  bless $self, $class;

  my ($r, $ssl);
  my $ctx_obj = $IO::Socket::SSL::SSL_Context_obj;
  my $ctx = $ctx_obj->get_context_handle;

  my $cipher_list = $args->{'SSL_cipher_list'} || $DEFAULT_CIPHER_LIST;
  my $verify_mode = (defined $args->{'SSL_verify_mode'}) ? 
    $args->{'SSL_verify_mode'} : undef;


  # create a new SSL structure and attach it to the context.
  if (!($ssl = Net::SSLeay::new($ctx)) ) {
    my $err_str =IO::Socket::SSL::_get_SSL_err_str();
    return IO::Socket::SSL::_myerror("SSL_new: '$err_str'.");
  }	

  # set per connection options.
  if (defined $verify_mode) {
    &Net::SSLeay::set_verify($ssl, $verify_mode, 0);
  }
  # see: bin/openssl ciphers -v,
  #      http://www.modssl.org/docs/2.3/ssl_reference.html#ToC9
  &Net::SSLeay::set_cipher_list($ssl, $cipher_list);
  
  if( ! ($r = Net::SSLeay::set_fd($ssl, $s->fileno)) ) {
    my $err_str = IO::Socket::SSL::_get_SSL_err_str();
    return IO::Socket::SSL::_myerror("set_fd: '$err_str'.");
  }

  $self->{'_SSL_ssl_handle'} = $ssl;

  return $self;
}


sub get_ssl_handle {
  my $self = shift;

  return $self->{'_SSL_ssl_handle'};
}


# ***** DESTROY

sub DESTROY {
  my $self = shift;

  my $ssl = $self->get_ssl_handle();

  print STDERR "DESTROY: $self.\n" if $IO::Socket::SSL::DEBUG;
  
  if($ssl) {
    # should release all SSL-struct related resources.
    Net::SSLeay::free($ssl);
    $self->{'_SSL_ssl_handle'} = undef;
  }
}


1;

#
# ******************** SSL_Context class ********************
#

package SSL_Context;

# class attributes:
# - _SSL_context.

@SSL_Context::ISA = ();

#
# ***** SSL_Context::new
#
# return values: SSL context ref or undef.
#
sub new {
  my ($class, $args) = @_;

  my ($key_file, $cert_file, $ca_file, $ca_path,
      $is_server, $use_cert, $verify_mode, $r, $s, $ctx);

  my $self = {};
  bless $self, $class;


  # get SSL arguments.
  $is_server = $args->{'SSL_server'} || $args->{'Listen'};
  if ( $is_server ) {
    # creating a server socket.
    $key_file=$args->{'SSL_key_file'}||$DEFAULT_SERVER_KEY_FILE;
    $cert_file=$args->{'SSL_cert_file'}||$DEFAULT_SERVER_CERT_FILE;
  } else {
    # creating a client socket.
    $key_file=$args->{'SSL_key_file'}||$DEFAULT_CLIENT_KEY_FILE;
    $cert_file=$args->{'SSL_cert_file'}||$DEFAULT_CLIENT_CERT_FILE;
  }
  $ca_file =  (defined $args->{'SSL_ca_file'}) ?
    $args->{'SSL_ca_file'} : $DEFAULT_CA_FILE;
  $ca_path = $args->{'SSL_ca_path'} || $DEFAULT_CA_PATH;
  $verify_mode = (defined $args->{'SSL_verify_mode'}) ? 
      $args->{'SSL_verify_mode'} : $DEFAULT_VERIFY_MODE;
  $use_cert = $args->{'SSL_use_cert'} || $DEFAULT_USE_CERT;

  # choose SSL protocol version to be used.
  my $CTX_constructor = undef;
  my $ssl_version = $args->{'SSL_version'} || $DEFAULT_SSL_VERSION;
  if($ssl_version) {
    if($ssl_version eq "sslv2" ) {
      $CTX_constructor = \&Net::SSLeay::CTX_v2_new;
      print STDERR "using SSLv2\n" if($IO::Socket::SSL::DEBUG);
    } elsif ($ssl_version eq "sslv3" ) {
      $CTX_constructor = \&Net::SSLeay::CTX_v3_new;
      print STDERR "using SSLv3\n" if($IO::Socket::SSL::DEBUG);
    } elsif ($ssl_version eq "tlsv1") {
      $CTX_constructor = \&Net::SSLeay::CTX_tlsv1_new;
      print STDERR "using TLSv1\n" if($IO::Socket::SSL::DEBUG);
    } else { # SSL v23
      ;
    }
  }
  if(!$ssl_version || !$CTX_constructor) { # default to SSL v23
    print STDERR "using SSLv2/3\n" if($IO::Socket::SSL::DEBUG);
    $CTX_constructor = \&Net::SSLeay::CTX_new;
  }

  # create SSL context;
  if(! ($ctx = &{$CTX_constructor}() ) ) {
    my $err_str = IO::Socket::SSL::_get_SSL_err_str();
    return IO::Socket::SSL::_myerror("CTX_new(): '$err_str'.");
  }

  # set options for the context.
  $r = Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL() );
      
  if( !($verify_mode == &Net::SSLeay::VERIFY_NONE()) ) {
      # set SSL certificate load paths.
      if(!($r = Net::SSLeay::CTX_load_verify_locations($ctx,
						       $ca_file,
						       $ca_path))) {
	  my $err_str = IO::Socket::SSL::_get_SSL_err_str();
	  return IO::Socket::SSL::_myerror("CTX_load_verify_locations: " .
					   "'$err_str'.");
      }
  }

  # NOTE: private key, certificate and certificate verification
  #       mode are associated only to the SSL context. this is
  #       because they are client/server specific attributes and
  #       it doesn't seem to make much sense to change them between
  #       requests (aspa@kronodoc.fi).

  # load certificate and private key.
  if( $is_server || $use_cert ) {
    print STDERR "loading private key ($key_file).\n"
      if ($IO::Socket::SSL::DEBUG);
    if(!($r=Net::SSLeay::CTX_use_PrivateKey_file($ctx,
		 $key_file, &Net::SSLeay::FILETYPE_PEM() ))) {
      my $err_str = IO::Socket::SSL::_get_SSL_err_str();    
      return IO::Socket::SSL::_myerror("CTX_use_RSAPrivateKey_file:" .
				       " '$err_str'.");
    }
    print STDERR "loading cert ($cert_file).\n"
      if ($IO::Socket::SSL::DEBUG);
    if(!($r=Net::SSLeay::CTX_use_certificate_file($ctx,
		 $cert_file, &Net::SSLeay::FILETYPE_PEM() ))) {
      my $err_str = IO::Socket::SSL::_get_SSL_err_str();    
      return IO::Socket::SSL::_myerror("CTX_use_certificate_file:" .
				       " '$err_str'.");
    }
  }

  $r = Net::SSLeay::CTX_set_verify($ctx, $verify_mode, 0);

  $self->{'_SSL_context'} = $ctx;

  return $self;
}

sub get_context_handle {
  my $self = shift;

  return $self->{'_SSL_context'};
}

sub DESTROY {
  my $self = shift;

  my $ctx = $self->get_context_handle;

  print STDERR "SSL_Context::DESTROY: '$self', '$ctx'.\n"
      if $IO::Socket::SSL::DEBUG;

  # this is an example of a potential race condition.
  if ($ctx && !$self->{'_CTX_freed'}) {
    # should release all SSL_CTX-struct related resources.
    Net::SSLeay::CTX_free($ctx);
    $self->{'_CTX_freed'} = 1;
  }

  # IO::Socket::SSL specific.
  if(defined($IO::Socket::SSL::SSL_Context_obj)) {
    $IO::Socket::SSL::SSL_Context_obj = 0;
  }
}


1;

#
# ******************** X509_Certificate class ********************
#

#
# a minimal class for providing certificate handling functionality
# needed by libwww-perl (LWP::Protocol::https).
#

package X509_Certificate;

# class attributes:
# - _cert_handle

@X509_Certificate::ISA = ();

sub new {
  bless {};
};

sub subject_name {
  my $self = shift;
  my $cert = $self->{'_cert_handle'};

  my ($name, $str_name);

  if(!($name = Net::SSLeay::X509_get_subject_name($cert))) {
    my $err_str = IO::Socket::SSL::_get_SSL_err_str();    
    return IO::Socket::SSL::_myerror("X509_get_subject_name: " .
				     "'$err_str'.");
  }

  $str_name = Net::SSLeay::X509_NAME_oneline($name);

  return "$str_name";
}

sub issuer_name {
  my $self = shift;
  my $cert = $self->{'_cert_handle'};

  my ($name, $str_name);

  if(!($name = Net::SSLeay::X509_get_issuer_name($cert))) {
    my $err_str = IO::Socket::SSL::_get_SSL_err_str();    
    return IO::Socket::SSL::_myerror("X509_get_issuer_name:" .
				     " '$err_str'.");    
  }
 
  $str_name = Net::SSLeay::X509_NAME_oneline($name);

  return "$str_name";
}

sub DESTROY {
  my $self = shift;

  my $cert = $self->{'_cert_handle'};

  print STDERR "X509_Certificate::DESTROY: '$self', '$cert'.\n"
      if $IO::Socket::SSL::DEBUG;
  
  # here we should free resources held by the the certificate.

  # include/openssl/x509.h: X509_free(X509 *a);
  # NB: Net::SSLeay (v1.05) doesn't define this!
  #Net::SSLeay::X509_free($cert);
}


1;

__END__

=head1 NAME

IO::Socket::SSL - a SSL socket interface class

=head1 SYNOPSIS

use IO::Socket::SSL;

=head1 DESCRIPTION

IO::Socket::SSL is a class implementing an object oriented
interface to SSL sockets. The class is a descendent of
IO::Socket::INET and provides a subset of the base class's
interface methods as well as SSL specific methods.

=head1 SUPPORTED INTERFACE

The following methods from the IO::Socket::INET interface are
supported, unimplemented and unsupported respectively:

=over 4

=item supported methods

IO::Socket::INET interface: new, close, fileno, opened, flush,
socket, socketpair, bind, listen, peername, sockname,
timeout, sockopt, sockdomain, socktype, protocol, sockaddr,
sockport, sockhost, peeraddr, peerport, peerhost, sysread,
syswrite, read, write, DESTROY, accept, connect, print, printf;

others: context_init, get_cipher, get_peer_certificate;

=item unimplemented methods

getline, getlines, fdopen, untaint, error, clearerr, send, recv;

=item unsupported methods

getc, eof, truncate, stat, ungetc, setbuf, setvbuf, <$fh>.

=back

=head1 CLASS VARIABLES

=over 4

=item IO::Socket::SSL::DEBUG

=back


=head1 METHODS

=head2 context_init ( [ARGS] )

This class method is used for initializing and setting
the global SSL settings. The following following arguments are
supported:

=over 4

=item SSL_server

This option must be used when a SSL_Context is explicitly created
for server contexts.

=item SSL_use_cert

With server sockets a server certificate is always used. For client
sockets certificate use is optional. This attribute is set to true
if a certificate is to be used.

=item SSL_verify_mode

Type of verification process which is to be performed upon a peer
certificate. This can be a combination of 0x00 (don't verify),
0x01 (verify peer), 0x02 (fail verification if there's no peer
certificate), and 0x04 (verify client once). Default: verify peer.

=item SSL_key_file

Filename of the PEM encoded private key file. Default:
"certs/server-key.pem" or "certs/client-key.pem".

=item SSL_cert_file

Filename of the PEM encoded certificate file. Default:
"certs/server-cert.pem" or "certs/client-cert.pem".

=item SSL_ca_path

Pathname to the Certicate Authority certificate directory. If server
or client certificates are to be verified the trusted CA certificates
have to reside in this directory. The CA certificate filename that is
used for finding the certificate is a hash value generated from the
certificate with a .<serial number> suffix appended to it. The hash
value can be obtained with the command line: ssleay x509 -hash
< ca-cert.pem.

=item SSL_ca_file

Filename of the CA certificate.

=back


=head2 new ( [ARGS] )

See IO::Socket::INET constructor's documentation for
details. The following additional per connection SSL options
are supported:

=over 4

=item SSL_verify_mode

See above.

=item SSL_cipher_list

A list of allowed ciphers. The list is in string form. See
http://www.modssl.org/docs/2.3/ssl_reference.html#ToC9.

=back

=head2 get_cipher

Get a string representation of the used cipher.

=head2 get_peer_certificate

Obtain a reference to the X509_Certificate object representing
peer's certificate.

=head1 RELATED CLASSES

These are internal classes with which the IO::Socket::SSL API
user usually doesn't have to be concerned with.

=head2 SSL_Context

Encapsulates global SSL options.

=head2 METHODS

=over 4

=item new ( [ARGS] )

See context_init arguments.

=item DESTROY

=back



=head2 SSL_SSL

Encapsulates per connection SSL options.

=head2 METHODS

=over 4

=item new ( [ARGS] )

=item DESTROY

=back



=head2 X509_Certificate

Encapsulates X509 certificate information.

=head2 METHODS

=over 4

=item subject_name

Returns a stringified representation of subject's name.

=item issuer_name

Returns a stringified representation of issuer's name.

=back



=head1 EXAMPLES

See demo and t directories.

=head1 RESTRICTIONS

Currently, the IO::Socket::INET interface as implemented by this
package is not quite complete. There can be only one SSL context at
a given time.

=head1 SEE ALSO

IO::Socket::INET.

=head1 ACKNOWLEDGEMENTS

This package has benefited from the work and help of
Gisle Aas and Sampo Kellomäki.

=head1 COPYRIGHT

Copyright 1999, Marko Asplund

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut


# net resources:
# ==============
# http://www.linpro.no/lwp
# http://search.ietf.org/internet-drafts/draft-ietf-tls-https-02.txt
# http://www.ietf.org/rfc/rfc2246.txt
# http://www.rsa.com/rsalabs/pubs/PKCS
# ftp://ftp.bull.com/pub/OSIdirectory/ITUnov96/X.509
# http://www.ietf.org/rfc/rfc1945.txt
# http://www.ietf.org/rfc/rfc2068.txt
# http://www.fortify.net
