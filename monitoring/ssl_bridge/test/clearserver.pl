#!/usr/bin/perl


$|=1;
use strict;
use IO::Socket::SSL;
use IO::Select;


my $ip       = $ARGV[0] || '192.168.0.25';
my $port     = $ARGV[1] || 9998;
my $timeout  = 10;
my $CRLF     = "\015\012";     # "\r\n" is not portable

$SIG{'PIPE'} = sub {print "Got a SIGPIPE!\n"};


print "Listening to ${ip}:$port\n";
my $sock = IO::Socket::INET->new(LocalAddr => "${ip}:$port",
				 Proto     => 'tcp',
				 Type      => SOCK_STREAM,
				 Listen    => 5,
				 Reuse     => 1);

die "Unable to connect: $!" unless ($sock);
print "\tSock: $sock\n";


while (1) {

  print "\n\n\nAccepting connections on $ip:$port\n";
  my $client = $sock->accept();
  my $peer   = join(":", $client->peerhost, $client->peerport);
  print "\tClient: $client ($peer)\n";

  my $s = IO::Select->new($client);

  my($timed_out, $remote_close, $req_close) = (0, 0, 0);
  while (not $timed_out and not $remote_close and not $req_close) {
    my($buf, $got);

    print "Waiting $timeout seconds for input...\n";
    while (1) {
      if ($s->can_read($timeout)) {
	$client->sysread($got, 32768);
	$remote_close = 1 and last unless (length($got));
	print "Got `$got' (" . length ($got) . " chars)\n";
	$buf .= $got;
	last if ($buf =~ /__END__/ || $buf =~ /$CRLF$CRLF/);
	$req_close = 1 and last if ($buf =~ /__EXIT__/);
      } else {
	$timed_out = 1;
	last;
      }
    }

    unless ($timed_out || $remote_close) {
      $buf =~ s/$CRLF$CRLF$//g;
      my $response = "You said: >>>$buf<<<\n";
      print "Writing response: (", length($response), " bytes)\n";
      print "\t$response";

      my $written = $client->syswrite($response, length($response));
      print "\tWrote $written bytes\n";
    }

  }
  if ($timed_out) {
    print "Timed out waiting for data\n";
  } elsif ($remote_close) {
    print "Remote end closed connection\n";
  } elsif ($req_close) {
    print "Remote end requested connection close\n";
  }


  print "Closing connection from $peer\n";
  $client->close();

}

$sock->close();
