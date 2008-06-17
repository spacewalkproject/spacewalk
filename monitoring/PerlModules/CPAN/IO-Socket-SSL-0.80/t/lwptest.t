#
# a test client for testing IO::Socket::SSL-class's behavior
# together with LWP (aspa@kronodoc.fi).
#
# $Id: lwptest.t,v 1.1.1.1 2002-02-23 00:31:09 dfaraldo Exp $.
#

use strict;
use IO::Socket::SSL;

BEGIN {
  my $r = eval 'require LWP::UserAgent';
  if (!$r) {
    print STDERR "LWP not installed. skipping test.\n";
    print "1..1\n";
    print "ok\n";
    exit(0);
  }
  require LWP::UserAgent;
}

my ($rq1, $rq2, $rq3, $rq4, $res, @res);

my $debug = $ARGV[0] || "";
if($debug eq "DEBUG") { $IO::Socket::SSL::DEBUG = 1; }

my $ua = new LWP::UserAgent;

# NB: we can't pass SSL options to IO::Socket::SSL through LWP but we
# can explicitly create and set the SSL context with specific
# options for IO::Socket::SSL.
# create and initialize the SSL context.
my $r = IO::Socket::SSL::context_init({
				       SSL_verify_mode => 0x01,
				      });

# CA cert filenames can be generated with:
# 'ssleay x509 -hash < ca-cert.pem'

$rq1 = new HTTP::Request('GET', 'https://www.thawte.com');
$rq2 = new HTTP::Request('GET', 'https://www.verisign.com');
# CA cert not present.
$rq3 = new HTTP::Request('GET', 'https://www.helsinki.fi');

print "1..3\n";


if($rq1) {
  $res = $ua->request($rq1);
  if($res->is_success) {
    if ($IO::Socket::SSL::DEBUG) {
      print STDERR "request 1: success.\n";
      print STDERR "" . $res->headers->as_string() . "\n";
    }
    print "ok\n";
  } else {
    print STDERR "request 1: failed: '" . $res->message . "'.\n";
    print "not ok\n";
  }
}

if($rq2) {
  $res = $ua->request($rq2);
  if($res->is_success) {
    if ($IO::Socket::SSL::DEBUG) {
      print STDERR "request 2: success.\n";
      print STDERR "" . $res->headers->as_string() . "\n";
    }
    print "ok\n";
  } else {
    #print STDERR "request 2: failed.\n";
    print "not ok\n";
  }
}


if($rq3) {
  $res = $ua->request($rq3);
  if(!$res->is_success) {
    #print STDERR "request 3: failed.\n";
    print "ok\n";
  } else {
    #print STDERR "request 3: success.\n";
    #print STDERR "" . $res->headers->as_string() . "\n";
    print "not ok\n";
  }
}

