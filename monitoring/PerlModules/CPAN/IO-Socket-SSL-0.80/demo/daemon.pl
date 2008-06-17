#
# test HTTP::Daemon with IO::Socket::SSL (aspa@kronodoc.fi).
#
# $Id: daemon.pl,v 1.1.1.1 2002-02-23 00:31:09 dfaraldo Exp $.
#

# NB: to use this demo script HTTP::Daemon and
# HTTP::Daemon::ClientConn have to be direct descendents of
# IO::Socket::SSL instead of IO::Socket::INET.


use HTTP::Daemon;
use HTTP::Status;
use IO::Socket::SSL;


my $debug = $ARGV[0] || "";
if($debug eq "DEBUG") { $IO::Socket::SSL::DEBUG = 1; }


$r = IO::Socket::SSL::context_init({
				    SSL_verify_mode => 0x00,
				    SSL_server => 1,
			   });

my $d = HTTP::Daemon->new(UseSSL => 1);
print "Please contact me at: <URL:", $d->url, ">\n";
while (my $c = $d->accept) {
  print STDERR "accepted.\n";
  while (my $r = $c->get_request) {
    if ($r->method eq 'GET' and $r->url->path eq "/xyzzy") {
      $c->send_file_response("/etc/hosts");
    } else {
      $c->send_error(RC_FORBIDDEN)
    }
  }
  $c->close;
  undef($c);
}

