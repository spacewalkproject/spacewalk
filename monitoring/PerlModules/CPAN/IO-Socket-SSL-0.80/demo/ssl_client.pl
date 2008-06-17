#
# a test client for testing IO::Socket::SSL-class's behavior
# (aspa@kronodoc.fi).
#
# $Id: ssl_client.pl,v 1.1.1.1 2002-02-23 00:31:09 dfaraldo Exp $.
#


use strict;
use IO::Socket::SSL;

my ($v_mode, $sock, $buf);

if($ARGV[0] eq "DEBUG") { $IO::Socket::SSL::DEBUG = 1; }


if(!($sock = IO::Socket::SSL->new( PeerAddr => 'localhost',
				   PeerPort => '9000',
				   Proto    => 'tcp',
				   SSL_use_cert => 1,
				   SSL_verify_mode => 0x01,
				 ))) {
  print STDERR "unable to create socket: '$!'.\n";
  exit(0);
} else {
  print STDERR "connect ($sock).\n" if ($IO::Socket::SSL::DEBUG);
}

# check server cert.
my ($peer_cert, $subject_name, $issuer_name, $cipher);
if( ref($sock) eq "IO::Socket::SSL") {
    if(($peer_cert = $sock->get_peer_certificate)) {
	$subject_name = $peer_cert->subject_name;
	$issuer_name = $peer_cert->issuer_name;
	$cipher = $sock->get_cipher();
    }
    print STDERR "cipher: $cipher.\n";
    print STDERR "server cert:\n". 
	"\t '$subject_name' \n\t '$issuer_name'.\n\n";
}

$buf = "";

$sock->sysread($buf, 32768);

print "read: '$buf'.\n";
