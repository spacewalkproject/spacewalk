#
# a test server for testing IO::Socket::SSL-class's behavior
# (aspa@kronodoc.fi).
#
# $Id: ssl_server.pl,v 1.1.1.1 2002-02-23 00:31:09 dfaraldo Exp $.
#

use strict;
use IO::Socket::SSL;


my ($sock, $s, $v_mode);

if($ARGV[0] eq "DEBUG") { $IO::Socket::SSL::DEBUG = 1; }


if(!($sock = IO::Socket::SSL->new( Listen => 5,
				   LocalAddr => 'localhost',
				   LocalPort => 9000,
				   Proto     => 'tcp',
				   Reuse     => 1,
				   SSL_verify_mode => 0x01,
				 )) ) {
  print STDERR "unable to create socket: $!.\n";
  exit(0);
}
print STDERR "socket created: $sock.\n";

while (1) {
  print STDERR "waiting for next connection.\n";

  while(($s = $sock->accept())) {
    my ($peer_cert, $subject_name, $issuer_name, $date, $str);
    
    if( ! $s ) {
      print STDERR "error: '$!'.\n";
      next;
    }

    print STDERR "connection opened ($s).\n";

    if( ref($sock) eq "IO::Socket::SSL") {
      if(($peer_cert = $s->get_peer_certificate())) {
	$subject_name = $peer_cert->subject_name;
	$issuer_name = $peer_cert->issuer_name;
      }
      
      print STDERR "\t subject: '$subject_name'.\n";
      print STDERR "\t issuer: '$issuer_name'.\n";
    }

    $date = `date`; chop $date;
    $str = "my date command says it's: '$date'";
    $s->write($str, length($str));

    $s->close();
    print STDERR "\t connection closed.\n";
    
  }
}

$sock->close();

print STDERR "loop exited.\n";
