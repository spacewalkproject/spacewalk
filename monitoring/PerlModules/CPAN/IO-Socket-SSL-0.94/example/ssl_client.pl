#
# a test client for testing IO::Socket::SSL-class's behavior
# (aspa@kronodoc.fi).
#
# $Id: ssl_client.pl,v 1.1.1.1 2003-08-22 19:58:45 cvs Exp $.
#


use strict;
use IO::Socket::SSL qw(debug4);

my ($v_mode, $sock, $buf);

if($ARGV[0] eq "DEBUG") { $IO::Socket::SSL::DEBUG = 1; }


if(!($sock = IO::Socket::SSL->new( PeerAddr => '192.168.167.166',
				   PeerPort => '9000',
				   Proto    => 'tcp',
#				   SSL_use_cert => 1,
#				   SSL_verify_mode => 0x01,
#				   SSL_passwd_cb => sub { return "opossum" },
				 ))) {
    warn "unable to create socket: ", &IO::Socket::SSL::errstr, "\n";
    exit(0);
} else {
    warn "connect ($sock).\n" if ($IO::Socket::SSL::DEBUG);
}

# check server cert.
my ($subject_name, $issuer_name, $cipher);
if( ref($sock) eq "IO::Socket::SSL") {
    $subject_name = $sock->peer_certificate("subject");
    $issuer_name = $sock->peer_certificate("issuer");
    $cipher = $sock->get_cipher();
}
warn "cipher: $cipher.\n", "server cert:\n", 
    "\t '$subject_name' \n\t '$issuer_name'.\n\n";

my ($buf) = $sock->getlines;

$sock->close();

print "read: '$buf'.\n";
