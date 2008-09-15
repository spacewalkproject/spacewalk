#!/usr/bin/perl

use IO::Socket;
use NOCpulse::Debug;
use Sys::Hostname;
use Fcntl;
use ObjectProxyPeer;
use Data::Dumper;

my $SLEEPTIME = 5;
my $port = 5490;


# Set up a debug object for this script ...
my $debug = new NOCpulse::Debug();
$debug->addstream(CONTEXT => 'literal',
                  LEVEL   => 3);

# ... and for all ObjectProxyMessages ...
ObjectProxyMessage->setDebugObject($debug);


my $hostname = hostname();
$debug->dprint(1, "Listening on $hostname:$port\n");

# Establish a listening socket
my $listener = new IO::Socket::INET(Listen    => 5,
                                    LocalAddr => $hostname,
                                    LocalPort => $port,
                                    Proto     => 'tcp',
				    Reuse     => 1)
   or die "Couldn't create listener: $!";


# Make the listener non-blocking -- we'll poll for connections
fcntl($listener, F_SETFL, O_NONBLOCK) or warn("fcntl: $!");


# Daemon loop
while (1) {
  $debug->dprint(1, "Accepting connections\n");

  my $client = $listener->accept();

  if (defined($client)) {
    $debug->dprint(1, "Accepted connection:\n");
    $debug->dprint(1, "\tClient: $client\n");

    my $peeraddr = $client->peeraddr();
    $debug->dprint(1, "\tPeer addr: $peeraddr\n");

    my $peerip   = join('.', unpack("C4", $peeraddr));
    $debug->dprint(1, "\tPeer IP: $peerip\n");

    $debug->dprint(1, "Accepted connection from $peerip\n");

    $debug->dprint(1, "Creating OPP object\n");
    my $opp = new ObjectProxyPeer(Connection => $client,
                                  Debug      => $debug);

    $debug->dprint(1, "Sleeping 3 seconds\n");
    sleep 3;

    $debug->dprint(1, "Reading message\n");
    my $msg = $opp->get_response();
    $debug->dprint(1, "Message:  ", &Dumper($msg), "\n");

    my $answer   = "You sent:  " . $msg->data();
    my $response = new ObjectProxyMessage(Opcode => 'ECHO',
                                          Data   => $answer,
				          Debug  => $debug);

    $opp->send($response);


    $debug->dprint(1, "Closing connection from $peerip\n");
    print $client "Thanks for your participation\n";
    shutdown($client, 0);

  } else {
    $debug->dprint(1, "\tNothing pending, sleeping $SLEEPTIME seconds...\n");
    sleep $SLEEPTIME;
  }
}


