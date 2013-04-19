package NOCpulse::PersistentConnection;

use NOCpulse::Debuggable;
use Socket;
use IO::Socket;
use Net::SSLeay qw(die_now die_if_ssl_error print_errs);

use strict;
use vars qw(@ISA);

@ISA = qw( NOCpulse::Debuggable );

my $SOCKET_TIMEOUT  = 30;
my $CONNECT_TIMEOUT = 30;
my $DEFAULTPORT     = 443;
my $CRLF            = "\015\012";     # "\r\n" is not portable
my $TRANS_END       = "0$CRLF$CRLF";


# Don't want to bail out if the remote end closes the connection ...
# just reconnect and try again.
$SIG{'PIPE'} = 'IGNORE';


# Accessor methods
sub host        { shift->_elem('host',        @_); }
sub port        { shift->_elem('port',        @_); }
sub connected   { shift->_elem('connected',   @_); }
sub socket      { shift->_elem('socket',      @_); }
sub ctx         { shift->_elem('ctx',         @_); }
sub ssl         { shift->_elem('ssl',         @_); }



sub new {
  my($class, %args) = @_;
  my $self   = {};
  bless $self, $class;

  my $host = $args{'Host'};
  my $port = $args{'Port'};
  my $debug = $args{'Debug'};

  # Process arguments
  if (! defined($host)) {
    $@ = "Host required but none supplied";
    return undef;
  } else {

    if ($port !~ /^\d+$/) {
     if (defined($port)) {
       $port = getservbyname($port, 'tcp');
     } else {
       $port = $DEFAULTPORT;
     }
    }

    $self->host($host);
    $self->port($port);
  }

  $self->debugobject($debug);

  # Initialize
  Net::SSLeay::load_error_strings();
  Net::SSLeay::SSLeay_add_ssl_algorithms();
  Net::SSLeay::randomize();

  #+++ FOR DEBUGGING
  #$Net::SSLeay::trace = 4;

  return $self;
}





sub connect {
  my($self) = shift;

  my $host     = $self->host;
  my $port     = $self->port;

  my $sock = new IO::Socket::INET(PeerAddr => $host,
				  PeerPort => $port,
				  Proto    => 'tcp',
				  Type     => SOCK_STREAM,
				  Timeout  => $CONNECT_TIMEOUT);

  if (! defined($sock)) {
    $@ = "Couldn't make socket connection: $!";
    return undef;
  }


  # The network connection is now open, lets fire up SSL
  my($ctx, $ssl, $connected);
  eval {
    local $SIG{'ALRM'} = sub {die "Timed out"};
    alarm($CONNECT_TIMEOUT);

    $ctx = Net::SSLeay::CTX_new();

    if (! $ctx) {

      $@ = "Failed to create CTX: $!";

    } else {

      $ssl = Net::SSLeay::new($ctx);

      if (! $ssl) {

	$@ = "Failed to create SSL: $!";

      } else {

	Net::SSLeay::set_fd($ssl, fileno($sock));

	$connected = Net::SSLeay::connect($ssl);
	$@ = "SSL_connect failed: $!" unless ($connected);

      }
    }

  };

  # Check for errors
  if ($@ && $@ =~ /Timed out/) {
    $@="Timed out trying to establish SSL connection";
    return undef;
  } elsif ($@) {
    return undef;
  }


  $self->socket($sock);
  $self->ctx($ctx);
  $self->ssl($ssl);
  $self->connected(1);

  return 1;

}



sub ssl_get {
  my($self, $path, $retry) = @_;

  # Make sure we're still connected
  $self->connect unless ($self->connected);

  my $host = $self->host;
  my $ssl  = $self->ssl;


  my $req = "GET $path HTTP/1.1$CRLF" .
	    "Host: $host$CRLF" .
	    "Connection: keep-alive$CRLF" .
	    "User-Agent:  Queuezilla (Faraldo queueing agent)$CRLF$CRLF";


  # Not quite correct HTTP/1.1 implementation, but close enough and 
  # more efficient.  (See below for discussion of HTTP/1.1 chunked
  # encoding.)
  my($got, $chunk, $sections);
  eval {
    local $SIG{'ALRM'} = sub {die "Timed out"};
    alarm($SOCKET_TIMEOUT);

    my $res = Net::SSLeay::write($ssl, $req);

    while ($got !~ /$TRANS_END$/) {
      $chunk = Net::SSLeay::read($ssl) or die_if_ssl_error("SSL read: $!");

      last if (length($chunk) eq 0);
      $got .= $chunk;
    }
    alarm(0);
  };

  if ($@ && $@ =~ /Timed out/) {

    $@="Timed out waiting for server response";

    # Shut down the socket so we can start anew next time
    $self->shutdown();

    return undef;

  }


  my($headers, @bodychunks) = split(/$CRLF$CRLF/, $got, 2);

  # Check two cases:
  #  1) Did the server request we close the connection?
  #       If so, close the connection and set connected=0
  if ($headers =~ /^Connection:\s+close/mi) {
    #print "+++ Closing connection at server request\n";
    $self->shutdown();
    #print "+++ Connection closed\n";
  }

  #  2) Did the server close the connection (0 bytes receved)?
  #       If so, reconnect and try again.
  if (length($got) == 0) {
    #print "+++ No response from server -- ";
    if ($retry) {
      #print "retry failed, bailing out\n";
    } else {
      if ($self->connect()) {
        $got = $self->ssl_get($path, 1);
      }
    }
  }

  if (length($got) == 0) {

    $@ = "No data from server";
    return undef;

  } else {

    # Check response for success/failure
    my($statusline, $body)  = split(/$CRLF/, $got, 2);
    my($proto, $code, $msg) = split(/\s+/, $statusline, 3);

    if ($code != 200) {
      $body .= "\n(REQUEST: $req)\n";
    }

    my $dechunked_body = $self->dechunk($body);

    return ($code, $msg, $dechunked_body, $statusline, $proto, $got);

  }
}


# Note:  quick hack, just a copy of ssl_get with slightly 
#        different args.  Should be properly decomposed.  -dfaraldo
sub ssl_post {
  my($self, $path, $content, $retry) = @_;

  # Make sure we're still connected
  unless ($self->connected()) {
    my $rv = $self->connect();
    return(500, "Connect failed: $@") unless ($rv);
  }

  my $host = $self->host;
  my $ssl  = $self->ssl;


  my $req = "POST $path HTTP/1.1$CRLF" .
	    "Host: $host$CRLF" .
	    "Connection: keep-alive$CRLF" .
	    "User-Agent:  Queuezilla (Faraldo queueing agent)$CRLF" .
	    "Content-type:  application/x-www-form-urlencoded$CRLF" .
	    "Content-length: " . length($content) . "$CRLF" .
	    "$CRLF" .
	    $content;

  # Not quite correct HTTP/1.1 implementation, but close enough and 
  # more efficient.  (See below for discussion of HTTP/1.1 chunked
  # encoding.)
  my($got, $chunk, $sections);
  eval {
    local $SIG{'ALRM'} = sub {die "Timed out"};
    alarm($SOCKET_TIMEOUT);

    my $res = Net::SSLeay::write($ssl, $req);

    while ($got !~ /$TRANS_END$/) {
      $chunk = Net::SSLeay::read($ssl) or die_if_ssl_error("SSL read: $!");

      last if (length($chunk) eq 0);
      $got .= $chunk;
    }
    alarm(0);
  };

  if ($@ && $@ =~ /Timed out/) {

    # Shut down the socket so we can start anew next time
    $self->shutdown();

    $@="Timed out waiting for server response";
    return (500, $@);

  }


  my($headers, @bodychunks) = split(/$CRLF$CRLF/, $got, 2);

  # Check two cases:
  #  1) Did the server request we close the connection?
  #       If so, close the connection and set connected=0
  if ($headers =~ /^Connection:\s+close/mi) {
    #print "+++ Closing connection at server request\n";
    $self->shutdown();
    #print "+++ Connection closed\n";
  }

  #  2) Did the server close the connection (0 bytes receved)?
  #       If so, reconnect and try again.
  if (length($got) == 0) {

    #print "+++ No response from server -- ";
    if ($retry) {
      # If this call is already a retry, do nothing.
    } else {
      # Shut down the existing connection and open a new one
      $self->shutdown();
      if ($self->connect()) {
        return($self->ssl_post($path, $content, 1));
      } else {
        return (500, "Connect failed: $@");
      }
    }

  }

  if (length($got) == 0) {

    $@ = "No data from server";
    return (500, $@);

  } else {

    # Check response for success/failure
    my($statusline, $body)  = split(/$CRLF/, $got, 2);
    my($proto, $code, $msg) = split(/\s+/, $statusline, 3);

    if ($code != 200) {
      $body .= "\n(REQUEST: $req)\n";
    }

    my $dechunked_body = $self->dechunk($body);

    return ($code, $msg, $dechunked_body, $statusline, $proto, $got);

  }
}







sub shutdown {
  my $self = shift;
  my $ssl  = $self->ssl;
  my $ctx  = $self->ctx;
  my $sock = $self->socket;

  #print "+++ Shutting down socket:\n";
  #print "+++\tSSL free ...\n";
  Net::SSLeay::free($ssl)     if (defined($ssl));

  #print "+++\tCTX free ...\n";
  Net::SSLeay::CTX_free($ctx) if (defined($ctx));

  #print "+++\tClosing socket ...\n";
  $sock->close()              if (defined($sock));
  #print "+++ Disconnected\n";

  $self->socket(undef);
  $self->ctx(undef);
  $self->ssl(undef);
  $self->connected(0);
}


sub dechunk
{
    my $self = shift;
    my $chunked = shift;
    
    my($headers, $body) = split(/$CRLF$CRLF/, $chunked, 2);

    if( not $headers =~ /Transfer-Encoding: chunked/ )
    {
        # The string isn't chunked
        return $body;
    } 

    my $dechunked = '';
    
    my $chunkno = 0;
    my ($chunksize);
    while (length($body)) {
	($chunksize, $body) = split(/$CRLF/, $body, 2);
	last unless ($chunksize);  # Only last chunk has size 0
	
	$chunkno++;

	$chunksize = hex($chunksize);
	my $chunk = substr($body, 0, $chunksize + 2, '');  # Eat that $CRLF, too.
	chop($chunk); chop($chunk);                        # munch munch

	$dechunked .= $chunk;
    }
    
    # What's left of $body are the entity headers

    return $dechunked;
}

# From LWP::MemberMixin by Martijn Koster && Gisle Aas
sub _elem
{
    my($self, $elem, $val) = @_;
    my $old = $self->{$elem};
    $self->{$elem} = $val if defined $val;
    return $old;
}

1;


__END__

# HTTP 1.1 uses a "chunked" transfer encoding.  This means you get:
#  <headers>$CRLF
#  $CRLF
#  <chunk size>$CRLF    \_ zero or more
#  <chunk data>$CRLF    /  of these
#  0$CRLF
#  <entity header>$CRLF -- zero or more of these
#  $CRLF

# Need to read two sections (header and body) each ending in <CRLF><CRLF>
while ($sections < 2) {
  # Getting closer
  $chunk = Net::SSLeay::ssl_read_CRLF($ssl) or die_if_ssl_error("SSL read: $!");
  # But make sure we bail out if the server stops talking to us.
  last if (length($chunk) eq 0);
  $got .= $chunk;

  $sections++ if ($chunk eq $CRLF);
}


# Chunk parsing:
sub blow_chunks {
  my($self, $response) = @_;
  my($headers, $body) = split(/$CRLF$CRLF/, $response, 2);
  print "HEADERS:\n>>>$headers<<<\n\n";

  print "BODY:\n>>>$body<<<\n\n";

  # Peel off chunks
  print "CHUNKS:\n";
  my $chunkno = 0;
  my ($chunksize);
  while (length($body)) {
    ($chunksize, $body) = split(/$CRLF/, $body, 2);
    last unless ($chunksize);  # Only last chunk has size 0

    print "\tchunkno: $chunkno\n"; $chunkno++;
    print "\tsize:    0x$chunksize"; $chunksize = hex($chunksize); print "(${chunksize}d)\n";
    my $chunk = substr($body, 0, $chunksize + 2, '');  # Eat that $CRLF, too.
    chop($chunk); chop($chunk);                        # munch munch
    print "\tchunk (", length($chunk), " bytes):\n";
    print ">>>$chunk<<<\n";
    print "\tleft (", length($body), " bytes):\n";
    print ">>>$body<<<\n";
    print "\t-----------------------------------\n";
  }

  # What's left are the entity headers
  print "\nENTITY HEADERS:\n>>>$body<<<\n";


}
