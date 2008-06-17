package Net::SSL;

use strict;
use vars qw(@ISA $VERSION $NEW_ARGS);

use MIME::Base64;
use Socket;
use Carp;

require IO::Socket;
@ISA=qw(IO::Socket::INET);
my %REAL; # private to this package only
my $DEFAULT_VERSION = '23';
my $CRLF = "\015\012";

require Crypt::SSLeay;
$VERSION = '2.77';

sub _default_context
{
    require Crypt::SSLeay::MainContext;
    Crypt::SSLeay::MainContext::main_ctx(@_);
}

sub new {
    my($class, %arg) = @_;
    local $NEW_ARGS = \%arg;
    $class->SUPER::new(%arg);
}

sub DESTROY {
    my $self = shift;
    delete $REAL{$self};
    local $@;
    eval { $self->SUPER::DESTROY; };
}

sub configure
{
    my($self, $arg) = @_;
    my $ssl_version = delete $arg->{SSL_Version} ||
      $ENV{HTTPS_VERSION} || $DEFAULT_VERSION;
    my $ssl_debug = delete $arg->{SSL_Debug} || $ENV{HTTPS_DEBUG} || 0;

    my $ctx = delete $arg->{SSL_Context} || _default_context($ssl_version);

    *$self->{'ssl_ctx'} = $ctx;
    *$self->{'ssl_version'} = $ssl_version;
    *$self->{'ssl_debug'} = $ssl_debug;
    *$self->{'ssl_arg'} = $arg;
    *$self->{'ssl_peer_addr'} = $arg->{PeerAddr};
    *$self->{'ssl_peer_port'} = $arg->{PeerPort};
    *$self->{'ssl_new_arg'} = $NEW_ARGS;
    *$self->{'ssl_peer_verify'} = 0;

    ## Crypt::SSLeay must also aware the SSL Proxy before calling
    ## $socket->configure($args). Because the $sock->configure() will
    ## die when failed to resolve the destination server IP address,
    ## whatever the SSL proxy is used or not!
    ## - dqbai, 2003-05-10
    if (my $proxy = $self->proxy) {
	my ($host, $port) = split(':',$proxy);
	$port || die("no port given for proxy server $proxy");
	$arg->{PeerAddr} = $host;
	$arg->{PeerPort} = $port;
    }

    $self->SUPER::configure($arg);
}

# override to make sure there is really a timeout
sub timeout {
    shift->SUPER::timeout || 60;
}

sub connect {
    my $self = shift;

    # configure certs on connect() time, so we can throw an undef
    # and have LWP understand the error
    eval { $self->configure_certs(); };
    if($@) {
	$@ = "configure certs failed: $@, $!";
	$self->die_with_error($@);
    }

    # finished, update set_verify status
    if(my $rv = *$self->{'ssl_ctx'}->set_verify()) {
	*$self->{'ssl_peer_verify'} = $rv;
    }

    if ($self->proxy) {
	# don't die() in connect, just return undef and set $@
	my $proxy_connect = eval { $self->proxy_connect_helper(@_); };
	if(! $proxy_connect || $@) {
	    $@ = "proxy connect failed: $@; $!";
	    die $@;
	}
    } else {
	*$self->{io_socket_peername}=@_ == 1 ? $_[0] : IO::Socket::sockaddr_in(@_);    
	if(!$self->SUPER::connect(@_)) {
	    # better to die than return here
	    $@ = "Connect failed: $@; $!";
	    die $@;
	}
    }

#    print "ssl_version ".*$self->{ssl_version}."\n";
    my $debug = *$self->{'ssl_debug'} || 0;
    my $ssl = Crypt::SSLeay::Conn->new(*$self->{'ssl_ctx'}, $debug, $self);
    my $arg = *$self->{ssl_arg};
    my $new_arg = *$self->{ssl_new_arg};
    $arg->{SSL_Debug} = $debug;

    eval {
	local $SIG{ALRM} = sub { $self->die_with_error("SSL connect timeout") };
	# timeout / 2 because we have 3 possible connects here
	alarm_ok() && alarm($self->timeout / 2);

	my $rv;
	{
	    local $SIG{PIPE} = \&die;
	    $rv = eval { $ssl->connect; };
	}
	if ($rv <= 0) {
	    alarm_ok() && alarm(0);
	    $ssl = undef;
	    my %args = (%$new_arg, %$arg);
	    if(*$self->{ssl_version} == 23) {
		$args{SSL_Version} = 3;
		# the new connect might itself be overridden with a REAL SSL
		my $new_ssl = Net::SSL->new(%args);
		$REAL{$self} = $REAL{$new_ssl} || $new_ssl;
		return $REAL{$self};
	    } elsif(*$self->{ssl_version} == 3) {
		# $self->die_with_error("SSL negotiation failed");
		$args{SSL_Version} = 2;
		my $new_ssl = Net::SSL->new(%args);
		$REAL{$self} = $new_ssl;
		return $new_ssl;
	    } else {
		# don't die, but do set $@, and return undef
		eval { $self->die_with_error("SSL negotiation failed") };
		$@ = "$@; $!";
		die $@;
	    }
	}
	alarm_ok() && alarm(0);
    };

    # odd error in eval {} block, maybe alarm outside the evals
    if($@) {
	$! = "$@; $!";
	die $@;
    }

    # successful SSL connection gets stored
    *$self->{'ssl_ssl'} = $ssl;
    $self;
}

sub accept
{
    die "NYI";
}

# Delegate these calls to the Crypt::SSLeay::Conn object
sub get_peer_certificate { 
    my $self = shift;
    $self = $REAL{$self} || $self;
    *$self->{'ssl_ssl'}->get_peer_certificate(@_);
}

sub get_peer_verify {
    my $self = shift;
    $self = $REAL{$self} || $self;
    *$self->{'ssl_peer_verify'};
}

sub get_shared_ciphers   { 
    my $self = shift;
    $self = $REAL{$self} || $self;
    *$self->{'ssl_ssl'}->get_shared_ciphers(@_);
}
sub get_cipher           { 
    my $self = shift;
    $self = $REAL{$self} || $self;
    *$self->{'ssl_ssl'}->get_cipher(@_);
}

#sub get_peer_certificate { *{shift()}->{'ssl_ssl'}->get_peer_certificate(@_) }
#sub get_shared_ciphers   { *{shift()}->{'ssl_ssl'}->get_shared_ciphers(@_) }
#sub get_cipher           { *{shift()}->{'ssl_ssl'}->get_cipher(@_) }

sub ssl_context
{
    my $self = shift;
    $self = $REAL{$self} || $self;
    *$self->{'ssl_ctx'};
}

sub die_with_error
{
    my $self=shift;
    my $reason=shift;

    my $errs='';
    while(my $err=Crypt::SSLeay::Err::get_error_string()) {
       $errs.=" | " if $errs ne '';
       $errs.=$err;
    }
    die "$reason: $errs";
}

sub alarm_ok() {
    $^O ne 'MSWin32';
}

sub read
{
    my $self = shift;
    $self = $REAL{$self} || $self;

    local $SIG{__DIE__} = \&Carp::confess;
    local $SIG{ALRM} = sub { $self->die_with_error("SSL read timeout") };

    alarm_ok() && alarm($self->timeout);
    my $n=*$self->{'ssl_ssl'}->read(@_);
    $self->die_with_error("read failed") if !defined $n;
    alarm_ok() && alarm(0);

    $n;
}

sub write
{
    my $self = shift;
    $self = $REAL{$self} || $self;
    my $n=*$self->{'ssl_ssl'}->write(@_);
    $self->die_with_error("write failed") if !defined $n;
    $n;
}

*sysread  = \&read;
*syswrite = \&write;

sub print
{
    my $self = shift;
    $self = $REAL{$self} || $self;
    # should we care about $, and $\??
    # I think it is too expensive...
    $self->write(join("", @_));
}

sub printf
{
    my $self = shift;
    $self = $REAL{$self} || $self;
    my $fmt  = shift;
    $self->write(sprintf($fmt, @_));
}


sub getchunk
{
    my $self = shift;
    $self = $REAL{$self} || $self;
    my $buf = '';  # warnings
    my $n = $self->read($buf, 32*1024);
    return unless defined $n;
    $buf;
}

# In order to implement these we will need to add a buffer in $self.
# Is it worth it?
sub getc     { shift->_unimpl("getc");     }
sub ungetc   { shift->_unimpl("ungetc");   }

#sub getline  { shift->_unimpl("getline");  }

# This is really inefficient, but we only use it for reading the proxy response
# so that does not really matter.
sub getline {
    my $self = shift;
    $self = $REAL{$self} || $self;
    my $val="";
    my $buf;
    do {
	$self->SUPER::recv($buf, 1);
	$val = $val . $buf;
    } until ($buf eq "\n");

    $val;
}


sub getlines { shift->_unimpl("getlines"); }

# XXX: no way to disable <$sock>??  (tied handle perhaps?)

sub _unimpl
{
    my($self, $meth) = @_;
    die "$meth not implemented for Net::SSL sockets";
}

sub get_lwp_object {
    my $self = shift;

    my $lwp_object;
    my $i = 0;
    while(1) {
	package DB;
	my @stack = caller($i++);
	last unless @stack;
	my @stack_args = @DB::args;
	my $stack_object = $stack_args[0] || next;
	ref($stack_object) || next;
	if($stack_object->isa('LWP::UserAgent')) {
	    $lwp_object = $stack_object;
	    last;
	}
    }

    $lwp_object;
}

sub proxy_connect_helper {
    my $self = shift;

    my $proxy = $self->proxy;
    my ($host, $port) = split(':',$proxy);
    my $conn_ok = 0;
    my $need_auth = 0;
    my $auth_basic = 0;
    my $realm = "";
    my $length = 0;
    my $line = "<noline>";
    my $lwp_object = $self->get_lwp_object;

    my $iaddr = gethostbyname($host);
    $iaddr || die("can't resolve proxy server name: $host, $!");
    $port || die("no port given for proxy server $proxy");
    
    $self->SUPER::connect($port, $iaddr)
      || die("proxy connect to $host:$port failed: $!");
    
    my($peer_port, $peer_addr) = (*$self->{ssl_peer_port}, *$self->{ssl_peer_addr});
    $peer_port || die("no peer port given");
    $peer_addr || die("no peer addr given");

    my $connect_string;
    if ($ENV{"HTTPS_PROXY_USERNAME"} || $ENV{"HTTPS_PROXY_PASSWORD"}) {
	my $user = $ENV{"HTTPS_PROXY_USERNAME"};
	my $pass = $ENV{"HTTPS_PROXY_PASSWORD"};

	my $credentials = encode_base64("$user:$pass", "");
	$connect_string = join($CRLF, 
			       "CONNECT $peer_addr:$peer_port HTTP/1.0",
			       "Proxy-authorization: Basic $credentials"
			      );
    }else{
	$connect_string = "CONNECT $peer_addr:$peer_port HTTP/1.0";
    }
    $connect_string .= $CRLF;
    if($lwp_object && $lwp_object->agent) {
	$connect_string .= "User-Agent: ".$lwp_object->agent.$CRLF;
    }
    $connect_string .= $CRLF;

    $self->SUPER::send($connect_string);
    my $header;
    my $n = $self->SUPER::sysread($header, 8192);
    if($header =~ /HTTP\/\d+\.\d+\s+200\s+/is) {
	$conn_ok = 1;
    }

    unless ($conn_ok) {
        die("PROXY ERROR HEADER, could be non-SSL URL:\n$header");
    }

    $conn_ok;
}

# code adapted from LWP::UserAgent, with $ua->env_proxy API
sub proxy {
    # don't iterate through %ENV for speed
    my $proxy_server;
    for ('HTTPS_PROXY', 'https_proxy') {
	$proxy_server = $ENV{$_};
	last if $proxy_server;
    }
    return unless $proxy_server;

    $proxy_server =~ s|^https?://||i;
    
    $proxy_server;
}

sub configure_certs {
    my $self = shift;
    my $ctx = *$self->{ssl_ctx};

    my $count = 0;
    for ('HTTPS_PKCS12_FILE', 'HTTPS_CERT_FILE', 'HTTPS_KEY_FILE') {
	my $file = $ENV{$_};
	if($file) {
	    (-e $file) or die("$file file does not exist: $!");
	    $count++;
	    if (/PKCS12/) {
		$count++;
		$ctx->use_pkcs12_file($file ,$ENV{'HTTPS_PKCS12_PASSWORD'}) || die("failed to load $file: $!");
		last;
	    } elsif (/CERT/) {
		$ctx->use_certificate_file($file ,1) || die("failed to load $file: $!");
	    } elsif (/KEY/) {
		$ctx->use_PrivateKey_file($file, 1) || die("failed to load $file: $!");
	    } else {
		die("setting $_ not supported");
	    }
	}
    }

    # if both configs are set, then verify them
    if (($count == 2)) {
	if (! $ctx->check_private_key) {
	    die("Private key and certificate do not match");
	}
    }
    
    $count; # number of successful cert loads/checks
}

1;
