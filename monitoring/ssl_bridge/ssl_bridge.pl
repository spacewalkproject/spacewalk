#!/usr/bin/perl

use strict;
use IO::Socket::SSL;
use IO::Socket::INET;
use IO::Select;
use NOCpulse::Config;
use NOCpulse::Debug;


# Constants
my $CRLF     = "\015\012";     # "\r\n" is not portable


# Globals
my $cfg           = new NOCpulse::Config;
my $conn          = 0;


# Log connections and disconnects
my $debug   = new NOCpulse::Debug();
my $logfile = $cfg->get('ssl_bridge', 'logfile');
my $log     = $debug->addstream(LEVEL  => 1,
                                FILE   => $logfile,
                                APPEND => 1);
$log->timestamps(1);
$debug->dprint(1,  "Starting ssl_bridge\n");




# Configuration
my $listen_ip    = $cfg->get('ssl_bridge', 'listenIP') 
                                         or die "No listen IP configured\n";
my $listen_port  = $cfg->get('ssl_bridge', 'listenPort') 
                                         or die "No listen port configured\n";
my $listen_queue = $cfg->get('ssl_bridge', 'listenQueue') || 5;


my $keyfile  = $cfg->get('ssl_bridge', 'key')
                                         or die "No key configured\n";
my $cert     = $cfg->get('ssl_bridge', 'cert')
                                         or die "No cert configured\n";
my $cfile    = $cfg->get('ssl_bridge', 'cfile')
                                         or die "No cfile configured\n";
my $cdir     = $cfg->get('ssl_bridge', 'cdir')
                                         or die "No cdir configured\n";
my $ciphers  = $cfg->get('ssl_bridge', 'ciphers')
                                         or die "No ciphers configured\n";

my $ctimeout = 30;  # Connect timeout
my $dtimeout = 60;  # Data timeout
my $SIGPIPE  = 0;

$SIG{'PIPE'} = sub {$SIGPIPE = 1;};
$SIG{'CHLD'} = 'IGNORE';  # Auto-reap children


IO::Socket::SSL::context_init({ SSL_server      => 1,
			        SSL_use_cert    => 1,
			        SSL_verify_mode => 0x3,
			        SSL_key_file    => $keyfile,
			        SSL_cert_file   => $cert,
			        SSL_ca_file     => $cfile,
			        SSL_ca_path     => $cdir})
                 or die "Unable to set context: $!";

$debug->dprint(1,  "Listening to ${listen_ip}:$listen_port\n");
my $listener = IO::Socket::SSL->new(LocalAddr => "${listen_ip}:$listen_port",
				Proto     => 'tcp',
				Type      => SOCK_STREAM,
				Listen    => $listen_queue,
				Reuse     => 1,
				SSL_cipher_list => $ciphers)
                 or die "Unable to bind to local port: $!";


while (1) {

  my $client = $listener->accept();
  if (! defined($client)) {
  # +++ No info from IO::Socket::SSL, so why bother?
  #  $debug->dprint(1, "ERROR:  Couldn't accept client: $@\n");
    next;
  }

  # Flush before a fork when buffered
  $debug->flush();

  # Increment the connection count
  $conn++;

  # Handle the request
  if (my $pid = fork()) {

    # I am the parent
    $client->close(SSL_no_shutdown => 1);

  } else {

    # I am the child
    &handle_session($client, $conn);
    exit(0);

  }

}

$listener->close();











##############################################################################
###############################  Subroutines  ################################
##############################################################################

sub handle_session {
  my $client = shift;
  my $conn   = shift;

  my ($peerport, $peerhost) = ($client->peerport, $client->peerhost);
  $debug->dprint(1, "Accepted connection $conn from ${peerhost}:$peerport\n");


  # OK, now we have an encrypted client connection.  

  # Read the requested service.  The first line should be:
  #
  #     "GET /XXXX HTTP/1.0<CR><LF><CR><LF>"
  #
  # where XXXX is the four-letter code for the requested service.

  my $req;
  $client->sysread($req, 22);  # +++ Note: this may block indefinitely!
  my($service) = (split(/\s+\/?/, $req))[1];

  # Special case:  Return 'OK' for PING service
  if ($service eq 'PING') {
    my $response = "OK$CRLF";
    $client->syswrite($response, length($response));
    $client->close(SSL_ctx_free => 1);
    $debug->dprint(1, "\t$conn: Closing PING connection\n");
    exit(0);
  }
  
  # Make a connection to the server in the clear.
  my($remip)   = $cfg->get('ssl_bridge', "remoteIP_$service");
  my($remport) = $cfg->get('ssl_bridge', "remotePort_$service");

  unless (defined($remip) and defined($remport)) {
    &blowoff($client, "\t$conn: Closing connection: service '$service' unknown\n");
  }

  my $server = IO::Socket::INET->new(PeerAddr => $remip,
				     PeerPort => $remport,
				     Type     => SOCK_STREAM,
				     Proto    => "TCP",
				     Timeout  => $ctimeout) 
	           or &blowoff($client, "\t$conn: Couldn't connect to service '$service': $!");

  $debug->dprint(1, "\t$conn: Connected to $service server ${remip}:$remport\n");
  $server->sockopt(SO_LINGER, 0);

  my %socket = ( #  name      peer    peername
    "$server" => ['server', $client, 'client'],
    "$client" => ['client', $server, 'server'],
  );


  # Now we've got two connections open.  From here, we just need to
  # shuttle bytes back and forth, and detect when either end has
  # closed the connection.


  my $selector = IO::Select->new($client, $server);
  while (1) {
    my @ready;
    if (@ready = $selector->can_read($dtimeout)) {

      my($got, $bailed);
      foreach my $fh (@ready) {
	my($name, $peer, $peername) = @{$socket{"$fh"}};
	$fh->sysread($got, 32768);
	unless (length($got)) {
	  $bailed = $fh;
	  last;
	}

	my $wrote = $peer->syswrite($got, length($got));

	# Sigpipe?
	if ($SIGPIPE || $wrote == 0) {
	  $bailed = $fh;
	  last;
	}
      }
      if ($bailed) {
	my($name, $peer, $peername) = @{$socket{"$bailed"}};
        my($port, $host) = ($bailed->peerport, $bailed->peerhost);
	$debug->dprint(1, "\t$conn: Connection closed by $name\n");
	last;
      }

    } else {
      $debug->dprint(1, "\t$conn: idle timeout\n");
      last;
    }
  }

  $server->close();
  $client->close(SSL_ctx_free => 1);
}


sub blowoff {
  my $client = shift;
  my $msg = join(" ", @_);
  $debug->dprint(1, "$msg\n");
  $msg .= $CRLF;
  $client->syswrite($msg, length($msg));
  $client->close();
  exit(0);
}
