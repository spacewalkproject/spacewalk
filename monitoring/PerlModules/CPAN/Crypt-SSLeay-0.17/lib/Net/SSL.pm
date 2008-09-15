package Net::SSL;

# $Id: SSL.pm,v 1.1 2000-10-14 01:30:56 dfaraldo Exp $

use strict;
use vars qw(@ISA $VERSION);
$VERSION = sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

require IO::Socket;
@ISA=qw(IO::Socket::INET);
my %REAL;

require Crypt::SSLeay;

sub _default_context
{
    require Crypt::SSLeay::MainContext;
    Crypt::SSLeay::MainContext::main_ctx(@_);
}

sub DESTROY {
    my $self = shift;
    delete $REAL{$self};
}

sub configure
{
    my($self, $arg) = @_;
    my $ssl_version = delete $arg->{SSL_Version} || 23;
    my $ctx = delete $arg->{SSL_Context} || _default_context($ssl_version);
    *$self->{'ssl_ctx'} = $ctx;
    *$self->{'ssl_version'} = $ssl_version;
    *$self->{'ssl_arg'} = $arg;
    $self->SUPER::configure($arg);
}

sub connect
{
    my $self = shift;

    *$self->{io_socket_peername}=@_ == 1 ? $_[0] : IO::Socket::sockaddr_in(@_);    
    if(!$self->SUPER::connect(@_)) {
	# better to die than return here
	die "Connect failed: $!";
    }

    my $ssl = Crypt::SSLeay::Conn->new(*$self->{'ssl_ctx'}, $self);
#    print "ssl_version ".*$self->{ssl_version}."\n";
    if ($ssl->connect <= 0) {
	if(*$self->{ssl_version} == 23) {
	    my $arg = *$self->{ssl_arg};
	    $arg->{SSL_Version} = 3;
	    # the new connect might itself be overridden with a REAL SSL
	    my $new_ssl = Net::SSL->new(%$arg);
	    $REAL{$self} = $REAL{$new_ssl} || $new_ssl;
	    return $REAL{$self};
	} elsif(*$self->{ssl_version} == 3) {
# +           $self->die_with_error("SSL negotiation failed");
	    my $arg = *$self->{ssl_arg};
	    $arg->{SSL_Version} = 2;
	    my $new_ssl = Net::SSL->new(%$arg);
	    $REAL{$self} = $new_ssl;
	    return $new_ssl;
	} else {
            $self->die_with_error("SSL negotiation failed");
	    return;
	}
    }

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

sub read
{
    my $self = shift;
    $self = $REAL{$self} || $self;
    my $n=*$self->{'ssl_ssl'}->read(@_);
    $self->die_with_error("read failed") if !defined $n;
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
    # should we care about $, and $\??
    # I think it is too expensive...
    $self->write(join("", @_));
}

sub printf
{
    my $self = shift;
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
sub getline  { shift->_unimpl("getline");  }
sub getlines { shift->_unimpl("getlines"); }

# XXX: no way to disable <$sock>??  (tied handle perhaps?)

sub _unimpl
{
    my($self, $meth) = @_;
    die "$meth not implemented for Net::SSL sockets";
}

1;
