#!/usr/bin/perl

$|=1;
use strict;
use IO::Socket::SSL;
use IO::Select;


my $ip       = $ARGV[0] || '192.168.0.25';
my $port     = $ARGV[1] || 9999;
my $certbase = '/home/dfaraldo/SPREAD_BRIDGE/new/certs/daphne';
my $keyfile  = "$certbase/client/client.key";
my $cert     = "$certbase/client/client.crt";
my $cdir     = "$certbase/chains";
my $cfile    = "$certbase/chains/nocpulse-dev-sys-proxy-chain.crt";
my $ctimeout = 30;
my $timeout  = 1;
my $CRLF     = "\015\012";     # "\r\n" is not portable
my $VERIFIED = 0;
my $SSLVP    = 1;  # Whether or not to verify peer
my $SIGPIPE  = 0;

$SIG{'PIPE'} = sub {print "Got a SIGPIPE!\n"; $SIGPIPE = 1};


my $sock;
my $tries = 0;

my $ctx = IO::Socket::SSL::context_init({
			    SSL_use_cert    => 1,
			    SSL_verify_mode => 0x3,
			    SSL_key_file    => $keyfile,
			    SSL_cert_file   => $cert,
			    SSL_ca_file     => $cfile});


print "Connecting to ${ip}:$port (attempt #$tries)\n";
$sock = IO::Socket::SSL->new(PeerAddr => $ip,
			     PeerPort => $port,
			     Type     => SOCK_STREAM,
			     Proto    => "TCP",
			     Timeout  => $ctimeout);

die "Unable to connect: $!" unless ($sock);

$sock->sockopt(SO_LINGER, 0);


my $buf;
my $peer_cert    = $sock->get_peer_certificate;
my $subject_name = $peer_cert->subject_name;
my $issuer_name  = $peer_cert->issuer_name;
my $cipher       = $sock->get_cipher();
print "
       Peer cert:     $peer_cert
       Subject name:  $subject_name
       Issuer name:   $issuer_name
       Cipher:        $cipher\n";


while (1) {
  my $s = IO::Select->new($sock);

  print "Enter a message:  ";
  chomp(my $msg = <STDIN>);
  $msg .= "$CRLF$CRLF";

  #my $msg = "Client: date is " . scalar(localtime(time)) . "$CRLF$CRLF";
  #my $msg = "GET /$CRLF$CRLF";

  print "Writing message: (", length($msg), " bytes)\n";
  my $written = $sock->syswrite($msg, length($msg)) + 0;
  print "\tWrote $written bytes\n";

  # Check for write errors
  if ($SIGPIPE) {
    print "Remote end closed connection\n";
    last;
  }

  if ($s->can_read($timeout)) {
    my $buf;
    $sock->sysread($buf, 32768);
    if (length($buf)) {
      $buf =~ s/$CRLF$//g;
      print "Response: '$buf'.\n";
    } else {
      print "Server closed connection\n";
      last;
    }
  } else {
    print "No response from server\n";
  }

}
print "Closing connection\n";
$sock->close();

